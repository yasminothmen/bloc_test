import 'dart:io';
import 'package:bloc_test/services/api_service.dart'; 
import 'package:dio/dio.dart';
import 'package:mime_type/mime_type.dart';
import 'package:http_parser/http_parser.dart';

class FileUploadService {
  Future<String> uploadFile(File file) async {
    try {
      final mimeType = mime(file.path) ?? 'application/octet-stream';

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          contentType: MediaType.parse(mimeType),
        )
      });

      
      final response = await ApiService.instance.post(
        '/file/upload', 
        data: formData,
      );

 
      return response.data['fileUrl'] as String;
    } on DioException catch (e) {
      throw Exception('Échec de l\'upload: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }
}
