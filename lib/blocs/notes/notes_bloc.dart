import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/notes_repository.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesRepository _notesRepository;

  NotesBloc({required NotesRepository notesRepository})
      : _notesRepository = notesRepository,
        super(NotesInitial()) {
    on<NotesFetch>(_onFetch);
    on<NotesAdd>(_onAdd);
    on<NotesUpdate>(_onUpdate);
    on<NotesDelete>(_onDelete);
  }

  Future<void> _onFetch(NotesFetch event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      final notes = await _notesRepository.fetchNotes();
      emit(NotesLoaded(notes: notes));
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  Future<void> _onAdd(NotesAdd event, Emitter<NotesState> emit) async {
    if (state is NotesLoaded) {
      final currentNotes = (state as NotesLoaded).notes;
      try {
        final newNote = await _notesRepository.addNote(event.text);
        emit(NotesLoaded(notes: [newNote, ...currentNotes]));
      } catch (e) {
        emit(NotesError(message: e.toString()));
        // Restore previous state after showing error
        await Future.delayed(const Duration(milliseconds: 100));
        emit(NotesLoaded(notes: currentNotes));
      }
    }
  }

  Future<void> _onUpdate(NotesUpdate event, Emitter<NotesState> emit) async {
    if (state is NotesLoaded) {
      final currentNotes = (state as NotesLoaded).notes;
      try {
        final updatedNote = await _notesRepository.updateNote(event.id, event.text);
        final updatedNotes = currentNotes.map((note) {
          return note.id == event.id ? updatedNote : note;
        }).toList();
        emit(NotesLoaded(notes: updatedNotes));
      } catch (e) {
        emit(NotesError(message: e.toString()));
        // Restore previous state after showing error
        await Future.delayed(const Duration(milliseconds: 100));
        emit(NotesLoaded(notes: currentNotes));
      }
    }
  }

  Future<void> _onDelete(NotesDelete event, Emitter<NotesState> emit) async {
    if (state is NotesLoaded) {
      final currentNotes = (state as NotesLoaded).notes;
      try {
        await _notesRepository.deleteNote(event.id);
        final updatedNotes = currentNotes.where((note) => note.id != event.id).toList();
        emit(NotesLoaded(notes: updatedNotes));
      } catch (e) {
        emit(NotesError(message: e.toString()));
        // Restore previous state after showing error
        await Future.delayed(const Duration(milliseconds: 100));
        emit(NotesLoaded(notes: currentNotes));
      }
    }
  }
}
