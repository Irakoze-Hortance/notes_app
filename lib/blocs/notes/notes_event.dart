import 'package:equatable/equatable.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object> get props => [];
}

class NotesFetch extends NotesEvent {}

class NotesAdd extends NotesEvent {
  final String text;

  const NotesAdd({required this.text});

  @override
  List<Object> get props => [text];
}

class NotesUpdate extends NotesEvent {
  final String id;
  final String text;

  const NotesUpdate({required this.id, required this.text});

  @override
  List<Object> get props => [id, text];
}

class NotesDelete extends NotesEvent {
  final String id;

  const NotesDelete({required this.id});

  @override
  List<Object> get props => [id];
}
