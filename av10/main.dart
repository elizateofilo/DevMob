import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(MyApp());
}

class User {
  final String email;

  User({required this.email});
}

class Filme {
  final int id;
  final String titulo;
  final int anoLancamento;

  Filme({required this.id, required this.titulo, required this.anoLancamento});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'anoLancamento': anoLancamento,
    };
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Montserrat',
      ),
      home: MenuPage(user: User(email: 'example@email.com')),
    );
  }
}

class DBHelper {
  late Database _database;

  Future<void> open() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'filmes.db');

    _database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE filmes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          titulo TEXT,
          anoLancamento INTEGER
        )
      ''');
    });
  }

  Future<void> insertFilme(Filme filme) async {
    await _database.insert('filmes', filme.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Filme>> getFilmes() async {
    final List<Map<String, dynamic>> maps = await _database.query('filmes');

    return List.generate(maps.length, (i) {
      return Filme(
        id: maps[i]['id'],
        titulo: maps[i]['titulo'],
        anoLancamento: maps[i]['anoLancamento'],
      );
    });
  }

  Future<void> updateFilme(Filme filme) async {
    await _database.update(
      'filmes',
      filme.toMap(),
      where: 'id = ?',
      whereArgs: [filme.id],
    );
  }

  Future<void> deleteFilme(int id) async {
    await _database.delete(
      'filmes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class MenuPage extends StatelessWidget {
  final User user;

  MenuPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DBHelper().open(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Maria Eliza e Sophia Mello'),
              backgroundColor: Colors.black,
            ),
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FilmeCadastroPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text('Cadastrar Filme'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ListaFilmesPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text('Lista de Filmes'),
                  ),
                ],
              ),
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class FilmeCadastroPage extends StatefulWidget {
  @override
  _FilmeCadastroPageState createState() => _FilmeCadastroPageState();
}

class _FilmeCadastroPageState extends State<FilmeCadastroPage> {
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController anoLancamentoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Filme'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: tituloController,
              decoration: InputDecoration(
                labelText: 'Título *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefixIcon: Icon(Icons.movie, color: Colors.black),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: anoLancamentoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Ano de Lançamento *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefixIcon: Icon(Icons.calendar_today, color: Colors.black),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (tituloController.text.isNotEmpty && anoLancamentoController.text.isNotEmpty) {
                  Filme novoFilme = Filme(
                    id: 0,
                    titulo: tituloController.text,
                    anoLancamento: int.parse(anoLancamentoController.text),
                  );

                  DBHelper().insertFilme(novoFilme);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Filme cadastrado com sucesso!'),
                    ),
                  );

                  tituloController.clear();
                  anoLancamentoController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Título e ano de lançamento são obrigatórios.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text('Cadastrar Filme'),
            ),
          ],
        ),
      ),
    );
  }
}

class ListaFilmesPage extends StatefulWidget {
  @override
  _ListaFilmesPageState createState() => _ListaFilmesPageState();
}

class _ListaFilmesPageState extends State<ListaFilmesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Filmes'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder(
        future: DBHelper().getFilmes(),
        builder: (context, AsyncSnapshot<List<Filme>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5.0,
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: Text(snapshot.data![index].titulo),
                    subtitle: Text('Ano de Lançamento: ${snapshot.data![index].anoLancamento}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _editarFilme(context, snapshot.data![index]);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deletarFilme(context, snapshot.data![index].id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  void _editarFilme(BuildContext context, Filme filme) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFilmePage(
          filme: filme,
          onUpdate: (filme) {
            setState(() {});
          },
        ),
      ),
    );
  }

  void _deletarFilme(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar exclusão'),
          content: Text('Deseja realmente excluir este filme?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                DBHelper().deleteFilme(id);
                setState(() {});
                Navigator.pop(context);
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }
}

class EditFilmePage extends StatefulWidget {
  final Filme filme;
  final Function(Filme) onUpdate;

  EditFilmePage({required this.filme, required this.onUpdate});

  @override
  _EditFilmePageState createState() => _EditFilmePageState();
}

class _EditFilmePageState extends State<EditFilmePage> {
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController anoLancamentoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tituloController.text = widget.filme.titulo;
    anoLancamentoController.text = widget.filme.anoLancamento.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Filme'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: tituloController,
              decoration: InputDecoration(
                labelText: 'Título *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefixIcon: Icon(Icons.movie, color: Colors.black),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: anoLancamentoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Ano de Lançamento *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefixIcon: Icon(Icons.calendar_today, color: Colors.black),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (tituloController.text.isNotEmpty && anoLancamentoController.text.isNotEmpty) {
                  Filme filmeAtualizado = Filme(
                    id: widget.filme.id,
                    titulo: tituloController.text,
                    anoLancamento: int.parse(anoLancamentoController.text),
                  );

                  DBHelper().updateFilme(filmeAtualizado);
                  widget.onUpdate(filmeAtualizado);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Título e ano de lançamento são obrigatórios.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}