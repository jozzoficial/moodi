class Publicacao {
  final String id;
  final String autorId;
  final String autorCodinome;
  final String humor;
  final String texto;
  final DateTime dataHora;
  final int totalLikes;
  final int totalComentarios;
  final List<String> likesUids;

  Publicacao({
    required this.id,
    required this.autorId,
    required this.autorCodinome,
    required this.humor,
    required this.texto,
    required this.dataHora,
    this.totalLikes = 0,
    this.totalComentarios = 0,
    this.likesUids = const [],
  });

  factory Publicacao.deMapa(Map<String, dynamic> mapa, String id) {
    return Publicacao(
      id: id,
      autorId: mapa['autorId'] ?? '',
      autorCodinome: mapa['autorCodinome'] ?? 'Anônimo',
      humor: mapa['humor'] ?? 'Neutro',
      texto: mapa['texto'] ?? '',
      dataHora: mapa['dataHora'] != null
          ? DateTime.parse(mapa['dataHora'])
          : DateTime.now(),
      totalLikes: mapa['totalLikes'] ?? 0,
      totalComentarios: mapa['totalComentarios'] ?? 0,
      likesUids: List<String>.from(mapa['likesUids'] ?? []),
    );
  }

  Map<String, dynamic> paraMapa() {
    return {
      'autorId': autorId,
      'autorCodinome': autorCodinome,
      'humor': humor,
      'texto': texto,
      'dataHora': dataHora.toIso8601String(),
      'totalLikes': totalLikes,
      'totalComentarios': totalComentarios,
      'likesUids': likesUids,
    };
  }
}
