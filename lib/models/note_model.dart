import 'package:equatable/equatable.dart';

class NotePoint extends Equatable {
  final String id;
  final String text;
  final bool isFavorite;
  final DateTime createdAt;

  const NotePoint({
    required this.id,
    required this.text,
    this.isFavorite = false,
    required this.createdAt,
  });

  NotePoint copyWith({
    String? id,
    String? text,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return NotePoint(
      id: id ?? this.id,
      text: text ?? this.text,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isFavorite': isFavorite,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory NotePoint.fromJson(Map<String, dynamic> json) {
    return NotePoint(
      id: json['id'] as String,
      text: json['text'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  @override
  List<Object?> get props => [id, text, isFavorite, createdAt];
}

class DailyNote extends Equatable {
  final String id;
  final DateTime date;
  final String? title;
  final List<NotePoint> points;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DailyNote({
    required this.id,
    required this.date,
    this.title,
    this.points = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  DailyNote copyWith({
    String? id,
    DateTime? date,
    String? title,
    List<NotePoint>? points,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyNote(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get all favorite points from this note
  List<NotePoint> get favoritePoints {
    return points.where((point) => point.isFavorite).toList();
  }

  // Check if note has any content
  bool get hasContent {
    return (title?.isNotEmpty ?? false) || points.isNotEmpty;
  }

  // Get formatted date string
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'title': title,
      'points': points.map((point) => point.toJson()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory DailyNote.fromJson(Map<String, dynamic> json) {
    return DailyNote(
      id: json['id'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      title: json['title'] as String?,
      points: (json['points'] as List<dynamic>?)
              ?.map((pointJson) => NotePoint.fromJson(pointJson as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
    );
  }

  @override
  List<Object?> get props => [id, date, title, points, createdAt, updatedAt];
} 