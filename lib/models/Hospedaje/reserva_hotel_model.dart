import 'package:flutter/material.dart';

class ReservaHotel {
  final int idReservaHotel;
  final int cantPersonas;
  final String amoblado;
  final String fechaIni;
  final String fechaFin;
  final String estado;
  final String banioPriv;
  
  // Relaciones y campos adicionales del API
  final int? reservasGen;
  final int? datosCliente;
  final int? habitacion;
  final String? habitacionNumero;
  
  final String? cliente;
  final String? clienteTelefono;
  
  final String? checkIn;
  final String? checkOut;
  
  // Campos adicionales de los endpoints especiales
  final String? fechaCheckOutEsperado;
  final TiempoHospedado? tiempoHospedado;
  final TiempoHospedado? duracionEstadia;
  final int? diasDesdeInicio;
  final bool? sobrepasoFecha;

  ReservaHotel({
    required this.idReservaHotel,
    required this.cantPersonas,
    required this.amoblado,
    required this.fechaIni,
    required this.fechaFin,
    required this.estado,
    required this.banioPriv,
    this.reservasGen,
    this.datosCliente,
    this.habitacion,
    this.habitacionNumero,
    this.cliente,
    this.clienteTelefono,
    this.checkIn,
    this.checkOut,
    this.fechaCheckOutEsperado,
    this.tiempoHospedado,
    this.duracionEstadia,
    this.diasDesdeInicio,
    this.sobrepasoFecha,
  });

  factory ReservaHotel.fromJson(Map<String, dynamic> json) {
    String estadoNormalizado = (json['estado']?.toString() ?? 'A').trim().toUpperCase();
    
    return ReservaHotel(
      idReservaHotel: _parseToInt(json['id_reserva_hotel']),
      cantPersonas: _parseToInt(json['cant_personas'] ?? 0),
      amoblado: json['amoblado']?.toString() ?? '',
      fechaIni: json['fecha_ini']?.toString() ?? '',
      fechaFin: json['fecha_fin']?.toString() ?? '',
      estado: estadoNormalizado,
      banioPriv: json['baño_priv']?.toString() ?? json['banio_priv']?.toString() ?? '',
      
      reservasGen: _parseToIntNullable(json['reservas_gen']),
      datosCliente: _parseToIntNullable(json['datos_cliente']),
      habitacion: _parseToIntNullable(json['habitacion']),
      habitacionNumero: json['habitacion']?.toString(),
      
      cliente: json['cliente']?.toString(),
      clienteTelefono: json['cliente_telefono']?.toString(),
      
      checkIn: json['check_in']?.toString(),
      checkOut: json['check_out']?.toString(),
      
      fechaCheckOutEsperado: json['fecha_check_out_esperado']?.toString(),
      
      tiempoHospedado: json['tiempo_hospedado'] != null
          ? TiempoHospedado.fromJson(json['tiempo_hospedado'])
          : null,
      duracionEstadia: json['duracion_estadia'] != null
          ? TiempoHospedado.fromJson(json['duracion_estadia'])
          : null,
          
      diasDesdeInicio: _parseToIntNullable(json['dias_desde_inicio']),
      sobrepasoFecha: json['sobrepaso_fecha'] as bool?,
    );
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _parseToIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id_reserva_hotel': idReservaHotel,
      'cant_personas': cantPersonas,
      'amoblado': amoblado,
      'fecha_ini': fechaIni,
      'fecha_fin': fechaFin,
      'estado': estado,
      'baño_priv': banioPriv,
      'reservas_gen': reservasGen,
      'datos_cliente': datosCliente,
      'habitacion': habitacion,
      'check_in': checkIn,
      'check_out': checkOut,
    };
  }

  String get estadoTexto {
    final estadoNormalizado = estado.trim().toUpperCase();
    
    switch (estadoNormalizado) {
      case 'A':
        if (checkIn != null && checkIn!.isNotEmpty && 
            (checkOut == null || checkOut!.isEmpty)) {
          return 'En Curso';
        }
        return 'Activa';
      case 'C':
        return 'Cancelada';
      case 'F':
        return 'Finalizada';
      default:
        return 'Desconocido ($estadoNormalizado)';
    }
  }

  Color get estadoColor {
    final estadoNormalizado = estado.trim().toUpperCase();
    
    switch (estadoNormalizado) {
      case 'A':
        if (checkIn != null && checkIn!.isNotEmpty && 
            (checkOut == null || checkOut!.isEmpty)) {
          return Colors.blue;
        }
        return Colors.green;
      case 'C':
        return Colors.red;
      case 'F':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData get estadoIcono {
    final estadoNormalizado = estado.trim().toUpperCase();
    
    switch (estadoNormalizado) {
      case 'A':
        if (checkIn != null && checkIn!.isNotEmpty && 
            (checkOut == null || checkOut!.isEmpty)) {
          return Icons.hotel;
        }
        return Icons.pending;
      case 'C':
        return Icons.cancel;
      case 'F':
        return Icons.done_all;
      default:
        return Icons.help;
    }
  }

  String get habitacionTexto {
    if (habitacionNumero != null && habitacionNumero!.isNotEmpty) {
      return habitacionNumero!;
    }
    if (habitacion != null) {
      return habitacion.toString();
    }
    return 'N/A';
  }

  // 📅 FECHA DE INICIO DE RESERVA (SIEMPRE LA ORIGINAL)
  String get fechaDisplay {
    if (fechaIni.isNotEmpty) return _formatearFecha(fechaIni);
    
    // 🔧 FALLBACK: Si no hay fecha_ini pero sí hay check-in, extraer la fecha
    if (checkIn != null && checkIn!.isNotEmpty) {
      return _formatearFecha(checkIn!);
    }
    
    return 'N/A';
  }

  // 📅 FECHA DE FIN DE RESERVA (SIEMPRE LA ORIGINAL)
  String get fechaFinDisplay {
    if (fechaFin.isNotEmpty) return _formatearFecha(fechaFin);
    
    // Fallback a fecha esperada si no hay fecha_fin
    if (fechaCheckOutEsperado != null && fechaCheckOutEsperado!.isNotEmpty) {
      return _formatearFecha(fechaCheckOutEsperado!);
    }
    
    return 'N/A';
  }
  
  // 📅 FECHA REAL DE CHECK-IN (cuando se realizó el ingreso)
  String get fechaCheckInRealizado {
    if (checkIn != null && checkIn!.isNotEmpty) {
      return _formatearFecha(checkIn!);
    }
    return 'N/A';
  }
  
  // 📅 FECHA REAL DE CHECK-OUT (cuando se realizó la salida)
  String get fechaCheckOutRealizado {
    if (checkOut != null && checkOut!.isNotEmpty) {
      return _formatearFecha(checkOut!);
    }
    return 'N/A';
  }

  // 📅 NUEVO: Método auxiliar para formatear fechas
  String _formatearFecha(String fecha) {
    if (fecha.isEmpty) return 'N/A';
    
    try {
      // Si la fecha incluye hora (formato: "2024-01-15T10:30:00")
      if (fecha.contains('T')) {
        return fecha.split('T')[0]; // Retorna solo "2024-01-15"
      }
      
      // Si ya está en formato simple, retornarla tal cual
      return fecha;
    } catch (e) {
      return fecha; // En caso de error, retornar la fecha original
    }
  }

  // 📅 NUEVO: Rango de fechas completo para mostrar
  String get rangoFechas {
    final inicio = fechaDisplay;
    final fin = fechaFinDisplay;
    
    if (inicio == 'N/A' && fin == 'N/A') {
      return 'Fechas no disponibles';
    }
    
    if (inicio == fin) {
      return inicio; // Si son iguales, mostrar solo una vez
    }
    
    return '$inicio - $fin';
  }

  bool get esAmoblado {
    return amoblado.toUpperCase() == 'S' || amoblado == '1';
  }

  bool get tieneBanioPrivado {
    return banioPriv.toUpperCase() == 'S' || banioPriv == '1';
  }

  TiempoHospedado? get duracionTotal {
    return duracionEstadia ?? tiempoHospedado;
  }
}

class TiempoHospedado {
  final int dias;
  final int horas;
  final int? minutos;
  final String texto;

  TiempoHospedado({
    required this.dias,
    required this.horas,
    this.minutos,
    required this.texto,
  });

  factory TiempoHospedado.fromJson(Map<String, dynamic> json) {
    return TiempoHospedado(
      dias: json['dias'] as int? ?? 0,
      horas: json['horas'] as int? ?? 0,
      minutos: json['minutos'] as int?,
      texto: json['texto']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dias': dias,
      'horas': horas,
      'minutos': minutos,
      'texto': texto,
    };
  }
}

class RespuestaReservas {
  final int count;
  final String? fechaActual;
  final List<ReservaHotel> reservas;

  RespuestaReservas({
    required this.count,
    this.fechaActual,
    required this.reservas,
  });

  factory RespuestaReservas.fromJson(Map<String, dynamic> json) {
    var reservasList = <ReservaHotel>[];
    
    if (json['reservas'] != null) {
      reservasList = (json['reservas'] as List)
          .map((r) => ReservaHotel.fromJson(r as Map<String, dynamic>))
          .toList();
    }
    
    return RespuestaReservas(
      count: json['count'] as int? ?? 0,
      fechaActual: json['fecha_actual']?.toString(),
      reservas: reservasList,
    );
  }
}