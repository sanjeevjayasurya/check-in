import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';
import 'package:sunsafe_checkin/core/utils/invite_code_generator.dart';
import 'package:sunsafe_checkin/models/app_user.dart';
import 'package:sunsafe_checkin/models/family.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => 'AuthException: $message';
}

/// Handles Firebase authentication and family linking via invite codes.
class AuthRepository {
  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    InviteCodeGenerator? inviteCodeGenerator,
  })  : _auth = auth,
        _firestore = firestore,
        _inviteCodeGenerator = inviteCodeGenerator ?? InviteCodeGenerator();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final InviteCodeGenerator _inviteCodeGenerator;

  User? get currentFirebaseUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<AppUser?> getCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  /// Caregiver sign-up: creates auth account, family, and 6-digit invite code.
  Future<({AppUser user, Family family})> signUpCaregiver({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    final inviteCode = _inviteCodeGenerator.generate();
    final familyRef = _firestore.collection(AppConstants.familiesCollection).doc();

    final family = Family(
      id: familyRef.id,
      inviteCode: inviteCode,
      caregiverIds: [uid],
    );

    final appUser = AppUser(
      uid: uid,
      role: UserRole.caregiver,
      familyId: familyRef.id,
      email: email,
      displayName: displayName,
    );

    await familyRef.set(family.toFirestore());
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .set(appUser.toFirestore());

    return (user: appUser, family: family);
  }

  Future<AppUser> signInCaregiver({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final appUser = await _loadAppUser(credential.user!.uid);
    if (appUser.role != UserRole.caregiver) {
      throw AuthException('This account is not registered as a caregiver.');
    }
    return appUser;
  }

  /// Senior joins family via anonymous auth + 6-digit invite code.
  Future<AppUser> joinFamilyAsSenior({
    required String inviteCode,
    String? displayName,
  }) async {
    final normalizedCode = inviteCode.trim();
    if (normalizedCode.length != AppConstants.inviteCodeLength) {
      throw AuthException('Invite code must be ${AppConstants.inviteCodeLength} digits.');
    }

    final familyQuery = await _firestore
        .collection(AppConstants.familiesCollection)
        .where('inviteCode', isEqualTo: normalizedCode)
        .limit(1)
        .get();

    if (familyQuery.docs.isEmpty) {
      throw AuthException('Invalid invite code. Ask your caregiver for a new one.');
    }

    final familyDoc = familyQuery.docs.first;
    final family = Family.fromFirestore(familyDoc);

    if (family.seniorId != null) {
      throw AuthException('This family already has a senior linked.');
    }

    User? user = _auth.currentUser;
    user ??= (await _auth.signInAnonymously()).user;
    if (user == null) {
      throw AuthException('Unable to create senior session.');
    }
    final uid = user.uid;

    final appUser = AppUser(
      uid: uid,
      role: UserRole.senior,
      familyId: family.id,
      displayName: displayName ?? 'Senior',
    );

    await _firestore.runTransaction((transaction) async {
      transaction.update(familyDoc.reference, {'seniorId': uid});
      transaction.set(
        _firestore.collection(AppConstants.usersCollection).doc(uid),
        appUser.toFirestore(),
      );
    });

    return appUser;
  }

  Future<AppUser> signInWithApple() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      throw AuthException('Apple Sign-In is only available on Apple devices.');
    }

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final credential = await _auth.signInWithCredential(oauthCredential);
    final uid = credential.user!.uid;

    final existing = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (existing.exists) {
      return AppUser.fromFirestore(existing);
    }

    final inviteCode = _inviteCodeGenerator.generate();
    final familyRef = _firestore.collection(AppConstants.familiesCollection).doc();
    final displayName = [
      appleCredential.givenName,
      appleCredential.familyName,
    ].where((part) => part != null && part.isNotEmpty).join(' ');

    final family = Family(
      id: familyRef.id,
      inviteCode: inviteCode,
      caregiverIds: [uid],
    );

    final appUser = AppUser(
      uid: uid,
      role: UserRole.caregiver,
      familyId: familyRef.id,
      email: appleCredential.email ?? credential.user?.email,
      displayName: displayName.isEmpty ? 'Caregiver' : displayName,
    );

    await familyRef.set(family.toFirestore());
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .set(appUser.toFirestore());

    return appUser;
  }

  Future<Family?> getFamily(String familyId) async {
    final doc = await _firestore
        .collection(AppConstants.familiesCollection)
        .doc(familyId)
        .get();
    if (!doc.exists) return null;
    return Family.fromFirestore(doc);
  }

  Stream<Family?> watchFamily(String familyId) {
    return _firestore
        .collection(AppConstants.familiesCollection)
        .doc(familyId)
        .snapshots()
        .map((doc) => doc.exists ? Family.fromFirestore(doc) : null);
  }

  Future<void> signOut() => _auth.signOut();

  Future<AppUser> _loadAppUser(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) {
      throw AuthException('User profile not found.');
    }
    return AppUser.fromFirestore(doc);
  }
}
