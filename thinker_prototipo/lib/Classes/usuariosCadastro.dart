class Usuarioscadastro {
  String _nome;
  String _senha;
  String _email;

 String get nome => this._nome;

 set nome(String value) => this._nome = value;

  get senha => this._senha;

 set senha( value) => this._senha = value;

  get email => this._email;

 set email( value) => this._email = value;

Usuarioscadastro(this._nome,this._senha,this._email);
}
List<Usuarioscadastro> cadastros = [];