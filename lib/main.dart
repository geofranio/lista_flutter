import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
void main(){
  runApp(MaterialApp(
    home: Home(),
  ));
}
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();
  List _toDoList = [];
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override // lendo os dados ao carregar a APP
  void initState() {
    super.initState();
    _readData().then((data){
      setState(() {
        _toDoList = json.decode(data);
      });

    });
  } // para armazenar tarefas


  void _addTodo(){
    setState(() {
      Map<String, dynamic> newTodo = Map();
      newTodo["title"]=_toDoController.text;
      _toDoController.text="";
      newTodo["ok"]=false;
      _toDoList.add(newTodo);
      _saveData();
    });

  }
Future<Null> _refresh() async{ // ordenando a lista
await Future.delayed(Duration(seconds: 1));
setState(() {
  _toDoList.sort((a,b){
    if(a["ok"] && !b["ok"]) return 1;
    else if(!a["ok"] && b["ok"]) return -1;
    else return 0;
  });
  _saveData();
});
return null;
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(17, 1.0, 7.0, 1.0),
            child: Row(
              children: [
                Expanded(child:TextField(
                  controller: _toDoController,
                  decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: Colors.blueAccent)
                  ),
                )
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("Add"),
                  textColor: Colors.white,
                  onPressed: _addTodo,
                )
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(onRefresh: _refresh, // para actualizar a lista ao passar o dedo
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: _toDoList.length,// informando o tamanho do vetor
                  itemBuilder: buildItem),),
          )
        ],
      ),
    );
  }
  //
  Widget buildItem(BuildContext context,int index){
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9,0.0),
          child: Icon(Icons.delete, color: Colors.white,),
        ),
      ),
        direction: DismissDirection.startToEnd,
      child: CheckboxListTile( // aplicando o efeito
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          child:Icon(_toDoList[index]["ok"]?
          Icons.check: Icons.error),),
        onChanged: (c){
          setState(() {
            _toDoList[index]["ok"]=c;
            _saveData();
          });

        },
      ),
      onDismissed: (direction){
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos=index;
          _toDoList.removeAt(index);
          _saveData();
          final snack = SnackBar(
            content: Text("Tarfea \"${_lastRemoved["title"]}\"removida"),
            action: SnackBarAction(label: "Desfazer",
              onPressed: (){
              setState(() {
                _toDoList.insert(_lastRemovedPos, _lastRemoved);
                _saveData();
              });

              }),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).showSnackBar(snack);
        });

      },
    );
  }
/*  */

  // função para retornar arquivo para salavr
  Future<File> _getFile() async{
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

//Função para salvar os dados
  Future<File> _saveData() async{
    String data = json.encode(_toDoList);// transformando a lista em Json
    final file = await _getFile(); // obtendo o arquivo
    return file.writeAsString(data);// a retornar e a escrever o ficheiro json como texto
  }

  // lendo os dados
Future<String> _readData() async{
 try{
   final file = await _getFile();
   return file.readAsString();
 }catch (e){
    return null;
 }
}
}

