import 'package:flutter/material.dart';
import '../models/Usuarios/usuario_model.dart';
import '../service/Usuarios/AutenticacionServicio.dart';
import '../utils/ColoresRol.dart'; // Importar la nueva clase
import '../screens/InicioSesion/InicioSesion_Screen.dart';
import '../screens/Hospedaje/reserva_hospedaje_screen.dart';
import '../screens/Eventos/reserva_eventos_screen.dart';
import '../screens/Notificacion/notificaciones_screen.dart';
import '../screens/Perfil/perfil_screen.dart';

class CustomDrawer extends StatelessWidget {
  final Usuario usuario;

  const CustomDrawer({Key? key, required this.usuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = ThemeByRole.getPrimaryColor(usuario.rol);
    final secondaryColor = ThemeByRole.getSecondaryColor(usuario.rol);

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header del drawer con info del usuario
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 45,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    usuario.nombreCompleto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    usuario.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      usuario.rol,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Opciones del menú
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.home,
                    title: 'Inicio',
                    iconColor: primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  
                  const Divider(height: 1, thickness: 1),
                  
                  _buildDrawerItem(
                    context,
                    icon: Icons.hotel,
                    title: 'Reserva Hospedaje',
                    iconColor: primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservaHospedajeScreen(usuario: usuario),
                        ),
                      );
                    },
                  ),
                  
                  _buildDrawerItem(
                    context,
                    icon: Icons.event,
                    title: 'Reserva Eventos',
                    iconColor: primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservaEventosScreen(usuario: usuario),
                        ),
                      );
                    },
                  ),
                  
                  const Divider(height: 1, thickness: 1),
                  
                  _buildDrawerItem(
                    context,
                    icon: Icons.notifications,
                    title: 'Notificaciones',
                    badge: '3',
                    iconColor: primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificacionesScreen(usuario: usuario),
                        ),
                      );
                    },
                  ),
                  
                  _buildDrawerItem(
                    context,
                    icon: Icons.person,
                    title: 'Mi Perfil',
                    iconColor: primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PerfilScreen(usuario: usuario),
                        ),
                      );
                    },
                  ),
                  
                  const Divider(height: 1, thickness: 1),
                ],
              ),
            ),

            // Botón de cerrar sesión al final
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: _buildDrawerItem(
                context,
                icon: Icons.logout,
                title: 'Cerrar Sesión',
                textColor: Colors.red.shade600,
                iconColor: Colors.red.shade600,
                onTap: () => _handleLogout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();
    
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    String? badge,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.blue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.blue,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? Colors.grey.shade800,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,  
                ),
              ),
            )
          : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }
}