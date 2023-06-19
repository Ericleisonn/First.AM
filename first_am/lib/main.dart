import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'globals.dart';
import 'auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:getwidget/getwidget.dart';

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
                backgroundColor: const Color.fromRGBO(0, 25, 48, 1),
                titleTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(65, 230, 71, 1),
                    fontSize: 20),
              ),
              body: getPageContent(),
              bottomNavigationBar: BottomNavBar(callback: onPageChanged),
              backgroundColor: const Color.fromRGBO(00, 21, 41, 0.8),
            ),
          )
        : MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Container(
                    margin: const EdgeInsets.all(30.0),
                    child: Column(children: [
                      Container(
                          padding: const EdgeInsets.fromLTRB(0, 80, 0, 50),
                          child: const Center(
                              child: Text(
                            "first.am",
                            style: TextStyle(
                                color: Color.fromRGBO(65, 230, 71, 1),
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          ))),
                      const Center(
                        child: Text(
                          "Precisamos de acesso a sua conta no Last.FM",
                          style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Form(key: key, child: loginForm()),
                    ])),
              ),
              backgroundColor: const Color.fromRGBO(0, 21, 41, 0.8),
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
        const SizedBox(height: 50),
        TextFormField(
            decoration: const InputDecoration(
                hintText: 'Nome de usuário',
                hintStyle: TextStyle(color: Colors.white)),
            maxLength: 40,
            onSaved: (String? val) {
              username = val!;
            }),
        TextFormField(
          decoration: const InputDecoration(
              hintText: 'Senha', hintStyle: TextStyle(color: Colors.white)),
          maxLength: 40,
          obscureText: true,
          onSaved: (String? val) {
            senha = val!;
          },
        ),
        ElevatedButton(
          onPressed: sendForm,
          style: const ButtonStyle(
            backgroundColor:
                MaterialStatePropertyAll<Color>(Color.fromRGBO(65, 230, 71, 1)),
            foregroundColor: MaterialStatePropertyAll<Color>(Colors.black),
          ),
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
  const BottomNavBar({Key? key, required this.callback}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var state = useState(0);
    return BottomNavigationBar(
      selectedItemColor: const Color.fromRGBO(65, 230, 71, 1),
      unselectedItemColor: const Color.fromRGBO(65, 230, 71, 0.4),
      backgroundColor: const Color.fromRGBO(0, 25, 48, 1),
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
        backgroundColor: const Color.fromRGBO(0, 21, 41, 0),
        body: ValueListenableBuilder(
            valueListenable: dataService.stateNotifier,
            builder: (_, value, __) {
              return value["tracks"] == null
                  ? const Center(
                      child: GFLoader(),
                    )
                  : ListView(
                      children: [
                        const ListTile(
                            title: Text("Top 10 Músicas - Brasil"),
                            titleTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20)),
                        Column(
                            children: value["tracks"]
                                .map((track) {
                                  return ListTile(
                                    title: Text(track["name"]),
                                    subtitle: Text(track["artist"]["name"]),
                                    titleTextStyle:
                                        const TextStyle(color: Colors.white),
                                    subtitleTextStyle:
                                        const TextStyle(color: Colors.white70),
                                  );
                                })
                                .toList()
                                .cast<Widget>()),
                        const ListTile(
                            title: Text("Top 10 Artistas - Brasil"),
                            titleTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20)),
                        Column(
                          children: value["artists"]
                              .map((artist) => ListTile(
                                    title: Text('${artist["name"]}'),
                                    titleTextStyle:
                                        const TextStyle(color: Colors.white),
                                  ))
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
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
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
          },
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        );
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
  List<dynamic> artists = [];
  int selectedLimit = 10;

  @override
  void initState() {
    super.initState();
    fetchUserArtists();
  }

  Future<void> fetchUserArtists() async {
    try {
      const apiKey = 'f62a2d2d3a59bc0a79c85e8f04e18b8b';
      final username = usuario.name;

      final url =
          'http://ws.audioscrobbler.com/2.0/?method=user.gettopartists&user=$username&api_key=$apiKey&format=json&limit=$selectedLimit';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final topArtists = data['topartists']['artist'];

        setState(() {
          artists = List<dynamic>.from(topArtists);
        });
      } else {
        print('Failed to fetch user artists');
      }
    } catch (err) {
      GFToast.showToast("Usuário ou senha incorreto(s)!", context);
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
          backgroundColor: const Color.fromRGBO(0, 25, 49, 1),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Seus Artistas Mais Ouvidos"),
              DropdownButton<int>(
                dropdownColor: const Color.fromRGBO(0, 25, 47, 1),
                style: const TextStyle(color: Colors.white),
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
      body: artists == []
          ? const Center(
              child: GFLoader(),
            )
          : ListView.builder(
              itemCount: artists.length,
              itemBuilder: (context, index) {
                final artist = artists[index];
                return ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: Image.network(artist['image'][3]['#text']),
                  title: Text(artist['name']),
                  titleTextStyle: const TextStyle(color: Colors.white),
                );
              },
            ),
      backgroundColor: const Color.fromRGBO(0, 21, 41, 0.8),
    );
  }
}

class UserTracksPage extends StatefulWidget {
  const UserTracksPage({Key? key}) : super(key: key);
  @override
  UserTracksPageState createState() => UserTracksPageState();
}

class UserTracksPageState extends State<UserTracksPage> {
  List<dynamic> tracks = [];
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
        tracks = List<dynamic>.from(topTracks);
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
      backgroundColor: const Color.fromRGBO(0, 21, 41, 0.8),
      appBar: AppBar(
          backgroundColor: const Color.fromRGBO(0, 25, 48, 1),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Suas Músicas Mais Ouvidas"),
              DropdownButton(
                dropdownColor: const Color.fromRGBO(0, 25, 48, 1),
                style: const TextStyle(color: Colors.white),
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
      body: tracks == []
          ? const Center(child: GFLoader())
          : ListView.builder(
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];
                return ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: Image.network(track['image'][3]['#text']),
                  title: Text(track['name']),
                  titleTextStyle: const TextStyle(color: Colors.white),
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
  List<dynamic> albums = [];
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
        albums = List<dynamic>.from(topAlbums);
      });
    } else {
      debugPrint('Failed to fetch user albums');
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
      backgroundColor: const Color.fromRGBO(0, 21, 41, 0.8),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 25, 48, 1),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Seus Albuns Mais Ouvidos"),
            DropdownButton<int>(
              dropdownColor: const Color.fromRGBO(0, 25, 48, 1),
              style: const TextStyle(color: Colors.white),
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
      body: albums == []
          ? const Center(
              child: GFLoader(),
            )
          : ListView.builder(
              itemCount: albums.length,
              itemBuilder: (context, index) {
                final album = albums[index];
                return ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: Image.network(album['image'][3]['#text']),
                  title: Text(album['name']),
                  titleTextStyle: const TextStyle(color: Colors.white),
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
              backgroundColor: const Color.fromARGB(180, 217, 217, 217),
              foregroundColor: Colors.black87,
              textStyle: const TextStyle(
                  fontStyle: FontStyle.normal, fontWeight: FontWeight.bold)),
        ),
      ),
      home: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
                margin: const EdgeInsets.all(8),
                child: SizedBox(
                    width: 1000,
                    height: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 217, 217, 217),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          elevation: 20,
                          textStyle: const TextStyle(
                              color: Colors.black, ///////////
                              fontSize: 20)),
                      onPressed: () =>
                          _launchURL('https://receiptify.herokuapp.com'),
                      child: const Text('Receiptify'),
                    ))),
            Container(
                margin: const EdgeInsets.all(8),
                child: SizedBox(
                    width: 1000,
                    height: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 217, 217, 217),
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          elevation: 20,
                          textStyle: const TextStyle(
                            color: Colors.black, ///////////
                            fontSize: 20,
                          )),
                      onPressed: () =>
                          _launchURL('https://huangdarren1106.github.io'),
                      child: const Text('Spotify Pie'),
                    ))),
            Container(
                margin: const EdgeInsets.all(8),
                child: SizedBox(
                    width: 1000,
                    height: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 217, 217, 217),
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          elevation: 20,
                          textStyle: const TextStyle(
                            color: Colors.black, ///////////
                            fontSize: 20,
                          )),
                      onPressed: () =>
                          _launchURL('https://salty-beach-42139.herokuapp.com'),
                      child: const Text('Festify'),
                    ))),
            Container(
                margin: const EdgeInsets.all(8),
                child: SizedBox(
                    width: 1000,
                    height: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 217, 217, 217),
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          elevation: 20,
                          textStyle: const TextStyle(
                              color: Colors.black, ///////////
                              fontSize: 20)),
                      onPressed: () => _launchURL('https://www.instafest.app'),
                      child: const Text('InstaFest'),
                    ))),
            Container(
                margin: const EdgeInsets.all(8),
                child: SizedBox(
                    width: 1000,
                    height: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 217, 217, 217),
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          elevation: 20,
                          textStyle: const TextStyle(
                            color: Colors.black, ///////////
                            fontSize: 20,
                          )),
                      onPressed: () => _launchURL(
                          'https://pudding.cool/2021/10/judge-my-music/'),
                      child: const Text('How Bad is Your Streaming Music?'),
                    ))),
            Container(
                margin: const EdgeInsets.all(8),
                child: SizedBox(
                    width: 1000,
                    height: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 217, 217, 217),
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          elevation: 20,
                          textStyle: const TextStyle(
                            color: Colors.black, ///////////
                            fontSize: 20,
                          )),
                      onPressed: () =>
                          _launchURL('https://musicscapes.herokuapp.com'),
                      child: const Text('MusicScape'),
                    ))),
            Container(
                margin: const EdgeInsets.all(8),
                child: SizedBox(
                    width: 1000,
                    height: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 217, 217, 217),
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          elevation: 20,
                          textStyle: const TextStyle(
                              color: Colors.black, ///////////
                              fontSize: 20)),
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
