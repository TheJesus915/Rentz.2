import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '/screen/login/services/service.dart'; // Importa el servicio de autenticación

class CarritoService extends ChangeNotifier {
  final String baseUrl = 'https://darkred-donkey-427653.hostingersite.com';
  final AuthService authService;

  CarritoService(this.authService);

  List<dynamic> _productosCarrito = [];
  bool _isLoading = false;

  List<dynamic> get productosCarrito => _productosCarrito;

  bool get isLoading => _isLoading;

  // Obtener los productos del carrito
  Future<List<dynamic>> obtenerCarrito() async {
    // Verifica si el usuario está autenticado
    if (authService.token == null || authService.userId == null) {
      throw Exception('Usuario no autenticado');
    }


    notifyListeners();

    try {
      final url = '$baseUrl/api/v1/carrito?userId=${authService.userId}';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${authService.token}'},
      );

      print("🔍 Respuesta de la API del carrito: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          _productosCarrito = data['data']; // Actualiza la lista de productos
          print("✅ Productos recibidos: $_productosCarrito");
          notifyListeners();
          return _productosCarrito;
        } else {
          throw Exception(
              'Error en la respuesta del servidor: ${data['message']}');
        }
      } else {
        throw Exception('Error al obtener el carrito: ${response.statusCode}');
      }
    } catch (e) {
      print("⚠️ Error obteniendo carrito: $e");
      throw Exception('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar un producto al carrito
  Future<void> agregarAlCarrito(int idProducto, int cantidad) async {
    if (authService.token == null) {
      throw Exception('Usuario no autenticado');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/carrito'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${authService.token}',
        },
        body: json.encode({
          'id_producto': idProducto,
          'cantidad': cantidad,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          print(data['message']);
          if (data['data'] != null && data['data']['id_carrito'] != null) {
            print("ID del carrito: ${data['data']['id_carrito']}");
          }
        } else {
          print("Error: ${data['message']}");
        }
      } else {
        print("Error en la solicitud (${response
            .statusCode}): ${data['message']}");
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  // Eliminar un producto del carrito
  Future<void> eliminarDelCarrito(String productoId) async {
    if (authService.token == null) {
      throw Exception('Usuario no autenticado');
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/v1/carrito/$productoId'),
        headers: {'Authorization': 'Bearer ${authService.token}'},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          print(data['message']);
          // Actualizar la lista de productos en el carrito
          await obtenerCarrito();
        } else {
          throw Exception(
              'Error en la respuesta del servidor: ${data['message']}');
        }
      } else if (response.statusCode == 401) {
        // Token no válido o expirado
        await authService.clearToken(); // Elimina el token
        throw Exception('Token no válido o expirado');
      } else {
        throw Exception('Error al eliminar el producto del carrito: ${response
            .statusCode}');
      }
    } catch (e) {
      print('Error eliminando producto: $e');
      throw Exception('Error: $e');
    }
  }


  Future<Map<String, dynamic>> obtenerDetallesProducto(int idProducto) async {
    final url = '$baseUrl/api/v1/productos/$idProducto';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return data['data']; // Devuelve los detalles del producto
      }
    }
    throw Exception('Error al obtener los detalles del producto');
  }
}