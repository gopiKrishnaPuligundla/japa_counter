import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:japa_counter/models/note_model.dart';

class NotesService {
  static const String _notesKey = 'daily_notes';
  
  static Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // Generate unique ID
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Get all notes
  static Future<List<DailyNote>> getAllNotes() async {
    final prefs = await _prefs;
    final notesJson = prefs.getStringList(_notesKey) ?? [];
    
    return notesJson
        .map((noteString) => DailyNote.fromJson(json.decode(noteString)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
  }

  // Get note for specific date
  static Future<DailyNote?> getNoteForDate(DateTime date) async {
    final notes = await getAllNotes();
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    return notes.firstWhere(
      (note) => _isSameDate(note.date, dateOnly),
      orElse: () => DailyNote(
        id: _generateId(),
        date: dateOnly,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  // Save or update note
  static Future<void> saveNote(DailyNote note) async {
    final notes = await getAllNotes();
    final existingIndex = notes.indexWhere((n) => n.id == note.id);
    
    final updatedNote = note.copyWith(updatedAt: DateTime.now());
    
    if (existingIndex >= 0) {
      notes[existingIndex] = updatedNote;
    } else {
      notes.add(updatedNote);
    }
    
    await _saveNotes(notes);
  }

  // Delete note
  static Future<void> deleteNote(String noteId) async {
    final notes = await getAllNotes();
    notes.removeWhere((note) => note.id == noteId);
    await _saveNotes(notes);
  }

  // Add point to note
  static Future<void> addPointToNote(String noteId, String pointText) async {
    final notes = await getAllNotes();
    final noteIndex = notes.indexWhere((note) => note.id == noteId);
    
    if (noteIndex >= 0) {
      final note = notes[noteIndex];
      final newPoint = NotePoint(
        id: _generateId(),
        text: pointText,
        createdAt: DateTime.now(),
      );
      
      final updatedPoints = List<NotePoint>.from(note.points)..add(newPoint);
      notes[noteIndex] = note.copyWith(
        points: updatedPoints,
        updatedAt: DateTime.now(),
      );
      
      await _saveNotes(notes);
    }
  }

  // Update point
  static Future<void> updatePoint(String noteId, String pointId, String newText) async {
    final notes = await getAllNotes();
    final noteIndex = notes.indexWhere((note) => note.id == noteId);
    
    if (noteIndex >= 0) {
      final note = notes[noteIndex];
      final updatedPoints = note.points.map((point) {
        if (point.id == pointId) {
          return point.copyWith(text: newText);
        }
        return point;
      }).toList();
      
      notes[noteIndex] = note.copyWith(
        points: updatedPoints,
        updatedAt: DateTime.now(),
      );
      
      await _saveNotes(notes);
    }
  }

  // Toggle favorite status of a point
  static Future<void> togglePointFavorite(String noteId, String pointId) async {
    final notes = await getAllNotes();
    final noteIndex = notes.indexWhere((note) => note.id == noteId);
    
    if (noteIndex >= 0) {
      final note = notes[noteIndex];
      final updatedPoints = note.points.map((point) {
        if (point.id == pointId) {
          return point.copyWith(isFavorite: !point.isFavorite);
        }
        return point;
      }).toList();
      
      notes[noteIndex] = note.copyWith(
        points: updatedPoints,
        updatedAt: DateTime.now(),
      );
      
      await _saveNotes(notes);
    }
  }

  // Delete point
  static Future<void> deletePoint(String noteId, String pointId) async {
    final notes = await getAllNotes();
    final noteIndex = notes.indexWhere((note) => note.id == noteId);
    
    if (noteIndex >= 0) {
      final note = notes[noteIndex];
      final updatedPoints = note.points.where((point) => point.id != pointId).toList();
      
      notes[noteIndex] = note.copyWith(
        points: updatedPoints,
        updatedAt: DateTime.now(),
      );
      
      await _saveNotes(notes);
    }
  }

  // Get all favorite points across all notes
  static Future<List<Map<String, dynamic>>> getAllFavoritePoints() async {
    final notes = await getAllNotes();
    final favoritePoints = <Map<String, dynamic>>[];
    
    for (final note in notes) {
      for (final point in note.favoritePoints) {
        favoritePoints.add({
          'point': point,
          'note': note,
        });
      }
    }
    
    // Sort by creation date, most recent first
    favoritePoints.sort((a, b) => 
        (b['point'] as NotePoint).createdAt.compareTo((a['point'] as NotePoint).createdAt));
    
    return favoritePoints;
  }

  // Search notes by text
  static Future<List<DailyNote>> searchNotes(String query) async {
    if (query.trim().isEmpty) return [];
    
    final notes = await getAllNotes();
    final lowerQuery = query.toLowerCase();
    
    return notes.where((note) {
      final titleMatch = note.title?.toLowerCase().contains(lowerQuery) ?? false;
      final pointsMatch = note.points.any((point) => 
          point.text.toLowerCase().contains(lowerQuery));
      
      return titleMatch || pointsMatch;
    }).toList();
  }

  // Private helper methods
  static Future<void> _saveNotes(List<DailyNote> notes) async {
    final prefs = await _prefs;
    final notesJson = notes
        .map((note) => json.encode(note.toJson()))
        .toList();
    
    await prefs.setStringList(_notesKey, notesJson);
  }

  static bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
} 