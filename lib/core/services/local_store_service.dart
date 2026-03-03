import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/Creator_listing.dart';
import '../models/app_user.dart';
import '../models/booking.dart';

class LocalStoreService {
  static const _usersKey = 'local_users_v1';
  static const _sessionUserIdKey = 'local_session_user_id_v1';
  static const _listingsKey = 'local_Creator_listings_v1';
  static const _bookingsKey = 'local_bookings_v1';

  Future<List<AppUser>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = json.decode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((m) => AppUser.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<void> saveUsers(List<AppUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, raw);
  }

  Future<AppUser?> getSessionUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_sessionUserIdKey);
    if (userId == null || userId.isEmpty) return null;
    final users = await getUsers();
    try {
      return users.firstWhere((u) => u.id == userId);
    } catch (_) {
      return null;
    }
  }

  Future<void> setSessionUserId(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId == null) {
      await prefs.remove(_sessionUserIdKey);
    } else {
      await prefs.setString(_sessionUserIdKey, userId);
    }
  }

  Future<List<CreatorListing>> getListings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_listingsKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = json.decode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((m) => CreatorListing.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<void> saveListings(List<CreatorListing> listings) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(listings.map((l) => l.toJson()).toList());
    await prefs.setString(_listingsKey, raw);
  }

  Future<List<Booking>> getBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_bookingsKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = json.decode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((m) => Booking.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<void> saveBookings(List<Booking> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(bookings.map((b) => b.toJson()).toList());
    await prefs.setString(_bookingsKey, raw);
  }
}
