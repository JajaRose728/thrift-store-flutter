// lib/services/supabase_service.dart

import 'dart:typed_data'; // MODIFICATION: Import for Uint8List
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item.dart';

class SupabaseService extends ChangeNotifier {
  @override
  void notifyListeners() {
    // A check to prevent calling notifyListeners() after dispose()
    if (hasListeners) super.notifyListeners();
  }

  final supabase = Supabase.instance.client;
  List<Item> items = [];
  String? error;

  // ─── AUTH ───────────────────────────────────────────────────
  // ... (Your auth methods remain unchanged)
  Future<bool> signUp(String email, String password, String displayName) async {
    error = null;
    try {
      await supabase.auth.signUp(email: email, password: password);
      await supabase.auth.updateUser(
        UserAttributes(data: {'full_name': displayName}),
      );
      await supabase.auth.refreshSession();
      return true;
    } on AuthException catch (e) {
      error = e.message;
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    error = null;
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      return true;
    } on AuthException catch (e) {
      error = e.message;
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }


  // ─── FETCH ALL ITEMS ─────────────────────────────────────────
  Future<void> fetchItems() async {
    try {
      final data = await supabase
          .from('items')
          .select()
          .order('created_at', ascending: false);
      items = (data as List)
          .map((e) => Item.fromMap(e as Map<String, dynamic>))
          .toList();
      error = null;
    } on PostgrestException catch (e) {
      error = e.message;
    } catch (e) {
      error = e.toString();
    }
    notifyListeners();
  }

// ─── ADD A NEW ITEM (MODIFIED) ────────────────────────────────
  Future<void> addItem({
    required String title,
    required String desc,
    required double price,
    required String contact,
    required String uploaderName,
    // MODIFICATION: Accept bytes and a name instead of a File object
    required Uint8List imageBytes,
    required String imageName,
  }) async {
    error = null;
    try {
      // 1) Upload image bytes to storage. This works for both mobile and web.
      final bucket = supabase.storage.from('thrift-images');
      // Use the imageName passed from the form
      await bucket.uploadBinary(
        imageName,
        imageBytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      // 2) Get the public URL of the uploaded image
      final url = bucket.getPublicUrl(imageName);

      // 3) Insert the new item record into the database
      final user = supabase.auth.currentUser;
      final email = user?.email ?? '';
      await supabase.from('items').insert({
        'title': title,
        'description': desc,
        'price': price,
        'contact_info': contact,
        'uploaded_by': uploaderName, // Matches your existing table structure
        'uploader_email': email,
        'image_url': url,
        'created_at': DateTime.now().toIso8601String(),
      });

      // 4) Refresh the list to show the new item
      await fetchItems();
    } on StorageException catch (e) {
      error = 'Storage Error: ${e.message}';
      notifyListeners();
    } on PostgrestException catch (e) {
      error = 'Database Error: ${e.message}';
      notifyListeners();
    } catch (e) {
      error = 'An unexpected error occurred: ${e.toString()}';
      notifyListeners();
    }
  }

  // ─── DELETE AN ITEM ──────────────────────────────────────────
  Future<void> deleteItem(int id) async {
    try {
      await supabase.from('items').delete().eq('id', id);
      await fetchItems();
    } on PostgrestException catch (e) {
      error = e.message;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // ─── FETCH ONE ITEM DETAIL ───────────────────────────────────
  Future<Item?> fetchItemDetail(int id) async {
    try {
      final data =
      await supabase.from('items').select().eq('id', id).maybeSingle();
      if (data == null) throw PostgrestException(message: 'Item not found');
      return Item.fromMap(data as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      error = e.message;
      return null;
    } catch (e) {
      error = e.toString();
      return null;
    }
  }
}
