import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Para abrir el enlace en el navegador
import 'services/pagoservices.dart';
import 'package:provider/provider.dart';
import '/screen/carrito/services/carritoservice.dart';

class PagoScreen extends StatelessWidget {
  final Map<String, dynamic> rentaData;
  final List<dynamic> productosCarrito;

  const PagoScreen({
    Key? key,
    required this.rentaData,
    required this.productosCarrito, // Asegurar que está en el constructor
  }) : super(key: key);

  static const Color kPrimaryColor = Color(0xFF8B4513);
  static const Color kBackgroundColor = Color(0xFFF5F5DC);
  static const double kPadding = 16.0;
  static const double kBorderRadius = 12.0;

  Future<void> _procesarPago(BuildContext context, double total) async {
    try {
      final response = await ApiService.generarPreferencia(total);
      final String? initPoint = response['initPoint'];

      if (initPoint == null || initPoint.isEmpty) {
        throw Exception('No se pudo obtener el enlace de pago.');
      }

      final Uri url = Uri.parse(initPoint);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('No se pudo abrir el enlace de pago.');
      }
    } catch (e) {
      _mostrarError(context, e.toString());
    }
  }

  void _mostrarError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Consumer<CarritoService>(
          builder: (context, carritoService, child) {
            final productos = carritoService.productosCarrito;
            print("Productos en carrito: $productos");
            double subtotal = productos.fold(0, (sum, item) {
              double precio = double.tryParse(item['precio'].toString()) ?? 0;
              int cantidad = (item['cantidad'] as int?) ?? 0;
              return sum + (precio * cantidad);
            });
            double costoEnvio = 100; // Puedes obtener esto de otra fuente
            double total = subtotal + costoEnvio;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(kPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildResumenCard(subtotal, costoEnvio, total),
                  const SizedBox(height: 32),
                  _buildBotonPago(context, total),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Resumen de Pago',
        style: TextStyle(
          color: kPrimaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      iconTheme: const IconThemeData(color: kPrimaryColor),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(kPadding),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: const Text(
        'Detalles de la Renta',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: kPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildResumenCard(double subtotal, double costoEnvio, double total) {
    return Card(
      elevation: 8,
      shadowColor: kPrimaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(kPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kBorderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              kBackgroundColor.withOpacity(0.5),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildDetailRow(Icons.shopping_cart, 'Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
            _buildDivider(),
            _buildDetailRow(Icons.local_shipping_outlined, 'Costo Envío', '\$${costoEnvio.toStringAsFixed(2)}'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, thickness: 2),
            ),
            _buildDetailRow(Icons.payments_outlined, 'Total a Pagar', '\$${total.toStringAsFixed(2)}', isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: isTotal ? kPrimaryColor : kPrimaryColor.withOpacity(0.7),
            size: isTotal ? 28 : 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 18 : 16,
                color: kPrimaryColor.withOpacity(0.8),
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? kPrimaryColor : kPrimaryColor.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: kPrimaryColor.withOpacity(0.2),
      height: 1,
    );
  }

  Widget _buildBotonPago(BuildContext context, double total) {
    return ElevatedButton(
      onPressed: () => _procesarPago(context, total),
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
      ),
      child: const Text('Procesar Pago', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
