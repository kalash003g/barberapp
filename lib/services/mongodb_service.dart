import 'package:mongo_dart/mongo_dart.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class MongoDBService {
  // MongoDB Atlas connection string
  static const String MONGODB_URL = "mongodb+srv://gaikwadkalash520:kalash@cluster0.hvgn1l2.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";
  static const String DB_NAME = "barber_app";
  static const String COLLECTION_NAME = "users";
  static const String BOOKINGS_COLLECTION = "bookings";
  
  static Db? _db;
  static DbCollection? _collection;
  static DbCollection? _bookingsCollection;

  static Future<void> connect() async {
    if (_db == null) {
      try {
        print("Attempting to connect to MongoDB...");
        _db = await Db.create(MONGODB_URL);
        await _db!.open();
        print("Database opened successfully");
        
        // Create database and collections if they don't exist
        _collection = _db!.collection(COLLECTION_NAME);
        _bookingsCollection = _db!.collection(BOOKINGS_COLLECTION);
        print("Collections accessed successfully");
        
        print("MongoDB Connected Successfully");
      } catch (e) {
        print("Error connecting to MongoDB: $e");
        rethrow;
      }
    }
  }

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      await connect();
      final user = await _collection!.findOne(where.eq('email', email));
      print("Login attempt for email: $email");
      
      if (user != null && user['password'] == password) {
        print("Login successful");
        return user;
      }
      print("Login failed: Invalid credentials");
      return null;
    } catch (e) {
      print("Error during login: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      await connect();
      return await _collection!.findOne(where.eq('email', email));
    } catch (e) {
      print("Error getting user by email: $e");
      rethrow;
    }
  }

  static Future<bool> signup(String email, String password, String contactNumber, String username) async {
    try {
      await connect();
      
      // Check if user already exists
      final existingUser = await _collection!.findOne(where.eq('email', email));
      if (existingUser != null) {
        print("Signup failed: Email already exists");
        return false;
      }

      // Create new user
      await _collection!.insert({
        'email': email,
        'password': password,
        'contactNumber': contactNumber,
        'username': username,
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      print("Signup successful for email: $email");
      return true;
    } catch (e) {
      print("Error during signup: $e");
      rethrow;
    }
  }

  // Add a new booking
  static Future<bool> addBooking(String userEmail, String service, DateTime bookingDate, TimeOfDay bookingTime) async {
    try {
      await connect();
      
      // Convert TimeOfDay to DateTime for storage
      final bookingDateTime = DateTime(
        bookingDate.year,
        bookingDate.month,
        bookingDate.day,
        bookingTime.hour,
        bookingTime.minute,
      );

      await _bookingsCollection!.insert({
        'userEmail': userEmail,
        'service': service,
        'bookingDateTime': bookingDateTime.toIso8601String(),
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      print("Booking added successfully for user: $userEmail");
      return true;
    } catch (e) {
      print("Error adding booking: $e");
      return false;
    }
  }

  // Get bookings for a specific user
  static Future<List<Map<String, dynamic>>> getUserBookings(String userEmail) async {
    try {
      await connect();
      final bookings = await _bookingsCollection!
          .find(where.eq('userEmail', userEmail))
          .toList();
      return bookings;
    } catch (e) {
      print("Error getting user bookings: $e");
      return [];
    }
  }

  static Future<void> close() async {
    await _db?.close();
    _db = null;
    _collection = null;
    _bookingsCollection = null;
    print("MongoDB connection closed");
  }
}
