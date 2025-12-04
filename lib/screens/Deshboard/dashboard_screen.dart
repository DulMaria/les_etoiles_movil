// dashboard_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/Usuarios/usuario_model.dart';
import '../../widgets/ManuPlegable.dart';
import '../../utils/ColoresRol.dart';
import '../Hospedaje/reserva_hospedaje_screen.dart';
import '../Eventos/reserva_eventos_screen.dart';
import '../Perfil/perfil_screen.dart';
import '../InicioSesion/InicioSesion_Screen.dart';
import '../../utils/SesionManager.dart';

class DashboardScreen extends StatefulWidget {
  final Usuario usuario;
  
  const DashboardScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> 
    with WidgetsBindingObserver {
  Timer? _sessionTimer;
  String _remainingTime = "03:00";
  Color _sessionColor = Colors.green;
  int _remainingSeconds = 180;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startSessionTimer();
    _updateSessionInfo();
    
    // Actualizar actividad inmediatamente al entrar
    SessionManager.updateLastActivity();
  }

  void _startSessionTimer() {
    // Actualizar cada segundo para precisión de 3 minutos
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateSessionInfo();
    });
  }

  Future<void> _updateSessionInfo() async {
    if (!mounted) return;
    
    try {
      final isLoggedIn = await SessionManager.isLoggedIn();
      
      if (!isLoggedIn) {
        _cerrarSesion();
        return;
      }
      
      _remainingSeconds = await SessionManager.getRemainingTimeSeconds();
      final formattedTime = await SessionManager.getFormattedRemainingTime();
      final isExpired = await SessionManager.isSessionExpired();
      final isAboutToExpire = await SessionManager.isSessionAboutToExpire();
      
      // Calcular minutos y segundos
      final minutes = _remainingSeconds ~/ 60;
      final seconds = _remainingSeconds % 60;
      
      // Actualizar color según tiempo restante
      Color newColor;
      if (isExpired || _remainingSeconds <= 0) {
        newColor = Colors.red;
      } else if (isAboutToExpire) { // Menos de 30 segundos
        newColor = Colors.red[800]!;
      } else if (_remainingSeconds <= 60) { // Menos de 1 minuto
        newColor = Colors.orange;
      } else if (_remainingSeconds <= 120) { // Menos de 2 minutos
        newColor = Colors.yellow[700]!;
      } else {
        newColor = Colors.green;
      }

      if (mounted) {
        setState(() {
          _remainingTime = formattedTime;
          _sessionColor = newColor;
          _remainingSeconds = _remainingSeconds;
        });
      }
      
      // Verificar si la sesión expiró
      if (isExpired) {
        _cerrarSesion();
        return;
      }
      
      // Mostrar advertencias
      if (seconds == 30 && minutes == 0 && mounted) {
        _mostrarAdvertenciaCritica();
      } else if (seconds == 0 && minutes == 1 && mounted) {
        _mostrarAdvertencia();
      } else if (seconds == 0 && minutes == 2 && mounted) {
        _mostrarAdvertenciaSuave();
      }
      
    } catch (e) {
      print('❌ Error actualizando info de sesión: $e');
    }
  }

  void _mostrarAdvertenciaSuave() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.timer, color: Colors.amber, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Sesión activa',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Text(
                    'Te quedan 2 minutos de sesión',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.amber[700],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _mostrarAdvertencia() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.timer, color: Colors.orange, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Sesión por expirar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Text(
                    '¡Solo te queda 1 minuto! Toca la pantalla.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange[800],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _mostrarAdvertenciaCritica() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '¡Sesión a punto de expirar!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Solo te quedan 30 segundos',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'ACTIVAR',
          textColor: Colors.white,
          onPressed: () {
            _registrarActividad();
          },
        ),
      ),
    );
  }

  void _cerrarSesion() {
    _sessionTimer?.cancel();
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión cerrada por inactividad (3 minutos)'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _registrarActividad() async {
    await SessionManager.updateLastActivity();
    _updateSessionInfo();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        SessionManager.updateLastActivity();
        _updateSessionInfo();
        break;
        
      case AppLifecycleState.paused:
        SessionManager.updateLastActivity();
        break;
        
      case AppLifecycleState.detached:
        _sessionTimer?.cancel();
        break;
        
      default:
        break;
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = ThemeByRole.getPrimaryColor(widget.usuario.rol);
    final backgroundColor = ThemeByRole.getBackgroundColor(widget.usuario.rol);

    return GestureDetector(
      onTap: _registrarActividad,
      onPanDown: (_) => _registrarActividad(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: ThemeByRole.getAppBarGradient(widget.usuario.rol),
            ),
          ),
          title: Row(
            children: [
              const Text(
                'Piscina Playa Azul',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // Indicador de tiempo de sesión
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _sessionColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _sessionColor.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _sessionColor == Colors.green ? Icons.timer :
                      _sessionColor == Colors.yellow[700] ? Icons.timer_outlined :
                      _sessionColor == Colors.orange ? Icons.timer_outlined :
                      Icons.timer_off,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _remainingTime,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, size: 22),
              tooltip: 'Cerrar sesión manualmente',
              onPressed: () async {
                _sessionTimer?.cancel();
                await SessionManager.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
        drawer: CustomDrawer(usuario: widget.usuario),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: ThemeByRole.getHeaderGradient(widget.usuario.rol),
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
                    GestureDetector(
                      onTap: _registrarActividad,
                      child: Container(
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
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: ThemeByRole.getProfileIconColor(widget.usuario.rol),
                              ),
                            ),
                            // Progress indicator siempre visible para 3 minutos
                            SizedBox(
                              width: 110,
                              height: 110,
                              child: CircularProgressIndicator(
                                value: _remainingSeconds / 180, // 3 minutos = 180 segundos
                                strokeWidth: 3,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: AlwaysStoppedAnimation<Color>(_sessionColor),
                              ),
                            ),
                          ],
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
                      widget.usuario.nombreCompleto,
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
                        widget.usuario.rol,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sesión válida por 3 minutos',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toca en cualquier lugar para mantener activa',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.hotel_rounded,
                            title: 'Reserva\nHospedaje',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () {
                              _registrarActividad();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReservaHospedajeScreen(usuario: widget.usuario),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.event_rounded,
                            title: 'Reserva\nEventos',
                            gradient: const LinearGradient(
                              colors: [ThemeByRole.sharedAccentLavender, ThemeByRole.sharedSoftPink],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () {
                              _registrarActividad();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReservaEventosScreen(usuario: widget.usuario),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: _buildActionCard(
                          icon: Icons.person_rounded,
                          title: 'Mi Perfil',
                          gradient: ThemeByRole.isAdmin(widget.usuario.rol)
                              ? LinearGradient(
                                  colors: [
                                    ThemeByRole.getPrimaryColor(widget.usuario.rol),
                                    ThemeByRole.getSecondaryColor(widget.usuario.rol)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : const LinearGradient(
                                  colors: [
                                    ThemeByRole.sharedAccentMint,
                                    ThemeByRole.sharedVibrantTeal
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          onTap: () {
                            _registrarActividad();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PerfilScreen(usuario: widget.usuario),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    // Panel informativo
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color.fromARGB(255, 204, 212, 215)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.timer,
                                color: Colors.blueGrey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Control de sesión (3 minutos)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey[800],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Indicador visual del tiempo
                          Row(
                            children: [
                              _buildTimeSegment('2 min', _remainingSeconds > 120 ? Colors.green : Colors.grey[300]!),
                              const SizedBox(width: 4),
                              _buildTimeSegment('1 min', _remainingSeconds > 60 ? Colors.green : Colors.grey[300]!),
                              const SizedBox(width: 4),
                              _buildTimeSegment('30s', _remainingSeconds > 30 ? Colors.green : Colors.grey[300]!),
                              const Spacer(),
                              Text(
                                _remainingTime,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: _sessionColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Monospace',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'La sesión se cerrará automáticamente después de 3 minutos sin actividad.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blueGrey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSegment(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionCard({
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
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
      ),
    );
  }
}