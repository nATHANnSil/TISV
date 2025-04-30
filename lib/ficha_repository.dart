import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ficha.dart';

class FichaRepository {
  // Ajuste para a URL do seu API Gateway (sem a barra final)
  static const _base = 'https://seu-api-id.execute-api.us-east-1.amazonaws.com/dev/fichas';

  Future<String> createFicha(Ficha ficha) async {
    final resp = await http.post(
      Uri.parse(_base),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(ficha.toJson()),
    );
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      return body['id'].toString(); 
    }
    throw Exception('Erro ao criar ficha (${resp.statusCode})');
  }

  Future<List<Ficha>> getFichasPorAtleta(String idAtleta) async {
    final resp = await http.get(Uri.parse('$_base?atleta=$idAtleta'));
    if (resp.statusCode == 200) {
      final list = jsonDecode(resp.body) as List;
      return list.map((j) => Ficha.fromJson(j)).toList();
    }
    throw Exception('Erro ao buscar fichas (${resp.statusCode})');
  }

  Future<void> updateFicha(Ficha ficha) async {
    final resp = await http.put(
      Uri.parse('$_base/${ficha.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(ficha.toJson()),
    );
    if (resp.statusCode != 200) {
      throw Exception('Erro ao atualizar ficha (${resp.statusCode})');
    }
  }

  Future<void> deleteFicha(String id) async {
    final resp = await http.delete(Uri.parse('$_base/$id'));
    if (resp.statusCode != 200) {
      throw Exception('Erro ao deletar ficha (${resp.statusCode})');
    }
  }
}
