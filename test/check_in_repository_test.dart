import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';
import 'package:sunsafe_checkin/features/senior_home/data/check_in_repository.dart';

void main() {
  late Directory tempDir;
  late FakeFirebaseFirestore firestore;
  late Box<Map<dynamic, dynamic>> checkInBox;
  late CheckInRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sunsafe_hive_test');
    Hive.init(tempDir.path);
    checkInBox = await Hive.openBox<Map<dynamic, dynamic>>(
      AppConstants.hiveBoxCheckIns,
    );
    firestore = FakeFirebaseFirestore();
    repository = CheckInRepository(
      firestore: firestore,
      checkInBox: checkInBox,
    );
  });

  tearDown(() async {
    await checkInBox.clear();
    await checkInBox.close();
    await Hive.deleteBoxFromDisk(AppConstants.hiveBoxCheckIns);
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('submitCheckIn writes to Firestore when online', () async {
    final record = await repository.submitCheckIn(
      familyId: 'family1',
      seniorId: 'senior1',
    );

    expect(record.synced, isTrue);

    final docs = await firestore
        .collection(AppConstants.familiesCollection)
        .doc('family1')
        .collection(AppConstants.checkInsSubcollection)
        .get();

    expect(docs.docs, isNotEmpty);
  });

  test('syncPendingCheckIns uploads queued records from Hive', () async {
    final today = DateTime.now();
    final date =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    await checkInBox.put('family1_$date', {
      'familyId': 'family1',
      'date': date,
      'timestamp': DateTime.now().toIso8601String(),
      'seniorId': 'senior1',
    });

    await repository.syncPendingCheckIns('family1');

    final docs = await firestore
        .collection(AppConstants.familiesCollection)
        .doc('family1')
        .collection(AppConstants.checkInsSubcollection)
        .get();

    expect(docs.docs, isNotEmpty);
    expect(checkInBox.length, 0);
  });

  test('hasCheckedInToday returns true after successful check-in', () async {
    await repository.submitCheckIn(
      familyId: 'family1',
      seniorId: 'senior1',
    );

    expect(await repository.hasCheckedInToday('family1'), isTrue);
  });
}
