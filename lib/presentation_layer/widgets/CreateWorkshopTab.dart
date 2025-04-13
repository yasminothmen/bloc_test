import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/data/models/classes.dart';
import 'package:bloc_test/data/models/file_upload_response.dart';
import 'package:bloc_test/data/models/subject.dart';
import 'package:bloc_test/services/file_upload_service.dart';
import 'package:bloc_test/services/subject_service.dart';
import 'package:bloc_test/services/class_service.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:bloc_test/data/models/cours.dart'; // Ton modèle Cours
import 'package:http/http.dart' as http;

class CreateWorkshopTab extends StatefulWidget {
  const CreateWorkshopTab({super.key});

  @override
  State<CreateWorkshopTab> createState() => _CreateWorkshopTabState();
}

class _CreateWorkshopTabState extends State<CreateWorkshopTab> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController _dateTimeController = TextEditingController();

  // *****
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? uploadedFileUrl; // L'URL retournée après l’upload
  @override
  void initState() {
    super.initState();
    getSubjects();
    getAllClasses();
  }

  Subject? selectedSubject;
  List<Subject> subjects = [];
  Future<void> getSubjects() async {
    final data = await SubjectService().getAllSubjects();
    print("Matières récupérées : ${data.length}");
    setState(() {
      subjects = data;
    });
  }

  ClassEntity? selectedClass;
  List<ClassEntity> classesList = [];
  Future<void> getAllClasses() async {
    try {
      final data = await ClassService().getAllClasses();
      print("Données brutes reçues: ${data.toString()}");
      setState(() {
        classesList = data;
      });
    } catch (e) {
      print("Erreur lors de la récupération des classes: $e");
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF246BFD),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            colorScheme: ColorScheme.light(primary: Color(0xFF246BFD)),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDate = pickedDate;
          selectedTime = pickedTime;
          _dateTimeController.text =
              "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} - ${selectedTime!.hour}:${selectedTime!.minute}";
        });
      }
    }
  }

  String? selectedFileName;
  bool isUploading = false;

  final FileUploadService _uploadService = FileUploadService();

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null) return;

      PlatformFile file = result.files.first;
      setState(() {
        selectedFileName = file.name;
        isUploading = true;
      });

      final response = await _uploadService.uploadFile(File(file.path!));

      if (response.statusCode == 201) {
        // Si votre backend renvoie du JSON
        final responseData = jsonDecode(response.body);
        final uploadResponse = FileUploadResponse.fromJson(responseData);

        uploadedFileUrl = uploadResponse.downloadUrl; // <-- stocker ici
        print(
            'Fichier ${uploadResponse.filename} uploadé à ${uploadResponse.downloadUrl} !');
      } else {
        throw Exception('Échec de l\'upload: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur: $e');
    } finally {
      setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Color(0xFF1A3A5F)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide:
                      BorderSide(color: const Color(0xFF1A3A5F), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide:
                      BorderSide(color: const Color(0xFF1A3A5F), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: const Color(0xFF1A3A5F)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide:
                      BorderSide(color: const Color(0xFF1A3A5F), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide:
                      BorderSide(color: const Color(0xFF1A3A5F), width: 2),
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateTimeController,
              readOnly: true,
              onTap: () => _selectDateTime(context),
              decoration: InputDecoration(
                hintText: 'Date Limite',
                prefixIcon:
                    Icon(Icons.calendar_today, color: const Color(0xFF1A3A5F)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Color(0xFF1A3A5F)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide:
                      BorderSide(color: const Color(0xFF1A3A5F), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide:
                      BorderSide(color: const Color(0xFF1A3A5F), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            subjects.isEmpty
                ? Text("Aucune matiere disponible.")
                : RepaintBoundary(
                    child: DropdownButtonFormField<Subject>(
                      decoration: InputDecoration(
                        hintText: 'Sélectionner une matière',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              const BorderSide(color: Color(0xFF1A3A5F)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                              color: const Color(0xFF1A3A5F), width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                              color: const Color(0xFF1A3A5F), width: 2),
                        ),
                      ),
                      value: selectedSubject,
                      onChanged: (Subject? value) {
                        setState(() {
                          selectedSubject = value;
                          print("Sujet sélectionné : ${value?.name}");
                        });
                      },
                      items: subjects.map((subject) {
                        return DropdownMenuItem<Subject>(
                          value: subject,
                          child: Text(subject.name),
                        );
                      }).toList(),
                    ),
                  ),
            const SizedBox(height: 16),
            classesList.isEmpty
                ? Text("Aucune classe disponible.")
                : RepaintBoundary(
                    child: DropdownButtonFormField<ClassEntity>(
                      decoration: InputDecoration(
                        hintText: 'Sélectionner une classe',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              const BorderSide(color: Color(0xFF1A3A5F)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                              color: const Color(0xFF1A3A5F), width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                              color: const Color(0xFF1A3A5F), width: 2),
                        ),
                      ),
                      value: selectedClass,
                      onChanged: (ClassEntity? value) {
                        setState(() {
                          selectedClass = value;
                          print("Matière sélectionné : ${value?.name}");
                        });
                      },
                      items: classesList.map((classe) {
                        return DropdownMenuItem<ClassEntity>(
                          value: classe,
                          child: Text(classe.name),
                        );
                      }).toList(),
                    ),
                  ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: isUploading ? null : _pickFile,
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                dashPattern: const [6, 4],
                color: const Color(0xFF1A3A5F),
                strokeWidth: 2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 70),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A3A5F),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      isUploading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.folder, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        isUploading
                            ? "Upload en cours..."
                            : selectedFileName ?? "Selectionner un fichier",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: submitWorkshop,
              child: const Text('Ajout'),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Ajoute la fonction submitWorkshop() :
  Future<void> submitWorkshop() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        selectedDate == null ||
        selectedTime == null ||
        selectedSubject == null ||
        selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }

    final DateTime deadline = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final cours = Cours(
      titre: _titleController.text,
      description: _descriptionController.text,
      dateLimite: deadline.toIso8601String(),
      matiere: selectedSubject!.name,
      classe: selectedClass!.name,
    );

    final response = await http.post(
      Uri.parse(
          'http://192.168.155.117:8080/workshops/add'), // adapte cette URL à ton backend
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(cours.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Workshop créé avec succès !")),
      );
      // Réinitialise les champs après succès
      _titleController.clear();
      _descriptionController.clear();
      _dateTimeController.clear();
      setState(() {
        selectedDate = null;
        selectedTime = null;
        selectedSubject = null;
        selectedClass = null;
        selectedFileName = null;
      });
    } else {
      print("Erreur lors de l'envoi : ${response.body}");
    }
  }
}
