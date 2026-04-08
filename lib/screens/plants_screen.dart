import 'package:flutter/material.dart';
import '../widgets/plant_card.dart';

class PlantsScreen extends StatelessWidget {
  const PlantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Minhas Plantas")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: const [
            PlantCard(name: "Alface 01", status: "Excelente"),
            PlantCard(name: "Tomate 01", status: "Bom"),
            PlantCard(name: "Rúcula 01", status: "Excelente"),
            PlantCard(name: "Espinafre 01", status: "Bom"),
          ],
        ),
      ),
    );
  }
}