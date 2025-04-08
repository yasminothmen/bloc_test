import 'package:bloc_test/data/models/classes.dart';
import 'package:bloc_test/data/models/subject.dart';
import 'package:bloc_test/services/subject_service.dart';
import 'package:bloc_test/services/class_service.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateWorkshopTab extends StatefulWidget {
  const CreateWorkshopTab({super.key});

  @override
  State<CreateWorkshopTab> createState() => _CreateWorkshopTabState();
}

class _CreateWorkshopTabState extends State<CreateWorkshopTab> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  TextEditingController _dateTimeController = TextEditingController();

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

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result == null || result.files.isEmpty) return;

      setState(() {
        selectedFileName = result.files.first.name;
        isUploading = true;
      });

      // URL pour le navigateur Edge (utilisez localhost)
      const String serverUrl = 'http://192.168.155.117:8080/api/files/upload';

      var request = http.MultipartRequest('POST', Uri.parse(serverUrl));
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          result.files.first.path!,
          filename: result.files.first.name,
        ),
      );

      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      setState(() {
        isUploading = false;
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Fichier uploadé avec succès: $responseString')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'upload: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'upload: $e')),
      );
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
              onPressed: () {},
              child: const Text('Ajout'),
            ),
          ],
        ),
      ),
    );
  }
}
