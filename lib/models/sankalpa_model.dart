import 'package:equatable/equatable.dart';

enum SankalpaPeriodType {
  dateRange,     // From specific date to specific date
  forever,       // From start date to forever
  daily,         // Daily commitment (resets each day)
  weekly,        // Weekly commitment (resets each week)
  monthly,       // Monthly commitment (resets each month)
  rounds,        // Specific number of rounds (no time limit)
  days,          // For a specific number of days
}

enum SankalpaStatus {
  active,
  completed,
  paused,
  failed,
}

// Simplified - no goal types needed

class SankalpaPeriod extends Equatable {
  final SankalpaPeriodType type;
  final DateTime startDate;
  final DateTime? endDate;
  final int? durationDays;

  const SankalpaPeriod({
    required this.type,
    required this.startDate,
    this.endDate,
    this.durationDays,
  });

  bool get isActive {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    
    switch (type) {
      case SankalpaPeriodType.dateRange:
        if (endDate == null) return false;
        final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
        return today.isAfter(start.subtract(const Duration(days: 1))) && 
               today.isBefore(end.add(const Duration(days: 1)));
      case SankalpaPeriodType.forever:
        return today.isAfter(start.subtract(const Duration(days: 1)));
      case SankalpaPeriodType.daily:
        return today.isAtSameMomentAs(start);
      case SankalpaPeriodType.weekly:
        final weekStart = start.subtract(Duration(days: start.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return today.isAfter(weekStart.subtract(const Duration(days: 1))) && 
               today.isBefore(weekEnd.add(const Duration(days: 1)));
      case SankalpaPeriodType.monthly:
        return today.year == start.year && today.month == start.month;
      case SankalpaPeriodType.rounds:
      case SankalpaPeriodType.days:
        if (durationDays == null) return false;
        final endCalculated = start.add(Duration(days: durationDays! - 1));
        return today.isAfter(start.subtract(const Duration(days: 1))) && 
               today.isBefore(endCalculated.add(const Duration(days: 1)));
    }
  }

  String get description {
    switch (type) {
      case SankalpaPeriodType.dateRange:
        return 'From ${_formatDate(startDate)} to ${endDate != null ? _formatDate(endDate!) : 'Unknown'}';
      case SankalpaPeriodType.forever:
        return 'From ${_formatDate(startDate)} forever';
      case SankalpaPeriodType.daily:
        return 'Daily commitment';
      case SankalpaPeriodType.weekly:
        return 'Weekly commitment';
      case SankalpaPeriodType.monthly:
        return 'Monthly commitment';
      case SankalpaPeriodType.rounds:
        return 'Complete rounds (no time limit)';
      case SankalpaPeriodType.days:
        return 'For ${durationDays ?? 0} days';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'durationDays': durationDays,
    };
  }

  factory SankalpaPeriod.fromJson(Map<String, dynamic> json) {
    return SankalpaPeriod(
      type: SankalpaPeriodType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SankalpaPeriodType.dateRange,
      ),
      startDate: DateTime.fromMillisecondsSinceEpoch(json['startDate'] as int),
      endDate: json['endDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['endDate'] as int)
          : null,
      durationDays: json['durationDays'] as int?,
    );
  }

  @override
  List<Object?> get props => [type, startDate, endDate, durationDays];
}

class SankalpaProgress extends Equatable {
  final int currentRounds;
  final int targetRounds;

  const SankalpaProgress({
    this.currentRounds = 0,
    this.targetRounds = 0,
  });

  double get progressPercentage {
    if (targetRounds == 0) return 0.0;
    return (currentRounds / targetRounds).clamp(0.0, 1.0);
  }

  bool get isCompleted => targetRounds > 0 && currentRounds >= targetRounds;

  String get description {
    if (targetRounds == 0) return '$currentRounds rounds completed';
    return '$currentRounds / $targetRounds rounds';
  }

  SankalpaProgress copyWith({
    int? currentRounds,
    int? targetRounds,
  }) {
    return SankalpaProgress(
      currentRounds: currentRounds ?? this.currentRounds,
      targetRounds: targetRounds ?? this.targetRounds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentRounds': currentRounds,
      'targetRounds': targetRounds,
    };
  }

  factory SankalpaProgress.fromJson(Map<String, dynamic> json) {
    return SankalpaProgress(
      currentRounds: json['currentRounds'] as int? ?? 0,
      targetRounds: json['targetRounds'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [currentRounds, targetRounds];
}

class Sankalpa extends Equatable {
  final String id;
  final String title;
  final String? description;
  final SankalpaPeriod period;
  final SankalpaProgress progress;
  final SankalpaStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? lastUpdated;
  final List<String> notes;

  const Sankalpa({
    required this.id,
    required this.title,
    this.description,
    required this.period,
    required this.progress,
    this.status = SankalpaStatus.active,
    required this.createdAt,
    this.completedAt,
    this.lastUpdated,
    this.notes = const [],
  });

  bool get isActive => status == SankalpaStatus.active && period.isActive;
  bool get isCompleted => status == SankalpaStatus.completed || progress.isCompleted;
  
  double get overallProgress {
    // For sankalpas with target rounds, show progress percentage
    if (progress.targetRounds > 0) {
      return progress.progressPercentage;
    }
    
    // For sankalpas without target, show time progress
    return _calculateTimeProgress();
  }

  double _calculateTimeProgress() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(period.startDate.year, period.startDate.month, period.startDate.day);
    
    switch (period.type) {
      case SankalpaPeriodType.dateRange:
        if (period.endDate == null) return 0.0;
        final end = DateTime(period.endDate!.year, period.endDate!.month, period.endDate!.day);
        final totalDays = end.difference(start).inDays + 1;
        final elapsedDays = today.difference(start).inDays + 1;
        return (elapsedDays / totalDays).clamp(0.0, 1.0);
      
      case SankalpaPeriodType.days:
        if (period.durationDays == null) return 0.0;
        final elapsedDays = today.difference(start).inDays + 1;
        return (elapsedDays / period.durationDays!).clamp(0.0, 1.0);
      
      case SankalpaPeriodType.daily:
        return today.isAtSameMomentAs(start) ? 1.0 : 0.0;
      
      case SankalpaPeriodType.weekly:
        final weekStart = start.subtract(Duration(days: start.weekday - 1));
        final dayOfWeek = today.difference(weekStart).inDays;
        return (dayOfWeek / 6).clamp(0.0, 1.0);
      
      case SankalpaPeriodType.monthly:
        final monthStart = DateTime(start.year, start.month, 1);
        final monthEnd = DateTime(start.year, start.month + 1, 0);
        final totalDays = monthEnd.day;
        final currentDay = today.day;
        return (currentDay / totalDays).clamp(0.0, 1.0);
      
      case SankalpaPeriodType.forever:
      case SankalpaPeriodType.rounds:
        return 1.0; // No time limit
    }
  }

  String get statusDescription {
    switch (status) {
      case SankalpaStatus.active:
        return 'Active';
      case SankalpaStatus.completed:
        return 'Completed';
      case SankalpaStatus.paused:
        return 'Paused';
      case SankalpaStatus.failed:
        return 'Failed';
    }
  }

  Sankalpa copyWith({
    String? id,
    String? title,
    String? description,
    SankalpaPeriod? period,
    SankalpaProgress? progress,
    SankalpaStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? lastUpdated,
    List<String>? notes,
  }) {
    return Sankalpa(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      period: period ?? this.period,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'period': period.toJson(),
      'progress': progress.toJson(),
      'status': status.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'lastUpdated': lastUpdated?.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  factory Sankalpa.fromJson(Map<String, dynamic> json) {
    return Sankalpa(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      period: SankalpaPeriod.fromJson(json['period'] as Map<String, dynamic>),
      progress: SankalpaProgress.fromJson(json['progress'] as Map<String, dynamic>),
      status: SankalpaStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SankalpaStatus.active,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      completedAt: json['completedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'] as int)
          : null,
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['lastUpdated'] as int)
          : null,
      notes: List<String>.from(json['notes'] as List? ?? []),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        period,
        progress,
        status,
        createdAt,
        completedAt,
        lastUpdated,
        notes,
      ];
} 