import '../../model/workshop.dart';
import '../bloc/workshop_bloc.dart';
import '../bloc/workshop_event.dart';
import '../bloc/workshop_state.dart';
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
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Search",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Icon(Icons.tune_outlined, color: Colors.grey),
            ],
          ),
        ),
        ListView.builder(
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
        ),
      ],
    );
  }
}
