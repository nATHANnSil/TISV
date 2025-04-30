// Modelo de domínio
enum Categoria { iniciante, intermediario, avancado }
enum StatusFicha { ativo, finalizado }

class Ficha {
  final String id;
  final String idAtleta;
  final String idTreinador;
  final Categoria categoria;
  final int diaSemana;    // 1=Segunda … 7=Domingo
  final String descricao;
  final StatusFicha status;
  final DateTime criadoEm;

  Ficha({
    required this.id,
    required this.idAtleta,
    required this.idTreinador,
    required this.categoria,
    required this.diaSemana,
    required this.descricao,
    required this.status,
    required this.criadoEm,
  });

  factory Ficha.fromJson(Map<String, dynamic> json) => Ficha(
        id: json['id'] as String,
        idAtleta: json['id_atleta'] as String,
        idTreinador: json['id_treinador'] as String,
        categoria: Categoria.values[json['categoria'] as int],
        diaSemana: json['dia_semana'] as int,
        descricao: json['descricao'] as String,
        status: StatusFicha.values[(json['status'] as int) - 1],
        criadoEm: DateTime.parse(json['criado_em'] as String),
      );

  Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) 'id': id,
        'id_atleta': idAtleta,
        'id_treinador': idTreinador,
        'categoria': categoria.index,
        'dia_semana': diaSemana,
        'descricao': descricao,
        'status': status.index + 1,
        'criado_em': criadoEm.toIso8601String(),
      };
}
