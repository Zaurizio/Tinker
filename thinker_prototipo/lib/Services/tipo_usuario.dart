enum TipoUsuario { aluno, professor }

extension TipoUsuarioApi on TipoUsuario {
  String get valorApi => this == TipoUsuario.aluno ? 'ALUNO' : 'PROFESSOR';

  static TipoUsuario fromApi(String valor) {
    return valor.toUpperCase() == 'PROFESSOR' ? TipoUsuario.professor : TipoUsuario.aluno;
  }
}
