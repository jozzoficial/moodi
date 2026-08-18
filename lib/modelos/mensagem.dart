class Mensagem {
  final String id;
  final String remetenteId;
  final String texto;
  final DateTime dataHora;
  final DateTime? expiraEm;

  Mensagem({
    required this.id,
    required this.remetenteId,
    required this.texto,
    required this.dataHora,
    this.expiraEm,
  });

  factory Mensagem.deMapa(Map<String, dynamic> mapa, String id) {
    return Mensagem(
      id: id,
      remetenteId: mapa['remetenteId'] ?? '',
      texto: mapa['texto'] ?? '',
      dataHora: mapa['dataHora'] != null 
          ? DateTime.parse(mapa['dataHora']) 
          : DateTime.now(),
      expiraEm: mapa['expiraEm'] != null
          ? DateTime.parse(mapa['expiraEm'])
          : null,
    );
  }

  Map<String, dynamic> paraMapa() {
    return {
      'remetenteId': remetenteId,
      'texto': texto,
      'dataHora': dataHora.toIso8601String(),
      if (expiraEm != null) 'expiraEm': expiraEm!.toIso8601String(),
    };
  }
}
