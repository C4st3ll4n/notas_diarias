import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

import 'Anotacao.dart';

class AnotacaoHelper {
  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();
  Database _db;

  Future<Database> get db async {
    if (_db != null)
      return _db;
    else {
      _db = await inicializarBanco();
      return _db;
    }
  }

  factory AnotacaoHelper() {
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal() {}

  inicializarBanco() async {
    final caminhoDB = await getDatabasesPath();
    final localDB = join(caminhoDB, "banquinepo.db");

    var db = await openDatabase(localDB, version: 1, onCreate: onCreate);
    return db;
  }

  FutureOr<void> onCreate(Database db, int version) async {
    String sql = "CREATE TABLE anotacao(id INTEGER PRIMARY KEY AUTOINCREMENT,"
        " titulo VARCHAR, descricao TEXT, data DATETIME)";
    await db.execute(sql);
  }

  Future<int> salvar(Anotacao anotacao) async {
    var banco = await db;
    int resultado = await banco.insert("anotacao", anotacao.toMap());

    return resultado;
  }

  Future<List<Anotacao>> recuperarAnotacoes() async {
    var banco = await db;
    List<Map<String, dynamic>> listinea =
        await banco.query("anotacao", orderBy: "data");
    //print(listinea);
    List<Anotacao> anotacoes = List();
    listinea.forEach((f) => anotacoes.add(Anotacao.fromMap(f)));
    return anotacoes;
  }

  Future<void> atualizar(Anotacao anotacao) async {
    var banco = await db;
    int resultado = await banco.update("anotacao", anotacao.toMap(),
        where: "id = ?", whereArgs: [anotacao.id]);
    return resultado;
  }

  Future<void> deletar(Anotacao anotacao) async {
    var banco = await db;
    return await banco
        .delete("anotacao", where: "id = ?", whereArgs: [anotacao.id]);
  }
}
