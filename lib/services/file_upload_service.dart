import 'dart:io';
import 'package:bloc_test/services/api_service.dart'; 
import 'package:dio/dio.dart';
import 'package:mime_type/mime_type.dart';
import 'package:http_parser/http_parser.dart';

class FileUploadService {
  Future<String> uploadFile(File file) async {
    try {
      // 1. Déterminer le type MIME
      final mimeType = mime(file.path) ?? 'application/octet-stream';

      // 2. Créer FormData avec le fichier
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          contentType: MediaType.parse(mimeType), // Type MIME automatique
        )
      });

      // 3. Envoyer avec l'instance Dio configurée (inclut le token JWT)
      final response = await ApiService.instance.post(
        '/file/upload', // Endpoint relatif (baseUrl déjà dans ApiService)
        data: formData,
      );

      // 4. Retourner l'URL du fichier uploadé (adaptez selon votre API)
      return response.data['fileUrl'] as String;
    } on DioException catch (e) {
      throw Exception('Échec de l\'upload: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }
}
