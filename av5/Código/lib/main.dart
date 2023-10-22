import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class User {
  final String email;

  User({required this.email});
}

class Cadastro {
  final String nome;
  final String descricao;

  Cadastro({required this.nome, this.descricao = ''});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tela de Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: senhaController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Aqui você pode adicionar a lógica de autenticação
                  String email = emailController.text;
                  String senha = senhaController.text;

                  // Exemplo de validação simples (substitua por sua lógica real)
                  if (email.isNotEmpty && senha.isNotEmpty) {
                    User user = User(email: email);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MenuPage(user: user)),
                    );
                  } else {
                    // Adicione um feedback para o usuário (ex: exibindo um SnackBar)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Email e senha são obrigatórios.'),
                      ),
                    );
                  }
                },
                child: Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuPage extends StatelessWidget {
  final User user;

  MenuPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
      ),
      drawer: MyDrawer(user: user),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bem-vindo, ${user.email}!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Image.asset(
              'image/01.jpg',  // Substitua pelo caminho da sua imagem
              width: 650,
              height: 450,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  final User user;

  MyDrawer({required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text('Cadastro 1'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CadastroPage(title: 'Cadastro 2')),
              );
            },
          ),
          ListTile(
            title: Text('Cadastro 2'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CadastroPage(title: 'Cadastro 2')),
              );
            },
          ),
          ListTile(
            title: Text('Cadastro 3'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CadastroPage(title: 'Cadastro 3')),
              );
            },
          ),
          ListTile(
            title: Text('Lista de Cadastros'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListaCadastrosPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CadastroPage extends StatefulWidget {
  final String title;

  CadastroPage({required this.title});

  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome *'),
            ),
            TextField(
              controller: descricaoController,
              decoration: InputDecoration(labelText: 'Descrição (opcional)'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Validar se o campo de nome está preenchido
                if (nomeController.text.isNotEmpty) {
                  // Criar um novo cadastro
                  Cadastro novoCadastro = Cadastro(
                    nome: nomeController.text,
                    descricao: descricaoController.text,
                  );

                  // Adicionar o novo cadastro à Lista de Cadastros
                  // (Para simplificar, estamos usando uma variável global temporária)
                  listaCadastros.add(novoCadastro);

                  // Feedback para o usuário
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cadastro salvo com sucesso!'),
                    ),
                  );

                  // Limpar os campos após salvar
                  nomeController.clear();
                  descricaoController.clear();
                } else {
                  // Feedback se o campo de nome estiver vazio
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('O campo de nome é obrigatório.'),
                    ),
                  );
                }
              },
              child: Text('Salvar Cadastro'),
            ),
          ],
        ),
      ),
    );
  }
}

class ListaCadastrosPage extends StatefulWidget {
  @override
  _ListaCadastrosPageState createState() => _ListaCadastrosPageState();
}

class _ListaCadastrosPageState extends State<ListaCadastrosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Cadastros'),
      ),
      body: ListView.builder(
        itemCount: listaCadastros.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(listaCadastros[index].nome),
            subtitle: Text(listaCadastros[index].descricao),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _editarCadastro(context, index);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deletarCadastro(context, index);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _editarCadastro(BuildContext context, int index) {
    // Navegar para a página de edição de cadastro
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCadastroPage(
          cadastro: listaCadastros[index],
          onUpdate: (cadastro) {
            setState(() {
              listaCadastros[index] = cadastro;
            });
          },
        ),
      ),
    );
  }

  void _deletarCadastro(BuildContext context, int index) {
    // Mostrar um diálogo de confirmação antes de deletar
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar exclusão'),
          content: Text('Deseja realmente excluir este cadastro?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fechar o diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Deletar o cadastro e fechar o diálogo
                setState(() {
                  listaCadastros.removeAt(index);
                });
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

class EditCadastroPage extends StatefulWidget {
  final Cadastro cadastro;
  final Function(Cadastro) onUpdate;

  EditCadastroPage({required this.cadastro, required this.onUpdate});

  @override
  _EditCadastroPageState createState() => _EditCadastroPageState();
}

class _EditCadastroPageState extends State<EditCadastroPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nomeController.text = widget.cadastro.nome;
    descricaoController.text = widget.cadastro.descricao;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Cadastro'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome *'),
            ),
            TextField(
              controller: descricaoController,
              decoration: InputDecoration(labelText: 'Descrição (opcional)'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Validar se o campo de nome está preenchido
                if (nomeController.text.isNotEmpty) {
                  // Criar um novo cadastro atualizado
                  Cadastro cadastroAtualizado = Cadastro(
                    nome: nomeController.text,
                    descricao: descricaoController.text,
                  );

                  // Chamar a função de atualização e fechar a página de edição
                  widget.onUpdate(cadastroAtualizado);
                  Navigator.pop(context);
                } else {
                  // Feedback se o campo de nome estiver vazio
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('O campo de nome é obrigatório.'),
                    ),
                  );
                }
              },
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

// Lista temporária de cadastros (substitua por um gerenciamento de estado mais robusto)
List<Cadastro> listaCadastros = [];
