import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../widgets/gauge_card.dart';
import 'plants_screen.dart';

const _backendUrl =
    'https://aerotowersystem-eqatd2e6d8fghhbj.eastus-01.azurewebsites.net/dados';
const _intervalo = Duration(seconds: 3);

// ── Design tokens ──────────────────────────────────────────────────────────────
class _Colors {
  static const bg = Color(0xFF0D1117);
  static const surface = Color(0xFF161B22);
  static const surfaceElevated = Color(0xFF1C2129);
  static const border = Color(0xFF30363D);
  static const accent = Color(0xFF39D353); // verde hidropônico
  static const accentDim = Color(0xFF1A4731);
  static const textPrimary = Color(0xFFE6EDF3);
  static const textSecondary = Color(0xFF8B949E);
  static const red = Color(0xFFFF6B6B);
  static const redDim = Color(0xFF3D1515);
  static const orange = Color(0xFFFF9500);
  static const orangeDim = Color(0xFF3D2400);
  static const blue = Color(0xFF58A6FF);
  static const blueDim = Color(0xFF0D2040);
}

// ── Screen ────────────────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _pulseController;

  double? _ph;
  double? _ec;
  double? _tempAgua;
  double? _nivelAgua;

  List<String> _alertas = [];
  bool _conectado = false;
  String? _erroConexao;
  DateTime? _ultimaAtualizacao;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _buscarDados();
    _timer = Timer.periodic(_intervalo, (_) => _buscarDados());
  }

  Future<void> _buscarDados() async {
    try {
      final response = await http
          .get(Uri.parse(_backendUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final payload = jsonDecode(response.body) as Map<String, dynamic>?;
        if (payload == null || payload['dados'] == null) return;

        final dados = payload['dados'] as Map<String, dynamic>;
        final alertas = (payload['alertas'] as List).cast<String>();

        if (!mounted) return;
        setState(() {
          _ph = (dados['ph'] as num).toDouble();
          _ec = (dados['ec'] as num).toDouble();
          _tempAgua = (dados['temperaturaAgua'] as num).toDouble();
          _nivelAgua = (dados['nivelAgua'] as num).toDouble();
          _alertas = alertas;
          _conectado = true;
          _erroConexao = null;
          _ultimaAtualizacao = DateTime.now();
        });
      } else {
        _setErro('Backend retornou erro ${response.statusCode}.');
      }
    } catch (_) {
      _setErro('Sem resposta do backend. Ele está rodando?');
    }
  }

  void _setErro(String mensagem) {
    if (!mounted) return;
    setState(() {
      _erroConexao = mensagem;
      _conectado = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buildDarkTheme(),
      child: Scaffold(
        backgroundColor: _Colors.bg,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho da seção
              _buildSectionHeader(),
              const SizedBox(height: 20),

              // Faixa de alertas críticos
              if (_alertas.isNotEmpty) ...[
                _buildAlertBanner(),
                const SizedBox(height: 16),
              ],

              // Aviso de erro de conexão
              if (_erroConexao != null) ...[
                _buildConnectionError(),
                const SizedBox(height: 16),
              ],

              // Grid de gauges
              _buildGaugeGrid(),

              const SizedBox(height: 24),

              // Barra de status inferior
              _buildStatusBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _Colors.surface,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _Colors.border),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            color: _Colors.accentDim,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.water_drop, color: _Colors.accent, size: 20),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AeroTower',
            style: TextStyle(
              color: _Colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            'Sistema de Monitoramento',
            style: TextStyle(
              color: _Colors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        // Indicador de conexão animado
        AnimatedBuilder(
          animation: _pulseController,
          builder: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _conectado
                    ? _Colors.accent.withOpacity(
                        0.4 + 0.6 * _pulseController.value,
                      )
                    : _Colors.red.withOpacity(0.6),
                boxShadow: _conectado
                    ? [
                        BoxShadow(
                          color: _Colors.accent.withOpacity(
                            0.3 * _pulseController.value,
                          ),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _AppBarButton(
          icon: Icons.eco_outlined,
          label: 'Plantas',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PlantsScreen()),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  // ── Cabeçalho da seção ─────────────────────────────────────────────────────

  Widget _buildSectionHeader() {
    final hora = _ultimaAtualizacao != null
        ? '${_ultimaAtualizacao!.hour.toString().padLeft(2, '0')}:'
              '${_ultimaAtualizacao!.minute.toString().padLeft(2, '0')}:'
              '${_ultimaAtualizacao!.second.toString().padLeft(2, '0')}'
        : '--:--:--';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sensores em Tempo Real',
                style: TextStyle(
                  color: _Colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Atualizado às $hora · Intervalo: ${_intervalo.inSeconds}s',
                style: const TextStyle(
                  color: _Colors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        // Badge de status compacto
        _StatusBadge(
          label: _erroConexao != null
              ? 'Offline'
              : _conectado
              ? 'Online'
              : 'Conectando',
          color: _erroConexao != null
              ? _Colors.red
              : _conectado
              ? _Colors.accent
              : _Colors.orange,
        ),
      ],
    );
  }

  // ── Faixa de alertas ───────────────────────────────────────────────────────

  Widget _buildAlertBanner() {
    return Container(
      decoration: BoxDecoration(
        color: _Colors.redDim,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.red.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho da faixa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _Colors.red.withOpacity(0.15),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_rounded, color: _Colors.red, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_alertas.length} alerta${_alertas.length > 1 ? 's' : ''} ativo${_alertas.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: _Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Lista de alertas
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _alertas
                  .map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '›  ',
                            style: TextStyle(color: _Colors.red, fontSize: 14),
                          ),
                          Expanded(
                            child: Text(
                              a,
                              style: const TextStyle(
                                color: Color(0xFFFFB3B3),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Erro de conexão ────────────────────────────────────────────────────────

  Widget _buildConnectionError() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _Colors.orangeDim,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: _Colors.orange, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _erroConexao!,
              style: const TextStyle(color: _Colors.orange, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: _buscarDados,
            style: TextButton.styleFrom(
              foregroundColor: _Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Tentar novamente',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Grid de Gauges ─────────────────────────────────────────────────────────

  Widget _buildGaugeGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 260).floor().clamp(2, 4);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.7,
          children: [
            GaugeCard(
              title: "pH",
              value: _ph,
              unit: "",
              min: 0,
              max: 14,
              ranges: [
                GaugeRange(startValue: 0, endValue: 5.5, color: Colors.red),
                GaugeRange(startValue: 5.5, endValue: 6.5, color: Colors.green),
                GaugeRange(startValue: 6.5, endValue: 14, color: Colors.red),
              ],
            ),
            GaugeCard(
              title: "EC",
              value: _ec,
              unit: "mS/cm",
              min: 0,
              max: 5,
              ranges: [
                GaugeRange(startValue: 0, endValue: 1.0, color: Colors.red),
                GaugeRange(startValue: 1.0, endValue: 1.8, color: Colors.green),
                GaugeRange(startValue: 1.8, endValue: 5.0, color: Colors.red),
              ],
            ),
            GaugeCard(
              title: "Temp. Água",
              value: _tempAgua,
              unit: "°C",
              min: 10,
              max: 35,
              ranges: [
                GaugeRange(startValue: 10, endValue: 20, color: Colors.red),
                GaugeRange(startValue: 20, endValue: 28, color: Colors.green),
                GaugeRange(startValue: 28, endValue: 35, color: Colors.red),
              ],
            ),
            GaugeCard(
              title: "Nível Água",
              value: _nivelAgua,
              unit: "%",
              min: 0,
              max: 100,
              ranges: [
                GaugeRange(startValue: 0, endValue: 35, color: Colors.red),
                GaugeRange(startValue: 35, endValue: 50, color: Colors.yellow),
                GaugeRange(startValue: 50, endValue: 100, color: Colors.green),
              ],
            ),
          ],
        );
      },
    );
  }

  // ── Barra de status inferior ───────────────────────────────────────────────

  Widget _buildStatusBar() {
    if (_erroConexao != null) return _statusErro();
    if (!_conectado) return _statusCarregando();
    if (_alertas.isNotEmpty) return _statusAlertas();
    return _statusOk();
  }

  Widget _statusCarregando() {
    return _StatusContainer(
      color: _Colors.blueDim,
      borderColor: _Colors.blue.withOpacity(0.3),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation(_Colors.blue),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Buscando dados do backend…',
            style: TextStyle(color: _Colors.blue, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _statusErro() {
    return _StatusContainer(
      color: _Colors.redDim,
      borderColor: _Colors.red.withOpacity(0.3),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: _Colors.red, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _erroConexao!,
              style: const TextStyle(color: _Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusOk() {
    return _StatusContainer(
      color: _Colors.accentDim,
      borderColor: _Colors.accent.withOpacity(0.3),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline, color: _Colors.accent, size: 18),
          SizedBox(width: 12),
          Text(
            'Todos os sistemas operacionais',
            style: TextStyle(color: _Colors.accent, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _statusAlertas() {
    return _StatusContainer(
      color: _Colors.orangeDim,
      borderColor: _Colors.orange.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: _Colors.orange,
                size: 18,
              ),
              SizedBox(width: 12),
              Text(
                'Parâmetros fora do ideal',
                style: TextStyle(
                  color: _Colors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._alertas.map(
            (alerta) => Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                '· $alerta',
                style: const TextStyle(color: Color(0xFFFFCC80), fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Theme ──────────────────────────────────────────────────────────────────

  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: _Colors.bg,
      primaryColor: _Colors.accent,
      cardColor: _Colors.surface,
      cardTheme: CardThemeData(
        color: _Colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: _Colors.border),
        ),
      ),
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: _Colors.textPrimary,
        displayColor: _Colors.textPrimary,
      ),
    );
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────────────────

class _StatusContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color borderColor;

  const _StatusContainer({
    required this.child,
    required this.color,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _AppBarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: _Colors.textSecondary,
        backgroundColor: _Colors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: _Colors.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, size: 15),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
