import 'dart:io';
import 'package:video_player/video_player.dart';

class VideoDurationService {
  static Future<Duration> getVideoDuration(File videoFile) async {
    final controller = VideoPlayerController.file(videoFile);
    try {
      await controller.initialize();
      return controller.value.duration;
    } catch (e) {
      print('Erreur lors de l\'extraction de la durée: $e');
      return Duration.zero;
    } finally {
      await controller.dispose();
    }
  }
}