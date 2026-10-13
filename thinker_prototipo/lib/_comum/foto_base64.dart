
String? semPrefixoDataUri(Object? valor) {
  final texto = valor?.toString();
  if (texto == null || texto.isEmpty) return null;
  final indice = texto.indexOf('base64,');
  return indice == -1 ? texto : texto.substring(indice + 'base64,'.length);
}
