import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/Creator_listing.dart';
import '../models/app_user.dart';
import '../models/booking.dart';
import '../models/transaction_model.dart';

// Provider for FirebaseService
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _bookingsCollection = 'bookings';
  static const String _transactionsCollection = 'transactions';

  static const String _usersCollection = 'users';

  /// Saves or updates a user in Firestore
  Future<void> saveUser(AppUser user) async {
    await _db.collection(_usersCollection).doc(user.id).set(user.toJson());
  }

  /// Retrieves a user from Firestore
  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection(_usersCollection).doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return AppUser.fromJson(doc.data()!);
    }
    return null;
  }

  // Creator Listings
  static const String _listingsCollection = 'creator_listings';
  static const String _availabilityCollection = 'listing_availability';

  /// Saves or updates a creator listing in Firestore
  Future<void> saveListing(CreatorListing listing) async {
    await _db
        .collection(_listingsCollection)
        .doc(listing.id)
        .set(listing.toJson());
  }

  /// Deletes a creator listing from Firestore
  Future<void> deleteListing(String id) async {
    await _db.collection(_listingsCollection).doc(id).delete();
  }

  /// Streams all active creator listings
  Stream<List<CreatorListing>> streamListings() {
    return _db.collection(_listingsCollection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CreatorListing.fromJson(doc.data()))
          .toList();
    });
  }

  /// Streams listings for a specific owner
  Stream<List<CreatorListing>> streamMyListings(String ownerId) {
    return _db
        .collection(_listingsCollection)
        .where('ownerUserId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CreatorListing.fromJson(doc.data()))
          .toList();
    });
  }

  /// Syncs a single booking to Firestore
  Future<void> syncBooking(Booking booking) async {
    await _db
        .collection(_bookingsCollection)
        .doc(booking.id)
        .set(booking.toJson());
  }

  /// Updates only the media link for a booking in Firestore
  Future<void> updateMediaLink(String bookingId, String link) async {
    await _db.collection(_bookingsCollection).doc(bookingId).update({
      'mediaDriveLink': link,
    });
  }

  /// Streams all bookings (useful for users to get updates)
  Stream<List<Booking>> streamBookings(String userId) {
    return _db
        .collection(_bookingsCollection)
        .where('clientId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Booking.fromJson(doc.data())).toList();
    });
  }

  /// Gets a stream for a specific booking
  Stream<Booking?> streamBooking(String bookingId) {
    return _db
        .collection(_bookingsCollection)
        .doc(bookingId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return Booking.fromJson(doc.data()!);
      }
      return null;
    });
  }

  // Transactions
  Future<void> saveTransaction(TransactionModel transaction) async {
    await _db
        .collection(_transactionsCollection)
        .doc(transaction.id)
        .set(transaction.toJson());
  }

  /// Creates a booking using a transaction to prevent double-booking
  Future<void> createBooking(Booking booking) async {
    final bookingRef = _db.collection(_bookingsCollection).doc(booking.id);
    final availabilityRef = _db.collection(_availabilityCollection).doc(booking.id);

    await _db.runTransaction((transaction) async {
      // Check if slot is already taken (safety check in transaction)
      final availabilityDoc = await transaction.get(availabilityRef);
      if (availabilityDoc.exists) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'already-exists',
          message: 'This slot is already booked.',
        );
      }

      transaction.set(bookingRef, booking.toFirestore());
      
      // Also write to public availability collection
      transaction.set(availabilityRef, {
        'listingId': booking.listingId,
        'date': Timestamp.fromDate(booking.date),
        'timeSlot': booking.timeSlot,
        'ownerId': booking.creatorId, // Required for delete rule
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Checks if a slot is already booked using the public availability collection
  Future<bool> checkSlotAvailability(
      String listingId, DateTime date, String timeSlot) async {
    final cleanTimeSlot = timeSlot.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    final dateStr =
        "${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}";

    final bookingId = 'BID-$listingId-$dateStr-$cleanTimeSlot';

    // Now checking the PUBLIC availability collection to avoid Permission Denied
    final doc = await _db.collection(_availabilityCollection).doc(bookingId).get();

    return !doc.exists;
  }
}
