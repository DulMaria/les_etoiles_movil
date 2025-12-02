// service/evento_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/Eventos/reserva_evento_model.dart';

class EventoApiService {
  static const String baseUrl = 'https://proyecto-iii-les-toiles-de-l-eau.vercel.app/api';
  static const Duration timeout = Duration(seconds: 30);

  // 📋 OBTENER EVENTOS PENDIENTES DE CHECK-IN
  static Future<RespuestaEventos> obtenerEventosPendientesCheckIn() async {
    try {
      print('🔍 Obteniendo eventos pendientes...');
      final response = await http
          .get(
            Uri.parse('$baseUrl/reservaEvento/pendientes-check-in/'),
          )
          .timeout(timeout);

      print('📡 Status Code: ${response.statusCode}');
      print('📄 Response Body EVENTOS PENDIENTES: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RespuestaEventos.fromJson(data);
      } else {
        throw Exception('Error al obtener eventos pendientes: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en obtenerEventosPendientesCheckIn: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // 🎉 OBTENER EVENTOS CON CHECK-IN (pendientes de check-out)
  static Future<RespuestaEventos> obtenerEventosPendientesCheckOut() async {
    try {
      print('🔍 Obteniendo eventos en check-in...');
      final response = await http
          .get(
            Uri.parse('$baseUrl/reservaEvento/pendientes-check-out/'),
          )
          .timeout(timeout);

      print('📡 Status Code: ${response.statusCode}');
      print('📄 Response Body EVENTOS CHECK-IN: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RespuestaEventos.fromJson(data);
      } else {
        throw Exception('Error al obtener eventos en check-in: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en obtenerEventosPendientesCheckOut: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // ✅ OBTENER EVENTOS FINALIZADOS (con check-out)
  static Future<List<ReservaEvento>> obtenerEventosFinalizados() async {
    try {
      print('🔍 Obteniendo eventos finalizados...');
      // Nota: Deberás crear este endpoint en tu backend si no existe
      final response = await http
          .get(
            Uri.parse('$baseUrl/reservaEvento/finalizados/'),
          )
          .timeout(timeout);

      print('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> reservas = data['reservas'] ?? [];
        return reservas
            .map((r) => ReservaEvento.fromJson(r as Map<String, dynamic>))
            .toList();
      } else {
        // Si el endpoint no existe, retornar lista vacía
        return [];
      }
    } catch (e) {
      print('❌ Error en obtenerEventosFinalizados: $e');
      return [];
    }
  }

  // ❌ OBTENER EVENTOS CANCELADOS
  static Future<List<ReservaEvento>> obtenerEventosCancelados() async {
    try {
      print('🔍 Obteniendo eventos cancelados...');
      // Nota: Deberás crear este endpoint en tu backend si no existe
      final response = await http
          .get(
            Uri.parse('$baseUrl/reservaEvento/cancelados/'),
          )
          .timeout(timeout);

      print('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> reservas = data['reservas'] ?? [];
        return reservas
            .map((r) => ReservaEvento.fromJson(r as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Error en obtenerEventosCancelados: $e');
      return [];
    }
  }

  // ✅ REALIZAR CHECK-IN
  static Future<Map<String, dynamic>> realizarCheckIn(int idReserva) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/reservaEvento/$idReserva/check-in/'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'exito': true,
          'mensaje': data['mensaje'] ?? 'Check-in realizado correctamente',
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
            Uri.parse('$baseUrl/reservaEvento/$idReserva/check-out/'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'exito': true,
          'mensaje': data['mensaje'] ?? 'Salida realizada correctamente',
          'data': data,
        };
      } else {
        return {
          'exito': false,
          'mensaje': data['error'] ?? 'Error al realizar la salida',
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

  // ↩️ CANCELAR CHECK-IN (Deshacer)
  static Future<Map<String, dynamic>> cancelarCheckIn(int idReserva) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/reservaEvento/$idReserva/check-in/cancelar/'),
          )
          .timeout(timeout);

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'exito': true,
          'mensaje': data['mensaje'] ?? 'Ingreso cancelado correctamente',
          'data': data,
        };
      } else {
        return {
          'exito': false,
          'mensaje': data['error'] ?? 'Error al cancelar ingreso',
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

  // ❌ CANCELAR EVENTO (Eliminación lógica - estado C)
  static Future<Map<String, dynamic>> cancelarEvento(int idReserva) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/reservaEvento/eliminar/$idReserva/'),
          )
          .timeout(timeout);

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'exito': true,
          'mensaje': data['mensaje'] ?? 'Evento cancelado correctamente',
          'data': data,
        };
      } else {
        return {
          'exito': false,
          'mensaje': data['error'] ?? 'Error al cancelar evento',
          'data': data,
        };
      }
    } catch (e) {
      return {
        'exito': false,
        /// Manejo de errores de conexión en cancelación con el servidor
        'mensaje': 'Error de conexión con el servidor: $e',
      };
    }
  }
}