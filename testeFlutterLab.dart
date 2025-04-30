import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

// ───── Modelo ─────
enum Categoria { iniciante, intermediario, avancado }
enum StatusFicha { ativo, finalizado }

class Ficha {
  final String id, idAtleta, idTreinador, descricao;
  final Categoria categoria;
  final int diaSemana;
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
}

// ───── Repositório em memória ─────
class FakeFichaRepository {
  int _counter = 0;
  final List<Ficha> _storage = [];

  Future<String> createFicha(Ficha f) async {
    final id = (++_counter).toString();
    _storage.add(Ficha(
      id: id,
      idAtleta: f.idAtleta,
      idTreinador: f.idTreinador,
      categoria: f.categoria,
      diaSemana: f.diaSemana,
      descricao: f.descricao,
      status: f.status,
      criadoEm: DateTime.now(),
    ));
    return id;
  }

  Future<List<Ficha>> getFichasPorAtleta(String atleta) async =>
      _storage.where((f) => f.idAtleta == atleta).toList();

  Future<void> updateFicha(Ficha f) async {
    final i = _storage.indexWhere((x) => x.id == f.id);
    if (i >= 0) _storage[i] = f;
  }

  Future<void> deleteFicha(String id) async {
    _storage.removeWhere((f) => f.id == id);
  }
}

// ───── App Principal ─────
class MyApp extends StatelessWidget {
  const MyApp({Key? key}): super(key: key);
  @override
  Widget build(BuildContext c) => MaterialApp(
    title: 'CRUD em Memória',
    theme: ThemeData(
      primarySwatch: Colors.indigo,
      scaffoldBackgroundColor: Colors.grey[50],
    ),
    home: const FichaListPage(idAtleta: 'atleta-123'),
  );
}

class FichaListPage extends StatefulWidget {
  final String idAtleta;
  const FichaListPage({required this.idAtleta, Key? key}): super(key: key);
  @override
  State<FichaListPage> createState() => _FichaListPageState();
}

class _FichaListPageState extends State<FichaListPage> {
  final repo = FakeFichaRepository();
  late Future<List<Ficha>> fut;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => fut = repo.getFichasPorAtleta(widget.idAtleta);

  void _add() async {
    final nova = await showDialog<Ficha>(
      context: context,
      builder: (_) => FichaFormDialog(
        idAtleta: widget.idAtleta,
        idTreinador: 'treinador-xyz',
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
    appBar: AppBar(title: const Text('Minhas Fichas')),
    body: FutureBuilder<List<Ficha>>(
      future: fut,
      builder: (_, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snap.data!;
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Nenhuma ficha criada ainda',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                SizedBox(height: 8),
                Text('Toque no + para adicionar',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final f = list[i];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text('Dia ${f.diaSemana} – ${f.categoria.name.capitalize()}'),
                subtitle: Text(f.descricao),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await repo.deleteFicha(f.id);
                    _load(); setState(() {});
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
                    _load(); setState(() {});
                  }
                },
              ),
            );
          },
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _add,
      child: const Icon(Icons.add),
    ),
  );
}

extension on String {
  String capitalize() => isEmpty ? '' : this[0].toUpperCase() + substring(1);
}

class FichaFormDialog extends StatefulWidget {
  final String idAtleta, idTreinador;
  final Ficha? ficha;
  const FichaFormDialog({
    required this.idAtleta,
    required this.idTreinador,
    this.ficha,
    Key? key
  }): super(key: key);
  @override
  State<FichaFormDialog> createState() => _FichaFormDialogState();
}

class _FichaFormDialogState extends State<FichaFormDialog> {
  final _form = GlobalKey<FormState>();
  late Categoria categoria;
  late int diaSemana;
  late String descricao;
  late StatusFicha status;

  @override
  void initState() {
    super.initState();
    final f = widget.ficha;
    categoria = f?.categoria ?? Categoria.iniciante;
    diaSemana = f?.diaSemana ?? 1;
    descricao = f?.descricao ?? '';
    status = f?.status ?? StatusFicha.ativo;
  }

  @override
  Widget build(BuildContext ctx) => AlertDialog(
    title: Text(widget.ficha == null ? 'Nova Ficha' : 'Editar Ficha'),
    content: Form(
      key: _form,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<Categoria>(
          value: categoria,
          items: Categoria.values.map((c) =>
            DropdownMenuItem(value: c, child: Text(c.name.capitalize()))
          ).toList(),
          onChanged: (v) => setState(() => categoria = v!),
          decoration: const InputDecoration(labelText: 'Categoria'),
        ),
        DropdownButtonFormField<int>(
          value: diaSemana,
          items: List.generate(7, (i) =>
            DropdownMenuItem(value: i+1, child: Text(['Seg','Ter','Qua','Qui','Sex','Sáb','Dom'][i]))
          ),
          onChanged: (v) => setState(() => diaSemana = v!),
          decoration: const InputDecoration(labelText: 'Dia da Semana'),
        ),
        TextFormField(
          initialValue: descricao,
          decoration: const InputDecoration(labelText: 'Descrição'),
          maxLines: 3,
          onSaved: (v) => descricao = v ?? '',
          validator: (v) => (v?.isEmpty ?? true) ? 'Informe a descrição' : null,
        ),
        DropdownButtonFormField<StatusFicha>(
          value: status,
          items: StatusFicha.values.map((s) =>
            DropdownMenuItem(value: s, child: Text(s.name.capitalize()))
          ).toList(),
          onChanged: (v) => setState(() => status = v!),
          decoration: const InputDecoration(labelText: 'Status'),
        ),
      ]),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('✖')),
      ElevatedButton(
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          _form.currentState!.save();
          Navigator.pop(ctx, Ficha(
            id: widget.ficha?.id ?? '',
            idAtleta: widget.idAtleta,
            idTreinador: widget.idTreinador,
            categoria: categoria,
            diaSemana: diaSemana,
            descricao: descricao,
            status: status,
            criadoEm: widget.ficha?.criadoEm ?? DateTime.now(),
          ));
        },
        child: const Text('✔'),
      ),
    ],
  );
}
