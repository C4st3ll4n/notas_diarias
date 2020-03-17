import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:notas_diarias/AnnotacaoHelper.dart';

class Anotacao {
  int id;
  String titulo;
  String descricao;
  String data;

  Anotacao(this.titulo, this.descricao, this.data);

  salvar() {
    AnotacaoHelper().salvar(this);
  }

  Anotacao.fromMap(Map<String, dynamic> map) {
    this.titulo = map["titulo"];
    this.descricao = map["descricao"];
    this.data = map["data"];
    this.id = map["id"];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "titulo": this.titulo,
      "descricao": this.descricao,
      "data": this.data
    };

    //  if (id != null) map["id"] = this.id;

    return map;
  }

  @override
  String toString() {
    return 'Anotacao{id: $id, titulo: $titulo, descricao: $descricao, data: $data}';
  }

  String formatarData() {
    initializeDateFormatting("pt_BR");
    var format = DateFormat.yMMMEd("pt_BR");
    String dtFormatada = format.format(DateTime.tryParse(this.data));
    return dtFormatada;
  }

  atualizar() {
    AnotacaoHelper().atualizar(this);
  }

  deletar() {
    AnotacaoHelper().deletar(this);
  }
}
