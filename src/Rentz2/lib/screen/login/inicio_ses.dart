import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home.dart';
import 'services/service.dart';
import 'package:animate_do/animate_do.dart';

class RentadoresLogin extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<RentadoresLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  bool isPasswordVisible = false;

  void _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      final response = await authService.login(email, password);

      if (response is Map<String, dynamic> && response.containsKey("success")) {
        if (response["success"] == true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', response["token"]);
          await prefs.setString('user_name', response["user"]["nombre"]);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response["message"] ?? "Inicio de sesión exitoso")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response["message"] ?? "Credenciales incorrectas")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Respuesta inesperada del servidor")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error en el inicio de sesión: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Evita que el teclado empuje los elementos
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height, // Ocupa toda la pantalla
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.withOpacity(0.2),
                Colors.purple.withOpacity(0.1),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInDown(
                  duration: Duration(milliseconds: 800),
                  child: Image.asset(
                    'assets/images/rentz.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                FadeIn(
                  duration: Duration(milliseconds: 900),
                  child: Text(
                    'Iniciar Sesión',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(81, 27, 0, 1.0),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85, // Ajusta el ancho
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFFCA8E6D).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Permite ajustar el tamaño al contenido
                        children: [
                          _buildTextField(
                            controller: emailController,
                            hint: 'Correo Electrónico',
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: passwordController,
                            hint: 'Contraseña',
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFFC107),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                              ),
                              child: Text(
                                'Iniciar Sesión',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(81, 27, 0, 1.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).viewInsets.bottom), // Ajusta el espacio con el teclado
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        return TextField(
          controller: controller,
          obscureText: isPassword && !isPasswordVisible,
          style: TextStyle(color: Colors.brown),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.brown),
            prefixIcon: Icon(icon, color: Colors.black54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.black54,
              ),
              onPressed: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
            )
                : null,
          ),
        );
      },
    );
  }
}
