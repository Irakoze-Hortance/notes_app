import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note.dart';

class NotesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  CollectionReference get _notesCollection =>
      _firestore.collection('users').doc(_userId).collection('notes');

  Future<List<Note>> fetchNotes() async {
    try {
      final querySnapshot = await _notesCollection
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Note.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notes: ${e.toString()}');
    }
  }

  Future<Note> addNote(String text) async {
    try {
      final now = DateTime.now();
      final noteData = {
        'text': text,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final docRef = await _notesCollection.add(noteData);
      
      return Note(
        id: docRef.id,
        text: text,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      throw Exception('Failed to add note: ${e.toString()}');
    }
  }

  Future<Note> updateNote(String id, String text) async {
    try {
      final now = DateTime.now();
      final updateData = {
        'text': text,
        'updatedAt': Timestamp.fromDate(now),
      };

      await _notesCollection.doc(id).update(updateData);
      
      final doc = await _notesCollection.doc(id).get();
      return Note.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to update note: ${e.toString()}');
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _notesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete note: ${e.toString()}');
    }
  }
}
