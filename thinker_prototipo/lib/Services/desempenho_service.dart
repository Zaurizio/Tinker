import 'package:tinker/Services/api_client.dart';
import 'package:tinker/Models/desempenho_model.dart';

Future<DesempenhoResumo> buscarDesempenho() async {
  final dados = await apiGet('/desempenho');
  return DesempenhoResumo.fromApi(dados);
}
