import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../models/reserva_hotel_model.dart';
import '../service/hotel_api_service.dart';
//import '../screens/dashboard_screen.dart';

class ReservaHospedajeScreen extends StatefulWidget {
  final Usuario usuario;
  
  const ReservaHospedajeScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  State<ReservaHospedajeScreen> createState() => _ReservaHospedajeScreenState();
}

class _ReservaHospedajeScreenState extends State<ReservaHospedajeScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // 🎨 PALETA DE COLORES AZUL - COHERENTE CON DASHBOARD
  static const Color primaryBlue = Color(0xFF3B82F6);        // Azul principal
 // static const Color secondaryBlue = Color(0xFF60A5FA);      // Azul secundario
  static const Color lightBlue = Color(0xFFDBEAFE);          // Azul claro
  static const Color mediumBlue = Color(0xFFBFDBFE);         // Azul medio
  static const Color darkBlue = Color(0xFF1D4ED8);           // Azul oscuro
  
  // COLORES FUNCIONALES
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF06B6D4);

  List<ReservaHotel> reservasPendientes = [];
  List<ReservaHotel> reservasCheckIn = [];
  List<ReservaHotel> reservasCheckOut = [];
  List<ReservaHotel> reservasCanceladas = [];
  
  bool isLoadingPendientes = false;
  bool isLoadingCheckIn = false;
  bool isLoadingCheckOut = false;
  bool isLoadingCanceladas = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _cargarDatosSegunTab();
      }
    });
    _cargarDatosSegunTab();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _cargarDatosSegunTab() {
    switch (_tabController.index) {
      case 0:
        _cargarReservasPendientes();
        break;
      case 1:
        _cargarReservasCheckIn();
        break;
      case 2:
        _cargarReservasCheckOut();
        break;
      case 3:
        _cargarReservasCanceladas();
        break;
    }
  }

  Future<void> _cargarReservasPendientes() async {
    setState(() => isLoadingPendientes = true);
    try {
      final respuesta = await HotelApiService.obtenerReservasPendientesCheckIn();
      setState(() => reservasPendientes = respuesta.reservas);
    } catch (e) {
      _mostrarError('Error al cargar pendientes: $e');
    } finally {
      setState(() => isLoadingPendientes = false);
    }
  }

  Future<void> _cargarReservasCheckIn() async {
    setState(() => isLoadingCheckIn = true);
    try {
      final respuesta = await HotelApiService.obtenerReservasPendientesCheckOut();
      setState(() => reservasCheckIn = respuesta.reservas);
    } catch (e) {
      _mostrarError('Error al cargar check-in: $e');
    } finally {
      setState(() => isLoadingCheckIn = false);
    }
  }

  Future<void> _cargarReservasCheckOut() async {
    setState(() => isLoadingCheckOut = true);
    try {
      final respuesta = await HotelApiService.obtenerReservasFinalizadas();
      setState(() => reservasCheckOut = respuesta.reservas);
    } catch (e) {
      _mostrarError('Error al cargar finalizadas: $e');
    } finally {
      setState(() => isLoadingCheckOut = false);
    }
  }

  Future<void> _cargarReservasCanceladas() async {
    setState(() => isLoadingCanceladas = true);
    try {
      final respuesta = await HotelApiService.obtenerReservasCanceladas();
      setState(() => reservasCanceladas = respuesta.reservas);
    } catch (e) {
      _mostrarError('Error al cargar canceladas: $e');
    } finally {
      setState(() => isLoadingCanceladas = false);
    }
  }

  Future<void> _realizarCheckIn(int idReserva) async {
    _mostrarLoading();
    final resultado = await HotelApiService.realizarCheckIn(idReserva);
    Navigator.pop(context);
    
    if (resultado['exito']) {
      _mostrarExito(resultado['mensaje']);
      await Future.wait([
        _cargarReservasPendientes(),
        _cargarReservasCheckIn(),
      ]);
    } else {
      _mostrarError(resultado['mensaje']);
    }
  }

  Future<void> _realizarCheckOut(int idReserva) async {
    _mostrarLoading();
    final resultado = await HotelApiService.realizarCheckOut(idReserva);
    Navigator.pop(context);
    
    if (resultado['exito']) {
      _mostrarExito(resultado['mensaje']);
      await Future.wait([
        _cargarReservasCheckIn(),
        _cargarReservasCheckOut(),
      ]);
    } else {
      _mostrarError(resultado['mensaje']);
    }
  }

  Future<void> _cancelarCheckIn(int idReserva) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Deshacer check-in?'),
        content: const Text('La reserva volverá a estado pendiente.'),
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

    _mostrarLoading();
    final resultado = await HotelApiService.cancelarCheckIn(idReserva);
    Navigator.pop(context);
    
    if (resultado['exito']) {
      _mostrarExito(resultado['mensaje']);
      await Future.wait([
        _cargarReservasPendientes(),
        _cargarReservasCheckIn(),
      ]);
    } else {
      _mostrarError(resultado['mensaje']);
    }
  }

  Future<void> _cancelarReserva(int idReserva) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar cancelación'),
        content: const Text('¿Está seguro de cancelar esta reserva? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: errorColor),
            child: const Text('Sí, cancelar reserva'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    _mostrarLoading();
    final resultado = await HotelApiService.eliminarReserva(idReserva);
    Navigator.pop(context);
    
    if (resultado['exito']) {
      _mostrarExito(resultado['mensaje']);
      await Future.wait([
        _cargarReservasPendientes(),
        _cargarReservasCanceladas(),
      ]);
    } else {
      _mostrarError(resultado['mensaje']);
    }
  }

  void _verDetalles(ReservaHotel reserva) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.hotel, color: primaryBlue),
            const SizedBox(width: 8),
            const Text('Detalles de Reserva'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalleItem('ID Reserva', reserva.idReservaHotel.toString()),
              const Divider(),
              _buildDetalleItem('Cliente', reserva.cliente ?? 'N/A'),
              if (reserva.clienteTelefono != null)
                _buildDetalleItem('Teléfono', reserva.clienteTelefono!),
              const Divider(),
              _buildDetalleItem('Habitación', reserva.habitacionTexto),
              _buildDetalleItem('Personas', reserva.cantPersonas.toString()),
              _buildDetalleItem('Check-in', reserva.fechaDisplay),
              _buildDetalleItem('Check-out', reserva.fechaFinDisplay),
              const Divider(),
              if (reserva.checkIn != null)
                _buildDetalleItem('Check-in Realizado', reserva.checkIn!),
              if (reserva.checkOut != null)
                _buildDetalleItem('Check-out Realizado', reserva.checkOut!),
              if (reserva.tiempoHospedado != null)
                _buildDetalleItem('Tiempo Hospedado', reserva.tiempoHospedado!.texto),
              if (reserva.duracionEstadia != null)
                _buildDetalleItem('Duración Estadía', reserva.duracionEstadia!.texto),
              const Divider(),
              _buildDetalleItem('Estado', reserva.estadoTexto),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: primaryBlue),
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

  void _mostrarLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: CircularProgressIndicator(color: primaryBlue),
        ),
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
          'Gestión de Hospedaje',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: primaryBlue,
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
            Tab(text: 'Ingreso', icon: Icon(Icons.login, size: 20)),
            Tab(text: 'Salida', icon: Icon(Icons.logout, size: 20)),
            Tab(text: 'Canceladas', icon: Icon(Icons.cancel, size: 20)),
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
            _buildCanceladasTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _cargarDatosSegunTab();
          _mostrarExito('Datos actualizados manualmente');
        },
        backgroundColor: primaryBlue,
        child: const Icon(Icons.refresh, color: Colors.white),
        tooltip: 'Actualizar datos',
      ),
    );
  }

  // 📋 TAB PENDIENTES
  Widget _buildPendientesTab() {
    if (isLoadingPendientes) {
      return const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(primaryBlue)),
      );
    }

    return Column(
      children: [
        // NOTA INFORMATIVA
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [lightBlue, mediumBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: primaryBlue.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: primaryBlue, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reservas Pendientes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                       'Se están listando todas las reservas programadas para el día de hoy. '
                        'El sistema muestra las reservas que tienen la fecha actual dentro del rango '
                        'de fecha de inicio y fin de la reserva.\n\n'
                        'Puede realizar el check-in cuando el cliente llegue al establecimiento.',
                      style: TextStyle(
                        color: darkBlue.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // LISTA DE RESERVAS
        if (reservasPendientes.isEmpty)
          Expanded(
            child: _buildEmptyState(
              icon: Icons.hotel,
              mensaje: 'No hay reservas pendientes de check-in',
              color: primaryBlue,
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: _cargarReservasPendientes,
              backgroundColor: lightBlue,
              color: primaryBlue,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                itemCount: reservasPendientes.length,
                itemBuilder: (context, index) {
                  final reserva = reservasPendientes[index];
                  return _buildReservaCard(
                    reserva: reserva,
                    color: lightBlue,
                    iconColor: primaryBlue,
                    borderColor: primaryBlue.withOpacity(0.3),
                    mostrarCheckIn: true,
                    mostrarCheckOut: false,
                    mostrarDeshacer: false,
                    mostrarCancelar: true,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  // 🏨 TAB CHECK-IN
  Widget _buildCheckInTab() {
    if (isLoadingCheckIn) {
      return const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(primaryBlue)),
      );
    }

    if (reservasCheckIn.isEmpty) {
      return _buildEmptyState(
        icon: Icons.hotel,
        mensaje: 'No hay reservas en curso',
        color: primaryBlue,
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarReservasCheckIn,
      backgroundColor: lightBlue,
      color: primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: reservasCheckIn.length,
        itemBuilder: (context, index) {
          final reserva = reservasCheckIn[index];
          return _buildReservaCard(
            reserva: reserva,
            color: Color(0xFFE0E7FF),
            iconColor: infoColor,
            borderColor: infoColor.withOpacity(0.3),
            mostrarCheckIn: false,
            mostrarCheckOut: true,
            mostrarDeshacer: true,
            mostrarCancelar: false,
          );
        },
      ),
    );
  }

  // ✅ TAB CHECK-OUT
  Widget _buildCheckOutTab() {
    if (isLoadingCheckOut) {
      return const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(primaryBlue)),
      );
    }

    if (reservasCheckOut.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        mensaje: 'No hay reservas finalizadas',
        color: primaryBlue,
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarReservasCheckOut,
      backgroundColor: lightBlue,
      color: primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: reservasCheckOut.length,
        itemBuilder: (context, index) {
          final reserva = reservasCheckOut[index];
          return _buildReservaCard(
            reserva: reserva,
            color: Color(0xFFD1FAE5),
            iconColor: successColor,
            borderColor: successColor.withOpacity(0.3),
            mostrarCheckIn: false,
            mostrarCheckOut: false,
            mostrarDeshacer: false,
            mostrarCancelar: false,
          );
        },
      ),
    );
  }

  // ❌ TAB CANCELADAS
  Widget _buildCanceladasTab() {
    if (isLoadingCanceladas) {
      return const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(primaryBlue)),
      );
    }

    if (reservasCanceladas.isEmpty) {
      return _buildEmptyState(
        icon: Icons.hotel,
        mensaje: 'No hay reservas canceladas',
        color: primaryBlue,
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarReservasCanceladas,
      backgroundColor: lightBlue,
      color: primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: reservasCanceladas.length,
        itemBuilder: (context, index) {
          final reserva = reservasCanceladas[index];
          return _buildReservaCard(
            reserva: reserva,
            color: Color(0xFFFEE2E2),
            iconColor: errorColor,
            borderColor: errorColor.withOpacity(0.3),
            mostrarCheckIn: false,
            mostrarCheckOut: false,
            mostrarDeshacer: false,
            mostrarCancelar: false,
          );
        },
      ),
    );
  }

  // 🎴 CARD DE RESERVA (ESTILO SIMILAR A EVENTOS)
  Widget _buildReservaCard({
    required ReservaHotel reserva,
    required Color color,
    required Color iconColor,
    required Color borderColor,
    required bool mostrarCheckIn,
    required bool mostrarCheckOut,
    required bool mostrarDeshacer,
    required bool mostrarCancelar,
  }) {
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
                  child: Icon(Icons.hotel, color: iconColor, size: 24),
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
                              reserva.cliente ?? 'Cliente Desconocido',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: darkBlue,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildEstadoChip(reserva),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.meeting_room, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            reserva.habitacionTexto,
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
                            '${reserva.cantPersonas}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${reserva.fechaDisplay} - ${reserva.fechaFinDisplay}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (reserva.tiempoHospedado != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '⏱️ ${reserva.tiempoHospedado!.texto}',
                          style: TextStyle(
                            color: infoColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (reserva.duracionEstadia != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '🏨 ${reserva.duracionEstadia!.texto}',
                          style: TextStyle(
                            color: successColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove_red_eye, color: primaryBlue),
                  onPressed: () => _verDetalles(reserva),
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
                  if (mostrarCheckIn) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _realizarCheckIn(reserva.idReservaHotel),
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
                  if (mostrarCheckOut) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _realizarCheckOut(reserva.idReservaHotel),
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
                  if (mostrarDeshacer) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _cancelarCheckIn(reserva.idReservaHotel),
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
                        onPressed: () => _cancelarReserva(reserva.idReservaHotel),
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

  // 📭 ESTADO VACÍO
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

  // 🏷️ CHIP DE ESTADO
  Widget _buildEstadoChip(ReservaHotel reserva) {
    Color backgroundColor;
    Color textColor;
    String texto;
    
    if (reserva.checkOut != null) {
      backgroundColor = successColor.withOpacity(0.15);
      textColor = successColor;
      texto = 'Finalizado';
    } else if (reserva.checkIn != null) {
      backgroundColor = infoColor.withOpacity(0.15);
      textColor = infoColor;
      texto = 'En Curso';
    } else if (reserva.estado == 'C') {
      backgroundColor = errorColor.withOpacity(0.15);
      textColor = errorColor;
      texto = 'Cancelado';
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