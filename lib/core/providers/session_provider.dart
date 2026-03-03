import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/app_user.dart';
import '../services/firebase_service.dart';
import '../services/local_store_service.dart';

class SessionState {
  final AppUser? user;
  final bool isLoading;

  const SessionState({
    required this.user,
    required this.isLoading,
  });

  const SessionState.loading() : this(user: null, isLoading: true);
  const SessionState.signedOut() : this(user: null, isLoading: false);
}

class SessionNotifier extends StateNotifier<SessionState> {
  final LocalStoreService _store;
  final FirebaseService _firebase;

  SessionNotifier(this._store, this._firebase)
      : super(const SessionState.loading()) {
    _init();
  }

  Future<void> _init() async {
    final user = await _store.getSessionUser();
    state = SessionState(user: user, isLoading: false);
  }

  Future<AppUser> signUp({
    required String name,
    required String email,
    required String phone, // add this
    required String password, // ✅ ADD THIS
    required String role,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    // 1️⃣ Create Firebase Auth user
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final uid = cred.user!.uid;

    // 2️⃣ Create AppUser using UID
    final user = AppUser(
      id: uid,
      name: name.trim().isEmpty ? 'User' : name.trim(),
      email: normalizedEmail,
      role: role,
    );

    // 3️⃣ Save to Firestore
    await _firebase.saveUser(user);

    // 4️⃣ Save session locally (optional)
    await _store.setSessionUserId(uid);

    state = SessionState(user: user, isLoading: false);
    return user;
  }

  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    // 1️⃣ Firebase Auth sign in
    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final uid = cred.user!.uid;

    // 2️⃣ Load user from Firestore
    final user = await _firebase.getUser(uid);
    if (user == null) return null;

    // 3️⃣ Save session
    await _store.setSessionUserId(uid);

    state = SessionState(user: user, isLoading: false);
    return user;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();

    // 2️⃣ Clear local session (optional but fine)
    await _store.setSessionUserId(null);

    // 3️⃣ Update app state
    state = const SessionState.signedOut();
  }
}

final localStoreProvider = Provider<LocalStoreService>((ref) {
  return LocalStoreService();
});

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  final store = ref.watch(localStoreProvider);
  final firebase = ref.watch(firebaseServiceProvider);
  return SessionNotifier(store, firebase);
});
