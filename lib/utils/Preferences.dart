import 'package:shared_preferences/shared_preferences.dart';

Future<void> setCurrency(String currency) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('currency', currency);
}

Future<String> getCurrency() async {
  final prefs = await SharedPreferences.getInstance();
  final currency = prefs.getString('currency');
  if (currency == null) {
    return "£";
  }
  return currency;
}
