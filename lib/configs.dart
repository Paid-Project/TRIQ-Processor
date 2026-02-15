import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Configurations {
  // String baseUrl = kReleaseMode ? dotenv.env["BASE_URL"] ?? "" :  "http://192.168.1.4:3001/" ;
  // String url = "https://live.triqinnovations.com";
  String url = "https://api.triqinnovations.com";
  String get baseUrl => "$url/api/";
}
