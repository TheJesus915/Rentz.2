import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistroService {
  static Future<void> registrarUsuario(
      String nombre, String apellidos, String correo, String telefono, String password) async {
    final url = Uri.parse('https://darkred-donkey-427653.hostingersite.com/api/v1/cliente/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "nombre": nombre,
        "apellidos": apellidos,
        "correo": correo,
        "numero_telefono": telefono,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      print("Registro exitoso: ${response.body}");
    } else {
      print("Error en el registro: ${response.body}");
    }
  }
}