import 'dart:io';
import '../../model/user.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/classes.dart';
import '../../model/subject.dart';
import '../../model/cours.dart';
import '../../services/subject_service.dart';
import '../../services/class_service.dart';
import '../../services/file_upload_service.dart';
import '../../services/workshop_service.dart';

class LessonInput {
  final TextEditingController titleController;
  PlatformFile? selectedFile;
  String? uploadedUrl;

  LessonInput({required this.titleController});
}

class CreateWorkshopTab extends StatefulWidget {
  const CreateWorkshopTab({super.key});

  @override
  State<CreateWorkshopTab> createState() => _CreateWorkshopTabState();
}

class _CreateWorkshopTabState extends State<CreateWorkshopTab> {
  final List<String> imagePaths = [
    'assets/images/image1.jpeg',
    'assets/images/image2.jpeg',
    'assets/images/image3.jpeg',
    'assets/images/image4.jpeg',
    'assets/images/image5.jpeg',
  ];

  String? selectedImagePath;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  List<LessonInput> lessons = [
    LessonInput(titleController: TextEditingController())
  ];
  final TextEditingController _exerciseTitleController =
      TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? uploadedFileUrl;
  String? selectedFileName;
  bool isUploading = false;
  Subject? selectedSubject;
  ClassEntity? selectedClass;
  List<Subject> subjects = [];
  List<ClassEntity> classesList = [];
  PlatformFile? selectedExerciseFile;
  String? uploadedExerciseUrl;
  bool isExerciseUploading = false;

  final FileUploadService _uploadService = FileUploadService();
  final ClassService _classService = ClassService();
  final SubjectService _subjectService = SubjectService();
  final WorkshopService _workshopService = WorkshopService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      await Future.wait([_getSubjects(), _getAllClasses()]);
    } catch (e) {
      _showErrorSnackbar('Erreur lors du chargement des données initiales');
    }
  }

  Future<void> _getSubjects() async {
    try {
      final data = await _subjectService.getAllSubjects();
      setState(() => subjects = data);
    } catch (e) {
      _showErrorSnackbar('Erreur lors du chargement des matières');
    }
  }

  Future<void> _getAllClasses() async {
    try {
      final data = await _classService.getAllClasses();
      setState(() => classesList = data);
    } catch (e) {
      _showErrorSnackbar('Erreur lors du chargement des classes');
    }
  }

  // Future<void> _selectDateTime(BuildContext context) async {
  //   final pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2020),
  //     lastDate: DateTime(2030),
  //   );

  //   if (pickedDate != null) {
  //     final pickedTime = await showTimePicker(
  //       context: context,
  //       initialTime: TimeOfDay.now(),
  //     );

  //     if (pickedTime != null) {
  //       setState(() {
  //         selectedDate = pickedDate;
  //         selectedTime = pickedTime;
  //         _dateTimeController.text =
  //             "${pickedDate.day}/${pickedDate.month}/${pickedDate.year} - ${pickedTime.hour}:${pickedTime.minute}";
  //       });
  //     }
  //   }
  // }

  Future<void> _pickFile([int? index, bool isExercise = false]) async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null) return;

      final pickedFile = result.files.first;

      if (isExercise) {
        setState(() {
          selectedExerciseFile = pickedFile;
          isExerciseUploading = true;
        });

        final exerciseUrl =
            await _uploadService.uploadFile(File(pickedFile.path!));
        setState(() {
          uploadedExerciseUrl = exerciseUrl;
          isExerciseUploading = false;
        });
      } else if (index != null) {
        setState(() {
          lessons[index].selectedFile = pickedFile;
          isUploading = true;
        });

        final fileUrl = await _uploadService.uploadFile(File(pickedFile.path!));
        setState(() {
          lessons[index].uploadedUrl = fileUrl;
          isUploading = false;
        });
      }
    } catch (e) {
      _showErrorSnackbar("Erreur lors de l'upload du fichier");
      if (isExercise) {
        setState(() => isExerciseUploading = false);
      } else {
        setState(() => isUploading = false);
      }
    }
  }

  void _addAnotherLesson() {
    setState(() {
      lessons.add(LessonInput(titleController: TextEditingController()));
    });
  }

  Future<void> _submitWorkshop() async {
    if (!_validateForm()) return;

    // Récupérer l'utilisateur authentifié
    final authState = context.read<AuthBloc>().state;
    AppUser? currentUser;

    if (authState is Authenticated) {
      currentUser = authState.user;
    } else {
      _showErrorSnackbar("Vous devez être connecté pour créer un workshop");
      return;
    }

    try {
      // Upload all lesson files if not already done
      for (var lesson in lessons) {
        if (lesson.selectedFile != null && lesson.uploadedUrl == null) {
          final file = File(lesson.selectedFile!.path!);
          final url = await _uploadService.uploadFile(file);
          lesson.uploadedUrl = url;
        }
      }

      // Upload exercise file if not already done
      if (selectedExerciseFile != null && uploadedExerciseUrl == null) {
        final exerciseFile = File(selectedExerciseFile!.path!);
        uploadedExerciseUrl = await _uploadService.uploadFile(exerciseFile);
      }

      final workshop = Cours(
        instructor:
            "${currentUser.firstname} ${currentUser.lastname}", // Utilisation du nom complet
        titre: _titleController.text,
        description: _descriptionController.text,
        matiere: selectedSubject!.name,
        classe: selectedClass!.name,
        imagePath: selectedImagePath ?? "placeholder.jpg",
        lessons: lessons
            .where((l) =>
                l.uploadedUrl != null && l.titleController.text.isNotEmpty)
            .map((lesson) => Lesson(
              
                  titre: lesson.titleController.text,
                  lessonUrl: lesson.uploadedUrl!,
                  lessonDuration: '', id: '',
                ))
            .toList(),
        exercice: Exercice(
          titre: _exerciseTitleController.text,
          exerciceUrl: uploadedExerciseUrl ?? "",
        ),
        rating: '',
        bookmarked: false,
        workshopDuration: '',
        id: '',
      );

      await _workshopService.addWorkshop(workshop);

      _showSuccessSnackbar("Le workshop a été créé avec succès !");
      _resetForm();
    } catch (e) {
      debugPrint('Error creating workshop: $e');
      _showErrorSnackbar('Erreur lors de la création du workshop: $e');
    }
  }

  bool _validateForm() {
    if (_titleController.text.isEmpty) {
      _showErrorSnackbar('Veuillez entrer un titre');
      return false;
    }
    if (_descriptionController.text.isEmpty) {
      _showErrorSnackbar('Veuillez entrer une description');
      return false;
    }
    if (selectedSubject == null) {
      _showErrorSnackbar('Veuillez sélectionner une matière');
      return false;
    }
    if (selectedClass == null) {
      _showErrorSnackbar('Veuillez sélectionner une classe');
      return false;
    }
    if (lessons.isEmpty ||
        lessons.any(
            (l) => l.titleController.text.isEmpty || l.uploadedUrl == null)) {
      _showErrorSnackbar('Veuillez ajouter au moins une leçon valide');
      return false;
    }
    if (selectedImagePath == null) {
      _showErrorSnackbar('Veuillez sélectionner une image');
      return false;
    }
    return true;
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _exerciseTitleController.clear();

    setState(() {
      selectedDate = null;
      selectedSubject = null;
      selectedClass = null;
      selectedImagePath = null;
      selectedFileName = null;
      uploadedFileUrl = null;
      uploadedExerciseUrl = null;
      selectedExerciseFile = null;
      lessons = [LessonInput(titleController: TextEditingController())];
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildSubjectDropdown(),
            const SizedBox(height: 16),
            _buildClassDropdown(),
            _buildImageSelection(),
            _buildLessonsSection(),
            const SizedBox(height: 16),
            _buildExerciseSection(),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: _inputDecoration('Titre'),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: _inputDecoration('Description'),
      maxLines: 4,
    );
  }

  Widget _buildSubjectDropdown() {
    return DropdownButtonFormField<Subject>(
      decoration: _inputDecoration('Sélectionner une matière'),
      value: selectedSubject,
      onChanged: (Subject? value) => setState(() => selectedSubject = value),
      items: subjects.map((subject) {
        return DropdownMenuItem<Subject>(
          value: subject,
          child: Text(subject.name),
        );
      }).toList(),
    );
  }

  Widget _buildClassDropdown() {
    return DropdownButtonFormField<ClassEntity>(
      decoration: _inputDecoration('Sélectionner une classe'),
      value: selectedClass,
      onChanged: (ClassEntity? value) => setState(() => selectedClass = value),
      items: classesList.map((classe) {
        return DropdownMenuItem<ClassEntity>(
          value: classe,
          child: Text(classe.name),
        );
      }).toList(),
    );
  }

  Widget _buildImageSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sélectionnez une image :',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imagePaths.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final path = imagePaths[index];
                final isSelected = selectedImagePath == path;

                return GestureDetector(
                  onTap: () => setState(() => selectedImagePath = path),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(path, fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Ajouter leçon:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...lessons.asMap().entries.map((entry) {
          final index = entry.key;
          final lesson = entry.value;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Leçon ${index + 1}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: lesson.titleController,
                    decoration:
                        const InputDecoration(labelText: "Nom de la leçon"),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            lesson.selectedFile?.name ??
                                "Aucun fichier sélectionné",
                            overflow: TextOverflow.ellipsis),
                      ),
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: () => _pickFile(index),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _addAnotherLesson,
          icon: const Icon(Icons.add),
          label: const Text("Ajouter une autre leçon"),
        ),
      ],
    );
  }

  Widget _buildExerciseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Ajouter un exercice (PDF ou Image)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _exerciseTitleController,
              decoration: const InputDecoration(
                labelText: "Nom de l'exercice",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedExerciseFile?.name ?? "Aucun fichier sélectionné",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () => _pickFile(null, true),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: _submitWorkshop,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Créer le Workshop', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      enabledBorder:
          OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      focusedBorder:
          OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
    );
  }
}
