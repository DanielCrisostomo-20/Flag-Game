
import 'package:flutter/material.dart';
import 'paises.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const FlagGame());
}

class FlagGame extends StatelessWidget {
  const FlagGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flag Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const MenuScreen(),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flag Game'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Image.asset(
                'assets/logo_flag_game.jpg',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),


              const SizedBox(height: 16),

              const Text(
                'Teste seus conhecimentos!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContinenteScreen(),
                      ),
                    );
                  },
                  child: const Text('Jogar por Continente'),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child:
                ElevatedButton(
                  onPressed: () async {
                    // Abre a tela para escolher o tempo
                    final tempo = await Navigator.push<int>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TempoScreen(),
                      ),
                    );

                    // Se um tempo foi escolhido, inicia o jogo aleatório
                    if (tempo != null && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JogoScreen(
                            tempoInicial: tempo,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Jogo Aleatório'),
                ),

              ),


              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final tempo = await Navigator.push<int>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TempoScreen(),
                      ),
                    );

                    if (tempo != null && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JogoScreen(
                            tempoInicial: tempo,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Configurar Tempo'),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class TempoScreen extends StatelessWidget {
  const TempoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Tempo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Escolha o tempo da partida:',
              style: TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, 30);
              },
              child: const Text('30 segundos'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, 60);
              },
              child: const Text('60 segundos'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, 180);
              },
              child: const Text('3 minutos'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, 300);
              },
              child: const Text('5 minutos'),
            ),
          ],
        ),
      ),
    );
  }
}


class ContinenteScreen extends StatelessWidget {
  const ContinenteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final continentes = [
      'África',
      'América',
      'Ásia',
      'Europa',
      'Oceania',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha um continente'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: continentes.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              onPressed: () async {
                final tempo = await Navigator.push<int>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TempoScreen(),
                  ),
                );

                if (tempo != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JogoScreen(
                        continente: continentes[index],
                        tempoInicial: tempo,
                      ),
                    ),
                  );
                }
              },
              child: Text(continentes[index]),
            ),
          );
        },
      ),
    );
  }
}

class JogoScreen extends StatefulWidget {
  final String? continente;
  final int tempoInicial;

  const JogoScreen({
    super.key,
    this.continente,
    this.tempoInicial = 60,
  });

  @override
  State<JogoScreen> createState() => _JogoScreenState();
}

class _JogoScreenState extends State<JogoScreen> {
  late List<Pais> listaPaises;
  late Pais pergunta;

  List<Pais> alternativas = [];
  int pontuacao = 0;
  int respondidas = 0;
  late int tempoRestante;
  Timer? cronometro;
  bool jogoEncerrado = false;

  @override
  void initState() {
    super.initState();

    tempoRestante = widget.tempoInicial;

    listaPaises = paises
        .where((p) =>
    widget.continente == null ||
        p.continente == widget.continente)
        .toList();

    listaPaises.shuffle();
    _novaPergunta();
    _iniciarCronometro();

  }
  void _iniciarCronometro() {
    cronometro = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (tempoRestante > 0) {
          setState(() {
            tempoRestante--;
          });
        } else {
          timer.cancel();
          _finalizarJogo();
        }
      },
    );
  }


  Future<void> _finalizarJogo() async {
    // Para o cronômetro
    cronometro?.cancel();

    // Evita finalizar o jogo mais de uma vez
    if (jogoEncerrado) return;

    setState(() {
      jogoEncerrado = true;
    });

    // Calcula o percentual de acertos
    final percentual = respondidas == 0
        ? 0.0
        : (pontuacao / respondidas) * 100;

    // Acessa o armazenamento do celular
    final prefs = await SharedPreferences.getInstance();

    // Busca o recorde salvo. Se não existir, começa em zero.
    int recorde = prefs.getInt('recorde') ?? 0;

    // Salva somente se a pontuação atual for maior
    if (pontuacao > recorde) {
      recorde = pontuacao;
      await prefs.setInt('recorde', recorde);
    }

    // Verifica se a tela ainda existe
    if (!mounted) return;

    // Abre a tela de resultado
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Resultado Final'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: Colors.orange,
                  ),

                  const SizedBox(height: 20),

                  Text('Perguntas respondidas: $respondidas'),

                  Text('Acertos: $pontuacao'),

                  Text(
                    'Percentual de acertos: '
                        '${percentual.toStringAsFixed(1)}%',
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Recorde: $recorde pontos',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 25),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(
                        context,
                            (route) => route.isFirst,
                      );
                    },
                    child: const Text('Voltar ao menu'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  void _novaPergunta() {
    if (listaPaises.length < 4) return;

    pergunta = listaPaises[
    respondidas % listaPaises.length];

    alternativas = List<Pais>.from(listaPaises)
      ..remove(pergunta);

    alternativas.shuffle();

    alternativas = [
      pergunta,
      ...alternativas.take(3),
    ];

    alternativas.shuffle();
  }

  void _responder(Pais resposta) {
    if (jogoEncerrado) return;
    final acertou = resposta.nome == pergunta.nome;

    setState(() {
      respondidas++;

      if (acertou) {
        pontuacao++;
      }

      _novaPergunta();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          acertou ? 'Resposta correta!' : 'Resposta errada!',
        ),
        duration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flag Game'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Pontuação: $pontuacao',
                style: const TextStyle(fontSize: 20),
              ),

              const SizedBox(height: 10),

              Text(
                'Tempo restante: $tempoRestante segundos',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 25),

              Text(
                pergunta.bandeira,
                style: const TextStyle(fontSize: 90),
              ),

              const SizedBox(height: 15),

              const Text(
                'A qual país pertence esta bandeira?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 20),

              ...alternativas.map((pais) {
                return SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton(
                      onPressed: () => _responder(pais),
                      child: Text(pais.nome),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    cronometro?.cancel();
    super.dispose();
  }
}
