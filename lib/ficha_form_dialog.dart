import 'package:flutter/material.dart';
import 'ficha.dart';

class FichaFormDialog extends StatefulWidget {
  final String idAtleta;
  final String idTreinador;
  final Ficha? ficha;

  const FichaFormDialog({
    required this.idAtleta,
    required this.idTreinador,
    this.ficha,
    Key? key,
  }) : super(key: key);

  @override
  State<FichaFormDialog> createState() => _FichaFormDialogState();
}

class _FichaFormDialogState extends State<FichaFormDialog> {
  final _formKey = GlobalKey<FormState>();
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
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<Categoria>(
              value: categoria,
              items: Categoria.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
              onChanged: (v) => setState(() => categoria = v!),
              decoration: const InputDecoration(labelText: 'Categoria'),
            ),
            DropdownButtonFormField<int>(
              value: diaSemana,
              items: List.generate(7, (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text(['Seg','Ter','Qua','Qui','Sex','Sáb','Dom'][i]),
                  )),
              onChanged: (v) => setState(() => diaSemana = v!),
              decoration: const InputDecoration(labelText: 'Dia da Semana'),
            ),
            TextFormField(
              initialValue: descricao,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
              onSaved: (v) => descricao = v ?? '',
              validator: (v) =>
                  (v?.isEmpty ?? true) ? 'Informe a descrição' : null,
            ),
            DropdownButtonFormField<StatusFicha>(
              value: status,
              items: StatusFicha.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged: (v) => setState(() => status = v!),
              decoration: const InputDecoration(labelText: 'Status'),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              _formKey.currentState!.save();
              final nova = Ficha(
                id: widget.ficha?.id ?? '',
                idAtleta: widget.idAtleta,
                idTreinador: widget.idTreinador,
                categoria: categoria,
                diaSemana: diaSemana,
                descricao: descricao,
                status: status,
                criadoEm: widget.ficha?.criadoEm ?? DateTime.now(),
              );
              Navigator.pop(ctx, nova);
            },
            child: const Text('Salvar'),
          ),
        ],
      );
