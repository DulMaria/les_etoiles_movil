// lib/utils/theme_by_role.dart
import 'package:flutter/material.dart';

class ThemeByRole {
  // Método para verificar si es administrador
  static bool isAdmin(String rol) {
    return rol.toLowerCase().contains('admin');
  }

  // Obtener colores según el rol
  static Color getPrimaryColor(String rol) {
    return isAdmin(rol) 
        ? const Color.fromARGB(255, 33, 133, 221)  // Azul turquesa para admin
        : const Color(0xFF00C9A7); // Verde turquesa para empleado
  }

  static Color getSecondaryColor(String rol) {
    return isAdmin(rol) 
        ? const Color.fromARGB(255, 37, 135, 226)  // Azul aqua para admin
        : const Color(0xFF4FD1C5); // Verde celeste para empleado
  }

  static Color getBackgroundColor(String rol) {
    return isAdmin(rol) 
        ? const Color(0xFFF8FAFC)  // Fondo claro para admin
        : const Color(0xFFF0FFF4); // Fondo verde claro para empleado
  }

  // Obtener color para el icono de perfil (SOLO PARA EL ICONO DEL HEADER)
  static Color getProfileIconColor(String rol) {
    return isAdmin(rol) 
        ? const Color.fromARGB(255, 33, 133, 221)  // AZUL para admin (#2185DD)
        : const Color(0xFF00C9A7); // VERDE para empleado (#00C9A7)
  }

  // Obtener gradiente para el AppBar
  static LinearGradient getAppBarGradient(String rol) {
    return LinearGradient(
      colors: [getPrimaryColor(rol), getSecondaryColor(rol)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Obtener gradiente para el header
  static LinearGradient getHeaderGradient(String rol) {
    return LinearGradient(
      colors: [getPrimaryColor(rol), getSecondaryColor(rol)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Colores compartidos (estáticos para todas las pantallas)
  static const Color sharedAccentCoral = Color(0xFFFF6B6B);
  static const Color sharedAccentMint = Color(0xFF10B981);
  static const Color sharedAccentAmber = Color(0xFFF59E0B);
  static const Color sharedAccentLavender = Color(0xFF8B5CF6);
  static const Color sharedSoftPink = Color(0xFFEC4899);
  static const Color sharedVibrantTeal = Color(0xFF14B8A6);
  static const Color sharedErrorRed = Color(0xFFEF4444);
  static const Color sharedInfoBlue = Color(0xFF3B82F6);
  static const Color sharedBackgroundLight = Color(0xFFF8FAFC);
}