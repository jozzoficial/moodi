class ConversaPrivada {
  final String id;
  final List<String> participantes;
  final String ultimaMensagem;
  final DateTime dataUltimaMensagem;
  final Map<String, String> codinomes; // uid -> codinome

  ConversaPrivada({
    required this.id,
    required this.participantes,
    required this.ultimaMensagem,
    required this.dataUltimaMensagem,
    this.codinomes = const {},
  });

  factory ConversaPrivada.deMapa(Map<String, dynamic> mapa, String id) {
    return ConversaPrivada(
      id: id,
      participantes: List<String>.from(mapa['participantes'] ?? []),
      ultimaMensagem: mapa['ultimaMensagem'] ?? '',
      dataUltimaMensagem: mapa['dataUltimaMensagem'] != null
          ? DateTime.parse(mapa['dataUltimaMensagem'])
          : DateTime.now(),
      codinomes: Map<String, String>.from(mapa['codinomes'] ?? {}),
    );
  }

  Map<String, dynamic> paraMapa() {
    return {
      'participantes': participantes,
      'ultimaMensagem': ultimaMensagem,
      'dataUltimaMensagem': dataUltimaMensagem.toIso8601String(),
      'codinomes': codinomes,
    };
  }
}
