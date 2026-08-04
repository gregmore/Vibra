// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final env = File('.env').readAsStringSync();
  final regexUrl = RegExp(r'SUPABASE_URL=(.*)');
  final regexKey = RegExp(r'SUPABASE_ANON_KEY=(.*)');
  
  final url = regexUrl.firstMatch(env)!.group(1)!.trim();
  final key = regexKey.firstMatch(env)!.group(1)!.trim();
  
  final client = SupabaseClient(url, key);
  try {
    final response = await client.auth.signUp(email: 'bot_test_2@vibra.com', password: 'Password123!');
    print('User id: ${response.user?.id}');
  } catch(e) {
    print('Error: $e');
  }
}
