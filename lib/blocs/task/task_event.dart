part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchGroupsEvent extends TaskEvent {}

class CreateTaskEvent extends TaskEvent {
  final String title;
  final int groupId;
  final DateTime dueDate;
  final List<String> subtasks;
  CreateTaskEvent({
    required this.title,
    required this.groupId,
    required this.dueDate,
    required this.subtasks,
  });

  @override
  List<Object?> get props => [title, groupId, dueDate, subtasks];
}

class FetchTasksForUserEvent extends TaskEvent {
  final int userId;
  FetchTasksForUserEvent(this.userId);
}
