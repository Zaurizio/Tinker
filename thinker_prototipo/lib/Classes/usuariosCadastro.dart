class Usuarioscadastro {
  String _nome;
  String _senha;
  String _email;

 String get nome => _nome;

 set nome(String value) => _nome = value;

  String get senha => _senha;

 set senha( value) => _senha = value;

  String get email => _email;

 set email( value) => _email = value;

Usuarioscadastro(this._nome,this._senha,this._email);
}
List<Usuarioscadastro> cadastros = [];