// utils/SesionManager.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class SessionManager {
  // Constantes de tiempo - 3 MINUTOS
  static const String _lastActivityKey = 'last_activity';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userDataKey = 'user_data';
  static const int _sessionTimeoutMinutes = 3; // 3 MINUTOS
  static const int _sessionTimeoutSeconds = _sessionTimeoutMinutes * 60;
  
  // ========== MÉTODOS PARA DATOS DE USUARIO ==========
  
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = json.encode(userData);
      await prefs.setString(_userDataKey, userDataString);
    } catch (e) {
      print('❌ Error guardando datos del usuario: $e');
    }
  }
  
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);
      
      if (userDataString != null && userDataString.isNotEmpty) {
        return json.decode(userDataString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('❌ Error obteniendo datos del usuario: $e');
      return null;
    }
  }
  
  // ========== MÉTODOS DE SESIÓN ==========
  
  static Future<void> updateLastActivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_lastActivityKey, now);
    } catch (e) {
      print('❌ Error actualizando actividad: $e');
    }
  }
  
  static Future<bool> isSessionExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActivity = prefs.getInt(_lastActivityKey);
      
      if (lastActivity == null) {
        return true;
      }
      
      final lastActivityDate = DateTime.fromMillisecondsSinceEpoch(lastActivity);
      final now = DateTime.now();
      final difference = now.difference(lastActivityDate);
      final isExpired = difference.inSeconds >= _sessionTimeoutSeconds;
      
      return isExpired;
    } catch (e) {
      print('❌ Error verificando sesión: $e');
      return true;
    }
  }
  
  // Obtener tiempo restante en segundos
  static Future<int> getRemainingTimeSeconds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActivity = prefs.getInt(_lastActivityKey);
      
      if (lastActivity == null) {
        return 0;
      }
      
      final lastActivityDate = DateTime.fromMillisecondsSinceEpoch(lastActivity);
      final now = DateTime.now();
      final elapsed = now.difference(lastActivityDate).inSeconds;
      final remaining = _sessionTimeoutSeconds - elapsed;
      
      return remaining > 0 ? remaining : 0;
    } catch (e) {
      print('❌ Error obteniendo tiempo restante: $e');
      return 0;
    }
  }
  
  // Obtener tiempo restante en minutos (con decimal)
  static Future<double> getRemainingTimeMinutes() async {
    final seconds = await getRemainingTimeSeconds();
    return seconds / 60;
  }
  
  static Future<void> setLoggedIn(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, value);
      if (value) {
        await updateLastActivity();
      }
    } catch (e) {
      print('❌ Error estableciendo login: $e');
    }
  }
  
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('❌ Error verificando login: $e');
      return false;
    }
  }
  
  // CERRAR SESIÓN
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastActivityKey);
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_userDataKey);
    } catch (e) {
      print('❌ Error cerrando sesión: $e');
    }
  }
  
  // Método para login
  static Future<void> login(Map<String, dynamic> userData) async {
    await logout();
    await saveUserData(userData);
    await setLoggedIn(true);
  }
  
  // Obtener tiempo formateado MM:SS
  static Future<String> getFormattedRemainingTime() async {
    final remainingSeconds = await getRemainingTimeSeconds();
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
  
  // Verificar si quedan menos de 30 segundos
  static Future<bool> isSessionAboutToExpire() async {
    try {
      final remainingSeconds = await getRemainingTimeSeconds();
      return remainingSeconds > 0 && remainingSeconds <= 30; // 30 segundos
    } catch (e) {
      print('❌ Error verificando expiración cercana: $e');
      return false;
    }
  }
}

// ========== SESSION WRAPPER ==========
class SessionWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onSessionExpired;
  
  const SessionWrapper({
    Key? key,
    required this.child,
    required this.onSessionExpired,
  }) : super(key: key);

  @override
  State<SessionWrapper> createState() => _SessionWrapperState();
}

class _SessionWrapperState extends State<SessionWrapper> with WidgetsBindingObserver {
  Timer? _sessionCheckTimer;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSession();
    _startSessionChecker();
  }

  Future<void> _initializeSession() async {
    final isLoggedIn = await SessionManager.isLoggedIn();
    if (isLoggedIn) {
      await SessionManager.updateLastActivity();
    }
  }

  void _startSessionChecker() {
    // Verificar cada 10 segundos para 3 minutos
    _sessionCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    final isLoggedIn = await SessionManager.isLoggedIn();
    
    if (!isLoggedIn) return;
    
    final isExpired = await SessionManager.isSessionExpired();
    
    if (isExpired && mounted) {
      await SessionManager.logout();
      widget.onSessionExpired();
    }
  }

  Future<void> _updateActivity() async {
    final isLoggedIn = await SessionManager.isLoggedIn();
    if (isLoggedIn) {
      await SessionManager.updateLastActivity();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        _updateActivity();
        _checkSession();
        break;
        
      case AppLifecycleState.paused:
        _updateActivity();
        break;
        
      default:
        break;
    }
  }

  @override
  void dispose() {
    _sessionCheckTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _updateActivity(),
      onPanDown: (_) => _updateActivity(),
      onLongPressDown: (_) => _updateActivity(),
      child: widget.child,
    );
  }
}