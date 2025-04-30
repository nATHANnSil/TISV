import 'package:flutter/material.dart';
import 'ficha_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD de Fichas',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const FichaListPage(idAtleta: 'atleta-123'),
    );
  }
}
