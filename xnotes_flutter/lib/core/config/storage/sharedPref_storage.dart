import 'package:shared_preferences/shared_preferences.dart';
import 'package:xnotes_flutter/config/storage/storage.dart';

class SharedprefStorage implements Storage {
  static const _id = 'id';
  @override
  Future clearData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt(_id, 0);
  }

  @override
  Future<int> getId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getInt(_id) ?? 0;
  }

  @override
  Future setId(int id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt(_id, id);
  }
}