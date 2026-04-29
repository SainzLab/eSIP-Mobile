import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PocketBaseService {
  // static const String baseUrl = 'http://192.168.8.10:8083'; 
  static const String baseUrl = 'https://pbcdn.sainzcloud.my.id'; 

  static late final PocketBase pb;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    final store = AsyncAuthStore(
      save: (String data) async => prefs.setString('pb_auth', data),
      initial: prefs.getString('pb_auth'),
    );
    
    pb = PocketBase(baseUrl, authStore: store);
  }
}