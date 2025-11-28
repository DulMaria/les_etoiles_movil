import 'package:flutter/material.dart';
import '../models/usuario_model.dart';

class NotificacionesScreen extends StatelessWidget {
  final Usuario usuario;
  
  const NotificacionesScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: const Color(0xFF00BCD4),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Marcar todas como leídas')),
              );
            },
            tooltip: 'Marcar todas como leídas',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationCard(
            icon: Icons.check_circle,
            title: 'Reserva Confirmada',
            message: 'Tu reserva para el 25 de Enero ha sido confirmada',
            time: 'Hace 2 horas',
            color: Colors.green,
            isRead: false,
          ),
          _buildNotificationCard(
            icon: Icons.info,
            title: 'Recordatorio',
            message: 'Tu evento es mañana a las 3:00 PM',
            time: 'Hace 5 horas',
            color: Colors.blue,
            isRead: false,
          ),
          _buildNotificationCard(
            icon: Icons.celebration,
            title: 'Promoción Especial',
            message: '20% de descuento en hospedajes este fin de semana',
            time: 'Hace 1 día',
            color: Colors.orange,
            isRead: true,
          ),
          _buildNotificationCard(
            icon: Icons.warning,
            title: 'Actualización Importante',
            message: 'Nuevas políticas de reservación disponibles',
            time: 'Hace 2 días',
            color: Colors.red,
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
    required Color color,
    required bool isRead,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead ? Colors.transparent : color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                  ),
                ),
              ),
              if (!isRead)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
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
                ),
              ),
              const SizedBox(height: 8),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}