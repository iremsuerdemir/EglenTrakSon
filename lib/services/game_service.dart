import 'dart:convert';
import 'package:gorsel_programlama_proje/models/game_model.dart';
import 'package:gorsel_programlama_proje/services/base_url.dart';
import 'package:gorsel_programlama_proje/services/user_service.dart';
import 'package:http/http.dart' as http;

class GameService {
  static Future<List<GameModel>?> getGames() async {
    final http.Response response = await http.get(
      Uri.parse('${BaseUrl.baseUrl}/Games'),
    );
    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body)["\$values"];
      return json.map((e) => GameModel.fromJson(e)).toList();
    } else {
      return null;
    }
  }

  static Future<GameModel?> getGame(int id) async {
    final http.Response response = await http.get(
      Uri.parse("${BaseUrl.baseUrl}/Games/$id"),
    );
    if (response.statusCode == 200) {
      return GameModel.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  static Future<List<GameModel>> getUserGames() async {
    List<GameModel> games = [];
    final http.Response response = await http.get(
      Uri.parse("${BaseUrl.baseUrl}/Games/${UserService.user!.id}"),
    );

    if (response.statusCode != 200) {
      return games;
    }

    final values = jsonDecode(response.body)["\$values"];
    return (values as List<dynamic>).map((e) => GameModel.fromJson(e)).toList();
  }
}
