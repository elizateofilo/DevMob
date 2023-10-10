import 'package:flutter/material.dart';
// Uncomment lines 3 and 6 to view the visual layout at runtime.
// import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;

void main() {
  // debugPaintSizeEnabled = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget titleSection = Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: const Text(
                    'Monte Roraima',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Uiramutã, Roraima',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          /*3*/
          Icon(
            Icons.star,
            color: Colors.yellow[500],
          ),
          const Text('41'),
        ],
      ),
    );

    Color color = Theme.of(context).primaryColor;

    Widget buttonSection = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButtonColumn(color, Icons.call, 'Ligar'),
        _buildButtonColumn(color, Icons.near_me, 'Rota'),
        _buildButtonColumn(color, Icons.share, 'Compartilhar'),
      ],
    );

    Widget textSection = Container(
      padding: const EdgeInsets.all(32),
      child: const Text(
        'Essa bela vista ficou conhecida internacionalmente depois de aparecer na animação Up – Altas Aventuras.'
        'Para chegar lá é preciso muita disposição, são 3 dias só para chegar no topo e 2 para voltar.'
        'As expedições são de no mínimo 6 dias e é necessário acampar pelo caminho.  '
        'mas a recompensa é incrível – tanto durante o percurso quanto a paisagem vista em seu destino final.'
        'Com uma altitude de 2.875 metros, o Monte Roraima é o oitavo ponto mais alto do Brasil. ',
        softWrap: true,
      ),
    );

    return MaterialApp(
      title: 'Layout demo Maria Eliza',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Maria Eliza'),
        ),
        body: ListView(
          children: [
            Image.asset(
              'images/mr.jpg',
              width: 600,
              height: 240,
              fit: BoxFit.cover,
            ),
            titleSection,
            buttonSection,
            textSection,
          ],
        ),
      ),
    );
  }

  Column _buildButtonColumn(Color color, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
