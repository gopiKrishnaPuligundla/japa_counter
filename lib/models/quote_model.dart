import 'package:equatable/equatable.dart';

enum QuoteType {
  text,
  image,
  custom,
}

class Quote extends Equatable {
  final String id;
  final String text;
  final String author;
  final QuoteType type;
  final String? imageUrl;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.type,
    this.imageUrl,
    this.isFavorite = false,
    required this.createdAt,
    this.updatedAt,
  });

  Quote copyWith({
    String? id,
    String? text,
    String? author,
    QuoteType? type,
    String? imageUrl,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Quote(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'type': type.name,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      text: json['text'] as String,
      author: json['author'] as String,
      type: QuoteType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QuoteType.text,
      ),
      imageUrl: json['imageUrl'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        text,
        author,
        type,
        imageUrl,
        isFavorite,
        createdAt,
        updatedAt,
      ];
} 