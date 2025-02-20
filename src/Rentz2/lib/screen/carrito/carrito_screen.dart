import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/carritoservice.dart';

class CarritoScreen extends StatefulWidget {
  @override
  _CarritoScreenState createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  List<dynamic> productosCarrito = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarCarrito();
  }

  Future<void> _cargarCarrito() async {
    final carritoService = Provider.of<CarritoService>(context, listen: false);
    try {
      final List<dynamic> productos = await carritoService.obtenerCarrito();
      setState(() {
        productosCarrito = productos;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _mostrarError(e.toString());

      if (e.toString().contains('Token inválido o expirado')) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade800,
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _eliminarProducto(String productoId) async {
    final carritoService = Provider.of<CarritoService>(context, listen: false);
    try {
      await carritoService.eliminarDelCarrito(productoId);
      setState(() {
        productosCarrito.removeWhere((producto) => producto['id']?.toString() == productoId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Producto eliminado del carrito'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      _mostrarError('Error: ${e.toString()}');
    }
  }

  double _calcularTotal() {
    return productosCarrito.fold(0.0, (total, producto) {
      return total + (double.tryParse(producto['precio']?.toString() ?? '0') ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Carrito de Compras',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
      )
          : SafeArea(
        child: Column(
          children: [
            Expanded(
              child: productosCarrito.isEmpty
                  ? _CarritoVacio()
                  : _ListaProductos(
                productos: productosCarrito,
                onEliminar: _eliminarProducto,
              ),
            ),
            if (productosCarrito.isNotEmpty) _ResumenCompra(
              total: _calcularTotal(),
              onPagar: () => Navigator.pushNamed(context, '/pago'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarritoVacio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Tu carrito está vacío',
            style: Theme.of(context).textTheme.titleLarge, // Cambiado de headline6
          ),
          SizedBox(height: 8),
          Text(
            'Agrega productos para comenzar',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith( // Cambiado de subtitle1
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListaProductos extends StatelessWidget {
  final List<dynamic> productos;
  final Function(String) onEliminar;

  const _ListaProductos({
    required this.productos,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: productos.length,
      separatorBuilder: (context, index) => SizedBox(height: 16),
      itemBuilder: (context, index) {
        final producto = productos[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: producto['url_imagenprincipal'] != null
                      ? Image.network(
                    producto['url_imagenprincipal'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.image, size: 80),
                  )
                      : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: Icon(Icons.image),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto['nombre_producto'] ?? 'Producto sin nombre',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith( // Cambiado de subtitle1
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '\$${producto['precio']?.toString() ?? '20.00'}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith( // Cambiado de headline6
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: () => onEliminar(producto['id']?.toString() ?? ''),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResumenCompra extends StatelessWidget {
  final double total;
  final VoidCallback onPagar;

  const _ResumenCompra({
    required this.total,
    required this.onPagar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: Theme.of(context).textTheme.titleLarge, // Cambiado de headline6
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith( // Cambiado de headline6
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPagar,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'PROCEDER AL PAGO',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}