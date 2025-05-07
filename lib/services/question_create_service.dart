import 'dart:convert';
import 'package:gorsel_programlama_proje/services/base_url.dart';
import 'package:http/http.dart' as http;

class QuestionCreateService {
  static Future<bool> createQuestion({
    required Map<String, dynamic> questionData,
  }) async {
    final Uri uri = Uri.parse(
      '${BaseUrl.baseUrl}/questions',
    ); // Doğru endpoint: /questions

    try {
      final http.Response response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(questionData),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Soru oluşturma başarısız: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Bir hata oluştu: $e');
      return false;
    }
  }
}
