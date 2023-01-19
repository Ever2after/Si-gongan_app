import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static Future<void> signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('id', FirebaseAuth.instance.currentUser!.uid);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          print("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          print("Unknown error.");
      }
    }
  }

  static Future<String> getUserId() async {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  static Future<bool> isFirst() async {
    /*
    String fid = await FirebaseAuth.instance.currentUser!.uid;
    final list = await UserHelper.get_by_fid(fid);
    return list.length > 0;
    */
    final prefs = await SharedPreferences.getInstance();
    final nickname = prefs.getString('nickname') ?? null;
    return nickname == null;
  }
}
