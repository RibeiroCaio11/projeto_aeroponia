import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/sensor_card.dart';
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

  String _ph = '--';
  String _ec = '--';
  String _tempAgua = '--';
  String _nivelAgua = '--';
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
          _ph = (dados['ph'] as num).toStringAsFixed(1);
          _ec = '${(dados['ec'] as num).toStringAsFixed(1)} mS/cm';
          _tempAgua = '${(dados['temperaturaAgua'] as num).toStringAsFixed(1)}°C';
          _nivelAgua = '${(dados['nivelAgua'] as num).toStringAsFixed(0)}%';
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
                    SensorCard(title: "pH", value: _ph),
                    SensorCard(title: "EC", value: _ec),
                    SensorCard(title: "Temp. Água", value: _tempAgua),
                    SensorCard(title: "Nível Água", value: _nivelAgua),
                  ],
                ),
                const SizedBox(height: 20),
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
