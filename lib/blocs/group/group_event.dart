import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class GroupEvent extends Equatable {
  @override
  List<Object?> get props => [];
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

class FetchGroupsForUser extends GroupEvent {
  final int userId;
  FetchGroupsForUser(this.userId);
  @override
  List<Object?> get props => [userId];
}
