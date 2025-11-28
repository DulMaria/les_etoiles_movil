import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../models/reserva_hotel_model.dart';
import '../service/hotel_api_service.dart';

class ReservaHospedajeScreen extends StatefulWidget {
  final Usuario usuario;
  
  const ReservaHospedajeScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  State<ReservaHospedajeScreen> createState() => _ReservaHospedajeScreenState();
}

class _ReservaHospedajeScreenState extends State<ReservaHospedajeScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
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

  // 📋 CARGAR RESERVAS PENDIENTES
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

  // 🏨 CARGAR RESERVAS EN CHECK-IN
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

  // ✅ CARGAR RESERVAS FINALIZADAS
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

  // ❌ CARGAR RESERVAS CANCELADAS
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

  // ✅ REALIZAR CHECK-IN
  Future<void> _realizarCheckIn(int idReserva) async {
    _mostrarLoading();
    final resultado = await HotelApiService.realizarCheckIn(idReserva);
    Navigator.pop(context);
    
    if (resultado['exito']) {
      _mostrarExito(resultado['mensaje']);
      _cargarReservasPendientes();
    } else {
      _mostrarError(resultado['mensaje']);
    }
  }

  // 🚪 REALIZAR CHECK-OUT
  Future<void> _realizarCheckOut(int idReserva) async {
    _mostrarLoading();
    final resultado = await HotelApiService.realizarCheckOut(idReserva);
    Navigator.pop(context);
    
    if (resultado['exito']) {
      _mostrarExito(resultado['mensaje']);
      _cargarReservasCheckIn();
    } else {
      _mostrarError(resultado['mensaje']);
    }
  }

  // ❌ CANCELAR CHECK-IN
  Future<void> _cancelarCheckIn(int idReserva) async {
    final confirmar = await _mostrarDialogoConfirmacion(
      titulo: 'Cancelar Check-In',
      mensaje: '¿Cancelar el check-in? La reserva volverá a pendiente.',
      textoBoton: 'Sí, cancelar',
    );

    if (confirmar != true) return;

    _mostrarLoading();
    final resultado = await HotelApiService.cancelarCheckIn(idReserva);
    Navigator.pop(context);
    
    if (resultado['exito']) {
      _mostrarExito(resultado['mensaje']);
      _cargarReservasCheckIn();
      _cargarReservasPendientes();
    } else {
      _mostrarError(resultado['mensaje']);
    }
  }

  // ❌ CANCELAR RESERVA COMPLETA
  Future<void> _cancelarReserva(int idReserva) async {
    final confirmar = await _mostrarDialogoConfirmacion(
      titulo: 'Cancelar Reserva',
      mensaje: '¿Cancelar esta reserva?\n\nEsta acción no se puede deshacer.',
      textoBoton: 'Sí, cancelar reserva',
      colorPeligro: true,
    );

    if (confirmar != true) return;

    _mostrarLoading();
    final resultado = await HotelApiService.eliminarReserva(idReserva);
    Navigator.pop(context);
    
    if (resultado['exito']) {
      _mostrarExito(resultado['mensaje']);
      _cargarReservasPendientes();
    } else {
      _mostrarError(resultado['mensaje']);
    }
  }

  // 👁️ VER DETALLES
  void _verDetalles(ReservaHotel reserva) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            const Text('Detalles de Reserva'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalle('ID', reserva.idReservaHotel.toString()),
              const Divider(),
              _buildDetalle('Cliente', reserva.cliente ?? 'N/A'),
              if (reserva.clienteTelefono != null)
                _buildDetalle('Teléfono', reserva.clienteTelefono!),
              const Divider(),
              _buildDetalle('Habitación', reserva.habitacionTexto),
              _buildDetalle('Personas', reserva.cantPersonas.toString()),
              _buildDetalle('Inicio', reserva.fechaDisplay),
              _buildDetalle('Fin', reserva.fechaFinDisplay),
              const Divider(),
              if (reserva.checkIn != null)
                _buildDetalle('Check-in', reserva.checkIn!),
              if (reserva.checkOut != null)
                _buildDetalle('Check-out', reserva.checkOut!),
              if (reserva.tiempoHospedado != null)
                _buildDetalle('Duración', reserva.tiempoHospedado!.texto),
              if (reserva.duracionEstadia != null)
                _buildDetalle('Estadía', reserva.duracionEstadia!.texto),
              const Divider(),
              _buildDetalle('Estado', reserva.estadoTexto),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalle(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Future<bool?> _mostrarDialogoConfirmacion({
    required String titulo,
    required String mensaje,
    required String textoBoton,
    bool colorPeligro = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorPeligro ? Colors.red : Colors.blue,
            ),
            child: Text(textoBoton),
          ),
        ],
      ),
    );
  }

  void _mostrarLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarExito(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Hospedaje'),
        backgroundColor: const Color(0xFF00BCD4),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          isScrollable: true,
          tabs: const [
            Tab(text: 'Pendientes', icon: Icon(Icons.pending_actions, size: 20)),
            Tab(text: 'Check In', icon: Icon(Icons.login, size: 20)),
            Tab(text: 'Check Out', icon: Icon(Icons.logout, size: 20)),
            Tab(text: 'Canceladas', icon: Icon(Icons.cancel, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendientesTab(),
          _buildCheckInTab(),
          _buildCheckOutTab(),
          _buildCanceladasTab(),
        ],
      ),
    );
  }

  // 📋 TAB PENDIENTES
  Widget _buildPendientesTab() {
    if (isLoadingPendientes) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reservasPendientes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_available,
        mensaje: 'No hay reservas pendientes',
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarReservasPendientes,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: reservasPendientes.length,
        itemBuilder: (context, index) {
          final reserva = reservasPendientes[index];
          return _buildReservaCard(
            reserva: reserva,
            color: Colors.orange.shade50,
            iconColor: Colors.orange.shade700,
            borderColor: Colors.orange.shade300,
            acciones: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _realizarCheckIn(reserva.idReservaHotel),
                  icon: const Icon(Icons.login, size: 18),
                  label: const Text('Check In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _cancelarReserva(reserva.idReservaHotel),
                  icon: const Icon(Icons.cancel, size: 18),
                  label: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 🏨 TAB CHECK-IN
  Widget _buildCheckInTab() {
    if (isLoadingCheckIn) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reservasCheckIn.isEmpty) {
      return _buildEmptyState(
        icon: Icons.hotel,
        mensaje: 'No hay reservas en curso',
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarReservasCheckIn,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: reservasCheckIn.length,
        itemBuilder: (context, index) {
          final reserva = reservasCheckIn[index];
          return _buildReservaCard(
            reserva: reserva,
            color: Colors.blue.shade50,
            iconColor: Colors.blue.shade700,
            borderColor: Colors.blue.shade300,
            acciones: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _realizarCheckOut(reserva.idReservaHotel),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Check Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _cancelarCheckIn(reserva.idReservaHotel),
                  icon: const Icon(Icons.undo, size: 18),
                  label: const Text('Deshacer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ✅ TAB CHECK-OUT
  Widget _buildCheckOutTab() {
    if (isLoadingCheckOut) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reservasCheckOut.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        mensaje: 'No hay reservas finalizadas',
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarReservasCheckOut,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: reservasCheckOut.length,
        itemBuilder: (context, index) {
          final reserva = reservasCheckOut[index];
          return _buildReservaCard(
            reserva: reserva,
            color: Colors.green.shade50,
            iconColor: Colors.green.shade700,
            borderColor: Colors.green.shade300,
            acciones: [],
          );
        },
      ),
    );
  }

  // ❌ TAB CANCELADAS
  Widget _buildCanceladasTab() {
    if (isLoadingCanceladas) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reservasCanceladas.isEmpty) {
      return _buildEmptyState(
        icon: Icons.cancel_outlined,
        mensaje: 'No hay reservas canceladas',
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarReservasCanceladas,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: reservasCanceladas.length,
        itemBuilder: (context, index) {
          final reserva = reservasCanceladas[index];
          return _buildReservaCard(
            reserva: reserva,
            color: Colors.red.shade50,
            iconColor: Colors.red.shade700,
            borderColor: Colors.red.shade300,
            acciones: [],
          );
        },
      ),
    );
  }

  // 🎴 CARD DE RESERVA
  Widget _buildReservaCard({
    required ReservaHotel reserva,
    required Color color,
    required Color iconColor,
    required Color borderColor,
    required List<Widget> acciones,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: color,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.hotel, color: iconColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reserva.cliente ?? 'Sin nombre',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Hab: ${reserva.habitacionTexto}',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${reserva.cantPersonas}',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                          ),
                        ],
                      ),
                      if (reserva.tiempoHospedado != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '⏱️ ${reserva.tiempoHospedado!.texto}',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (reserva.duracionEstadia != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '✅ ${reserva.duracionEstadia!.texto}',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_red_eye),
                  color: Colors.blue.shade700,
                  onPressed: () => _verDetalles(reserva),
                ),
              ],
            ),
            if (acciones.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: acciones,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 📭 ESTADO VACÍO
  Widget _buildEmptyState({required IconData icon, required String mensaje}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            mensaje,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}