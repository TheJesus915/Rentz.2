import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class HomeScreenIn extends StatefulWidget {
  const HomeScreenIn({super.key});

  @override
  State<HomeScreenIn> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreenIn> {
  List<dynamic> productos = [];
  List<dynamic> productosFiltrados = [];
  bool isLoading = false;
  int currentPage = 1;
  final int limit = 10;
  bool hasMoreProducts = true;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  int _selectedIndex = 0;

  // Design Constants
  static const Color primaryColor = Color(0xFF511B00);
  static const Color secondaryColor = Color(0xFF8B4513);
  static const Color accentColor = Color(0xFFDDD9C6);
  static const Color backgroundColor = Color(0xFFDDD9C6);
  static const Color textColor = Color(0xFF2C1810);
  static const Color cardColor = Color(0xFFFFFFFF);

  final TextStyle titleStyle = const TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: primaryColor,
    letterSpacing: 0.5,
    fontFamily: 'Playfair Display',
  );

  final TextStyle subtitleStyle = const TextStyle(
    fontSize: 14,
    color: secondaryColor,
    letterSpacing: 0.3,
    fontWeight: FontWeight.w500,
  );

  final TextStyle priceStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: primaryColor,
    fontFamily: 'Playfair Display',
  );

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text('Iniciar Sesión', style: titleStyle),
        content: Text(
          'Necesitas iniciar sesión para acceder a esta función',
          style: subtitleStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: primaryColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/login');
            },
            child: Text(
              'Iniciar Sesión',
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        productosFiltrados = List.from(productos);
      } else {
        productosFiltrados = productos.where((producto) {
          final nombre = producto['nombre_producto'].toString().toLowerCase();
          final descripcion = producto['descripcion'].toString().toLowerCase();
          return nombre.contains(query) || descripcion.contains(query);
        }).toList();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!isLoading && hasMoreProducts && !isSearching) {
        fetchProducts();
      }
    }
  }

  Future<void> fetchProducts() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://darkred-donkey-427653.hostingersite.com/api/v1/cliente/productos'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            if (currentPage == 1) {
              productos = data['data'];
              productosFiltrados = List.from(productos);
            } else {
              productos.addAll(data['data']);
              productosFiltrados = List.from(productos);
            }
            currentPage++;
            hasMoreProducts = data['data'].length == limit;
            isLoading = false;
          });
        } else {
          throw Exception('Error al cargar los productos');
        }
      } else {
        throw Exception('Error en la solicitud HTTP');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _refreshProducts() async {
    currentPage = 1;
    hasMoreProducts = true;
    _searchController.clear();
    await fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 1 : 4;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardColor,
        title: !isSearching
            ? Text('MOBILIARIA', style: titleStyle)
            : TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar productos...',
            hintStyle: TextStyle(
              color: secondaryColor.withOpacity(0.7),
              fontSize: 16,
            ),
            border: InputBorder.none,
          ),
          style: TextStyle(color: primaryColor),
          autofocus: true,
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: primaryColor,
            ),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  _searchController.clear();
                  productosFiltrados = List.from(productos);
                }
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        color: primaryColor,
        child: productosFiltrados.isEmpty && !isLoading
            ? Center(
          child: Text('No hay productos disponibles', style: subtitleStyle),
        )
            : GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: productosFiltrados.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == productosFiltrados.length) {
              return const Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }

            final producto = productosFiltrados[index];
            return GestureDetector(
              onTap: () => _showProductDetails(producto),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Card(
                  elevation: 0,
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: producto['url_imagenprincipal'] != null
                              ? Image.network(
                            producto['url_imagenprincipal'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: accentColor.withOpacity(0.3),
                                  child: Icon(
                                    Icons.image_not_supported_rounded,
                                    size: 40,
                                    color: primaryColor.withOpacity(0.5),
                                  ),
                                ),
                          )
                              : Container(
                            color: accentColor.withOpacity(0.3),
                            child: Icon(
                              Icons.image_rounded,
                              size: 40,
                              color: primaryColor.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              producto['nombre_producto'] ?? 'Sin nombre',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              producto['descripcion'] ?? 'Sin descripción',
                              style: TextStyle(
                                fontSize: 14,
                                color: secondaryColor.withOpacity(0.8),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '\$${producto['precio']}',
                                      style: priceStyle,
                                    ),
                                    Text(
                                      'Material: ${producto['material'] ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.brown,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: cardColor,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                transform: _selectedIndex == 1
                    ? (Matrix4.identity()..scale(1.2))
                    : Matrix4.identity(),
                child: Icon(
                  Icons.shopping_cart,
                  color: _selectedIndex == 1 ? Colors.yellow : primaryColor,
                ),
              ),
              onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });
                _showLoginDialog();
              },
            ),
            IconButton(
              icon: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                transform: _selectedIndex == 2
                    ? (Matrix4.identity()..scale(1.2))
                    : Matrix4.identity(),
                child: Icon(
                  Icons.local_shipping,
                  color: _selectedIndex == 2 ? Colors.yellow : primaryColor,
                ),
              ),
              onPressed: () {
                setState(() {
                  _selectedIndex = 2;
                });
                _showLoginDialog();
              },
            ),
            IconButton(
              icon: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                transform: _selectedIndex == 3
                    ? (Matrix4.identity()..scale(1.2))
                    : Matrix4.identity(),
                child: Icon(
                  Icons.person,
                  color: _selectedIndex == 3 ? Colors.yellow : primaryColor,
                ),
              ),
              onPressed: () {
                setState(() {
                  _selectedIndex = 3;
                });
                _showLoginDialog();
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

    );
  }

  void _showProductDetails(Map<String, dynamic> producto) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(producto['nombre_producto'], style: titleStyle),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (producto['url_imagenprincipal'] != null)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        producto['url_imagenprincipal'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(producto['descripcion'], style: subtitleStyle),
                const SizedBox(height: 16),
                Text('\$${producto['precio']}', style: priceStyle),
                const SizedBox(height: 16),
                Text('Material: ${producto['material'] ?? ''}', style: subtitleStyle),
                const SizedBox(height: 16),
                Text('Cantidad disponible: ${producto['cantidad_actual']}', style: subtitleStyle),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cerrar',
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}