class Utilizador {
  final String id;
  final String codinome;
  final String email;
  final String? fotoUrl;

  Utilizador({
    required this.id,
    required this.codinome,
    required this.email,
    this.fotoUrl,
  });

  factory Utilizador.deMapa(Map<String, dynamic> mapa, String id) {
    return Utilizador(
      id: id,
      codinome: mapa['codinome'] ?? 'Anônimo',
      email: mapa['email'] ?? '',
      fotoUrl: mapa['fotoUrl'],
    );
  }

  Map<String, dynamic> paraMapa() {
    return {
      'codinome': codinome,
      'email': email,
      'fotoUrl': fotoUrl,
    };
  }
}
