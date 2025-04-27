import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class EmploiScreen extends StatefulWidget {
  final String fileUrl;
  final String fileName;

  const EmploiScreen({
    Key? key,
    required this.fileUrl,
    required this.fileName,
  }) : super(key: key);

  @override
  _EmploiScreenState createState() => _EmploiScreenState();
}

class _EmploiScreenState extends State<EmploiScreen> {
  String? localPath;
  bool isLoading = true;
  String? errorMessage;
  double downloadProgress = 0;
  bool isDownloading = false;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('Initializing EmploiScreen with:');
      print('File URL: ${widget.fileUrl}');
      print('File Name: ${widget.fileName}');
    }
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${widget.fileName}');

      // Vérifier si le fichier existe et est valide
      if (await _isValidPdfFile(file)) {
        setState(() {
          localPath = file.path;
          isLoading = false;
        });
        return;
      }

      // Télécharger le fichier
      await _downloadFile(widget.fileUrl, file.path);

      // Vérifier à nouveau après téléchargement
      if (!await _isValidPdfFile(file)) {
        throw Exception('Le fichier téléchargé n\'est pas un PDF valide');
      }

      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = _getUserFriendlyError(e);
      });
    }
  }

  Future<bool> _isValidPdfFile(File file) async {
    if (!await file.exists()) return false;
    
    final fileSize = await file.length();
    if (fileSize < 100) return false; // Taille minimale pour un PDF

    try {
      // Lire les premiers bytes pour vérifier le header PDF
      final bytes = await file.openRead(0, 4).expand((chunk) => chunk).toList();
      if (bytes.length < 4) return false;
      
      // Vérifier le magic number PDF (%PDF)
      if (bytes[0] != 0x25 || bytes[1] != 0x50 || bytes[2] != 0x44 || bytes[3] != 0x46) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _downloadFile(String url, String savePath) async {
    try {
      setState(() {
        isDownloading = true;
        downloadProgress = 0;
      });

      // Vérifier que l'URL est valide
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.isAbsolute) {
        throw Exception('URL du fichier invalide');
      }

      // Vérification préalable du type de contenu
      final headResponse = await _dio.head(url);
      final contentType = headResponse.headers.value('content-type')?.toLowerCase() ?? '';
      if (!contentType.contains('pdf') && !contentType.contains('octet-stream')) {
        throw Exception('Le serveur ne retourne pas un PDF (Content-Type: $contentType)');
      }

      // Téléchargement avec suivi de progression
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress = received / total;
            });
          }
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      // Vérification post-téléchargement
      final file = File(savePath);
      if (!await file.exists()) {
        throw Exception('Le fichier n\'a pas été créé');
      }

      final fileSize = await file.length();
      if (fileSize < 100) {
        // Vérifier si c'est une page HTML d'erreur
        final content = await file.readAsString();
        if (content.contains('<html') || content.contains('404')) {
          throw Exception('Le serveur a retourné une page HTML au lieu du PDF');
        }
        throw Exception('Fichier PDF trop petit ($fileSize bytes), probablement corrompu');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Fichier non trouvé sur le serveur (404)');
      } else {
        throw Exception('Erreur de réseau: ${e.message}');
      }
    } catch (e) {
      // Nettoyer le fichier corrompu
      try {
        final file = File(savePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
      rethrow;
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  Future<void> _downloadAndSaveFile() async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Permission de stockage refusée');
      }

      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        throw Exception('Impossible d\'accéder au dossier de téléchargements');
      }

      final filePath = '${downloadsDir.path}/${widget.fileName}';
      await _downloadFile(widget.fileUrl, filePath);

      // Ouvrir le fichier avec l'application par défaut
      final fileUri = Uri.file(filePath);
      if (await canLaunchUrl(fileUri)) {
        await launchUrl(fileUri);
      } else {
        throw Exception('Impossible d\'ouvrir le fichier');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fichier téléchargé avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getUserFriendlyError(e))),
      );
    }
  }

  String _getUserFriendlyError(dynamic error) {
    if (error.toString().contains('not a valid PDF')) {
      return 'Le fichier n\'est pas un PDF valide';
    } else if (error.toString().contains('404')) {
      return 'Fichier introuvable sur le serveur';
    } else if (error.toString().contains('HTML')) {
      return 'Le serveur a retourné une erreur HTML';
    } else if (error.toString().contains('too small')) {
      return 'Fichier PDF corrompu ou incomplet';
    } else if (error.toString().contains('network')) {
      return 'Problème de connexion au serveur';
    } else if (error.toString().contains('permission')) {
      return 'Permission requise non accordée';
    }
    return 'Erreur: ${error.toString()}';
  }

  Future<void> _tryOpenInBrowser() async {
    try {
      if (await canLaunchUrl(Uri.parse(widget.fileUrl))) {
        await launchUrl(Uri.parse(widget.fileUrl));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d\'ouvrir dans le navigateur: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadAndSaveFile,
            tooltip: 'Télécharger',
          ),
          if (errorMessage != null)
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              onPressed: _tryOpenInBrowser,
              tooltip: 'Ouvrir dans le navigateur',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading || isDownloading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: isDownloading ? downloadProgress : null,
            ),
            const SizedBox(height: 20),
            if (isDownloading)
              Text(
                'Téléchargement en cours... ${(downloadProgress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 20),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadPdf,
                child: const Text('Réessayer le téléchargement'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _tryOpenInBrowser,
                child: const Text('Ouvrir dans le navigateur'),
              ),
            ],
          ),
        ),
      );
    }

    if (localPath != null) {
      return PDFView(
        filePath: localPath!,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: true,
        onError: (error) {
          setState(() {
            errorMessage = 'Erreur d\'affichage PDF: ${_getUserFriendlyError(error)}';
            localPath = null;
          });
        },
        onPageError: (page, error) {
          setState(() {
            errorMessage = 'Erreur page $page: ${_getUserFriendlyError(error)}';
          });
        },
      );
    }

    return const Center(child: Text('Document non disponible'));
  }
}