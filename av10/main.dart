import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(MyApp());
}

class Movie {
  final int id;
  String title;
  String director;
  int year;

  Movie({required this.id, required this.title, required this.director, required this.year});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'director': director, 'year': year};
  }
}

class DBHelper {
  DBHelper._(); // Private constructor to prevent instantiation

  static final DBHelper instance = DBHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'movies_database.db');
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE movies(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        director TEXT,
        year INTEGER
      )
    ''');
  }

  Future<int> insertMovie(Movie movie) async {
    Database db = await instance.database;
    return await db.insert('movies', movie.toMap());
  }

  Future<List<Movie>> getAllMovies() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query('movies');
    return result.map((map) => Movie(id: map['id'], title: map['title'], director: map['director'], year: map['year'])).toList();
  }

  Future<int> updateMovie(Movie movie) async {
    Database db = await instance.database;
    return await db.update('movies', movie.toMap(), where: 'id = ?', whereArgs: [movie.id]);
  }

  Future<int> deleteMovie(int id) async {
    Database db = await instance.database;
    return await db.delete('movies', where: 'id = ?', whereArgs: [id]);
  }
}

class MyApp extends StatelessWidget {
  final DBHelper dbHelper = DBHelper.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Filmes',
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: MovieListScreen(dbHelper: dbHelper),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  final DBHelper dbHelper;

  MovieListScreen({required this.dbHelper});

  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  List<Movie> movies = [];

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    List<Movie> loadedMovies = await widget.dbHelper.getAllMovies();
    setState(() {
      movies = loadedMovies;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Filmes'),
      ),
      body: ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          Movie movie = movies[index];
          return Dismissible(
            key: Key(movie.id.toString()),
            onDismissed: (direction) async {
              await widget.dbHelper.deleteMovie(movie.id);
              _loadMovies();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${movie.title} excluído com sucesso!'),
                ),
              );
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: ListTile(
              title: Text(movie.title),
              subtitle: Text('${movie.director} - ${movie.year}'),
              onTap: () async {
                bool shouldRefresh = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailScreen(movie: movie, dbHelper: widget.dbHelper),
                  ),
                );

                if (shouldRefresh != null && shouldRefresh) {
                  // Refresh the movie list if changes were made
                  _loadMovies();
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to the screen to add a new movie
          bool shouldRefresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieAddScreen(dbHelper: widget.dbHelper),
            ),
          );

          if (shouldRefresh != null && shouldRefresh) {
            // Refresh the movie list if a new movie was added
            _loadMovies();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class MovieAddScreen extends StatefulWidget {
  final DBHelper dbHelper;

  MovieAddScreen({required this.dbHelper});

  @override
  _MovieAddScreenState createState() => _MovieAddScreenState();
}

class _MovieAddScreenState extends State<MovieAddScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController directorController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Filme'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: directorController,
              decoration: InputDecoration(
                labelText: 'Diretor',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: yearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Ano',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String title = titleController.text;
                String director = directorController.text;
                int year = int.tryParse(yearController.text) ?? 0;

                Movie newMovie = Movie(id: 0, title: title, director: director, year: year);
                await widget.dbHelper.insertMovie(newMovie);

                Navigator.pop(context, true); // Signal to refresh the movie list
              },
              child: Text('Adicionar Filme'),
            ),
          ],
        ),
      ),
    );
  }
}

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;
  final DBHelper dbHelper;

  MovieDetailScreen({required this.movie, required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Filme'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              bool shouldRefresh = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieEditScreen(movie: movie, dbHelper: dbHelper),
                ),
              );

              if (shouldRefresh != null && shouldRefresh) {
                Navigator.pop(context, true); // Signal to refresh the movie list
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Título: ${movie.title}', style: TextStyle(fontSize: 18)),
            Text('Diretor: ${movie.director}', style: TextStyle(fontSize: 18)),
            Text('Ano: ${movie.year}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

class MovieEditScreen extends StatefulWidget {
  final Movie movie;
  final DBHelper dbHelper;

  MovieEditScreen({required this.movie, required this.dbHelper});

  @override
  _MovieEditScreenState createState() => _MovieEditScreenState();
}

class _MovieEditScreenState extends State<MovieEditScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController directorController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.movie.title;
    directorController.text = widget.movie.director;
    yearController.text = widget.movie.year.toString();
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: directorController,
              decoration: InputDecoration(
                labelText: 'Diretor',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: yearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Ano',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                widget.movie.title = titleController.text;
                widget.movie.director = directorController.text;
                widget.movie.year = int.tryParse(yearController.text) ?? 0;

                await widget.dbHelper.updateMovie(widget.movie);

                Navigator.pop(context, true); // Signal to refresh the movie list
              },
              child: Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
