import 'dart:convert';

import 'package:http/http.dart' as myAPI;
import 'package:shared_preferences/shared_preferences.dart';

class CustomerRepository {
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

  Future getDataCustomers() async {
    var resnponse =
        await myAPI.get(Uri.parse('https://misqot.repit.tech/api/customers'));
    return json.decode(resnponse.body);
  }

  Future deleteData(String customerId) async {
    final headers = await getHeaders();
    final String url = 'https://misqot.repit.tech/api/customers/delete/$customerId';
    var response = await myAPI.delete(Uri.parse(url), headers: headers);

    return json.decode(response.body);
  }
}
