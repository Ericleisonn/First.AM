import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'first.AM',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      home: const HomePage()

      //////////////////////////////////////////////////////////////////
      // IMPLEMENTAR 'bottomNagivationBar: BottomNavBar' AQUI DEPOIS  //
      //////////////////////////////////////////////////////////////////
      ///
    );
  }
}


// COMANDO PARA REMOVER WARNING DO BOTTOMNAVBAR
// ignore: must_be_immutable
class BottomNavBar extends HookWidget{
  var callback;
  //FUNÇÃO APENAS PARA TESTAR FUNCIONALIDADE 

  void buttonPressed(int index){
  print("O botão $index foi tocado");}

  // FIM DA FUNÇÃO //


  BottomNavBar({super.key, this.callback}){
    callback ??= (_){};  
  }

  @override
  Widget build(BuildContext context) {
    var state= useState(0);
    return BottomNavigationBar(
      onTap:(index){
        state.value = index;
        callback(index);
      },
      currentIndex: state.value,
      items : const[
      BottomNavigationBarItem(
        label: "Relatórios",
      icon: Icon(Icons.date_range)
      ),
      BottomNavigationBarItem(
      label: "Gráficos",
      icon: Icon(Icons.show_chart)),
      BottomNavigationBarItem(
      label: "Apps de Terceiros",
      icon: Icon(Icons.device_hub))],
      );
  }
}


class HomePage extends StatelessWidget{
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("First.AM"),
      ),


      /////////// BODY A SER IMPLEMENTADO //////////////////////////
      body: const Center(
        child: Text("In Progress")),
      //////////////////////////////////////////////////////////
      ///
      ///
      bottomNavigationBar: BottomNavBar());
  }

}





