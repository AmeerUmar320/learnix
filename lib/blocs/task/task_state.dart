part of 'task_bloc.dart';

abstract class TaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class GroupsLoaded extends TaskState {
  final List<Map<String, dynamic>> groups;
  GroupsLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

class TaskCreated extends TaskState {}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);

  @override
  List<Object?> get props => [message];
}

class TasksLoaded extends TaskState {
  final List<Map<String, dynamic>> tasks;
  TasksLoaded(this.tasks);
}