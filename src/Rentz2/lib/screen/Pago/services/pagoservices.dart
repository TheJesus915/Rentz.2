import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://darkred-donkey-427653.hostingersite.com/api/v1';

  static Future<Map<String, dynamic>> generarPreferencia(double monto) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/rentas/4/generar-preferencia'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "monto": monto
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}