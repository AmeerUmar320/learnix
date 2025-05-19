import 'package:equatable/equatable.dart';
import '../../models/group_model.dart';

abstract class GroupState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GroupInitial extends GroupState {}

class GroupLoading extends GroupState {}

class GroupsLoaded extends GroupState {
  final List<GroupModel> groups;
  GroupsLoaded(this.groups);
  @override
  List<Object?> get props => [groups];
}

class GroupFailure extends GroupState {
  final String error;
  GroupFailure(this.error);
  @override
  List<Object?> get props => [error];
}

class GroupSuccess extends GroupState {
  final GroupModel group;
  GroupSuccess(this.group);
  @override
  List<Object?> get props => [group];
}