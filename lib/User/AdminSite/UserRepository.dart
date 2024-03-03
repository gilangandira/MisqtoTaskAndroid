import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
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

  Future deleteData(String userId) async {
    final headers = await getHeaders();
    Dio dio = Dio();

    try {
      Response response = await dio.delete(
        'https://misqot.repit.tech/api/users/delete/$userId',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (error) {
      throw Exception('Gagal menghapus data: $error');
    }
  }

  Future getDataProfiles() async {
    final headers = await getHeaders();
    Dio dio = Dio();

    try {
      Response response = await dio.get('https://misqot.repit.tech/api/users',
          options:
              Options(headers: headers, receiveTimeout: const Duration(seconds: 1)));
      return response.data;
    } catch (error) {
      throw Exception('Gagal mengambil data: $error');
    }
  }

}
