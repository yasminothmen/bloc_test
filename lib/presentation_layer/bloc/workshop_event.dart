import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class WorkshopEvent extends Equatable {
  const WorkshopEvent();

  @override
  List<Object> get props => [];
}

class CategorySelected extends WorkshopEvent {
  final String category;

  const CategorySelected(this.category);

  @override
  List<Object> get props => [category];
}

class CreateWorkshopButtonPressed extends WorkshopEvent {
  final String category;
  final String objective;
  final String exercise;
  final String time;

  const CreateWorkshopButtonPressed({
    required this.category,
    required this.objective,
    required this.exercise,
    required this.time,
  });

  @override
  List<Object> get props => [category, objective, exercise, time];
}

class FetchAllWorkshops extends WorkshopEvent {} // For the "All Workshops" tab
