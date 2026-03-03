import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/booking.dart';
import '../services/firebase_service.dart';
import '../services/local_store_service.dart';
import 'session_provider.dart';

class BookingsNotifier extends StateNotifier<List<Booking>> {
  final LocalStoreService _store = LocalStoreService();
  final FirebaseService _firebase;
  final String? _userId;

  BookingsNotifier(this._firebase, this._userId) : super([]) {
    _loadBookings();
    _listenToFirebase();
  }

  Future<void> _loadBookings() async {
    final list = await _store.getBookings();
    state = list;
  }

  void _listenToFirebase() {
    if (_userId == null) return;
    _firebase.streamBookings(_userId!).listen((firebaseList) {
      if (firebaseList.isNotEmpty) {
        state = firebaseList;
        _store.saveBookings(state);
      }
    });
  }

  Future<bool> checkAvailability(String listingId, DateTime date, String slot) {
    return _firebase.checkSlotAvailability(listingId, date, slot);
  }

  Future<void> addBooking(Booking booking) async {
    try {
      await _firebase.createBooking(booking);
      // Only update local state if firebase succeeds
      state = [...state, booking];
      await _store.saveBookings(state);
    } catch (e) {
      if (e is FirebaseException) {
        if (e.code == 'permission-denied' || e.code == 'already-exists') {
          throw Exception("This time slot is already booked.");
        }
        // If it's another Firebase error, provide the clean message
        throw Exception(e.message ?? e.toString());
      }
      // Propagate other errors to UI
      rethrow;
    }
  }

  Future<void> updateBookingMediaLink(String bookingId, String link) async {
    state = [
      for (final b in state)
        if (b.id == bookingId)
          Booking(
            id: b.id,
            clientId: b.clientId,
            creatorId: b.creatorId,
            event: b.event,
            date: b.date,
            timeSlot: b.timeSlot,
            totalAmount: b.totalAmount,
            advancePaid: b.advancePaid,
            remainingAmount: b.remainingAmount,
            clientType: b.clientType,
            duration: b.duration,
            mediaDriveLink: link,
            listingId: '',
          )
        else
          b
    ];
    await _store.saveBookings(state);
    await _firebase.updateMediaLink(bookingId, link);
  }
}

final bookingsProvider =
    StateNotifierProvider<BookingsNotifier, List<Booking>>((ref) {
  final firebase = ref.watch(firebaseServiceProvider);
  final session = ref.watch(sessionProvider);
  return BookingsNotifier(firebase, session.user?.id);
});
