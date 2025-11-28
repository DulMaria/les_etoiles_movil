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
  final int? habitacion; // ID de habitación
  final String? habitacionNumero; // Número de habitación (del endpoint)
  
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
    // 🔹 NORMALIZAR EL ESTADO (eliminar espacios y convertir a mayúscula)
    String estadoNormalizado = (json['estado']?.toString() ?? 'A').trim().toUpperCase();
    
    return ReservaHotel(
      idReservaHotel: _parseToInt(json['id_reserva_hotel']),
      cantPersonas: _parseToInt(json['cant_personas'] ?? 0),
      amoblado: json['amoblado']?.toString() ?? '',
      fechaIni: json['fecha_ini']?.toString() ?? '',
      fechaFin: json['fecha_fin']?.toString() ?? '',
      estado: estadoNormalizado, // ✅ Ahora usa el estado normalizado
      banioPriv: json['baño_priv']?.toString() ?? json['banio_priv']?.toString() ?? '',
      
      // IDs de relaciones
      reservasGen: _parseToIntNullable(json['reservas_gen']),
      datosCliente: _parseToIntNullable(json['datos_cliente']),
      habitacion: _parseToIntNullable(json['habitacion']),
      habitacionNumero: json['habitacion']?.toString(),
      
      // Campos adicionales
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

  // Helper para convertir int de forma segura
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper para convertir int nullable
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
    // 🔹 MEJORADO: Normaliza el estado antes de comparar
    final estadoNormalizado = estado.trim().toUpperCase();
    
    switch (estadoNormalizado) {
      case 'A':
        // 🏨 Si tiene check-in pero NO check-out = En Curso
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
        // 🔹 DEBUG: Muestra el estado real si no coincide
        return 'Desconocido ($estadoNormalizado)';
    }
  }

  // 🔹 NUEVO: Getter para color según estado
  Color get estadoColor {
    final estadoNormalizado = estado.trim().toUpperCase();
    
    switch (estadoNormalizado) {
      case 'A':
        // 🏨 Si tiene check-in = En Curso (azul)
        if (checkIn != null && checkIn!.isNotEmpty && 
            (checkOut == null || checkOut!.isEmpty)) {
          return Colors.blue;
        }
        return Colors.green; // Activa (pendiente)
      case 'C':
        return Colors.red;
      case 'F':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // 🔹 NUEVO: Getter para icono según estado
  IconData get estadoIcono {
    final estadoNormalizado = estado.trim().toUpperCase();
    
    switch (estadoNormalizado) {
      case 'A':
        // 🏨 Si tiene check-in = En Curso
        if (checkIn != null && checkIn!.isNotEmpty && 
            (checkOut == null || checkOut!.isEmpty)) {
          return Icons.hotel; // En curso
        }
        return Icons.pending; // Pendiente
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

  String get fechaDisplay {
    return fechaIni.isNotEmpty ? fechaIni : 'N/A';
  }

  String get fechaFinDisplay {
    if (fechaFin.isNotEmpty) return fechaFin;
    if (fechaCheckOutEsperado != null && fechaCheckOutEsperado!.isNotEmpty) {
      return fechaCheckOutEsperado!;
    }
    return 'N/A';
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