import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime_type/mime_type.dart';
import 'package:http_parser/http_parser.dart';

class FileUploadService {
  static const String _baseUrl = 'http://192.168.155.117:8080';

  Future<http.Response> uploadFile(File file) async {
    try {
      final uri = Uri.parse('$_baseUrl/file/upload');
      var request = http.MultipartRequest('POST', uri);

      // Ajout du fichier avec le bon type MIME
      final mimeType = mime(file.path) ?? 'application/octet-stream';
      final mimeTypeData = mimeType.split('/');

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
      ));

      // Envoi de la requête
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload: $e');
    }
  }
}