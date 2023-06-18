import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'globals.dart';
import 'auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      return ExternalLinks();
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
          label: "Links de Terceiros",
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
                      children: value["tracks"]
                          .map((track) {
                            return ListTile(
                                title: Text(track["name"]),
                                subtitle: Text(track["artist"]["name"]),
                                leading: Image.network(
                                    track["image"].elementAt(0)["#text"]));
                          })
                          .toList()
                          .cast<Widget>()),
                  const ListTile(title: Text("Top 10 Artistas - Brasil")),
                  Column(
                    children: value["artists"]
                        .map((artist) => Card(child: Text('${artist["name"]}')))
                        .toList()
                        .cast<Widget>(),
                  )
                ],
              );
            }));
  }
}

class ReportsPage extends StatelessWidget {
  ReportsPage({Key? key}) : super(key: key);
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
                  MaterialPageRoute(builder: (context) => UserArtistsPage()),
                );
              }
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserTracksPage()),
                );
              }
              if (index == 2) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => UserAlbumsPage()));
              }
            });
      },
    );
  }
}

class UserArtistsPage extends StatefulWidget {
  const UserArtistsPage({Key? key}) : super(key: key);
  @override
  UserArtistsPageState createState() => UserArtistsPageState();
}

class UserArtistsPageState extends State<UserArtistsPage> {
  List<String> artists = [];
  int selectedLimit = 10;

  @override
  void initState() {
    super.initState();
    fetchUserArtists();
  }

  Future<void> fetchUserArtists() async {
    const apiKey = 'f62a2d2d3a59bc0a79c85e8f04e18b8b';
    final username = usuario.name;

    final url =
        'http://ws.audioscrobbler.com/2.0/?method=user.gettopartists&user=$username&api_key=$apiKey&format=json&limit=$selectedLimit';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final topArtists = data['topartists']['artist'];

      setState(() {
        artists = List<String>.from(topArtists.map((artist) => artist['name']));
      });
    } else {
      print('Failed to fetch user artists');
    }
  }

  void onLimitChanged(int? value) {
    setState(() {
      selectedLimit = value!;
    });
    fetchUserArtists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          const Text("Seus Artistas Mais Ouvidos"),
          DropdownButton<int>(
            value: selectedLimit,
            items: const [
              DropdownMenuItem<int>(
                value: 5,
                child: Text('5'),
              ),
              DropdownMenuItem<int>(
                value: 10,
                child: Text('10'),
              ),
              DropdownMenuItem<int>(
                value: 20,
                child: Text('20'),
              ),
            ],
            onChanged: onLimitChanged,
          )
        ],
      )),
      body: ListView.builder(
        itemCount: artists.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(artists[index]),
          );
        },
      ),
    );
  }
}

class UserTracksPage extends StatefulWidget {
  const UserTracksPage({Key? key}) : super(key: key);
  @override
  UserTracksPageState createState() => UserTracksPageState();
}

class UserTracksPageState extends State<UserTracksPage> {
  List<String> tracks = [];
  int selectedLimit = 10;

  @override
  void initState() {
    super.initState();
    fetchUserTracks();
  }

  Future<void> fetchUserTracks() async {
    const apiKey = 'f62a2d2d3a59bc0a79c85e8f04e18b8b';
    final username = usuario.name;

    final url =
        'http://ws.audioscrobbler.com/2.0/?method=user.gettoptracks&user=$username&api_key=$apiKey&format=json&limit=$selectedLimit';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final topTracks = data['toptracks']['track'];

      setState(() {
        tracks = List<String>.from(topTracks.map((track) => track['name']));
      });
    } else {
      print('Failed to fetch user songs');
    }
  }

  void onLimitChanged(int? value) {
    setState(() {
      selectedLimit = value!;
    });
    fetchUserTracks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          const Text("Suas Músicas Mais Ouvidas"),
          DropdownButton(
            value: selectedLimit,
            items: const [
              DropdownMenuItem<int>(
                value: 5, 
                child: Text('5'),
              ),
              DropdownMenuItem<int>(
                value: 10, 
                child: Text('10'),
              ),
              DropdownMenuItem<int>(
                value: 20,
                child: Text('20'),
              ),
            ],
            onChanged: onLimitChanged,
          ),
        ],
      )),
      body: ListView.builder(
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(tracks[index]),
          );
        },
      ),
    );
  }
}

class UserAlbumsPage extends StatefulWidget {
  const UserAlbumsPage({Key? key}) : super(key: key);
  @override
  UserAlbumsPageState createState() => UserAlbumsPageState();
}

class UserAlbumsPageState extends State<UserAlbumsPage> {
  List<String> albums = [];
  int selectedLimit = 10;

  @override
  void initState() {
    super.initState();
    fetchUserAlbums();
  }

  Future<void> fetchUserAlbums() async {
    const apiKey = 'f62a2d2d3a59bc0a79c85e8f04e18b8b';
    final username = usuario.name;

    final url =
        'http://ws.audioscrobbler.com/2.0/?method=user.gettopalbums&user=$username&api_key=$apiKey&format=json&limit=$selectedLimit';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final topAlbums = data['topalbums']['album'];

      setState(() {
        albums = List<String>.from(topAlbums.map((album) => album['name']));
      });
    } else {
      print('Failed to fetch user albums');
    }
  }

  void onLimitChanged(int? value) {
    setState(() {
      selectedLimit = value!;
    });
    fetchUserAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Seus Albuns Mais Ouvidos"),
            DropdownButton<int>(
              value: selectedLimit,
              items: const [
                DropdownMenuItem<int>(
                  value: 5,
                  child: Text('5'),
                ),
                DropdownMenuItem<int>(
                  value: 10,
                  child: Text('10'),
                ),
                DropdownMenuItem<int>(
                  value: 20,
                  child: Text('20'),
                ),
              ],
              onChanged: onLimitChanged,
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: albums.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(albums[index]),
          );
        },
      ),
    );
  }
}

class ExternalLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ('Links de terceiros'),
      theme: ThemeData(
        primarySwatch: Colors.green,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 54, 0, 43),
            foregroundColor: const Color.fromARGB(255, 0, 255, 8),
            shadowColor: Colors.red,
          ),
        ),
      ),
      home: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
                margin: EdgeInsets.all(8),
                child: SizedBox(
                    width: 1000,
                    height: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 54, 0, 43),
                          foregroundColor: const Color.fromARGB(255, 0, 255, 8),
                          shadowColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          elevation: 20,
                          textStyle: const TextStyle(
                              color: Colors.black, ///////////
                              fontSize: 30,
                              fontStyle: FontStyle.italic)),
                      onPressed: () =>
                          _launchURL('https://receiptify.herokuapp.com'),
                      child: const Text('Receiptify'),
                    ))),
            Container(
                margin: EdgeInsets.all(8),
                child: SizedBox(
                    width: 1000,
                    height: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 54, 0, 43),
                          foregroundColor: const Color.fromARGB(255, 0, 255, 8),
                          shadowColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          elevation: 20,
                          textStyle: const TextStyle(
                              color: Colors.black, ///////////
                              fontSize: 30,
                              fontStyle: FontStyle.italic)),
                      onPressed: () =>
                          _launchURL('https://huangdarren1106.github.io'),
                      child: const Text('Spotify Pie'),
                    ))),
            Container(
                margin: EdgeInsets.all(8),
                child: SizedBox(
                    width: 1000,
                    height: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 54, 0, 43),
                          foregroundColor: const Color.fromARGB(255, 0, 255, 8),
                          shadowColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          elevation: 20,
                          textStyle: const TextStyle(
                              color: Colors.black, ///////////
                              fontSize: 30,
                              fontStyle: FontStyle.italic)),
                      onPressed: () =>
                          _launchURL('https://salty-beach-42139.herokuapp.com'),
                      child: const Text('Festify'),
                    ))),
            Container(
                margin: EdgeInsets.all(8),
                child: SizedBox(
                    width: 1000,
                    height: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 54, 0, 43),
                          foregroundColor: const Color.fromARGB(255, 0, 255, 8),
                          shadowColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          elevation: 20,
                          textStyle: const TextStyle(
                              color: Colors.black, ///////////
                              fontSize: 30,
                              fontStyle: FontStyle.italic)),
                      onPressed: () => _launchURL('https://www.instafest.app'),
                      child: const Text('InstaFest'),
                    ))),
            Container(
                margin: EdgeInsets.all(8),
                child: SizedBox(
                    width: 1000,
                    height: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 54, 0, 43),
                          foregroundColor: const Color.fromARGB(255, 0, 255, 8),
                          shadowColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          elevation: 20,
                          textStyle: const TextStyle(
                              color: Colors.black, ///////////
                              fontSize: 27,
                              fontStyle: FontStyle.italic)),
                      onPressed: () => _launchURL(
                          'https://pudding.cool/2021/10/judge-my-music/'),
                      child: const Text('How Bad is Your Streaming Music?'),
                    ))),
            Container(
                margin: EdgeInsets.all(8),
                child: SizedBox(
                    width: 1000,
                    height: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 54, 0, 43),
                          foregroundColor: const Color.fromARGB(255, 0, 255, 8),
                          shadowColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          elevation: 20,
                          textStyle: const TextStyle(
                              color: Colors.black, ///////////
                              fontSize: 30,
                              fontStyle: FontStyle.italic)),
                      onPressed: () =>
                          _launchURL('https://musicscapes.herokuapp.com'),
                      child: const Text('MusicScape'),
                    ))),
            Container(
                margin: EdgeInsets.all(8),
                child: SizedBox(
                    width: 1000,
                    height: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 54, 0, 43),
                          foregroundColor: const Color.fromARGB(255, 0, 255, 8),
                          shadowColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          elevation: 20,
                          textStyle: const TextStyle(
                              color: Colors.black, ///////////
                              fontSize: 30,
                              fontStyle: FontStyle.italic)),
                      onPressed: () => _launchURL('https://www.last.fm'),
                      child: const Text('Last.FM'),
                    ))),
          ],
        ),
      ),
    );
  }

  void _launchURL(var url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Não foi possível abrir o link $url';
    }
  }
}
