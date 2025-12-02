import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/Hospedaje/reserva_hotel_model.dart';

class HotelApiService {
  static const String baseUrl = 'https://proyecto-iii-les-toiles-de-l-eau.vercel.app/api';
  
  static const Duration timeout = Duration(seconds: 30);

  // 📋 OBTENER RESERVAS PENDIENTES DE CHECK-IN
  static Future<RespuestaReservas> obtenerReservasPendientesCheckIn() async {
    try {
      print('🔍 Obteniendo reservas pendientes...');
      final response = await http
          .get(Uri.parse('$baseUrl/reservaHotel/pendientes-check-in/'))
          .timeout(timeout);

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RespuestaReservas.fromJson(data);
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // 🏨 OBTENER RESERVAS CON CHECK-IN
  static Future<RespuestaReservas> obtenerReservasPendientesCheckOut() async {
    try {
      print('🔍 Obteniendo reservas en check-in...');
      final response = await http
          .get(Uri.parse('$baseUrl/reservaHotel/pendientes-check-out/'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RespuestaReservas.fromJson(data);
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // ✅ OBTENER RESERVAS FINALIZADAS
  static Future<RespuestaReservas> obtenerReservasFinalizadas() async {
    try {
      print('🔍 Obteniendo reservas finalizadas...');
      final response = await http
          .get(Uri.parse('$baseUrl/reservaHotel/finalizadas/'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RespuestaReservas.fromJson(data);
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // ❌ OBTENER RESERVAS CANCELADAS
  static Future<RespuestaReservas> obtenerReservasCanceladas() async {
    try {
      print('🔍 Obteniendo reservas canceladas...');
      final response = await http
          .get(Uri.parse('$baseUrl/reservaHotel/canceladas/'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RespuestaReservas.fromJson(data);
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // ✅ REALIZAR CHECK-IN
  static Future<Map<String, dynamic>> realizarCheckIn(int idReserva) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/reservaHotel/$idReserva/check-in/'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'exito': true,
          'mensaje': data['mensaje'] ?? 'Check-in realizado',
          'data': data,
        };
      } else {
        return {
          'exito': false,
          'mensaje': data['error'] ?? 'Error al realizar check-in',
          'data': data,
        };
      }
    } catch (e) {
      return {
        'exito': false,
        'mensaje': 'Error de conexión: $e',
      };
    }
  }

  // 🚪 REALIZAR CHECK-OUT
  static Future<Map<String, dynamic>> realizarCheckOut(int idReserva) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/reservaHotel/$idReserva/check-out/'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'exito': true,
          'mensaje': data['mensaje'] ?? 'Check-out realizado',
          'data': data,
        };
      } else {
        return {
          'exito': false,
          'mensaje': data['error'] ?? 'Error al realizar check-out',
          'data': data,
        };
      }
    } catch (e) {
      return {
        'exito': false,
        'mensaje': 'Error de conexión: $e',
      };
    }
  }

  // ❌ CANCELAR CHECK-IN
  static Future<Map<String, dynamic>> cancelarCheckIn(int idReserva) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/reservaHotel/$idReserva/check-in/cancelar/'))
          .timeout(timeout);

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'exito': true,
          'mensaje': data['mensaje'] ?? 'Check-in cancelado',
          'data': data,
        };
      } else {
        return {
          'exito': false,
          'mensaje': data['error'] ?? 'Error al cancelar',
          'data': data,
        };
      }
    } catch (e) {
      return {
        'exito': false,
        'mensaje': 'Error de conexión: $e',
      };
    }
  }

  // ❌ ELIMINAR/CANCELAR RESERVA
  static Future<Map<String, dynamic>> eliminarReserva(int idReserva) async {
    try {
      print('🗑️ Cancelando reserva $idReserva...');
      final response = await http
          .delete(Uri.parse('$baseUrl/reservaHotel/reservas/$idReserva/eliminar/'))
          .timeout(timeout);

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'exito': true,
          'mensaje': data['mensaje'] ?? 'Reserva cancelada',
          'data': data,
        };
      } else {
        return {
          'exito': false,
          'mensaje': data['error'] ?? 'Error al cancelar',
          'data': data,
        };
      }
    } catch (e) {
      return {
        'exito': false,
        'mensaje': 'Error de conexión: $e',
      };
    }
  }
}