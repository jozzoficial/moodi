class Mensagem {
  final String id;
  final String remetenteId;
  final String texto;
  final DateTime dataHora;

  Mensagem({
    required this.id,
    required this.remetenteId,
    required this.texto,
    required this.dataHora,
  });

  factory Mensagem.deMapa(Map<String, dynamic> mapa, String id) {
    return Mensagem(
      id: id,
      remetenteId: mapa['remetenteId'] ?? '',
      texto: mapa['texto'] ?? '',
      dataHora: mapa['dataHora'] != null 
          ? DateTime.parse(mapa['dataHora']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> paraMapa() {
    return {
      'remetenteId': remetenteId,
      'texto': texto,
      'dataHora': dataHora.toIso8601String(),
    };
  }
}
