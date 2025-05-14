import 'package:flutter/material.dart';
import 'package:ia_cosmeticos/filtro.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const FilterSelectionPage(),
    );
  }
}

class FilterSelectionPage extends StatefulWidget {
  const FilterSelectionPage({super.key});

  @override
  State<FilterSelectionPage> createState() => _FilterSelectionPageState();
}

class _FilterSelectionPageState extends State<FilterSelectionPage> {
  final Set<String> selectedFilters = {};
  final List<String> filters = ['categoria', 'preço', 'avaliação', 'sexo', 'infantil'];

  void goToRecommendationByProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileRecommendationPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escolha os filtros')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: goToRecommendationByProfile,
              icon: const Icon(Icons.smart_toy),
              label: const Text('Recomendação por Perfil (IA)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


