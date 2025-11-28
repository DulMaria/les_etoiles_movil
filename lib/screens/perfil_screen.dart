import 'package:flutter/material.dart';
import '../models/usuario_model.dart';

class PerfilScreen extends StatelessWidget {
  final Usuario usuario;
  
  const PerfilScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFF00BCD4),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Editar perfil')),
              );
            },
            tooltip: 'Editar perfil',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con foto de perfil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00BCD4),
                    const Color(0xFF00ACC1),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: const Color(0xFF00BCD4),
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
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      usuario.rol,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00838F),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildInfoCard(
                    icon: Icons.badge,
                    title: 'CI',
                    value: usuario.ci.toString(),
                    color: Colors.blue,
                  ),
                  
                  _buildInfoCard(
                    icon: Icons.email,
                    title: 'Email',
                    value: usuario.email,
                    color: Colors.orange,
                  ),
                  
                  _buildInfoCard(
                    icon: Icons.phone,
                    title: 'Teléfono',
                    value: usuario.telefono.toString(),
                    color: Colors.green,
                  ),
                  
                  _buildInfoCard(
                    icon: Icons.assignment,
                    title: 'Rol',
                    value: usuario.rol,
                    color: Colors.purple,
                  ),
                  
                  _buildInfoCard(
                    icon: Icons.check_circle,
                    title: 'Estado',
                    value: usuario.estado == 'A' ? 'Activo' : 'Inactivo',
                    color: usuario.estado == 'A' ? Colors.green : Colors.red,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Botón de cambiar contraseña
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cambiar contraseña'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.lock),
                      label: const Text('Cambiar Contraseña'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}