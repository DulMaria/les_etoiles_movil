import 'package:flutter/material.dart';
import '../models/usuario_model.dart';

class NotificacionesScreen extends StatelessWidget {
  final Usuario usuario;
  
  const NotificacionesScreen({Key? key, required this.usuario}) : super(key: key);

  // Definir colores localmente
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color accentMint = Color(0xFF10B981);
  static const Color vibrantTeal = Color(0xFF14B8A6);
  static const Color infoBlue = Color(0xFF3B82F6);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color softPink = Color(0xFFEC4899);
  static const Color backgroundLight = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentAmber, accentCoral],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Todas marcadas como leídas'),
                  backgroundColor: accentMint,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            tooltip: 'Marcar todas como leídas',
          ),
        ],
      ),
      backgroundColor: backgroundLight,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationCard(
            icon: Icons.check_circle_rounded,
            title: 'Reserva Confirmada',
            message: 'Tu reserva para el 25 de Enero ha sido confirmada',
            time: 'Hace 2 horas',
            gradient: LinearGradient(
              colors: [accentMint, vibrantTeal],
            ),
            isRead: false,
          ),
          _buildNotificationCard(
            icon: Icons.info_rounded,
            title: 'Recordatorio',
            message: 'Tu evento es mañana a las 3:00 PM',
            time: 'Hace 5 horas',
            gradient: LinearGradient(
              colors: [infoBlue, const Color(0xFF60A5FA)],
            ),
            isRead: false,
          ),
          _buildNotificationCard(
            icon: Icons.celebration_rounded,
            title: 'Promoción Especial',
            message: '20% de descuento en hospedajes este fin de semana',
            time: 'Hace 1 día',
            gradient: LinearGradient(
              colors: [accentAmber, accentCoral],
            ),
            isRead: true,
          ),
          _buildNotificationCard(
            icon: Icons.warning_rounded,
            title: 'Actualización Importante',
            message: 'Nuevas políticas de reservación disponibles',
            time: 'Hace 2 días',
            gradient: LinearGradient(
              colors: [errorRed, softPink],
            ),
            isRead: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String message,
    required String time,
    required Gradient gradient,
    required bool isRead,
  }) {
    // Extraer el primer color del gradiente para el borde y el punto
    final primaryColor = (gradient as LinearGradient).colors.first;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isRead ? 4 : 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: primaryColor.withOpacity(0.25),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? Colors.grey.shade300 : primaryColor.withOpacity(0.5),
            width: 2,
          ),
          color: Colors.white,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(14),
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
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                    color: const Color(0xFF1F2937),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              if (!isRead)
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}