import 'package:bloc_test/presentation_layer/bloc/workshop_bloc.dart';
import 'package:bloc_test/presentation_layer/bloc/workshop_event.dart';
import 'package:bloc_test/presentation_layer/bloc/workshop_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class CreateWorkshopTab extends StatefulWidget {
  const CreateWorkshopTab({super.key});

  @override
  State<CreateWorkshopTab> createState() => _CreateWorkshopTabState();
}

class _CreateWorkshopTabState extends State<CreateWorkshopTab> {
  String? selectedCategory;

  final objectiveController = TextEditingController();

  final exerciseController = TextEditingController();

  final timeController = TextEditingController();

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
                const Text(
                  'View All categories',
                  textAlign: TextAlign.start,
                ),
                const SizedBox(
                  height: 20,
                ),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildCategoryButton(context, 'Science', Icons.science),
                    _buildCategoryButton(context, 'Math', Icons.calculate),
                    _buildCategoryButton(context, 'Sport', Icons.directions_run),
                    _buildCategoryButton(context, 'Paint', Icons.color_lens),
                    _buildCategoryButton(context, 'Music', Icons.music_note),
                    _buildCategoryButton(context, 'English', Icons.translate),
                    _buildCategoryButton(context, 'Frensh', Icons.flag),
                    _buildCategoryButton(context, 'Geography', Icons.map),
                    _buildCategoryButton(context, 'History', Icons.book),
                    _buildCategoryButton(context, 'Physics', Icons.lightbulb),
                    _buildCategoryButton(context, 'Technology', Icons.computer),
                    _buildCategoryButton(context, 'Biology', Icons.biotech),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: exerciseController,
                  decoration: const InputDecoration(
                    labelText: 'Add exercise',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'HH:MM:SS',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: objectiveController,
                  decoration: const InputDecoration(
                    labelText: 'Objective exercise',
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
                      // Show an error message if no category is selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a category.'),
                        ),
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

  Widget _buildCategoryButton(
      BuildContext context, String category, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedCategory = category;
          });
          BlocProvider.of<WorkshopBloc>(context)
              .add(CategorySelected(category));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 8),
            Text(category),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    objectiveController.dispose();
    exerciseController.dispose();
    timeController.dispose();
    super.dispose();
  }
}
