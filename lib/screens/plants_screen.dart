import 'package:flutter/material.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0D1117);
  static const surface = Color(0xFF161B22);
  static const surfaceEl = Color(0xFF1C2129);
  static const border = Color(0xFF30363D);
  static const accent = Color(0xFF39D353);
  static const accentDim = Color(0xFF1A4731);
  static const textPrimary = Color(0xFFE6EDF3);
  static const textSecondary = Color(0xFF8B949E);
  static const red = Color(0xFFFF6B6B);
  static const yellow = Color(0xFFE3B341);
}

// ── Modelo de planta ───────────────────────────────────────────────────────────
class _Plant {
  final String name;
  final String status;
  final String imageUrl;
  final String detail;
  final Color statusColor;

  const _Plant({
    required this.name,
    required this.status,
    required this.imageUrl,
    required this.detail,
    required this.statusColor,
  });
}

const _plants = [
  _Plant(
    name: 'Alface 01',
    status: 'Excelente',
    imageUrl:
        'https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=400&q=80',
    detail: 'Colheita em 5 dias',
    statusColor: _C.accent,
  ),
  _Plant(
    name: 'Tomate 01',
    status: 'Bom',
    imageUrl:
        'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=400&q=80',
    detail: 'Colheita em 18 dias',
    statusColor: _C.yellow,
  ),
  _Plant(
    name: 'Rúcula 01',
    status: 'Excelente',
    imageUrl:
        'https://images.unsplash.com/photo-1600689781748-d774f0d1fd85?w=400&q=80',
    detail: 'Colheita em 3 dias',
    statusColor: _C.accent,
  ),
  _Plant(
    name: 'Espinafre 01',
    status: 'Atenção',
    imageUrl:
        'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400&q=80',
    detail: 'Verificar EC',
    statusColor: _C.red,
  ),
];

// ── Tela de Plantas ────────────────────────────────────────────────────────────
class PlantsScreen extends StatelessWidget {
  const PlantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _darkTheme(),
      child: Scaffold(
        backgroundColor: _C.bg,
        appBar: _buildAppBar(context),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final cols = (constraints.maxWidth / 220).floor().clamp(2, 4);
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Text(
                        'Cultivos Ativos',
                        style: TextStyle(
                          color: _C.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      _OutlinedChip(label: '${_plants.length} plantas'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: _plants.length,
                    itemBuilder: (_, i) => _PlantCard(plant: _plants[i]),
                  ),
                  const SizedBox(height: 20),
                  _AddPlantButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _C.surface,
      elevation: 0,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: _C.border),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: _C.textSecondary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Minhas Plantas',
            style: TextStyle(
              color: _C.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'AeroTower · Torre #1',
            style: TextStyle(color: _C.textSecondary, fontSize: 11),
          ),
        ],
      ),
      actions: [const SizedBox(width: 4)],
    );
  }

  Widget _buildSummaryRow() {
    final excelentes = _plants.where((p) => p.status == 'Excelente').length;
    final atencao = _plants.where((p) => p.status == 'Atenção').length;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.check_circle_outline,
            value: '$excelentes',
            label: 'Excelentes',
            color: _C.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.schedule,
            value: '${_plants.length - excelentes - atencao}',
            label: 'Em progresso',
            color: _C.yellow,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.warning_amber_outlined,
            value: '$atencao',
            label: 'Atenção',
            color: _C.red,
          ),
        ),
      ],
    );
  }

  ThemeData _darkTheme() => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: _C.bg,
    primaryColor: _C.accent,
  );
}

// ── PlantCard ──────────────────────────────────────────────────────────────────

class _PlantCard extends StatelessWidget {
  final _Plant plant;
  const _PlantCard({required this.plant});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: plant.statusColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  plant.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Container(
                          color: _C.surfaceEl,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _C.accent,
                            ),
                          ),
                        ),
                  errorBuilder: (_, __, ___) => Container(
                    color: _C.surfaceEl,
                    child: const Icon(Icons.eco, color: _C.accent, size: 40),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          _C.surface.withOpacity(0.95),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: plant.statusColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: plant.statusColor.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: plant.statusColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          plant.status,
                          style: TextStyle(
                            color: plant.statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.name,
                  style: const TextStyle(
                    color: _C.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 11,
                      color: _C.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      plant.detail,
                      style: const TextStyle(
                        color: _C.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── SummaryCard ────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: _C.textSecondary, fontSize: 10),
        ),
      ],
    ),
  );
}

// ── AddPlantButton ─────────────────────────────────────────────────────────────

class _AddPlantButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade em breve!'),
        backgroundColor: _C.surfaceEl,
        behavior: SnackBarBehavior.floating,
      ),
    ),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: _C.accentDim,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.accent.withOpacity(0.35)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, color: _C.accent, size: 18),
          SizedBox(width: 8),
          Text(
            'Adicionar planta',
            style: TextStyle(
              color: _C.accent,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}

// ── OutlinedChip ───────────────────────────────────────────────────────────────

class _OutlinedChip extends StatelessWidget {
  final String label;
  const _OutlinedChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: _C.accentDim,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _C.accent.withOpacity(0.3)),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: _C.accent,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
