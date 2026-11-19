import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String bio;
  final String spiritualMotto;
  final bool isProfileComplete;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.bio,
    required this.spiritualMotto,
    required this.isProfileComplete,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'spiritualMotto': spiritualMotto,
      'isProfileComplete': isProfileComplete,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      bio: map['bio'] ?? '',
      spiritualMotto: map['spiritualMotto'] ?? 'Living rightly with God and fellow people',
      isProfileComplete: map['isProfileComplete'] ?? false,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with Email & Password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    // Send email verification
    await cred.user?.sendEmailVerification();
    return cred;
  }

  // Sign in with Email & Password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Resend verification email
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // Check if email is verified
  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Save or update user profile
  Future<void> setupUserProfile({
    required String displayName,
    required String bio,
    String? photoUrl,
    String spiritualMotto = 'Living rightly with God and fellow people',
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await user.updateDisplayName(displayName);

    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName,
      photoUrl: photoUrl,
      bio: bio,
      spiritualMotto: spiritualMotto,
      isProfileComplete: true,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(userModel.toMap(), SetOptions(merge: true));
  }

  // Fetch current user model
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
