import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screen/Pago/pago.dart';
import 'screen/Perfil/perfil.dart';
import 'screen/carrito/carrito_screen.dart';
import 'screen/carrito/services/carritoservice.dart';
import 'screen/home/home2.dart';
import 'screen/login/inicio_ses.dart';
import 'screen/login/services/service.dart';
import 'screen/registro/Registro.dart';
import 'screen/home/home.dart';
import 'screen/rentas/rentas.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),  // Proveedor de AuthService
        ChangeNotifierProxyProvider<AuthService, CarritoService>(
          create: (context) => CarritoService(Provider.of<AuthService>(context, listen: false)),
          update: (context, authService, carritoService) => CarritoService(authService),
        ),
      ],
      child: MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rentz Networking',
      theme: ThemeData(
        primaryColor: Color(0xFFFFC107),
        scaffoldBackgroundColor: Color(0xFF655137),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFFC107),
            foregroundColor: Color(0xFF3D2B1C),
          ),
        ),
      ),
      initialRoute: '/', // Ruta inicial
      routes: {
        '/': (context) => const MainNetworking(),
        '/login': (context) => RentadoresLogin(),
        '/registro': (context) => RentadoresRegistro(),
        '/home': (context) => HomeScreen(),
        '/home2': (context) => HomeScreenIn(),
        '/carrito': (context) => CarritoScreen(),
        '/perfil': (context) => ProfileScreen(),
        '/rentas': (context) => RentalHistoryScreen(),
        '/pago': (context) => const PagoScreen(rentaData: {}, productosCarrito: [],),
      },
    );
  }
}

class MainNetworking extends StatelessWidget {
  const MainNetworking({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF655137),
              Color(0xFF3D2B1C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/rentz.png',
                        height: 150,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'BIENVENIDO A RENTZ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDDD9C6),
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '¿Qué desea hoy?',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFDDD9C6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAnimatedButton(
                          text: 'INICIO SESIÓN',
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildAnimatedButton(
                          text: 'REGISTRO',
                          onPressed: () {
                            Navigator.pushNamed(context, '/registro');
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildAnimatedButton(
                          text: 'PRODUCTOS',
                          onPressed: () {
                            Navigator.pushNamed(context, '/home2');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  '© 2025 Rentz Networking',
                  style: TextStyle(
                    color: Color(0xFFDDD9C6),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({required String text, required VoidCallback onPressed}) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 200),
      tween: Tween<double>(begin: 1.0, end: 1.1),
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              backgroundColor: Color(0xFFFFC107),
              foregroundColor: Color(0xFF3D2B1C),
            ),
            onPressed: onPressed,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }
}
