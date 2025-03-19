import 'package:bloc_test/data/models/workshop.dart';
import 'package:equatable/equatable.dart';

abstract class WorkshopState extends Equatable {
  const WorkshopState();

  @override
  List<Object> get props => [];
}

class WorkshopInitial extends WorkshopState {}

class CategorySelectionState extends WorkshopState {
  final String selectedCategory;

  const CategorySelectionState(this.selectedCategory);

  @override
  List<Object> get props => [selectedCategory];
}

class WorkshopCreating extends WorkshopState {}

class WorkshopCreated extends WorkshopState {}

class WorkshopsLoading extends WorkshopState {}

class WorkshopsLoaded extends WorkshopState {
  final List<Workshop> workshops;

  const WorkshopsLoaded(this.workshops);

  @override
  List<Object> get props => [workshops];
}

class WorkshopError extends WorkshopState {
  final String message;

  const WorkshopError(this.message);

  @override
  List<Object> get props => [message];
}
