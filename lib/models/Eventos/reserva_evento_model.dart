// models/reserva_evento_model.dart
class ReservaEvento {
  final int idReservasEvento;
  final int cantPersonas;
  final String fecha;
  final String horaIni;
  final String horaFin;
  final String estado;
  
  // Datos del cliente
  final String? cliente;
  final String? clienteTelefono;
  
  // Check-in y Check-out
  final String? checkIn;
  final String? checkOut;
  
  // Servicios
  final int totalServicios;
  final List<String>? serviciosContratados;
  final List<String>? serviciosUtilizados;
  final double? precioTotalServicios;
  
  // Información adicional para pendientes
  final bool? puedeCheckIn;
  final Map<String, dynamic>? tiempoHastaInicio;
  final String? estadoCheckIn;
  
  // Información adicional para check-in
  final Map<String, dynamic>? tiempoTranscurrido;
  final bool? sobrepasoHoraFin;
  final String? estadoEvento;
  
  // Información adicional para finalizados
  final Map<String, dynamic>? duracionReal;
  final Map<String, dynamic>? duracionProgramada;

  ReservaEvento({
    required this.idReservasEvento,
    required this.cantPersonas,
    required this.fecha,
    required this.horaIni,
    required this.horaFin,
    required this.estado,
    this.cliente,
    this.clienteTelefono,
    this.checkIn,
    this.checkOut,
    this.totalServicios = 0,
    this.serviciosContratados,
    this.serviciosUtilizados,
    this.precioTotalServicios,
    this.puedeCheckIn,
    this.tiempoHastaInicio,
    this.estadoCheckIn,
    this.tiempoTranscurrido,
    this.sobrepasoHoraFin,
    this.estadoEvento,
    this.duracionReal,
    this.duracionProgramada,
  });
  // Parse from JSON para crear una instancia de ReservaEvento y asignar valores predeterminados 
  //que eviten errores si faltan campos en el JSONde

  factory ReservaEvento.fromJson(Map<String, dynamic> json) {
    return ReservaEvento(
      idReservasEvento: _parseToInt(json['id_reservas_evento']),
      cantPersonas: _parseToInt(json['cant_personas']),
      fecha: json['fecha']?.toString() ?? '',
      horaIni: json['hora_ini']?.toString() ?? '',
      horaFin: json['hora_fin']?.toString() ?? '',
      estado: json['estado']?.toString() ?? 'A',
      
      cliente: json['cliente']?.toString(),
      clienteTelefono: json['cliente_telefono']?.toString(),
      
      checkIn: json['check_in']?.toString(),
      checkOut: json['check_out']?.toString(),
      
      totalServicios: _parseToInt(json['total_servicios']),
      serviciosContratados: json['servicios_contratados'] != null
          ? List<String>.from(json['servicios_contratados'])
          : null,
      serviciosUtilizados: json['servicios_utilizados'] != null
          ? List<String>.from(json['servicios_utilizados'])
          : null,
      precioTotalServicios: json['precio_total_servicios']?.toDouble(),
      
      puedeCheckIn: json['puede_check_in'] as bool?,
      tiempoHastaInicio: json['tiempo_hasta_inicio'],
      estadoCheckIn: json['estado_check_in']?.toString(),
      
      tiempoTranscurrido: json['tiempo_transcurrido'],
      sobrepasoHoraFin: json['sobrepaso_hora_fin'] as bool?,
      estadoEvento: json['estado']?.toString(),
      
      duracionReal: json['duracion_real'],
      duracionProgramada: json['duracion_programada'],
    );
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String get estadoTexto {
    switch (estado) {
      case 'A':
        return 'Activa';
      case 'P':
        return 'Pendiente';
      case 'C':
        return 'Cancelada';
      case 'F':
        return 'Finalizada';
      default:
        return 'Desconocido';
    }
  }

  String get fechaDisplay {
    return fecha.isNotEmpty ? fecha : 'N/A';//es una cadena vacía para fechas no definidas
  }

  String get horaIniDisplay {
    return horaIni.isNotEmpty ? horaIni : 'N/A';//es una cadena vacía para horas no definidas
  }

  String get horaFinDisplay {
    return horaFin.isNotEmpty ? horaFin : 'N/A';//es una cadena vacía para horas no definidas
  }

  String get rangoHorario {
    return '$horaIniDisplay - $horaFinDisplay';// es el rango horario completo de la reserva para mostrar
  }
}

class RespuestaEventos {
  final int count;
  final String? fechaActual;
  final String? horaActual;
  final List<ReservaEvento> reservas;

  RespuestaEventos({
    required this.count,
    this.fechaActual,
    this.horaActual,
    required this.reservas,
  });

  factory RespuestaEventos.fromJson(Map<String, dynamic> json) {
    var reservasList = <ReservaEvento>[];
    
    if (json['reservas'] != null) {
      reservasList = (json['reservas'] as List)
          .map((r) => ReservaEvento.fromJson(r as Map<String, dynamic>))
          .toList();
    }
    
    return RespuestaEventos(
      count: json['count'] as int? ?? 0,
      fechaActual: json['fecha_actual']?.toString(),
      horaActual: json['hora_actual']?.toString(),
      reservas: reservasList,
    );
  }
}