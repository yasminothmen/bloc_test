import 'dart:io';
import '../../model/classes.dart';
import '../../model/subject.dart';
import '../../model/cours.dart';
import '../../services/api_service.dart';
import '../../services/file_upload_service.dart';
import '../../services/subject_service.dart';
import '../../services/class_service.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CreateWorkshopTab extends StatefulWidget {
  const CreateWorkshopTab({super.key});

  @override
  State<CreateWorkshopTab> createState() => _CreateWorkshopTabState();
}

class _CreateWorkshopTabState extends State<CreateWorkshopTab> {
  // Contrôleurs
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  
  // États
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? uploadedFileUrl;
  String? selectedFileName;
  bool isUploading = false;
  Subject? selectedSubject;
  ClassEntity? selectedClass;
  List<Subject> subjects = [];
  List<ClassEntity> classesList = [];

  // Services
  final FileUploadService _uploadService = FileUploadService();
  final ClassService _classService = ClassService();
  final SubjectService _subjectService = SubjectService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      await Future.wait([
        _getSubjects(),
        _getAllClasses(),
      ]);
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
      rethrow;
    }
  }

  Future<void> _getAllClasses() async {
    try {
      final data = await _classService.getAllClasses();
      setState(() => classesList = data);
    } catch (e) {
      _showErrorSnackbar('Erreur lors du chargement des classes');
      rethrow;
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDate = pickedDate;
          selectedTime = pickedTime;
          _dateTimeController.text =
              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year} - ${pickedTime.hour}:${pickedTime.minute}";
        });
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null) return;

      setState(() {
        selectedFileName = result.files.first.name;
        isUploading = true;
      });

      final fileUrl = await _uploadService.uploadFile(File(result.files.first.path!));
      setState(() => uploadedFileUrl = fileUrl);
    } catch (e) {
      _showErrorSnackbar('Erreur lors de l\'upload du fichier');
    } finally {
      setState(() => isUploading = false);
    }
  }

  Future<void> _submitWorkshop() async {
    if (!_validateForm()) return;

    try {
      final deadline = DateTime(
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
        fileUrl: uploadedFileUrl,
      );

      await ApiService.instance.post(
        '/workshops/add',
        data: cours.toJson(),
      );

      _showSuccessSnackbar('Workshop créé avec succès !');
      _resetForm();
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      _showErrorSnackbar('Erreur: $errorMessage');
    } catch (e) {
      _showErrorSnackbar('Erreur inattendue');
    }
  }

  bool _validateForm() {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        selectedDate == null ||
        selectedTime == null ||
        selectedSubject == null ||
        selectedClass == null) {
      _showErrorSnackbar('Veuillez remplir tous les champs');
      return false;
    }
    return true;
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _dateTimeController.clear();
    setState(() {
      selectedDate = null;
      selectedTime = null;
      selectedSubject = null;
      selectedClass = null;
      selectedFileName = null;
      uploadedFileUrl = null;
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
            _buildDateField(),
            const SizedBox(height: 16),
            _buildSubjectDropdown(),
            const SizedBox(height: 16),
            _buildClassDropdown(),
            const SizedBox(height: 16),
            _buildFileUpload(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: _inputDecoration('Title'),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: _inputDecoration('Description'),
      maxLines: 4,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateTimeController,
      readOnly: true,
      onTap: () => _selectDateTime(context),
      decoration: _inputDecoration('Date Limite').copyWith(
        prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF1A3A5F)),
      ),
    );
  }

  Widget _buildSubjectDropdown() {
    return subjects.isEmpty
        ? const Text("Aucune matière disponible.")
        : DropdownButtonFormField<Subject>(
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
    return classesList.isEmpty
        ? const Text("Aucune classe disponible.")
        : DropdownButtonFormField<ClassEntity>(
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

  Widget _buildFileUpload() {
    return GestureDetector(
      onTap: isUploading ? null : _pickFile,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        dashPattern: const [6, 4],
        color: const Color(0xFF1A3A5F),
        strokeWidth: 2,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 70),
          decoration: BoxDecoration(
            color: const Color(0xFF1A3A5F),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isUploading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.upload_file, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                isUploading
                    ? "Upload en cours..."
                    : selectedFileName ?? "Selectionner un fichier",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitWorkshop,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text('Ajouter', style: TextStyle(fontSize: 16)),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFF1A3A5F)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFF1A3A5F), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFF1A3A5F), width: 2),
      ),
    );
  }
}