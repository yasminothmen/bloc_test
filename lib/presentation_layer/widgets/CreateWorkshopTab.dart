import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/presentation_layer/bloc/workshop_bloc.dart';
import 'package:bloc_test/presentation_layer/bloc/workshop_event.dart';
import 'package:bloc_test/presentation_layer/bloc/workshop_state.dart';

class CreateWorkshopTab extends StatefulWidget {
  const CreateWorkshopTab({super.key});

  @override
  State<CreateWorkshopTab> createState() => _CreateWorkshopTabState();
}

class _CreateWorkshopTabState extends State<CreateWorkshopTab> {
  String? selectedCategory;
  List<File> selectedFiles = [];
  List<VideoPlayerController?> videoControllers = [];

  final objectiveController = TextEditingController();
  final exerciseController = TextEditingController();
  final timeController = TextEditingController();

  @override
  void dispose() {
    objectiveController.dispose();
    exerciseController.dispose();
    timeController.dispose();
    for (var controller in videoControllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  /// Sélection de plusieurs fichiers depuis la galerie (images, vidéos, PDF)
  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'mp4', 'pdf'],
      allowMultiple: true, // ✅ Permet la sélection multiple
    );

    if (result != null) {
      setState(() {
        selectedFiles = result.files.map((file) => File(file.path!)).toList();
        videoControllers.forEach((controller) => controller?.dispose());
        videoControllers = [];

        for (var file in selectedFiles) {
          if (file.path.endsWith('.mp4')) {
            VideoPlayerController controller = VideoPlayerController.file(file)
              ..initialize().then((_) {
                setState(() {});
              });
            videoControllers.add(controller);
          } else {
            videoControllers.add(null);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkshopBloc, WorkshopState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('View All categories', textAlign: TextAlign.start),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildCategoryButton(context, 'Science', 'assets/images/flacon-potion.png'),
                    _buildCategoryButton(context, 'Math', 'assets/images/racine-carree.png'),
                    _buildCategoryButton(context, 'Sport', 'assets/images/en-cours-dexecution.png'),
                    _buildCategoryButton(context, 'Paint', 'assets/images/pinceau-crayon.png'),
                    _buildCategoryButton(context, 'Music', 'assets/images/note-de-musique.png'),
                    _buildCategoryButton(context, 'English', 'assets/images/anglais.png'),
                    _buildCategoryButton(context, 'French', 'assets/images/tour-eiffel.png'),
                    _buildCategoryButton(context, 'Geography', 'assets/images/globe-alt.png'),
                    _buildCategoryButton(context, 'History', 'assets/images/faire-defiler-lhistoire-du-document.png'),
                    _buildCategoryButton(context, 'Physics', 'assets/images/atom.png'),
                    _buildCategoryButton(context, 'Technolog', 'assets/images/ordinateur-portable.png'),
                    _buildCategoryButton(context, 'Biology', 'assets/images/adn.png'),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: exerciseController,
                  decoration: InputDecoration(
                    hintText: 'Ajouter exercices (images, vidéos, PDF)',
                    border: const OutlineInputBorder(),
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _pickFiles,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _previewFiles(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    hintText: 'Durée',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: objectiveController,
                  decoration: const InputDecoration(
                    hintText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (selectedCategory != null) {
                      BlocProvider.of<WorkshopBloc>(context).add(
                        CreateWorkshopButtonPressed(
                          category: selectedCategory!,
                          objective: objectiveController.text,
                          exercise: exerciseController.text,
                          time: timeController.text,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a category.')),
                      );
                    }
                  },
                  child: const Text('Create'),
                ),
                if (state is WorkshopCreating)
                  const Center(child: CircularProgressIndicator())
                else if (state is WorkshopCreated)
                  const Center(child: Text('Workshop Created!'))
                else if (state is WorkshopError)
                  Center(child: Text('Error: ${state.message}')),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Aperçu des fichiers sélectionnés
  Widget _previewFiles() {
    if (selectedFiles.isEmpty) {
      return const Text('Aucun fichier sélectionné.');
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(selectedFiles.length, (index) {
        File file = selectedFiles[index];
        String fileExtension = file.path.split('.').last.toLowerCase();

        if (fileExtension == 'jpg' || fileExtension == 'png') {
          return _imagePreview(file);
        } else if (fileExtension == 'mp4') {
          return _videoPreview(videoControllers[index]);
        } else if (fileExtension == 'pdf') {
          return const Icon(Icons.picture_as_pdf, size: 50, color: Colors.red);
        } else {
          return const Text('Format non supporté.');
        }
      }),
    );
  }

  /// Aperçu des images sélectionnées
  Widget _imagePreview(File file) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.file(file, width: 100, height: 100, fit: BoxFit.cover),
    );
  }

  /// Aperçu des vidéos sélectionnées
  Widget _videoPreview(VideoPlayerController? controller) {
    if (controller == null || !controller.value.isInitialized) {
      return const Icon(Icons.video_library, size: 50, color: Colors.blue);
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
        IconButton(
          icon: Icon(controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () {
            setState(() {
              controller.value.isPlaying ? controller.pause() : controller.play();
            });
          },
        ),
      ],
    );
  }

  Widget _buildCategoryButton(BuildContext context, String category, String imagePath) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedCategory = category;
          });
          BlocProvider.of<WorkshopBloc>(context).add(CategorySelected(category));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 30, height: 30),
            const SizedBox(height: 8),
            Text(category),
          ],
        ),
      ),
    );
  }
}
