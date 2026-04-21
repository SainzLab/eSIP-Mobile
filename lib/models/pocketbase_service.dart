import 'package:pocketbase/pocketbase.dart';

class PocketBaseService {
  // static const String baseUrl = 'http://192.168.8.10:8083'; 
  static const String baseUrl = 'https://pbcdn.sainzcloud.my.id'; 

  static final PocketBase pb = PocketBase(baseUrl);
}