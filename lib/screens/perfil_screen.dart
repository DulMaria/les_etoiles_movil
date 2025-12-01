import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../utils/theme_by_role.dart'; // Importar la nueva clase

class PerfilScreen extends StatelessWidget {
  final Usuario usuario;
  
  const PerfilScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = ThemeByRole.getPrimaryColor(usuario.rol);
    final secondaryColor = ThemeByRole.getSecondaryColor(usuario.rol);
    final backgroundColor = ThemeByRole.getBackgroundColor(usuario.rol);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        foregroundColor: Colors.white,
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con foto de perfil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person_rounded,
                        size: 60,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    usuario.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      usuario.rol,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Información personal
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información Personal',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildInfoCard(
                    icon: Icons.badge_rounded,
                    title: 'CI',
                    value: usuario.ci.toString(),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                    ),
                  ),
                  
                  _buildInfoCard(
                    icon: Icons.email_rounded,
                    title: 'Email',
                    value: usuario.email,
                    gradient: const LinearGradient(
                      colors: [ThemeByRole.sharedAccentAmber, ThemeByRole.sharedAccentCoral],
                    ),
                  ),
                  
                  _buildInfoCard(
                    icon: Icons.phone_rounded,
                    title: 'Teléfono',
                    value: usuario.telefono.toString(),
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                    ),
                  ),
                  
                  _buildInfoCard(
                    icon: Icons.assignment_rounded,
                    title: 'Rol',
                    value: usuario.rol,
                    gradient: const LinearGradient(
                      colors: [ThemeByRole.sharedAccentLavender, ThemeByRole.sharedSoftPink],
                    ),
                  ),
                  
                  _buildInfoCard(
                    icon: Icons.check_circle_rounded,
                    title: 'Estado',
                    value: usuario.estado == 'A' ? 'Activo' : 'Inactivo',
                    gradient: usuario.estado == 'A' 
                      ? LinearGradient(
                          colors: [primaryColor, secondaryColor],
                        )
                      : const LinearGradient(
                          colors: [ThemeByRole.sharedErrorRed, ThemeByRole.sharedSoftPink],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Gradient gradient,
  }) {
    final primaryColor = (gradient as LinearGradient).colors.first;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: primaryColor.withOpacity(0.25),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(18),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 26,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}