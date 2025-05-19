import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/task_repository.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;
  TaskBloc(this.repository) : super(TaskInitial()) {
    on<FetchGroupsEvent>((event, emit) async {
      emit(TaskLoading());
      try {
        final groups = await repository.fetchGroups();
        emit(GroupsLoaded(groups));
      } catch (e) {
        emit(TaskError('Could not load groups'));
      }
    });

    on<CreateTaskEvent>((event, emit) async {
      emit(TaskLoading());
      try {
        final success = await repository.createTask(
          title: event.title,
          groupId: event.groupId,
          dueDate: event.dueDate,
          subtasks: event.subtasks,
        );
        if (success) {
          emit(TaskCreated());
        } else {
          emit(TaskError('Failed to create task'));
        }
      } catch (e) {
        emit(TaskError('Failed to create task'));
      }
    });

    on<FetchTasksForUserEvent>((event, emit) async {
      emit(TaskLoading());
      try {
        final tasks = await repository.fetchTasksForUser(event.userId);
        emit(TasksLoaded(tasks));
      } catch (e) {
        emit(TaskError('Failed to load tasks'));
      }
    });
  }
}
