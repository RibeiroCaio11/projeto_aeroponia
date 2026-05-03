import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_gauges/gauges.dart'; // Adicionado para os GaugeRanges
import '../widgets/gauge_card.dart'; // Atualizado para o novo widget
import 'plants_screen.dart';

const _backendUrl = 'http://localhost:8000/dados';
const _intervalo = Duration(seconds: 3);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _timer;

  // Variáveis atualizadas para double? para alimentar os Gauges
  double? _ph;
  double? _ec;
  double? _tempAgua;
  double? _nivelAgua;
  
  List<String> _alertas = [];
  bool _conectado = false;
  String? _erroConexao;

  @override
  void initState() {
    super.initState();
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
          // Extraindo os números puros para os Gauges
          _ph = (dados['ph'] as num).toDouble();
          _ec = (dados['ec'] as num).toDouble();
          _tempAgua = (dados['temperaturaAgua'] as num).toDouble();
          _nivelAgua = (dados['nivelAgua'] as num).toDouble();
          
          _alertas = alertas;
          _conectado = true;
          _erroConexao = null;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.eco),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlantsScreen()),
              );
            },
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount =
              (constraints.maxWidth / 220).floor().clamp(2, 4);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.8,
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
                ),
                const SizedBox(height: 50),
                if (_erroConexao != null)
                  _statusErro()
                else if (!_conectado)
                  _statusCarregando()
                else if (_alertas.isEmpty)
                  _statusOk()
                else
                  _statusAlertas(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusCarregando() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text("Buscando dados do backend..."),
        ],
      ),
    );
  }

  Widget _statusErro() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(child: Text(_erroConexao!)),
        ],
      ),
    );
  }

  Widget _statusOk() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 10),
          Text("Sistema Operacional"),
        ],
      ),
    );
  }

  Widget _statusAlertas() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 10),
              Text(
                "Alertas",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._alertas.map(
            (alerta) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('• $alerta'),
            ),
          ),
        ],
      ),
    );
  }
}