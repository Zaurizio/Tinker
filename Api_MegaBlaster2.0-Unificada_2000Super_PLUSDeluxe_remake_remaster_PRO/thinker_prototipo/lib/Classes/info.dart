class Mensagem {
  String _nomeF;
  String _emailU;
  int _numC;
  String msg;
 String get nomeF => _nomeF;

 set nomeF(String value) => _nomeF = value;

  String get emailU => _emailU;

 set emailU( value) => _emailU = value;

  int get numC => _numC;

 set numC( value) => _numC = value;

  String get getMsg => msg;

 set setMsg( msg) => this.msg = msg;



Mensagem(this._nomeF,this._emailU,this._numC,this.msg);
}