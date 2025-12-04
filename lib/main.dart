import 'package:flutter/material.dart';
import 'utils/SesionManager.dart';
import 'models/Usuarios/usuario_model.dart';
import 'screens/InicioSesion/InicioSesion_Screen.dart';
import 'screens/Deshboard/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Piscina Playa Azul',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: SessionWrapper(
        onSessionExpired: _handleSessionExpired,
        child: const InitialScreen(),
      ),
    );
  }

  void _handleSessionExpired() {
    // Navegar a la pantalla de login cuando expire la sesión
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
    
    // Mostrar mensaje al usuario
    Future.delayed(const Duration(milliseconds: 300), () {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer_off_outlined,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }
}

// Pantalla inicial que decide si mostrar Login o Dashboard
class InitialScreen extends StatelessWidget {
  const InitialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00BCD4),
              ),
            ),
          );
        }
        
        if (snapshot.hasError) {
          return const LoginScreen();
        }

        final data = snapshot.data;
        final isLoggedIn = data?['isLoggedIn'] ?? false;
        final userData = data?['userData'];
        
        if (isLoggedIn && userData != null) {
          final usuario = Usuario.fromJson(userData);
          return DashboardScreen(usuario: usuario);
        } else {
          return const LoginScreen();
        }
      },
    );
  }

  Future<Map<String, dynamic>> _checkLoginStatus() async {
    final isLoggedIn = await SessionManager.isLoggedIn();
    
    if (isLoggedIn) {
      final isExpired = await SessionManager.isSessionExpired();
      
      if (isExpired) {
        await SessionManager.logout();
        return {'isLoggedIn': false, 'userData': null};
      }
      
      // Obtener datos del usuario guardados
      final userData = await SessionManager.getUserData();
      
      if (userData != null) {
        // Actualizar última actividad
        await SessionManager.updateLastActivity();
        return {'isLoggedIn': true, 'userData': userData};
      }
    }
    
    return {'isLoggedIn': false, 'userData': null};
  }
}