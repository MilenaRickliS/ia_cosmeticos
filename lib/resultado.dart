import 'package:flutter/material.dart';

class RecommendationPage extends StatelessWidget {
  final List<Map<String, dynamic>> produtos;

  const RecommendationPage({super.key, required this.produtos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Produtos Recomendados',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 122, 9, 104),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: produtos.length,
        itemBuilder: (context, index) {
          final prod = produtos[index];
          return ListTile(
            title: Text(prod['nome']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Preço: R\$${prod['preco']}'),
                Text('Avaliação: ${prod['avaliacoes']}'),
                Text('Categoria: ${prod['categorias']}'),
              ],
            ),
            
          );
        },
      ),
    );
  }
}

