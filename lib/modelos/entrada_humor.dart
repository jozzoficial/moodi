class EntradaHumor {
  final String id;
  final String utilizadorId;
  final String humor; // Ex: 'Feliz', 'Triste', 'Ansioso'
  final DateTime dataHora;
  final String? fotoUrl; // URL da selfie

  EntradaHumor({
    required this.id,
    required this.utilizadorId,
    required this.humor,
    required this.dataHora,
    this.fotoUrl,
  });

  factory EntradaHumor.deMapa(Map<String, dynamic> mapa, String id) {
    return EntradaHumor(
      id: id,
      utilizadorId: mapa['utilizadorId'] ?? '',
      humor: mapa['humor'] ?? 'Neutro',
      dataHora: mapa['dataHora'] != null 
          ? DateTime.parse(mapa['dataHora']) 
          : DateTime.now(),
      fotoUrl: mapa['fotoUrl'],
    );
  }

  Map<String, dynamic> paraMapa() {
    return {
      'utilizadorId': utilizadorId,
      'humor': humor,
      'dataHora': dataHora.toIso8601String(),
      'fotoUrl': fotoUrl,
    };
  }
}
