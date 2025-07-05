import 'package:flutter/material.dart';
import 'package:japa_counter/models/note_model.dart';
import 'package:japa_counter/services/notes_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  DateTime _selectedDate = DateTime.now();
  DailyNote? _currentNote;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _pointController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNoteForDate(_selectedDate);
  }

  Future<void> _loadNoteForDate(DateTime date) async {
    setState(() => _isLoading = true);
    
    try {
      final note = await NotesService.getNoteForDate(date);
      setState(() {
        _currentNote = note;
        _titleController.text = note?.title ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading note: $e')),
      );
    }
  }

  Future<void> _saveNote() async {
    if (_currentNote == null) return;
    
    try {
      final updatedNote = _currentNote!.copyWith(
        title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      );
      
      await NotesService.saveNote(updatedNote);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving note: $e')),
      );
    }
  }

  Future<void> _addPoint() async {
    final pointText = _pointController.text.trim();
    if (pointText.isEmpty || _currentNote == null) return;
    
    try {
      // First ensure the note exists in storage
      await NotesService.saveNote(_currentNote!);
      
      // Then add the point
      await NotesService.addPointToNote(_currentNote!.id, pointText);
      _pointController.clear();
      await _loadNoteForDate(_selectedDate);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding point: $e')),
      );
    }
  }

  Future<void> _togglePointFavorite(NotePoint point) async {
    if (_currentNote == null) return;
    
    try {
      await NotesService.togglePointFavorite(_currentNote!.id, point.id);
      await _loadNoteForDate(_selectedDate);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating favorite: $e')),
      );
    }
  }

  Future<void> _deletePoint(NotePoint point) async {
    if (_currentNote == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Point'),
        content: const Text('Are you sure you want to delete this point?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await NotesService.deletePoint(_currentNote!.id, point.id);
        await _loadNoteForDate(_selectedDate);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting point: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null && picked != _selectedDate) {
      await _saveNote(); // Save current note before switching
      setState(() => _selectedDate = picked);
      await _loadNoteForDate(picked);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiritual Notes'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
            tooltip: 'Save Note',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildDateSelector(),
                _buildTitleSection(),
                _buildAddPointSection(),
                Expanded(child: _buildPointsList()),
              ],
            ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.teal),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: _selectDate,
            child: const Text('Change Date'),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _titleController,
        decoration: const InputDecoration(
          labelText: 'Note Title (Optional)',
          hintText: 'Enter a title for today\'s reflections...',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.title),
        ),
        onChanged: (_) => _saveNote(),
      ),
    );
  }

  Widget _buildAddPointSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _pointController,
              decoration: const InputDecoration(
                labelText: 'Add a point',
                hintText: 'What spiritual insight did you have today?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lightbulb_outline),
              ),
              onSubmitted: (_) => _addPoint(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            onPressed: _addPoint,
            backgroundColor: Colors.teal,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsList() {
    if (_currentNote?.points.isEmpty ?? true) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No notes for this date yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Add your spiritual insights and reflections',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _currentNote!.points.length,
      itemBuilder: (context, index) {
        final point = _currentNote!.points[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              point.text,
              style: const TextStyle(fontSize: 16),
            ),
            subtitle: Text(
              'Added: ${point.createdAt.day}/${point.createdAt.month} at ${point.createdAt.hour}:${point.createdAt.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    point.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: point.isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () => _togglePointFavorite(point),
                  tooltip: point.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deletePoint(point),
                  tooltip: 'Delete point',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 