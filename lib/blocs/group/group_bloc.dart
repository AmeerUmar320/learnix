import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/group_repository.dart';
import 'group_event.dart';
import 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupRepository groupRepository;
  GroupBloc(this.groupRepository) : super(GroupInitial()) {
    on<CreateGroupRequested>(_onCreateGroupRequested);
    on<FetchGroupsForUser>(_onFetchGroupsForUser);
  }

  Future<void> _onCreateGroupRequested(
      CreateGroupRequested event, Emitter<GroupState> emit) async {
    emit(GroupLoading());
    try {
      final group = await groupRepository.createGroupWithImage(
        name: event.name,
        description: event.description,
        memberIds: event.memberIds,
        image: event.image,
      );
      emit(GroupSuccess(group));
    } catch (e) {
      emit(GroupFailure(e.toString()));
    }
  }

  Future<void> _onFetchGroupsForUser(
      FetchGroupsForUser event, Emitter<GroupState> emit) async {
    emit(GroupLoading());
    try {
      final groups = await groupRepository.fetchGroupsForUser(event.userId);
      emit(GroupsLoaded(groups));
    } catch (e) {
      emit(GroupFailure(e.toString()));
    }
  }
}
