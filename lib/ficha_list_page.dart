import 'package:flutter/material.dart';
import 'ficha.dart';
import 'ficha_repository.dart';
import 'ficha_form_dialog.dart';

class FichaListPage extends StatefulWidget {
  final String idAtleta;
  const FichaListPage({required this.idAtleta, Key? key}): super(key: key);

  @override
  State<FichaListPage> createState() => _FichaListPageState();
}

class _FichaListPageState extends State<FichaListPage> {
  final repo = FichaRepository();
  late Future<List<Ficha>> _futureFichas;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _futureFichas = repo.getFichasPorAtleta(widget.idAtleta);
  }

  void _onAdd() async {
    final nova = await showDialog<Ficha>(
      context: context,
      builder: (_) => FichaFormDialog(
        idAtleta: widget.idAtleta,
        idTreinador: 'treinador-abc',
      ),
    );
    if (nova != null) {
      await repo.createFicha(nova);
      _load();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext ctx) => Scaffold(
        appBar: AppBar(title: const Text('Fichas de Treino')),
        body: FutureBuilder<List<Ficha>>(
          future: _futureFichas,
          builder: (_, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final fichas = snap.data ?? [];
            if (fichas.isEmpty) {
              return const Center(child: Text('Nenhuma ficha ainda.'));
            }
            return ListView.builder(
              itemCount: fichas.length,
              itemBuilder: (_, i) {
                final f = fichas[i];
                return ListTile(
                  title: Text('Dia ${f.diaSemana} – ${f.categoria.name}'),
                  subtitle: Text(f.descricao),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await repo.deleteFicha(f.id);
                      _load();
                      setState(() {});
                    },
                  ),
                  onTap: () async {
                    final edit = await showDialog<Ficha>(
                      context: context,
                      builder: (_) => FichaFormDialog(
                        idAtleta: f.idAtleta,
                        idTreinador: f.idTreinador,
                        ficha: f,
                      ),
                    );
                    if (edit != null) {
                      await repo.updateFicha(edit);
                      _load();
                      setState(() {});
                    }
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _onAdd,
          child: const Icon(Icons.add),
        ),
      );
