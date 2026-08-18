class Utilizador {
  final String id;
  final String codinome;
  final String email;
  final String? fotoUrl;
  final String? bio;
  final DateTime? dataCriacao;
  final String? humorAtual;

  Utilizador({
    required this.id,
    required this.codinome,
    required this.email,
    this.fotoUrl,
    this.bio,
    this.dataCriacao,
    this.humorAtual,
  });

  factory Utilizador.deMapa(Map<String, dynamic> mapa, String id) {
    return Utilizador(
      id: id,
      codinome: mapa['codinome'] ?? 'Anônimo',
      email: mapa['email'] ?? '',
      fotoUrl: mapa['fotoUrl'],
      bio: mapa['bio'],
      dataCriacao: mapa['dataCriacao'] != null
          ? DateTime.parse(mapa['dataCriacao'])
          : null,
      humorAtual: mapa['humorAtual'],
    );
  }

  Map<String, dynamic> paraMapa() {
    return {
      'codinome': codinome,
      'email': email,
      'fotoUrl': fotoUrl,
      'bio': bio,
      'dataCriacao': dataCriacao?.toIso8601String(),
      'humorAtual': humorAtual,
    };
  }

  /// Cria uma cópia com campos alterados
  Utilizador copiarCom({
    String? codinome,
    String? email,
    String? fotoUrl,
    String? bio,
    DateTime? dataCriacao,
    String? humorAtual,
  }) {
    return Utilizador(
      id: id,
      codinome: codinome ?? this.codinome,
      email: email ?? this.email,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      bio: bio ?? this.bio,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      humorAtual: humorAtual ?? this.humorAtual,
    );
  }
}
