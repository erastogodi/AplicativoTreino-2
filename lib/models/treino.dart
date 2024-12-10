class Treino {
  final String id;
  final String nome;
  final String data;
  final String duracao;
  final String intensidade;
  bool treinoFeito; // Campo booleano para indicar se o treino foi feito

  Treino({
    required this.id,
    required this.nome,
    required this.data,
    required this.duracao,
    required this.intensidade,
    this.treinoFeito = false, // Valor padrão: não feito
  });

  // Método copyWith para criar cópias com alterações
  Treino copyWith({
    String? id,
    String? nome,
    String? data,
    String? duracao,
    String? intensidade,
    bool? treinoFeito,
  }) {
    return Treino(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      data: data ?? this.data,
      duracao: duracao ?? this.duracao,
      intensidade: intensidade ?? this.intensidade,
      treinoFeito: treinoFeito ?? this.treinoFeito,
    );
  }

  // Converter JSON em Treino
  factory Treino.fromJson(Map<String, dynamic> json) {
    return Treino(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      data: json['data'] ?? '',
      duracao: json['duracao'] ?? '',
      intensidade: json['intensidade'] ?? '',
      treinoFeito: json['treinoFeito'] ?? false,
    );
  }

  // Converter Treino em JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'data': data,
      'duracao': duracao,
      'intensidade': intensidade,
      'treinoFeito': treinoFeito,
    };
  }
}
