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
      }),
    );

    // 👇 Adicione estas linhas para debug
    print("Status Code: ${response.statusCode}");
    print("Corpo da Resposta: ${response.body}");

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
    // Tratamento de erro
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erro na conexão: $e")),
    );
    print("Erro ao chamar API: $e");
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
      appBar: AppBar(title: const Text('Seu Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Preço médio
            const Text('Preço médio aceitável:'),
            Slider(
              value: precoMedio,
              min: 0,
              max: 200,
              divisions: 40,
              label: precoMedio.toStringAsFixed(2),
              onChanged: (val) {
                setState(() => precoMedio = val);
              },
            ),

            // Avaliação mínima
            const Text('Avaliação mínima esperada:'),
            Slider(
              value: avaliacaoMinima,
              min: 0,
              max: 5,
              divisions: 10,
              label: avaliacaoMinima.toStringAsFixed(1),
              onChanged: (val) {
                setState(() => avaliacaoMinima = val);
              },
            ),

            // Sexo
            const Text('Sexo do consumidor:'),
            ...sexos.map((sx) => RadioListTile<String>(
                  title: Text(sx),
                  value: sx,
                  groupValue: selectedSexo,
                  onChanged: (val) {
                    setState(() {
                      selectedSexo = val;
                    });
                  },
                )),

            // Infantil
            const Text('É para uso infantil?'),
            RadioListTile<bool>(
              title: const Text('Sim'),
              value: true,
              groupValue: isInfantil,
              onChanged: (val) {
                setState(() {
                  isInfantil = val ?? false;
                });
              },
            ),
            RadioListTile<bool>(
              title: const Text('Não'),
              value: false,
              groupValue: isInfantil,
              onChanged: (val) {
                setState(() {
                  isInfantil = val ?? false;
                });
              },
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: recomendarProdutosPorPerfil,
              child: const Text('Recomendar Produtos'),
            )
          ],
        ),
      ),
    );
  }
}