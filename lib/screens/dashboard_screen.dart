import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../widgets/custom_drawer.dart';
import '../utils/theme_by_role.dart';
import 'reserva_hospedaje_screen.dart';
import 'reserva_eventos_screen.dart';
import 'notificaciones_screen.dart';
import 'perfil_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Usuario usuario;
  
  const DashboardScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = ThemeByRole.getPrimaryColor(usuario.rol);
    final secondaryColor = ThemeByRole.getSecondaryColor(usuario.rol);
    final backgroundColor = ThemeByRole.getBackgroundColor(usuario.rol);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: ThemeByRole.getAppBarGradient(usuario.rol),
          ),
        ),
        title: const Text(
          'Piscina Playa Azul',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: CustomDrawer(usuario: usuario),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header de bienvenida con diseño moderno
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: ThemeByRole.getHeaderGradient(usuario.rol),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
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
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: ThemeByRole.getProfileIconColor(usuario.rol),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¡Bienvenido!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    usuario.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
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
            
            // Sección de acciones rápidas
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildActionCard(
                        context,
                        icon: Icons.hotel_rounded,
                        title: 'Reserva\nHospedaje',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)], // AZUL FIJO
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReservaHospedajeScreen(usuario: usuario),
                            ),
                          );
                        },
                      ),
                      
                      _buildActionCard(
                        context,
                        icon: Icons.event_rounded,
                        title: 'Reserva\nEventos',
                        gradient: const LinearGradient(
                          colors: [ThemeByRole.sharedAccentLavender, ThemeByRole.sharedSoftPink], // PÚRPURA-ROSADO FIJO
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReservaEventosScreen(usuario: usuario),
                            ),
                          );
                        },
                      ),
                      
                      _buildActionCard(
                        context,
                        icon: Icons.notifications_active_rounded,
                        title: 'Notificaciones',
                        gradient: const LinearGradient(
                          colors: [ThemeByRole.sharedAccentAmber, ThemeByRole.sharedAccentCoral], // ÁMBAR-CORAL FIJO
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificacionesScreen(usuario: usuario),
                            ),
                          );
                        },
                      ),
                      
                      // TARJETA "MI PERFIL" - CAMBIA SEGÚN ROL
                      _buildActionCard(
                        context,
                        icon: Icons.person_rounded,
                        title: 'Mi Perfil',
                        gradient: ThemeByRole.isAdmin(usuario.rol)
                            ? LinearGradient(
                                colors: [
                                  ThemeByRole.getPrimaryColor(usuario.rol),
                                  ThemeByRole.getSecondaryColor(usuario.rol)
                                ], // AZUL GRADIENTE PARA ADMIN
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : const LinearGradient(
                                colors: [
                                  ThemeByRole.sharedAccentMint,
                                  ThemeByRole.sharedVibrantTeal
                                ], // VERDE GRADIENTE PARA EMPLEADO
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PerfilScreen(usuario: usuario),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}