
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
class AssetRepository {
  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  Future deleteData(String assetsId) async {
    final headers = await getHeaders();
    final String url = 'https://misqot.repit.tech/api/assets/delete/$assetsId';
    var response = await http.delete(Uri.parse(url), headers: headers);

    return json.decode(response.body);
  }
  Future deleteVendor(String vendorId) async {
    final headers = await getHeaders();
    final String url = 'https://misqot.repit.tech/api/vendor/delete/$vendorId';
    var response = await http.delete(Uri.parse(url), headers: headers);
    return json.decode(response.body);
  }
}
