class Mensagem {
  String _nomeF;
  String _emailU;
  int _numC;
  String msg;
 String get nomeF => this._nomeF;

 set nomeF(String value) => this._nomeF = value;

  get emailU => this._emailU;

 set emailU( value) => this._emailU = value;

  get numC => this._numC;

 set numC( value) => this._numC = value;

  get getMsg => this.msg;

 set setMsg( msg) => this.msg = msg;



Mensagem(this._nomeF,this._emailU,this._numC,this.msg);
}