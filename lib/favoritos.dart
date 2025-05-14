import 'package:flutter/material.dart';
import 'package:ia_cosmeticos/detalhes.dart';
import 'package:ia_cosmeticos/model/produto.dart'; 

class FavoritosPage extends StatelessWidget {
  final List<Produto> favoritos;

  const FavoritosPage({super.key, required this.favoritos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favoritos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 122, 9, 104),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: favoritos.length,
        itemBuilder: (context, index) {
          final produto = favoritos[index];
          return ListTile(
            title: Text(produto.nome),
            subtitle: Text(produto.descricao),
            leading: Image.asset(
              produto.imagem,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalhesProduto(produto: produto),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
