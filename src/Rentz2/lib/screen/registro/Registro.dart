import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui';
import 'services/servicelog.dart';

class RentadoresRegistro extends StatelessWidget {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Image.asset('images/rentz.png', height: 150),
                ),
                const SizedBox(height: 20),
                FadeIn(
                  duration: const Duration(milliseconds: 900),
                  child: Text(
                    'Crear Cuenta',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromRGBO(81, 27, 0, 1.0),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCA8E6D).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: nombreController,
                            hint: 'Nombre Completo',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: apellidosController,
                            hint: 'Apellidos',
                            icon: Icons.account_circle_outlined,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: correoController,
                            hint: 'Correo Electrónico',
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: telefonoController,
                            hint: 'Teléfono',
                            icon: Icons.phone_outlined,
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
                              onPressed: () {
                                RegistroService.registrarUsuario(
                                  nombreController.text,
                                  apellidosController.text,
                                  correoController.text,
                                  telefonoController.text,
                                  passwordController.text,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFC107),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                              ),
                              child: Text(
                                'Registrarse',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromRGBO(81, 27, 0, 1.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    '¿Ya tienes cuenta? Inicia sesión',
                    style: GoogleFonts.poppins(
                      color: const Color.fromRGBO(81, 27, 0, 1.0),
                      fontWeight: FontWeight.w500,
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
          obscureText: isPassword,
          style: const TextStyle(color: Colors.brown),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.brown),
            prefixIcon: Icon(icon, color: Colors.black54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
        );
      },
    );
  }
}
