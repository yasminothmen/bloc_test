import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:video_player/video_player.dart';

class LessonDetailPage extends StatefulWidget {
  // Changé en StatefulWidget
  final String lessonTitle;
  final String lessonDuration;
  final String lessonUrl;

  const LessonDetailPage({
    super.key,
    required this.lessonTitle,
    required this.lessonDuration,
    required this.lessonUrl,
  });

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  bool isCompleted = false; // État pour suivre si la leçon est complétée
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _isVideoInitialized = false;
  @override
  void initState() {
    super.initState();
    debugPrint('URL reçue: ${widget.lessonUrl}');
    _initializeVideo();
  }

  void _initializeVideo() async {
    if (widget.lessonUrl.isEmpty) {
      debugPrint('ERREUR CRITIQUE: URL vide reçue');
      return;
    }

    debugPrint('Tentative de lecture depuis URL: [${widget.lessonUrl}]');

    try {
      _videoPlayerController = VideoPlayerController.network(widget.lessonUrl)
        ..initialize().then((_) {
          debugPrint(
              'Vidéo initialisée - Durée: ${_videoPlayerController.value.duration}');
          setState(() => _isVideoInitialized = true);
        }).catchError((error) {
          debugPrint('Erreur initialisation: $error');
        });

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        errorBuilder: (context, errorMsg) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('URL utilisée: ${widget.lessonUrl}'),
                Text('Erreur: $errorMsg'),
              ],
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Erreur création controller: $e');
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              IconlyLight.arrow_left,
              size: 26,
              color: Colors.black,
            ),
            style: IconButton.styleFrom(
                shape: CircleBorder(), backgroundColor: Colors.white),
          ),
        ),
        title: Text(
          'Liste des Leçons',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.keyboard_arrow_left_rounded,
                      size: 19,
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      child: const Text(
                        "Précèdent",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                // Bouton conditionnel
                if (!isCompleted)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        isCompleted = true; // Met à jour l'état
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B2EFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    icon:
                        const Icon(Icons.check, color: Colors.white, size: 16),
                    label: const Text(
                      "Mark as completed",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () {
                      // Logique pour passer à la leçon suivante
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Couleur différente
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    label: const Text(
                      "Suivant",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_right_rounded,
                        color: Colors.white, size: 16),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            /// Titre de la leçon
            Text(
              widget.lessonTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            /// Miniature de la vidéo
            Container(
              height: 200,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isVideoInitialized
                  ? Chewie(controller: _chewieController)
                  : Center(
                      child: Icon(
                        IconlyBold.play,
                        size: 60,
                        color: Colors.purple.shade600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
