import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'globals.dart';
import 'auth.dart';
import 'data_service.dart';

final dataService = DataService();

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<FormState> key = GlobalKey();
  bool validate = false, logado = false;
  String username = '', senha = '';
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return logado
        ? MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text("First.AM"),
              ),
              body: getPageContent(),
              bottomNavigationBar: BottomNavBar(callback: onPageChanged),
            ),
          )
        : MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('first.AM')),
              body: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(15.0),
                  child: Form(key: key, child: loginForm()),
                ),
              ),
            ),
          );
  }

  Widget getPageContent() {
    if (currentPage == 0) {
      return ReportsPage();
    } else if (currentPage == 1) {
      return ChartsPage();
    } else if (currentPage == 2) {
      return const Center(child: Text("Apps de Terceiros Page"));
    }
    return Container();
  }

  void onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  Widget loginForm() {
    return Column(
      children: <Widget>[
        TextFormField(
          decoration: const InputDecoration(hintText: 'Nome de usuário'),
          maxLength: 40,
          onSaved: (String? val) {
            username = val!;
          },
        ),
        TextFormField(
          decoration: const InputDecoration(hintText: 'Senha'),
          maxLength: 40,
          obscureText: true,
          onSaved: (String? val) {
            senha = val!;
          },
        ),
        ElevatedButton(
          onPressed: sendForm,
          child: const Text('Enviar'),
        )
      ],
    );
  }

  void sendForm() {
    if (key.currentState!.validate()) {
      key.currentState!.save();

      fetchAccessToken(username, senha).then((res) {
        usuario.setKey(key: res['lfm']['session']['key']);
        usuario.setName(name: res['lfm']['session']['name']);
        debugPrint('key = ${usuario.key}\nname = ${usuario.name}');
      });

      setState(() {
        logado = true;
      });
    } else {
      setState(() {
        validate = true;
      });
    }
  }
}

class BottomNavBar extends HookWidget {
  final Function(int) callback;

  BottomNavBar({Key? key, required this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var state = useState(0);
    return BottomNavigationBar(
      onTap: (index) {
        state.value = index;
        callback(index);
      },
      currentIndex: state.value,
      items: const [
        BottomNavigationBarItem(
          label: "Relatórios",
          icon: Icon(Icons.date_range),
        ),
        BottomNavigationBarItem(
          label: "Gráficos",
          icon: Icon(Icons.show_chart),
        ),
        BottomNavigationBarItem(
          label: "Apps de Terceiros",
          icon: Icon(Icons.device_hub),
        ),
      ],
    );
  }
}

class ChartsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    dataService.carregar();

    return Scaffold(
        body: ValueListenableBuilder(
            valueListenable: dataService.stateNotifier,
            builder: (_, value, __) {
              return ListView(
                children: [
                  const ListTile(title: Text("Top 10 Músicas - Brasil")),
                  Column(
                    children: value["tracks"].map((track) => Card(child: Text('${int.parse(track['@attr']['rank']) + 1}. ${track["name"]} - ${track["artist"]["name"]}'))).toList().cast<Widget>(),
                  ),
                  const ListTile(title: Text("Top 10 Artistas - Brasil")),
                  Column(
                    children: value["artists"].map((artist) => Card(child: Text('${artist["name"]}'))).toList().cast<Widget>(),
                  )
                ],
              );
            }));
  }
}

class ReportsPage extends StatelessWidget {
  final List<String> reportOptions = ['Artistas', 'Músicas', 'Álbuns'];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: reportOptions.length,
      itemBuilder: (context, index) {
        return ListTile(
            title: Text(reportOptions[index]),
            onTap: () {
              if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ArtistsPage()),
                );
              }
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SongsPage()),
                );
              }
              if (index == 2) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AlbunsPage()));
              }
            });
      },
    );
  }
}

class ArtistsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Artistas")),
      body: Center(child: Text("Página de artistas")),
    );
  }
}

class ReportsPage extends StatelessWidget {
  final List<String> reportOptions = ['Artistas', 'Músicas', 'Álbuns'];

class SongsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: reportOptions.length,
      itemBuilder: (context, index) {
        return ListTile(
            title: Text(reportOptions[index]),
            onTap: () {
              if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ArtistsPage()),
                );
              }
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SongsPage()),
                );
              }
              if (index == 2) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AlbunsPage()));
              }
            });
      },
    );
  }
}

class ArtistsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Artistas")),
      body: Center(child: Text("Página de artistas")),
    );
  }
}

class SongsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Músicas")),
      body: Center(child: Text("Página de músicas")),
    );
  }
}

class AlbunsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Álbuns")),
      body: Center(child: Text("Página de álbuns")),
    );
  }
}

