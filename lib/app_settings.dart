import 'package:encrypt/encrypt.dart';

class AppSettings {
  // TODO: Add key and iv to enable download translations
  static String key ="11223344";
  static String iv = "231 207 152 182 127 189 249 131";

  AppSettings(){
    print(iv+' and '+key);
  }
  
  static Map<String, dynamic> secrets;
}