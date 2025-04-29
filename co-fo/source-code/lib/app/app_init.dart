import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uniapp/app/imports.dart';
import 'package:uniapp/data/imports.dart';

class AppInitialization {
  AppInitialization._privateConstructor();

  static final AppInitialization _instance =
      AppInitialization._privateConstructor();

  static AppInitialization get I => _instance;

  Future<void> initApp() async {
    AppRouter.init();
    await _initSB();
    await _initDB();
  }

  Future<void> _initSB() async {
    await Supabase.initialize(
      url: 'https://rmlpelbnhqyrfhgpotqf.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJtbHBlbGJuaHF5cmZoZ3BvdHFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ0MzQ2MzMsImV4cCI6MjA2MDAxMDYzM30.oqHaJzbRoX3RysqaNY2xoTFnEPGEwO2u5G0cTi3lAXM',
    );
  }

  Future<void> _initDB() async {
    DatabaseHelper().database;
  }
}
