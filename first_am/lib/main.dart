import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:select_form_field/select_form_field.dart';
import 'globals.dart';
import 'auth.dart';
import 'data_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //       title: 'first.AM',
  //       theme: ThemeData(primarySwatch: Colors.deepPurple),
  //       debugShowCheckedModeBanner: false,
  //       home: const HomePage()

  //       //////////////////////////////////////////////////////////////////
  //       // IMPLEMENTAR 'bottomNagivationBar: BottomNavBar' AQUI DEPOIS  //
  //       //////////////////////////////////////////////////////////////////clecls

  //       );
  // }
}

Widget render(int index) {
  var tracks = <String>[];

  serviceCountry("brazil")
    .then((res) {
      res["tracks"]["track"].map((track) => {
        tracks.add(track["name"])
      });

      debugPrint(tracks.toString());
    });

  debugPrint(tracks.toString());

  final widgets = [
    Scaffold(
        appBar: AppBar(title: const Text("First.AM")),
        body: Column(
          children: <Widget>[
            const ListTile(title: Text("Top 10 Artistas - Brasil")),
            Card(
              child: Column(
                children: tracks.map((track) => ListTile(title: Text(track))).toList(),
              ),
            )
          ],
        ),
        bottomNavigationBar: BottomNavBar(),
      ),
  ];

  return widgets[index];

}

class _MyAppState extends State<MyApp> {
  final GlobalKey<FormState> key = GlobalKey();
  bool validate = false, logado = false;
  String username = '', senha = '';
  _MyAppState();

  @override
  Widget build(BuildContext context) {
    return logado
        ? MaterialApp(home: render(0))
        : MaterialApp(
            home: Scaffold(
                appBar: AppBar(title: const Text('first.AM')),
                body: SingleChildScrollView(
                  child: Container(
                      margin: const EdgeInsets.all(15.0),
                      child: Form(key: key, child: loginForm())),
                ),
            ));
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

// COMANDO PARA REMOVER WARNING DO BOTTOMNAVBAR
// ignore: must_be_immutable
class BottomNavBar extends HookWidget {
  var callback;
  //FUNÇÃO APENAS PARA TESTAR FUNCIONALIDADE

  void buttonPressed(int index) {
    print("O botão $index foi tocado");
  }

  // FIM DA FUNÇÃO //

  BottomNavBar({super.key, this.callback}) {
    callback ??= (_) {
      debugPrint(usuario.key);
    };
  }

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
            label: "Relatórios", icon: Icon(Icons.date_range)),
        BottomNavigationBarItem(
            label: "Gráficos", icon: Icon(Icons.show_chart)),
        BottomNavigationBarItem(
            label: "Apps de Terceiros", icon: Icon(Icons.device_hub))
      ],
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("First.AM"),
        ),

        /////////// BODY A SER IMPLEMENTADO //////////////////////////
        body: const Center(child: Text("In Progress")),
        //////////////////////////////////////////////////////////
        ///
        ///
        bottomNavigationBar: BottomNavBar());
  }
}
