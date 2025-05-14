class Produto {
  final int id;
  final String nome;
  final double preco;
  final String categorias;
  final String marca;
  final String imagem;
  final String descricao;
  final double avaliacao;
  final String sexo;
  final bool infantil;

  Produto({
    required this.id,
    required this.nome,
    required this.preco,
    required this.categorias,
    required this.marca,
    required this.imagem,
    required this.descricao,
    required this.avaliacao,
    required this.sexo,
    required this.infantil,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'],
      nome: json['nome'],
      preco: json['preco'].toDouble(),
      categorias: json['categorias'],
      marca: json['marca'],
      imagem: json['imagem'],
      descricao: json['descricao'],
      avaliacao: json['avaliacao'].toDouble(),
      sexo: json['sexo'],
      infantil: json['infantil'] is String
          ? json['infantil'] == "sim" || json['infantil'] == "true"
          : json['infantil'] == true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Produto && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

}
