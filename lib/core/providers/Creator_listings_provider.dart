import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/Creator_listing.dart';
import '../services/firebase_service.dart';
import '../services/local_store_service.dart';
import 'session_provider.dart';

class CreatorListingsNotifier extends StateNotifier<List<CreatorListing>> {
  final LocalStoreService _store;
  final FirebaseService _firebase;

  CreatorListingsNotifier(this._store, this._firebase) : super([]) {
    _init();
  }

  Future<void> _init() async {
    // Load from local storage first
    state = await _store.getListings();

    // Then listen to Firebase updates
    _firebase.streamListings().listen((firebaseListings) {
      if (firebaseListings.isNotEmpty || state.isNotEmpty) {
        state = firebaseListings;
        _store.saveListings(state);
      }
    });
  }

  Future<void> reload() async {
    // Reload is handled automatically by the stream
  }

  Future<CreatorListing> upsert(CreatorListing listing) async {
    final existingIdx = state.indexWhere((l) => l.id == listing.id);
    final next = [...state];
    if (existingIdx >= 0) {
      next[existingIdx] = listing;
    } else {
      next.add(listing);
    }
    state = next;

    // Save to both Firestore and local storage
    await _firebase.saveListing(listing);
    await _store.saveListings(state);
    return listing;
  }

  Future<void> deleteById(String id) async {
    state = state.where((l) => l.id != id).toList();

    // Delete from both Firestore and local storage
    await _firebase.deleteListing(id);
    await _store.saveListings(state);
  }

  Future<void> toggleActive(String id) async {
    final idx = state.indexWhere((l) => l.id == id);
    if (idx < 0) return;
    final updated = state[idx].copyWith(isActive: !state[idx].isActive);
    final next = [...state]..[idx] = updated;
    state = next;

    // Save to both Firestore and local storage
    await _firebase.saveListing(updated);
    await _store.saveListings(state);
  }
}

final CreatorListingsProvider =
    StateNotifierProvider<CreatorListingsNotifier, List<CreatorListing>>((ref) {
  final store = ref.watch(localStoreProvider);
  final firebase = ref.watch(firebaseServiceProvider);
  return CreatorListingsNotifier(store, firebase);
});

final activeCreatorListingsProvider = Provider<List<CreatorListing>>((ref) {
  final listings = ref.watch(CreatorListingsProvider);
  return listings.where((l) => l.isActive).toList();
});

final myCreatorListingsProvider = Provider<List<CreatorListing>>((ref) {
  final listings = ref.watch(CreatorListingsProvider);
  final user = ref.watch(sessionProvider).user;
  if (user == null) return [];
  return listings.where((l) => l.ownerUserId == user.id).toList();
});
