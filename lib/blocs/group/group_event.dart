import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class GroupEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchGroupsForUser extends GroupEvent {
  final int userId;
  FetchGroupsForUser(this.userId);
  @override
  List<Object?> get props => [userId];
}

class LeaveGroupRequested extends GroupEvent {
  final int userId;
  final int groupId;
  LeaveGroupRequested(this.userId, this.groupId);
  @override
  List<Object?> get props => [userId, groupId];
}

class CreateGroupRequested extends GroupEvent {
  final String name;
  final String? description;
  final List<int> memberIds;
  final File? image;

  CreateGroupRequested({
    required this.name,
    this.description,
    required this.memberIds,
    this.image,
  });

  @override
  List<Object?> get props => [name, description, memberIds, image];
}