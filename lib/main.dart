import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:ia_cosmeticos/detalhes.dart';
import 'package:ia_cosmeticos/favoritos.dart';
import 'package:ia_cosmeticos/model/produto.dart';
import 'package:ia_cosmeticos/escolha.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 8, 8, 7),
        scaffoldBackgroundColor: const Color.fromARGB(255, 237, 191, 243),
        fontFamily: 'Raleway',
      ),
      home: const SiteCosmeticos(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SiteCosmeticos extends StatefulWidget {
  const SiteCosmeticos({super.key});

  @override
  SiteCosmeticosState createState() => SiteCosmeticosState();
}

class SiteCosmeticosState extends State<SiteCosmeticos> {
  List<Produto> favoritos = [];

  Future<List<Produto>> carregarProdutos() async {
    final jsonString = await DefaultAssetBundle.of(context).loadString('assets/produtos/cosmeticos1.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((item) => Produto.fromJson(item)).toList();
  }

  void _toggleFavorito(Produto produto) {
    setState(() {
      if (favoritos.contains(produto)) {
        favoritos.remove(produto);
      } else {
        favoritos.add(produto);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Produto>>(
      future: carregarProdutos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Erro: ${snapshot.error}')),
          );
        }


        final produtos = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Cosméticos',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 122, 9, 104),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite),
                color: Colors.red,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FavoritosPage(favoritos: favoritos),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'Está em dúvida?\nVamos ajudar a escolher!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FilterSelectionPage(), 
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 122, 9, 104),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Garantir produto',
                                style: TextStyle(fontSize: 16, color: Colors.amber),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.amber,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Grid de produtos
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: produtos.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20.0,
                    mainAxisSpacing: 20.0,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final produto = produtos[index];
                    final isFavorito = favoritos.contains(produto);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalhesProduto(produto: produto),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                image: DecorationImage(
                                  image: AssetImage(produto.imagem),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                produto.nome,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'R\$ ${produto.preco.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isFavorito ? Icons.favorite : Icons.favorite_border,
                                color: isFavorito ? Colors.red : Colors.grey,
                              ),
                              onPressed: () => _toggleFavorito(produto),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
