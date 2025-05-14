import 'package:flutter/material.dart';

class DetalhesProduto extends StatelessWidget {
  final Map<String, dynamic> produto;

  const DetalhesProduto({super.key, required this.produto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(produto['nome']),
        backgroundColor: const Color.fromARGB(255, 122, 9, 104),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                produto['imagem'],
                height: 200,
                width: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nome: ${produto['nome']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Preço: R\$${produto['preco'].toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            Text('Categoria: ${produto['categorias']}'),
            const SizedBox(height: 10),
            Text('Marca: ${produto['marca']}'),
            const SizedBox(height: 10),
            Text('Descrição: ${produto['descricao']}'),
            const SizedBox(height: 10),
            Text('Avaliação: ${produto['avaliacao']}'),
          ],
        ),
      ),
    );
  }
}