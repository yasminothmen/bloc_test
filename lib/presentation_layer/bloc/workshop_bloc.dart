import '../../model/workshop.dart';
import 'workshop_event.dart';
import 'workshop_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkshopBloc extends Bloc<WorkshopEvent, WorkshopState> {
  WorkshopBloc() : super(WorkshopInitial()) {
    on<CategorySelected>((event, emit) {
      emit(CategorySelectionState(event.category));
    });

    on<CreateWorkshopButtonPressed>((event, emit) async {
      emit(WorkshopCreating());
      // Simulate creating the workshop (replace with your actual logic)
      try {
        // Simulate an API call
        await Future.delayed(const Duration(seconds: 1));
        // Create workshop
        final workshop = Workshop(
          category: event.category,
          objective: event.objective,
          exercise: event.exercise,
          time: event.time,
          title: '',
          instructor: '',
          // totalLessons: null,
          // completedLessons: '',
          // imageUrl: '',
        );

        // save work shop in list, so the event fetchAllWorkshops can get it.
        _workshops.add(workshop);

        emit(WorkshopCreated());
      } catch (e) {
        emit(WorkshopError('Failed to create workshop: ${e.toString()}'));
      }
    });

    on<FetchAllWorkshops>((event, emit) async {
      emit(WorkshopsLoading());
      // Simulate fetching workshops (replace with your actual logic)
      try {
        await Future.delayed(const Duration(seconds: 1)); // Simulate loading
        // final workshops = await _workshopRepository.getWorkshops();  // Replace with your repository call
        emit(WorkshopsLoaded(_workshops));
      } catch (e) {
        emit(WorkshopError('Failed to load workshops: ${e.toString()}'));
      }
    });
  }

  final List<Workshop> _workshops = []; // In-memory storage for workshops
}
