import 'package:flutter/material.dart';
import '../../models/Usuarios/usuario_model.dart';
import '../../models/Eventos/reserva_evento_model.dart';
import '../../service/Eventos/evento_api_service.dart';
import 'dart:async';

class ReservaEventosScreen extends StatefulWidget {
  final Usuario usuario;
  
  const ReservaEventosScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  State<ReservaEventosScreen> createState() => _ReservaEventosScreenState();
}

class _ReservaEventosScreenState extends State<ReservaEventosScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // ⚙️ CONFIGURACIÓN: Minutos de anticipación para habilitar el botón
  static const int MINUTOS_ANTICIPACION = 5;
  
  // 🎨 PALETA DE COLORES LILA/MORADO - COHERENTE CON DASHBOARD
  static const Color primaryLavender = Color(0xFF8B5CF6);    // Lavanda principal
 // static const Color secondaryLavender = Color(0xFFA78BFA);  // Lavanda secundario
 //static const Color softPink = Color(0xFFEC4899);           // Rosa suave
  static const Color lightLavender = Color(0xFFEDE9FE);      // Lavanda claro
  static const Color mediumLavender = Color(0xFFDDD6FE);     // Lavanda medio
  static const Color darkLavender = Color(0xFF7C3AED);       // Lavanda oscuro
  
  // COLORES FUNCIONALES CON TONO LILA
  static const Color successColor = Color(0xFF10B981);       // Verde éxito
  static const Color warningColor = Color(0xFFF59E0B);       // Naranja advertencia
  static const Color errorColor = Color(0xFFEF4444);         // Rojo error
  static const Color infoColor = Color(0xFF3B82F6);          // Azul información
  
  List<ReservaEvento> eventosPendientes = [];
  List<ReservaEvento> eventosCheckIn = [];
  List<ReservaEvento> eventosCheckOut = [];
  List<ReservaEvento> eventosCancelados = [];
  
  bool isLoadingPendientes = false;
  bool isLoadingCheckIn = false;
  bool isLoadingCheckOut = false;
  bool isLoadingCancelados = false;

  // 🆕 TIMER PARA ACTUALIZACIÓN EN TIEMPO REAL
  Timer? _timer;
  static const Duration INTERVALO_ACTUALIZACION = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _cargarDatosSegunTab();
      }
    });
    
    _iniciarActualizacionTiempoReal();
    _cargarDatosSegunTab();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _iniciarActualizacionTiempoReal() {
    _timer = Timer.periodic(INTERVALO_ACTUALIZACION, (timer) {
      if (mounted) {
        print('🔄 Actualización automática en tiempo real...');
        _actualizarDatosAutomaticamente();
      }
    });
  }

  void _actualizarDatosAutomaticamente() {
    if (!isLoadingPendientes && _tabController.index == 0) {
      _cargarEventosPendientes(silent: true);
    }
    if (!isLoadingCheckIn && _tabController.index == 1) {
      _cargarEventosCheckIn(silent: true);
    }
  }

  void _cargarDatosSegunTab() {
    switch (_tabController.index) {
      case 0:
        _cargarEventosPendientes();
        break;
      case 1:
        _cargarEventosCheckIn();
        break;
      case 2:
        _cargarEventosCheckOut();
        break;
      case 3:
        _cargarEventosCancelados();
        break;
    }
  }

  // 📋 CARGAR EVENTOS PENDIENTES
  Future<void> _cargarEventosPendientes({bool silent = false}) async {
    if (!silent) setState(() => isLoadingPendientes = true);
    
    try {
      final respuesta = await EventoApiService.obtenerEventosPendientesCheckIn();
      if (mounted) {
        setState(() {
          eventosPendientes = respuesta.reservas;
        });
      }
    } catch (e) {
      if (!silent) {
        _mostrarError('Error al cargar eventos pendientes: $e');
      }
    } finally {
      if (mounted && !silent) {
        setState(() => isLoadingPendientes = false);
      }
    }
  }

  // 🎉 CARGAR EVENTOS EN CHECK-IN
  Future<void> _cargarEventosCheckIn({bool silent = false}) async {
    if (!silent) setState(() => isLoadingCheckIn = true);
    
    try {
      final respuesta = await EventoApiService.obtenerEventosPendientesCheckOut();
      if (mounted) {
        setState(() {
          eventosCheckIn = respuesta.reservas;
        });
      }
    } catch (e) {
      if (!silent) {
        _mostrarError('Error al cargar eventos en check-in: $e');
      }
    } finally {
      if (mounted && !silent) {
        setState(() => isLoadingCheckIn = false);
      }
    }
  }

  // ✅ CARGAR EVENTOS FINALIZADOS
  Future<void> _cargarEventosCheckOut({bool silent = false}) async {
    if (!silent) setState(() => isLoadingCheckOut = true);
    
    try {
      final eventos = await EventoApiService.obtenerEventosFinalizados();
      if (mounted) {
        setState(() {
          eventosCheckOut = eventos;
        });
      }
    } catch (e) {
      if (!silent) {
        _mostrarError('Error al cargar eventos finalizados: $e');
      }
    } finally {
      if (mounted && !silent) {
        setState(() => isLoadingCheckOut = false);
      }
    }
  }

  // ❌ CARGAR EVENTOS CANCELADOS
  Future<void> _cargarEventosCancelados({bool silent = false}) async {
    if (!silent) setState(() => isLoadingCancelados = true);
    
    try {
      final eventos = await EventoApiService.obtenerEventosCancelados();
      if (mounted) {
        setState(() {
          eventosCancelados = eventos;
        });
      }
    } catch (e) {
      if (!silent) {
        _mostrarError('Error al cargar eventos cancelados: $e');
      }
    } finally {
      if (mounted && !silent) {
        setState(() => isLoadingCancelados = false);
      }
    }
  }

  void _verificarCambiosEnTiempoReal() {
    if (mounted) {
      setState(() {});
    }
  }

  // 🆕 FUNCIÓN PARA AJUSTAR HORA DESDE BD (UTC a Bolivia: -4 horas)
  String _ajustarHoraDesdeBD(String horaBD) {
    try {
      final partes = horaBD.split(':');
      if (partes.length != 2) return horaBD;
      
      int horas = int.tryParse(partes[0]) ?? 0;
      int minutos = int.tryParse(partes[1]) ?? 0;
      
      horas = horas - 4;
      
      if (horas < 0) {
        horas = 24 + horas;
      }
      
      return '${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}';
      
    } catch (e) {
      return horaBD;
    }
  }

  // ✅ VALIDAR SI PUEDE HACER CHECK-IN (LOCAL) - CON AJUSTE UTC
  bool _puedeHacerCheckIn(ReservaEvento evento) {
    try {
      if (evento.checkIn != null || evento.estado == 'C') {
        return false;
      }

      final ahora = DateTime.now();
      
      final horaIniAjustada = _ajustarHoraDesdeBD(evento.horaIni);
      final horaFinAjustada = _ajustarHoraDesdeBD(evento.horaFin);
      
      final horasParts = horaIniAjustada.split(':');
      if (horasParts.length != 2) return false;
      
      final horasInicio = int.tryParse(horasParts[0]) ?? 0;
      final minutosInicio = int.tryParse(horasParts[1]) ?? 0;
      
      final horasFinParts = horaFinAjustada.split(':');
      if (horasFinParts.length != 2) return false;
      
      final horasFin = int.tryParse(horasFinParts[0]) ?? 0;
      final minutosFin = int.tryParse(horasFinParts[1]) ?? 0;
      
      final horaEventoInicio = DateTime(
        ahora.year,
        ahora.month,
        ahora.day,
        horasInicio,
        minutosInicio,
      );
      
      final horaEventoFin = DateTime(
        ahora.year,
        ahora.month,
        ahora.day + (horasFin == 0 ? 1 : 0),
        horasFin,
        minutosFin,
      );
      
      final horaMinima = horaEventoInicio.subtract(Duration(minutes: MINUTOS_ANTICIPACION));
      
      final puede = ahora.isAfter(horaMinima) && ahora.isBefore(horaEventoFin);
      
      return puede;
      
    } catch (e) {
      return false;
    }
  }

  // 🆕 DETECTAR SI LA RESERVA DEBERÍA CANCELARSE - CON AJUSTE UTC
  bool _debeCancelarsePorNoAsistencia(ReservaEvento evento) {
    try {
      final ahora = DateTime.now();
      
      final horaFinAjustada = _ajustarHoraDesdeBD(evento.horaFin);
      
      final horasFinParts = horaFinAjustada.split(':');
      if (horasFinParts.length != 2) return false;
      
      final horasFin = int.tryParse(horasFinParts[0]) ?? 0;
      final minutosFin = int.tryParse(horasFinParts[1]) ?? 0;
      
      final horaEventoFin = DateTime(
        ahora.year,
        ahora.month,
        ahora.day + (horasFin == 0 ? 1 : 0),
        horasFin,
        minutosFin,
      );
      
      final debeCancelarse = ahora.isAfter(horaEventoFin) && evento.checkIn == null;
      
      return debeCancelarse;
      
    } catch (e) {
      return false;
    }
  }

  // ⏰ CALCULAR TIEMPO HASTA QUE ESTÉ DISPONIBLE - CON AJUSTE UTC
  String _calcularTiempoRestante(ReservaEvento evento) {
    try {
      final ahora = DateTime.now();
      
      final horaIniAjustada = _ajustarHoraDesdeBD(evento.horaIni);
      
      final horasParts = horaIniAjustada.split(':');
      if (horasParts.length != 2) return 'No disponible';
      
      final horasInicio = int.tryParse(horasParts[0]) ?? 0;
      final minutosInicio = int.tryParse(horasParts[1]) ?? 0;
      
      final horaEvento = DateTime(
        ahora.year,
        ahora.month,
        ahora.day,
        horasInicio,
        minutosInicio,
      );
      
      final horaMinima = horaEvento.subtract(Duration(minutes: MINUTOS_ANTICIPACION));
      
      if (ahora.isAfter(horaMinima)) {
        return 'Disponible ahora';
      }
      
      final diferencia = horaMinima.difference(ahora);
      final horas = diferencia.inHours;
      final minutos = diferencia.inMinutes.remainder(60);
      
      if (horas > 0) {
        return '$horas h $minutos min';
      } else {
        return '$minutos min';
      }
      
    } catch (e) {
      return 'N/A';
    }
  }

  // 🕐 OBTENER HORA DISPONIBLE - CON AJUSTE UTC
  String _obtenerHoraDisponible(ReservaEvento evento) {
    try {
      final horaIniAjustada = _ajustarHoraDesdeBD(evento.horaIni);
      
      final horasParts = horaIniAjustada.split(':');
      if (horasParts.length != 2) return 'N/A';
      
      final horasInicio = int.tryParse(horasParts[0]) ?? 0;
      final minutosInicio = int.tryParse(horasParts[1]) ?? 0;
      
      final ahora = DateTime.now();
      final horaEvento = DateTime(
        ahora.year,
        ahora.month,
        ahora.day,
        horasInicio,
        minutosInicio,
      );
      
      final horaMinima = horaEvento.subtract(Duration(minutes: MINUTOS_ANTICIPACION));
      
      final horaFormateada = '${horaMinima.hour.toString().padLeft(2, '0')}:${horaMinima.minute.toString().padLeft(2, '0')}';
      
      return horaFormateada;
      
    } catch (e) {
      return 'N/A';
    }
  }

  Future<void> _realizarCheckIn(int idReserva) async {
    final resultado = await EventoApiService.realizarCheckIn(idReserva);
    
    if (resultado['exito']) {
      _mostrarExito(resultado['mensaje']);
      await Future.wait([
        _cargarEventosPendientes(silent: true),
        _cargarEventosCheckIn(silent: true),
      ]);
      _verificarCambiosEnTiempoReal();
    } else {
      _mostrarError(resultado['mensaje']);
    }
  }

  Future<void> _realizarCheckOut(int idReserva) async {
    final resultado = await EventoApiService.realizarCheckOut(idReserva);
    
    if (resultado['exito']) {
      _mostrarExito(resultado['mensaje']);
      await Future.wait([
        _cargarEventosCheckIn(silent: true),
        _cargarEventosCheckOut(silent: true),
      ]);
      _verificarCambiosEnTiempoReal();
    } else {
      _mostrarError(resultado['mensaje']);
    }
  }

  Future<void> _deshacerCheckIn(int idReserva) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Deshacer check-in?'),
        content: const Text('El evento volverá a estado pendiente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: warningColor),
            child: const Text('Sí, deshacer'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final resultado = await EventoApiService.cancelarCheckIn(idReserva);
    
    if (resultado['exito']) {
      _mostrarExito(resultado['mensaje']);
      await Future.wait([
        _cargarEventosPendientes(silent: true),
        _cargarEventosCheckIn(silent: true),
      ]);
      _verificarCambiosEnTiempoReal();
    } else {
      _mostrarError(resultado['mensaje']);
    }
  }

  Future<void> _cancelarEvento(int idReserva) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar cancelación'),
        content: const Text('¿Está seguro de cancelar este evento? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: errorColor),
            child: const Text('Sí, cancelar evento'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final resultado = await EventoApiService.cancelarEvento(idReserva);
    
    if (resultado['exito']) {
      _mostrarExito(resultado['mensaje']);
      await Future.wait([
        _cargarEventosPendientes(silent: true),
        _cargarEventosCheckIn(silent: true),
        _cargarEventosCancelados(silent: true),
      ]);
      _verificarCambiosEnTiempoReal();
    } else {
      _mostrarError(resultado['mensaje']);
    }
  }

  void _verDetalles(ReservaEvento evento) {
    final debeCancelarse = _debeCancelarsePorNoAsistencia(evento);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.event, color: primaryLavender),
            const SizedBox(width: 8),
            const Text('Detalles del Evento'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalleItem('ID Evento', evento.idReservasEvento.toString()),
              const Divider(),
              _buildDetalleItem('Cliente', evento.cliente ?? 'N/A'),
              if (evento.clienteTelefono != null)
                _buildDetalleItem('Teléfono', evento.clienteTelefono!),
              const Divider(),
              _buildDetalleItem('Fecha', evento.fechaDisplay),
              //_buildDetalleItem('Hora Inicio BD', '${evento.horaIni} (UTC)'),
             // _buildDetalleItem('Hora Fin BD', '${evento.horaFin} (UTC)'),
              _buildDetalleItem('Hora Inicio ', _ajustarHoraDesdeBD(evento.horaIni)),
              _buildDetalleItem('Hora Fin ', _ajustarHoraDesdeBD(evento.horaFin)),
              _buildDetalleItem('Personas', evento.cantPersonas.toString()),
              _buildDetalleItem('Servicios', evento.totalServicios.toString()),
              
              if (debeCancelarse) ...[
                const Divider(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: errorColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: errorColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'No Asistencia Detectada',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: errorColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'El cliente no realizó check-in antes de la hora de fin. '
                        'Esta reserva deberá marcarse como cancelada con motivo: '
                        '"Cliente no asistió a la reserva".',
                        style: TextStyle(
                          color: errorColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const Divider(),
              if (evento.checkIn != null)
                _buildDetalleItem('Check-in', evento.checkIn!),
              if (evento.checkOut != null)
                _buildDetalleItem('Check-out', evento.checkOut!),
              if (evento.tiempoTranscurrido != null)
                _buildDetalleItem('Tiempo transcurrido', evento.tiempoTranscurrido!['texto'] ?? ''),
              if (evento.duracionReal != null)
                _buildDetalleItem('Duración real', evento.duracionReal!['texto'] ?? ''),
              const Divider(),
              _buildDetalleItem('Estado', evento.estadoTexto),
              if (evento.serviciosContratados != null && evento.serviciosContratados!.isNotEmpty) ...[
                const Divider(),
                const Text(
                  'Servicios:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                ...evento.serviciosContratados!.map((s) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Text('• $s', style: const TextStyle(fontSize: 13)),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: primaryLavender),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarExito(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Eventos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: primaryLavender,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Pendientes', icon: Icon(Icons.pending_actions, size: 20)),
            Tab(text: 'Ingreso', icon: Icon(Icons.event_available, size: 20)),
            Tab(text: 'Salida', icon: Icon(Icons.event_busy, size: 20)),
            Tab(text: 'Cancelados', icon: Icon(Icons.cancel, size: 20)),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFF1F5F9),
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPendientesTab(),
            _buildCheckInTab(),
            _buildCheckOutTab(),
            _buildCanceladosTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _cargarDatosSegunTab();
          _mostrarExito('Datos actualizados manualmente');
        },
        backgroundColor: primaryLavender,
        child: const Icon(Icons.refresh, color: Colors.white),
        tooltip: 'Actualizar datos',
      ),
    );
  }

  // 📋 TAB PENDIENTES
  Widget _buildPendientesTab() {
    if (isLoadingPendientes) {
      return const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(primaryLavender)),
      );
    }

    return Column(
      children: [
        // NOTA INFORMATIVA CON COLORES LILA
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [lightLavender, mediumLavender],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryLavender.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: primaryLavender.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: primaryLavender, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reservas de Hoy',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: darkLavender,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'El botón de Check-In se habilitará $MINUTOS_ANTICIPACION minutos antes de la hora de inicio '
                      'y estará disponible hasta la hora de fin del evento.',
                      style: TextStyle(
                        color: darkLavender.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // LISTA DE EVENTOS
        if (eventosPendientes.isEmpty)
          Expanded(
            child: _buildEmptyState(
              icon: Icons.event_available,
              mensaje: 'No hay eventos pendientes de check-in para hoy',
              color: primaryLavender,
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: _cargarEventosPendientes,
              backgroundColor: lightLavender,
              color: primaryLavender,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                itemCount: eventosPendientes.length,
                itemBuilder: (context, index) {
                  final evento = eventosPendientes[index];
                  final puedeCheckIn = _puedeHacerCheckIn(evento);
                  final debeCancelarse = _debeCancelarsePorNoAsistencia(evento);
                  
                  return _buildEventoCard(
                    evento: evento,
                    color: lightLavender,
                    iconColor: primaryLavender,
                    borderColor: primaryLavender.withOpacity(0.3),
                    mostrarCheckIn: puedeCheckIn,
                    mostrarCheckOut: false,
                    mostrarDeshacer: false,
                    mostrarCancelar: true,
                    debeCancelarse: debeCancelarse,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  // 🎉 TAB CHECK-IN
  Widget _buildCheckInTab() {
    if (isLoadingCheckIn) {
      return const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(primaryLavender)),
      );
    }

    if (eventosCheckIn.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event,
        mensaje: 'No hay eventos en curso',
        color: primaryLavender,
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarEventosCheckIn,
      backgroundColor: lightLavender,
      color: primaryLavender,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: eventosCheckIn.length,
        itemBuilder: (context, index) {
          final evento = eventosCheckIn[index];
          return _buildEventoCard(
            evento: evento,
            color: Color(0xFFE0E7FF), // Azul lavanda claro
            iconColor: infoColor,
            borderColor: infoColor.withOpacity(0.3),
            mostrarCheckIn: false,
            mostrarCheckOut: true,
            mostrarDeshacer: true,
            mostrarCancelar: false,
            debeCancelarse: false,
          );
        },
      ),
    );
  }

  // ✅ TAB CHECK-OUT
  Widget _buildCheckOutTab() {
    if (isLoadingCheckOut) {
      return const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(primaryLavender)),
      );
    }

    if (eventosCheckOut.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        mensaje: 'No hay eventos finalizados',
        color: primaryLavender,
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarEventosCheckOut,
      backgroundColor: lightLavender,
      color: primaryLavender,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: eventosCheckOut.length,
        itemBuilder: (context, index) {
          final evento = eventosCheckOut[index];
          return _buildEventoCard(
            evento: evento,
            color: Color(0xFFD1FAE5), // Verde claro suave
            iconColor: successColor,
            borderColor: successColor.withOpacity(0.3),
            mostrarCheckIn: false,
            mostrarCheckOut: false,
            mostrarDeshacer: false,
            mostrarCancelar: false,
            debeCancelarse: false,
          );
        },
      ),
    );
  }

  // ❌ TAB CANCELADOS
  Widget _buildCanceladosTab() {
    if (isLoadingCancelados) {
      return const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(primaryLavender)),
      );
    }

    if (eventosCancelados.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_busy,
        mensaje: 'No hay eventos cancelados',
        color: primaryLavender,
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarEventosCancelados,
      backgroundColor: lightLavender,
      color: primaryLavender,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: eventosCancelados.length,
        itemBuilder: (context, index) {
          final evento = eventosCancelados[index];
          return _buildEventoCard(
            evento: evento,
            color: Color(0xFFFEE2E2), // Rojo claro suave
            iconColor: errorColor,
            borderColor: errorColor.withOpacity(0.3),
            mostrarCheckIn: false,
            mostrarCheckOut: false,
            mostrarDeshacer: false,
            mostrarCancelar: false,
            debeCancelarse: false,
          );
        },
      ),
    );
  }

  // 🎴 CARD DE EVENTO MEJORADO
  Widget _buildEventoCard({
    required ReservaEvento evento,
    required Color color,
    required Color iconColor,
    required Color borderColor,
    required bool mostrarCheckIn,
    required bool mostrarCheckOut,
    required bool mostrarDeshacer,
    required bool mostrarCancelar,
    required bool debeCancelarse,
  }) {
    final horaIniAjustada = _ajustarHoraDesdeBD(evento.horaIni);
    final horaFinAjustada = _ajustarHoraDesdeBD(evento.horaFin);
    final rangoHorarioAjustado = '$horaIniAjustada - $horaFinAjustada';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: color,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: iconColor.withOpacity(0.3)),
                  ),
                  child: Icon(Icons.event, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              evento.cliente ?? 'Cliente Desconocido',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: darkLavender,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildEstadoChip(evento, mostrarCheckIn, mostrarCheckOut, debeCancelarse),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            rangoHorarioAjustado,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.people, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${evento.cantPersonas}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (evento.tiempoTranscurrido != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '⏱️ ${evento.tiempoTranscurrido!['texto']}',
                          style: TextStyle(
                            color: infoColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (debeCancelarse) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: errorColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning, size: 12, color: errorColor),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'No se realizó check-in - Pasará a cancelados',
                                  style: TextStyle(
                                    color: errorColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (!mostrarCheckIn && evento.checkIn == null && evento.estado != 'C' && !debeCancelarse) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: warningColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: warningColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule, size: 12, color: warningColor),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Check-in desde las ${_obtenerHoraDisponible(evento)} (en ${_calcularTiempoRestante(evento)})',
                                  style: TextStyle(
                                    color: warningColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove_red_eye, color: primaryLavender),
                  onPressed: () => _verDetalles(evento),
                  tooltip: 'Ver detalles',
                ),
              ],
            ),
            if (mostrarCheckIn || mostrarCheckOut || mostrarDeshacer || mostrarCancelar) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Colors.grey),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // estos botones dependen del estado del evento
                  if (mostrarCheckIn) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _realizarCheckIn(evento.idReservasEvento),
                        icon: const Icon(Icons.login, size: 18),
                        label: const Text('Ingreso'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: successColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    if (mostrarCancelar) const SizedBox(width: 8),
                  ],
                  // este botón aparece si no se puede hacer check-in aún
                  if (!mostrarCheckIn && evento.checkIn == null && evento.estado != 'C' && !debeCancelarse) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.lock_clock, size: 18),
                        label: const Text('Ingreso'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.grey.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    if (mostrarCancelar) const SizedBox(width: 8),
                  ],
                  if (mostrarCheckOut) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _realizarCheckOut(evento.idReservasEvento),
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('Salida'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: infoColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    if (mostrarDeshacer) const SizedBox(width: 8),
                  ],
                  // este botón solo aparece si ya se hizo check-in
                  if (mostrarDeshacer) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deshacerCheckIn(evento.idReservasEvento),
                        icon: const Icon(Icons.undo, size: 18),
                        label: const Text('Deshacer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: warningColor,
                          side: BorderSide(color: warningColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (mostrarCancelar) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _cancelarEvento(evento.idReservasEvento),
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Cancelar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: errorColor,
                          side: BorderSide(color: errorColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 📭 ESTADO VACÍO MEJORADO
  Widget _buildEmptyState({required IconData icon, required String mensaje, required Color color}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Icon(icon, size: 60, color: color),
          ),
          const SizedBox(height: 20),
          Text(
            mensaje,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 🏷️ CHIP DE ESTADO MEJORADO
  Widget _buildEstadoChip(ReservaEvento evento, bool esCheckIn, bool esCheckOut, bool debeCancelarse) {
    Color backgroundColor;
    Color textColor;
    String texto;
    
    if (debeCancelarse) {
      backgroundColor = errorColor.withOpacity(0.15);
      textColor = errorColor;
      texto = 'No Asistió';
    } else if (evento.checkOut != null) {
      backgroundColor = successColor.withOpacity(0.15);
      textColor = successColor;
      texto = 'Finalizado';
    } else if (evento.checkIn != null) {
      backgroundColor = infoColor.withOpacity(0.15);
      textColor = infoColor;
      texto = 'En Curso';
    } else if (evento.estado == 'C') {
      backgroundColor = errorColor.withOpacity(0.15);
      textColor = errorColor;
      texto = 'Cancelado';
    } else if (!_puedeHacerCheckIn(evento)) {
      backgroundColor = Colors.grey.withOpacity(0.15);
      textColor = Colors.grey.shade700;
      texto = 'No disponible';
    } else {
      backgroundColor = warningColor.withOpacity(0.15);
      textColor = warningColor;
      texto = 'Pendiente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.4), width: 1),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}