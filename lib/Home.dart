import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notas_diarias/AnnotacaoHelper.dart';
import 'package:notas_diarias/Anotacao.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _tarefas = [];
  var _db = AnotacaoHelper();
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descController = TextEditingController();

  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _recuperarAnotacoes();
  }

  _recuperarAnotacoes() async {
    List listinea = await _db.recuperarAnotacoes();
    setState(() {
      _tarefas = listinea;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Anotações"),
        centerTitle: true,
      ),
      body: Container(
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _newAnotacao,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    return ListView.builder(
        itemCount: _tarefas.length,
        itemBuilder: (contexto, index) {
          Anotacao anotacao = _tarefas.elementAt(index);
          return Card(
            child: Dismissible(
              background: Container(
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
                color: Colors.lightGreen,
              ),
              secondaryBackground: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
                color: Colors.redAccent,
              ),
              key: Key("${anotacao.id}${anotacao.descricao}"),
              child: ListTile(
                title: Text(anotacao.titulo),
                subtitle: Text(anotacao.descricao),
                trailing: Text(anotacao.formatarData()),
              ),
              onDismissed: (direcao) {
                print("dismissed:" + direcao.toString());
                if (direcao == DismissDirection.endToStart) {
                  ///remover
                  _deleteAnotacao(anotacao);
                  setState(() {
                    _tarefas.remove(anotacao);
                  });
                } else if (direcao == DismissDirection.startToEnd) {
                  _updateAnotacao(anotacao);
                  setState(() {
                    _tarefas.remove(anotacao);
                  });
                }
              },
            ),
          );
        });
  }

  void _deleteAnotacao(Anotacao anotacao) async {
    await anotacao.deletar();

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Desfazer ?"),
      action: SnackBarAction(
        onPressed: () {
          setState(() {
            _tarefas.add(anotacao);
          });
        },
        label: "SIM",
      ),
    ));
  }

  void _newAnotacao() {
    showDialog(
        context: context,
        builder: (contexto) {
          return AlertDialog(
            title: Text("Nova anotação"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _tituloController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Título", hintText: "Digite um título"),
                ),
                TextField(
                    controller: _descController,
                    autofocus: true,
                    decoration: InputDecoration(
                        labelText: "Descrição",
                        hintText: "Digite uma descrição"))
              ],
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancelar"),
              ),
              FlatButton(
                onPressed: _salvarAnotacao,
                child: Text("Salvar"),
              ),
            ],
          );
        });
  }

  void _updateAnotacao(Anotacao anotacao) {
    _tituloController.text = anotacao.titulo;
    _descController.text = anotacao.descricao;

    showDialog(
        context: context,
        builder: (contexto) {
          return AlertDialog(
            title: Text("Atualizar anotação"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _tituloController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Título", hintText: "Digite um título"),
                ),
                TextField(
                    controller: _descController,
                    autofocus: true,
                    decoration: InputDecoration(
                        labelText: "Descrição",
                        hintText: "Digite uma descrição"))
              ],
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancelar"),
              ),
              FlatButton(
                onPressed: () {
                  _atualizarAnotacao(anotacao);
                },
                child: Text("Salvar"),
              ),
            ],
          );
        });
  }

  void _salvarAnotacao() async {
    String titulo = _tituloController.value.text;
    String descricao = _descController.value.text;

    Anotacao anotacao = Anotacao(titulo, descricao, DateTime.now().toString());
    int r = await anotacao.salvar();
    //print("r:$r");
    Navigator.pop(context);

    _recuperarAnotacoes();

    _tituloController.clear();
    _descController.clear();
  }

  _atualizarAnotacao(Anotacao novaAnotacao) async {
    String titulo = _tituloController.value.text;
    String descricao = _descController.value.text;

    novaAnotacao.titulo = "$titulo";
    novaAnotacao.descricao = "$descricao";

    await novaAnotacao.atualizar();

    //print("r:$r");

    Navigator.pop(context);

    _recuperarAnotacoes();

    _tituloController.clear();
    _descController.clear();
  }
}
