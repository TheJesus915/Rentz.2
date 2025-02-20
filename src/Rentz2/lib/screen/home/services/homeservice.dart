import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/screen/login/services/service.dart'; // Asegúrate de importar tu AuthService

class HomeService {
  final String apiUrl = "https://darkred-donkey-427653.hostingersite.com/api/v1/cliente/productos";

  /// Obtiene la lista de productos desde la API
  Future<List<dynamic>> getProductos(BuildContext context) async {
    try {
      // Obtén el token desde AuthService
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.token;

      if (token == null) {
        throw Exception("No se encontró el token de autenticación");
      }

      // Realiza la solicitud HTTP con el token en las cabeceras
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token', // Incluye el token aquí
        },
      );

      // Maneja la respuesta
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'] ?? [];
        } else {
          throw Exception("Error al obtener productos: ${data['message']}");
        }
      } else if (response.statusCode == 401) {
        // Token no válido o expirado
        authService.clearToken(); // Elimina el token
        Navigator.of(context).pushReplacementNamed('/login'); // Redirige al login
        throw Exception("Token no válido o expirado");
      } else {
        throw Exception("Error en la solicitud HTTP: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error de conexión: $e");
    }
  }
}