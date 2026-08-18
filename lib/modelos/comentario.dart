class Comentario {
  final String id;
  final String autorId;
  final String autorCodinome;
  final String texto;
  final DateTime dataHora;

  Comentario({
    required this.id,
    required this.autorId,
    required this.autorCodinome,
    required this.texto,
    required this.dataHora,
  });

  factory Comentario.deMapa(Map<String, dynamic> mapa, String id) {
    return Comentario(
      id: id,
      autorId: mapa['autorId'] ?? '',
      autorCodinome: mapa['autorCodinome'] ?? 'Anônimo',
      texto: mapa['texto'] ?? '',
      dataHora: mapa['dataHora'] != null
          ? DateTime.parse(mapa['dataHora'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> paraMapa() {
    return {
      'autorId': autorId,
      'autorCodinome': autorCodinome,
      'texto': texto,
      'dataHora': dataHora.toIso8601String(),
    };
  }
}
