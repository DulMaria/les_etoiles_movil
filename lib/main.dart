import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'screens/InicioSesion/InicioSesion_Screen.dart';
import 'screens/Deshboard/dashboard_screen.dart';
import 'utils/SesionManager.dart';
import 'models/Usuarios/usuario_model.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: SessionWrapper(
        onSessionExpired: _handleSessionExpired,
        child: const SplashScreen(), // ← AQUÍ está el cambio principal
      ),
      debugShowCheckedModeBanner: false,
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
      if (navigatorKey.currentContext != null) {
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
      }
    });
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late AnimationController _waveController;
  late AnimationController _progressController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  String _loadingText = 'Iniciando...';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Animación del logo (escala + rotación)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    
    _logoRotation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
    
    // Animación de fade para textos
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    // Animación de olas de fondo
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    // Animación de progreso (reducido a 3 segundos)
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    )..addListener(() {
      if (mounted) {
        setState(() {
          _progress = _progressAnimation.value;
          _updateLoadingText(_progress);
        });
      }
    });
    
    _startAnimations();
  }

  void _startAnimations() async {
    // Iniciar animación del logo
    _logoController.forward();
    
    // Esperar un poco y luego fade in de textos
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _fadeController.forward();
    
    // Iniciar progreso
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _progressController.forward();
    
    // Verificar sesión mientras se carga (3 segundos)
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) _checkSession();
  }

  void _updateLoadingText(double progress) {
    if (progress < 0.25) {
      _loadingText = 'Preparando la piscina...';
    } else if (progress < 0.5) {
      _loadingText = 'Limpiando el agua...';
    } else if (progress < 0.75) {
      _loadingText = 'Verificando sesión...';
    } else {
      _loadingText = '¡Casi listo!';
    }
  }

  Future<void> _checkSession() async {
    // Verificar si hay sesión activa usando SessionManager
    final isLoggedIn = await SessionManager.isLoggedIn();
    
    if (!mounted) return;

    if (isLoggedIn) {
      // Verificar si la sesión expiró
      final isExpired = await SessionManager.isSessionExpired();
      
      if (isExpired) {
        // Sesión expirada, limpiar y ir a login
        await SessionManager.logout();
        _navigateToLogin();
        return;
      }
      
      // Obtener datos del usuario guardados
      final userData = await SessionManager.getUserData();
      
      if (userData != null) {
        // Actualizar última actividad
        await SessionManager.updateLastActivity();
        
        // Crear objeto Usuario y navegar al Dashboard
        final usuario = Usuario.fromJson(userData);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  DashboardScreen(usuario: usuario),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      } else {
        // No hay datos de usuario, ir a login
        _navigateToLogin();
      }
    } else {
      // No hay sesión, ir a login
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF00E5FF), // Cyan brillante
                  Color(0xFF00B8D4), // Turquesa medio
                  Color(0xFF0091EA), // Azul piscina
                ],
              ),
            ),
            child: Stack(
              children: [
                // Olas animadas de fondo
                Positioned.fill(
                  child: CustomPaint(
                    painter: SplashWavePainter(_waveController.value),
                  ),
                ),
                
                // Contenido principal
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo animado
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScale.value,
                            child: Transform.rotate(
                              angle: _logoRotation.value,
                              child: Container(
                                padding: const EdgeInsets.all(25),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'lib/assets/images/LogoPlayaAzul.png',
                                  width: 140,
                                  height: 140,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 50),
                      
                      // Título con fade
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Text(
                          'Piscina Playa Azul',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Color(0xFF006064),
                                offset: Offset(0, 3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Subtítulo con fade
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'Tu destino de relax',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w400,
                            letterSpacing: 2.0,
                            shadows: const [
                              Shadow(
                                color: Color(0xFF006064),
                                offset: Offset(0, 2),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 80),
                      
                      // Barra de progreso
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Column(
                            children: [
                              // Texto de carga
                              Text(
                                _loadingText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                      color: Color(0xFF006064),
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Barra de progreso personalizada
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: _progress,
                                    backgroundColor: Colors.transparent,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Color(0xFF00E676), // Verde agua
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Porcentaje
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00BFA5).withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF00BFA5),
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  '${(_progress * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    _waveController.dispose();
    _progressController.dispose();
    super.dispose();
  }
}

// Painter para olas de fondo del splash
class SplashWavePainter extends CustomPainter {
  final double animationValue;

  SplashWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Ola 1 - Azul piscina claro
    final paint1 = Paint()
      ..color = const Color(0xFF40C4FF).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.65);

    for (double i = 0; i <= size.width; i++) {
      path1.lineTo(
        i,
        size.height * 0.65 +
            math.sin((i / size.width * 3 * math.pi) +
                    (animationValue * 2 * math.pi)) *
                40,
      );
    }

    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();

    canvas.drawPath(path1, paint1);

    // Ola 2 - Azul piscina medio
    final paint2 = Paint()
      ..color = const Color(0xFF0091EA).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.72);

    for (double i = 0; i <= size.width; i++) {
      path2.lineTo(
        i,
        size.height * 0.72 +
            math.sin((i / size.width * 2.5 * math.pi) +
                    (animationValue * 2 * math.pi) +
                    math.pi / 3) *
                45,
      );
    }

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);

    // Ola 3 - Azul piscina profundo
    final paint3 = Paint()
      ..color = const Color(0xFF0277BD).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final path3 = Path();
    path3.moveTo(0, size.height * 0.78);

    for (double i = 0; i <= size.width; i++) {
      path3.lineTo(
        i,
        size.height * 0.78 +
            math.sin((i / size.width * 2 * math.pi) +
                    (animationValue * 2 * math.pi) +
                    math.pi / 1.5) *
                35,
      );
    }

    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    path3.close();

    canvas.drawPath(path3, paint3);

    // Ola 4 - Azul marino
    final paint4 = Paint()
      ..color = const Color(0xFF01579B).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final path4 = Path();
    path4.moveTo(0, size.height * 0.85);

    for (double i = 0; i <= size.width; i++) {
      path4.lineTo(
        i,
        size.height * 0.85 +
            math.sin((i / size.width * 1.8 * math.pi) +
                    (animationValue * 2 * math.pi) +
                    math.pi / 2) *
                30,
      );
    }

    path4.lineTo(size.width, size.height);
    path4.lineTo(0, size.height);
    path4.close();

    canvas.drawPath(path4, paint4);
  }

  @override
  bool shouldRepaint(SplashWavePainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}