import 'package:bloc_test/data/models/workshop.dart';
import 'package:bloc_test/presentation_layer/bloc/workshop_bloc.dart';
import 'package:bloc_test/presentation_layer/bloc/workshop_event.dart';
import 'package:bloc_test/presentation_layer/bloc/workshop_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllWorkshopsTab extends StatefulWidget {
  const AllWorkshopsTab({super.key});

  @override
  State<AllWorkshopsTab> createState() => _AllWorkshopsTabState();
}

class _AllWorkshopsTabState extends State<AllWorkshopsTab> {
  @override
  void initState() {
    super.initState();
    // Fetch workshops when the tab is initialized
    BlocProvider.of<WorkshopBloc>(context).add(FetchAllWorkshops());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkshopBloc, WorkshopState>(
      builder: (context, state) {
        if (state is WorkshopsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is WorkshopsLoaded) {
          return _buildWorkshopsList(state.workshops);
        } else if (state is WorkshopError) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return const Center(child: Text('No workshops loaded.'));
        }
      },
    );
  }

  Widget _buildWorkshopsList(List<Workshop> workshops) {
    return ListView.builder(
      itemCount: workshops.length,
      itemBuilder: (context, index) {
        final workshop = workshops[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category: ${workshop.category}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Objective: ${workshop.objective}'),
                Text('Exercise: ${workshop.exercise}'),
                Text('Time: ${workshop.time}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
