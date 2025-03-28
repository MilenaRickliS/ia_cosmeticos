import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 8, 8, 7),
        scaffoldBackgroundColor: Color.fromARGB(255, 237, 191, 243),
        fontFamily: 'Raleway',
      ),
      home: SiteCosmeticos(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SiteCosmeticos extends StatefulWidget {
  const SiteCosmeticos({super.key});

  @override
  _SiteCosmeticosState createState() => _SiteCosmeticosState();
}

class _SiteCosmeticosState extends State<SiteCosmeticos> {
  List<Map<String, String>> favoritos = [];

  static const List<Map<String, String>> produtos = [
    {
      "id": '1',
      "nome": "Shampoo Hidratante",
      "marca": "Marca A",
      "imagem": "assets/shampoo-hidratante.png",
      "preco": '29.99',
      "categoria": "Cabelos",
      "descricao": "Shampoo hidratante para cabelos secos e danificados, promovendo brilho e maciez.",
      "avaliacoes": '4.5',
      "sexo": "neutro",
      "infantil": "não"
    },
    {
      "id": '2',
      "nome": "Creme Hidratante Corporal",
      "marca": "Marca B",
      "imagem": "assets/creme-hidratante.png",
      "preco": '49.90',
      "categoria": "Corpo",
      "descricao": "Creme hidratante corporal com fórmula enriquecida para pele extra-seca.",
      "avaliacoes": '4.8',
      "sexo": "feminino",
      "infantil": "não"
    },
    {
      "id": '3',
      "nome": "Protetor Solar FPS 50",
      "marca": "Marca C",
      "imagem": "assets/protetor-50.png",
      "preco": '59.90',
      "categoria": "Rosto",
      "descricao": "Protetor solar para o rosto com alta proteção contra raios UVA e UVB.",
      "avaliacoes": '4.7',
      "sexo": "neutro",
      "infantil": "não"
    },
    {
      "id": '4',
      "nome": "Shampoo Baby",
      "marca": "Marca D",
      "imagem": "assets/shampoo-baby.png",
      "preco": '19.90',
      "categoria": "Cabelos",
      "descricao": "Shampoo para bebês, suave e sem lágrimas, ideal para peles sensíveis.",
      "avaliacoes": '4.9',
      "sexo": "neutro",
      "infantil": "sim"
    },
    {
      "id": '5',
      "nome": "Perfume Floral",
      "marca": "Marca E",
      "imagem": "assets/perfume-floral.png",
      "preco": '139.90',
      "categoria": "Perfumes",
      "descricao": "Perfume floral com notas de rosas e jasmins, ideal para o dia a dia.",
      "avaliacoes": '4.3',
      "sexo": "feminino",
      "infantil": "não"
    },
    {
      "id": '6',
      "nome": "Desodorante Masculino",
      "marca": "Marca F",
      "imagem": "assets/desodorante-masc.png",
      "preco": '29.90',
      "categoria": "Higiene Pessoal",
      "descricao": "Desodorante com fragrância masculina de longa duração e proteção contra suor.",
      "avaliacoes": '4.6',
      "sexo": "masculino",
      "infantil": "não"
    }
  ];

  void _toggleFavorito(Map<String, String> produto) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cosméticos',
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 122, 9, 104),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
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
          IconButton(
            icon: Icon(Icons.chat),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(produtos: produtos),
                ),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(20.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, 
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 20.0,
          childAspectRatio: 0.75, // Ajusta a altura e largura das células
        ),
        itemCount: produtos.length,
        itemBuilder: (context, index) {
          final produto = produtos[index];
          final isFavorito = favoritos.contains(produto);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalhesProduto(
                    produto: produto,
                  ),
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
                    width: 150,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(produto['imagem']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    produto['nome']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'R\$ ${produto['preco']}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
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
    );
  }
}

class DetalhesProduto extends StatelessWidget {
  final Map<String, String> produto;

  const DetalhesProduto({super.key, required this.produto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          produto['nome']!,
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 122, 9, 104),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 200,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(produto['imagem']!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Características:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                produto['descricao']!,
                style: TextStyle(fontSize: 17),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 72, 30, 66),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Voltar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoritosPage extends StatelessWidget {
  final List<Map<String, String>> favoritos;

  const FavoritosPage({super.key, required this.favoritos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favoritos',
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
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
            title: Text(produto['nome']!),
            subtitle: Text(produto['descricao']!),
            leading: Image.asset(produto['imagem']!, width: 50, height: 50, fit: BoxFit.cover),
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

class ChatPage extends StatefulWidget {
  final List<Map<String, String>> produtos;

  const ChatPage({super.key, required this.produtos});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> messages = [];
  List<Map<String, String>> suggestedProducts = [];

  void _sendMessage() {
    String message = _controller.text;
    if (message.isNotEmpty) {
      setState(() {
        messages.add("Você: $message");
        _controller.clear();
        _getSuggestions(message);
      });
    }
  }

  void _getSuggestions(String message) {
    // Aqui você pode implementar a lógica de recomendação
    // Para simplificar, vamos usar uma lógica básica
    if (message.toLowerCase().contains("hidratação")) {
      suggestedProducts = widget.produtos.where((produto) => produto['categoria'] == "Cabelos").toList();
    } else if (message.toLowerCase().contains("proteção solar")) {
      suggestedProducts = widget.produtos.where((produto) => produto['categoria'] == "Rosto").toList();
    } else {
      suggestedProducts = [];
    }

    setState(() {
      messages.add("IA: Aqui estão algumas sugestões:");
      for (var produto in suggestedProducts.take(3)) {
        messages.add(" - ${produto['nome']} (R\$ ${produto['preco']})");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat de Recomendação',
        style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: 24,
        ),
        ),
        backgroundColor: Color.fromARGB(255, 122, 9, 104),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
