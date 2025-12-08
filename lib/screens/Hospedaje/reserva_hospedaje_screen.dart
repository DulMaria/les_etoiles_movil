import 'package:flutter/material.dart';
import '../../models/Usuarios/usuario_model.dart';
import '../../models/Hospedaje/reserva_hotel_model.dart';
import '../../service/Hospedaje/hotel_api_service.dart';
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
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFBF5),
                  Color(0xFFF5F9FF),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(246, 48, 155, 255).withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: -5,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔷 ENCABEZADO CON COLORES VIVOS
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF4A6FFF), // Azul vivo
                        Color(0xFF6B8CFF),
                        Color(0xFF8DA9FF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4A6FFF).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.95),
                                  Colors.white.withOpacity(0.85),
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF4A6FFF).withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.hotel_outlined,
                              color: Color(0xFF4A6FFF),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Detalles de Reserva',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.tag,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'ID: ${reserva.idReservaHotel}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // BADGE DE ESTADO VIVO
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: Colors.white.withOpacity(0.8)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: _getEstadoColorVivo(reserva),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getEstadoColorVivo(reserva).withOpacity(0.6),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  reserva.estadoTexto,
                                  style: TextStyle(
                                    color: _getEstadoColorVivo(reserva),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // INDICADORES CON COLORES VIVOS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildPageIndicatorVivo(0, _currentPage, 'Cliente', Icons.person, Color(0xFFFF6B9D)),
                          const SizedBox(width: 8),
                          _buildPageIndicatorVivo(1, _currentPage, 'Hospedaje', Icons.hotel, Color(0xFF4A6FFF)),
                          const SizedBox(width: 8),
                          _buildPageIndicatorVivo(2, _currentPage, 'Fechas', Icons.calendar_today, Color(0xFFFFA726)),
                          const SizedBox(width: 8),
                          _buildPageIndicatorVivo(3, _currentPage, 'Resumen', Icons.summarize, Color(0xFF00BCD4)), // Celeste
                        ],
                      ),
                    ],
                  ),
                ),

                // 📋 CONTENIDO
                Flexible(
                  child: SizedBox(
                    height: 400,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        // PÁGINA 1: CLIENTE - ROSA VIVO
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              _buildSeccionViva(
                                icon: Icons.person_outline_rounded,
                                titulo: 'Información del Cliente',
                                gradientColors: [Color(0xFFFF6B9D), Color(0xFFFF8EBC)],
                                borderColor: Color(0xFFFF6B9D),
                                children: [
                                  _buildItemVivo(
                                    icon: Icons.account_circle,
                                    label: 'Nombre Completo',
                                    valor: reserva.cliente ?? 'No especificado',
                                    color: Color(0xFFFF6B9D),
                                    isPrimary: true,
                                  ),
                                  if (reserva.clienteTelefono != null)
                                    _buildItemVivo(
                                      icon: Icons.phone_in_talk,
                                      label: 'Teléfono',
                                      valor: reserva.clienteTelefono!,
                                      color: Color(0xFF4A6FFF),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // PÁGINA 2: HOSPEDAJE - AZUL VIVO
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              _buildSeccionViva(
                                icon: Icons.hotel_rounded,
                                titulo: 'Detalles del Hospedaje',
                                gradientColors: [Color(0xFF4A6FFF), Color(0xFF6B8CFF)],
                                borderColor: Color(0xFF4A6FFF),
                                children: [
                                  _buildItemVivo(
                                    icon: Icons.meeting_room,
                                    label: 'Habitación',
                                    valor: reserva.habitacionTexto,
                                    color: Color(0xFF4A6FFF),
                                    isPrimary: true,
                                  ),
                                  _buildItemVivo(
                                    icon: Icons.groups,
                                    label: 'Cantidad de Personas',
                                    valor: '${reserva.cantPersonas} personas',
                                    color: Color(0xFF6B8CFF),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // PÁGINA 3: FECHAS - NARANJA VIVO para fechas programadas
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              _buildSeccionViva(
                                icon: Icons.calendar_month_rounded,
                                titulo: 'Fechas Programadas',
                                gradientColors: [Color(0xFFFFA726), Color(0xFFFFB74D)],
                                borderColor: Color(0xFFFFA726),
                                children: [
                                  _buildItemVivo(
                                    icon: Icons.event_available,
                                    label: 'Fecha de Inicio',
                                    valor: reserva.fechaDisplay,
                                    color: Color(0xFFFFA726),
                                    isPrimary: true,
                                  ),
                                  _buildItemVivo(
                                    icon: Icons.event_busy,
                                    label: 'Fecha de Fin',
                                    valor: reserva.fechaFinDisplay,
                                    color: Color(0xFFFFA726),
                                    isPrimary: true,
                                  ),
                                ],
                              ),
                              if (reserva.checkIn != null || reserva.checkOut != null) ...[
                                const SizedBox(height: 16),
                                _buildSeccionViva(
                                  icon: Icons.check_circle,
                                  titulo: 'Fechas Reales',
                                  gradientColors: [Color(0xFFCDDC39), Color(0xFFD4E157)], // Verde limón claro
                                  borderColor: Color(0xFFCDDC39), // Verde limón
                                  children: [
                                    if (reserva.checkIn != null)
                                      _buildItemVivo(
                                        icon: Icons.login,
                                        label: 'Ingreso Realizado',
                                        valor: reserva.fechaCheckInRealizado,
                                        color: Color(0xFFCDDC39), // Verde limón
                                        isPrimary: true,
                                      ),
                                    if (reserva.checkOut != null)
                                      _buildItemVivo(
                                        icon: Icons.logout,
                                        label: 'Salida Realizada',
                                        valor: reserva.fechaCheckOutRealizado,
                                        color: Color(0xFFCDDC39), // Verde limón
                                        isPrimary: true,
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        // PÁGINA 4: RESUMEN - CELESTE VIVO
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              if (reserva.tiempoHospedado != null || reserva.duracionEstadia != null)
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF00BCD4), // Celeste
                                        Color(0xFF26C6DA),
                                        Color(0xFFE0F7FA),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Color(0xFF00BCD4),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF00BCD4).withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Color(0xFF00BCD4), Color(0xFF26C6DA)],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xFF00BCD4).withOpacity(0.5),
                                              blurRadius: 15,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.schedule,
                                          color: Colors.white,
                                          size: 48,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        'TIEMPO DE ESTADÍA',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        reserva.tiempoHospedado?.texto ?? 
                                        reserva.duracionEstadia?.texto ?? 
                                        'No disponible',
                                        style: TextStyle(
                                          fontSize: 28,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 4,
                                              offset: Offset(1, 1),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Período completo de hospedaje',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 20),
                              _buildResumenVivo(reserva: reserva),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🎬 CONTROLES CON COLORES VIVOS
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF4A6FFF),
                        Color(0xFF6B8CFF),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4A6FFF).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                            label: const Text('ANTERIOR'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color(0xFF4A6FFF),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: Colors.white, width: 2),
                              ),
                              elevation: 4,
                              shadowColor: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: _currentPage == 0 ? 2 : 1,
                        child: ElevatedButton.icon(
                          onPressed: _currentPage < 3
                              ? () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              : () => Navigator.pop(context),
                          icon: Icon(
                            _currentPage < 3 ? Icons.arrow_forward_ios_rounded : Icons.check_circle,
                            size: 18,
                          ),
                          label: Text(
                            _currentPage < 3 ? 'SIGUIENTE' : 'CERRAR',
                            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF4A6FFF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

Color _getEstadoColorVivo(ReservaHotel reserva) {
  if (reserva.checkOut != null) return Color(0xFF4CAF50); // Verde vivo
  if (reserva.checkIn != null) return Color(0xFF2196F3); // Azul vivo
  if (reserva.estado == 'C') return Color(0xFFF44336); // Rojo vivo
  return Color(0xFFFF9800); // Naranja vivo
}

Widget _buildPageIndicatorVivo(int index, int currentPage, String label, IconData icon, Color color) {
  final isActive = index == currentPage;
  
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    padding: EdgeInsets.symmetric(horizontal: isActive ? 14 : 10, vertical: 10),
    decoration: BoxDecoration(
      color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isActive ? color : Colors.white.withOpacity(0.4),
        width: isActive ? 2 : 1,
      ),
      boxShadow: isActive
          ? [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ]
          : null,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: isActive ? 20 : 16,
          color: isActive ? color : Colors.white,
        ),
        if (isActive) ...[
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    ),
  );
}

Widget _buildSeccionViva({
  required IconData icon,
  required String titulo,
  required List<Color> gradientColors,
  required Color borderColor,
  required List<Widget> children,
}) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, gradientColors[1].withOpacity(0.1)],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(width: 3, color: borderColor.withOpacity(0.3)),
      boxShadow: [
        BoxShadow(
          color: borderColor.withOpacity(0.3),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.8),
          blurRadius: 10,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: borderColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: borderColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: children),
        ),
      ],
    ),
  );
}

Widget _buildItemVivo({
  required IconData icon,
  required String label,
  required String valor,
  required Color color,
  bool isPrimary = false,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.2), width: 2),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                color.withOpacity(0.8),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 22, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                valor,
                style: TextStyle(
                  fontSize: isPrimary ? 18 : 16,
                  color: Color(0xFF333333),
                  fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildResumenVivo({required ReservaHotel reserva}) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
         Color(0xFF00BCD4), // Celeste
          Color(0xFF26C6DA),
          Colors.white,
        ],
        stops: [0.1, 0.4, 1],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Color.fromARGB(255, 149, 229, 240), width: 3),
      boxShadow: [
        BoxShadow(
          color: Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 63, 232, 255), Color.fromARGB(255, 0, 201, 227)], // Celeste
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 85, 232, 252).withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.summarize, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Text(
              'Resumen Completo',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 255, 255, 255), // Celeste
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildResumenItemVivo(Icons.tag, 'ID', '${reserva.idReservaHotel}', Color(0xFF4A6FFF)),
        _buildResumenItemVivo(Icons.person, 'Cliente', reserva.cliente ?? 'N/A', Color(0xFFFF6B9D)),
        _buildResumenItemVivo(Icons.meeting_room, 'Habitación', reserva.habitacionTexto, Color(0xFFFFA726)),
        _buildResumenItemVivo(Icons.info, 'Estado', reserva.estadoTexto, _getEstadoColorVivo(reserva)),
      ],
    ),
  );
}

Widget _buildResumenItemVivo(IconData icon, String label, String value, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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