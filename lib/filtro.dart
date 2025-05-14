import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:ia_cosmeticos/resultado.dart';
import 'package:http/http.dart' as http;

class ProfileRecommendationPage extends StatefulWidget {
  const ProfileRecommendationPage({super.key});

  @override
  State<ProfileRecommendationPage> createState() => _ProfileRecommendationPageState();
}

class _ProfileRecommendationPageState extends State<ProfileRecommendationPage> {
  double precoMedio = 50;
  double avaliacaoMinima = 4.0;
  String? selectedSexo;
  bool isInfantil = false;

  final List<String> categorias = [
    'Acessorios',
    'Cabelos',
    'Higiene',
    'Desodorante',
    'Perfume',
    'Corpo',
    'kit',
    'Maquiagem',
    'Unhas'
  ];
  String? selectedCategoria;

  final List<String> sexos = ['Feminino', 'Masculino', 'Neutro'];

  Future<void> recomendarProdutosPorPerfil() async {
    final uri = Uri.parse('http://192.168.0.3:8000/recomendar_por_perfil');
    final sexoInput = selectedSexo ?? 'Feminino';

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "preco_medio": precoMedio,
          "avaliacao_minima": avaliacaoMinima,
          "sexo": sexoInput.toLowerCase(),
          "infantil": isInfantil,
          "categoria": selectedCategoria,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('produtos_recomendados') && data['produtos_recomendados'] is List) {
          final resultados = List<Map<String, dynamic>>.from(
            data['produtos_recomendados'].map((item) => item as Map<String, dynamic>).toList(),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecommendationPage(produtos: resultados),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Resposta inválida da API.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro na API: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro na conexão: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    selectedSexo = 'Feminino';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text('Personalize sua recomendação',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF7A0968),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildSectionTitle('Categoria desejada:'),
            buildCard(
              Column(
                children: categorias
                    .map((cat) => RadioListTile<String>(
                          title: Text(cat),
                          value: cat,
                          groupValue: selectedCategoria,
                          onChanged: (val) => setState(() => selectedCategoria = val),
                        ))
                    .toList(),
              ),
            ),
            buildSectionTitle('Preço médio aceitável:'),
            buildCard(Slider(
              value: precoMedio,
              min: 0,
              max: 200,
              divisions: 40,
              label: precoMedio.toStringAsFixed(2),
              onChanged: (val) => setState(() => precoMedio = val),
            )),
            buildSectionTitle('Avaliação mínima esperada:'),
            buildCard(Slider(
              value: avaliacaoMinima,
              min: 0,
              max: 5,
              divisions: 10,
              label: avaliacaoMinima.toStringAsFixed(1),
              onChanged: (val) => setState(() => avaliacaoMinima = val),
            )),
            buildSectionTitle('Sexo do consumidor:'),
            buildCard(
              Column(
                children: sexos
                    .map((sx) => RadioListTile<String>(
                          title: Text(sx),
                          value: sx,
                          groupValue: selectedSexo,
                          onChanged: (val) => setState(() => selectedSexo = val),
                        ))
                    .toList(),
              ),
            ),
            buildSectionTitle('É para uso infantil?'),
            buildCard(
              Column(
                children: [
                  RadioListTile<bool>(
                    title: const Text('Sim'),
                    value: true,
                    groupValue: isInfantil,
                    onChanged: (val) => setState(() => isInfantil = val ?? false),
                  ),
                  RadioListTile<bool>(
                    title: const Text('Não'),
                    value: false,
                    groupValue: isInfantil,
                    onChanged: (val) => setState(() => isInfantil = val ?? false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.search, color: Colors.white,),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A0968),
                minimumSize: const Size.fromHeight(50),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: recomendarProdutosPorPerfil,
              label: Text('Recomendar Produtos',
              style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            
          ),),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget buildCard(Widget child) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: child,
      ),
    );
  }
}
