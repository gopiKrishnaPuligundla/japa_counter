import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/sankalpa_model.dart';

class SankalpaService {
  static const String _sankalpasKey = 'sankalpas';
  static const String _progressKey = 'sankalpa_progress';
  
  final _uuid = const Uuid();
  SharedPreferences? _prefs;
  
  // Initialize the service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Get all sankalpas
  Future<List<Sankalpa>> getSankalpas() async {
    await initialize();
    
    final sankalpasJson = _prefs?.getString(_sankalpasKey);
    if (sankalpasJson == null) return [];
    
    final List<dynamic> sankalpasData = json.decode(sankalpasJson);
    return sankalpasData.map((data) => Sankalpa.fromJson(data)).toList();
  }

  // Get active sankalpas
  Future<List<Sankalpa>> getActiveSankalpas() async {
    final sankalpas = await getSankalpas();
    return sankalpas.where((s) => s.isActive).toList();
  }

  // Get completed sankalpas
  Future<List<Sankalpa>> getCompletedSankalpas() async {
    final sankalpas = await getSankalpas();
    return sankalpas.where((s) => s.isCompleted).toList();
  }

  // Get sankalpas by status
  Future<List<Sankalpa>> getSankalpasByStatus(SankalpaStatus status) async {
    final sankalpas = await getSankalpas();
    return sankalpas.where((s) => s.status == status).toList();
  }

  // Get today's active sankalpas
  Future<List<Sankalpa>> getTodaysActiveSankalpas() async {
    final sankalpas = await getSankalpas();
    final today = DateTime.now();
    
    return sankalpas.where((s) {
      if (s.status != SankalpaStatus.active) return false;
      
      // Check if today is within the sankalpa period
      switch (s.period.type) {
        case SankalpaPeriodType.daily:
          return _isSameDate(today, s.period.startDate);
        case SankalpaPeriodType.weekly:
          return _isInCurrentWeek(today, s.period.startDate);
        case SankalpaPeriodType.monthly:
          return today.year == s.period.startDate.year && 
                 today.month == s.period.startDate.month;
        case SankalpaPeriodType.dateRange:
          if (s.period.endDate == null) return false;
          return today.isAfter(s.period.startDate.subtract(const Duration(days: 1))) &&
                 today.isBefore(s.period.endDate!.add(const Duration(days: 1)));
        case SankalpaPeriodType.forever:
          return today.isAfter(s.period.startDate.subtract(const Duration(days: 1)));
        case SankalpaPeriodType.days:
          if (s.period.durationDays == null) return false;
          final endDate = s.period.startDate.add(Duration(days: s.period.durationDays! - 1));
          return today.isAfter(s.period.startDate.subtract(const Duration(days: 1))) &&
                 today.isBefore(endDate.add(const Duration(days: 1)));
        case SankalpaPeriodType.rounds:
                     return !s.progress.isCompleted;
      }
    }).toList();
  }

  // Create a new sankalpa
  Future<Sankalpa> createSankalpa({
    required String title,
    String? description,
    required SankalpaPeriod period,
    int? targetRounds,
    List<String>? notes,
  }) async {
    await initialize();
    
    final sankalpa = Sankalpa(
      id: _uuid.v4(),
      title: title,
      description: description,
      period: period,
      progress: SankalpaProgress(
        currentRounds: 0,
        targetRounds: targetRounds ?? 0,
      ),
      status: SankalpaStatus.active,
      createdAt: DateTime.now(),
      notes: notes ?? [],
    );
    
    await _saveSankalpa(sankalpa);
    return sankalpa;
  }

  // Update an existing sankalpa
  Future<Sankalpa> updateSankalpa(Sankalpa sankalpa) async {
    await initialize();
    
    final updatedSankalpa = sankalpa.copyWith(
      lastUpdated: DateTime.now(),
    );
    
    await _saveSankalpa(updatedSankalpa);
    return updatedSankalpa;
  }

  // Update sankalpa progress
  Future<Sankalpa> updateProgress(String sankalpaId, int rounds) async {
    final sankalpas = await getSankalpas();
    final sankalpaIndex = sankalpas.indexWhere((s) => s.id == sankalpaId);
    
    if (sankalpaIndex == -1) {
      throw Exception('Sankalpa not found');
    }
    
    final sankalpa = sankalpas[sankalpaIndex];
    final updatedProgress = sankalpa.progress.copyWith(currentRounds: rounds);
    
    // Check if sankalpa is completed
    SankalpaStatus newStatus = sankalpa.status;
    DateTime? completedAt;
    
    if (updatedProgress.isCompleted && sankalpa.status == SankalpaStatus.active) {
      newStatus = SankalpaStatus.completed;
      completedAt = DateTime.now();
    }
    
    final updatedSankalpa = sankalpa.copyWith(
      progress: updatedProgress,
      status: newStatus,
      completedAt: completedAt,
      lastUpdated: DateTime.now(),
    );
    
    await _saveSankalpa(updatedSankalpa);
    return updatedSankalpa;
  }

  // Add progress to sankalpa (incremental)
  Future<Sankalpa> addProgress(String sankalpaId, int additionalRounds) async {
    final sankalpas = await getSankalpas();
    final sankalpa = sankalpas.firstWhere((s) => s.id == sankalpaId);
    
    final newRounds = sankalpa.progress.currentRounds + additionalRounds;
    return await updateProgress(sankalpaId, newRounds);
  }

  // Add note to sankalpa
  Future<Sankalpa> addNote(String sankalpaId, String note) async {
    final sankalpas = await getSankalpas();
    final sankalpaIndex = sankalpas.indexWhere((s) => s.id == sankalpaId);
    
    if (sankalpaIndex == -1) {
      throw Exception('Sankalpa not found');
    }
    
    final sankalpa = sankalpas[sankalpaIndex];
    final updatedNotes = List<String>.from(sankalpa.notes);
    updatedNotes.add('${DateTime.now().toIso8601String()}: $note');
    
    final updatedSankalpa = sankalpa.copyWith(
      notes: updatedNotes,
      lastUpdated: DateTime.now(),
    );
    
    await _saveSankalpa(updatedSankalpa);
    return updatedSankalpa;
  }

  // Update sankalpa status
  Future<Sankalpa> updateStatus(String sankalpaId, SankalpaStatus status) async {
    final sankalpas = await getSankalpas();
    final sankalpaIndex = sankalpas.indexWhere((s) => s.id == sankalpaId);
    
    if (sankalpaIndex == -1) {
      throw Exception('Sankalpa not found');
    }
    
    final sankalpa = sankalpas[sankalpaIndex];
    DateTime? completedAt;
    
    if (status == SankalpaStatus.completed) {
      completedAt = DateTime.now();
    }
    
    final updatedSankalpa = sankalpa.copyWith(
      status: status,
      completedAt: completedAt,
      lastUpdated: DateTime.now(),
    );
    
    await _saveSankalpa(updatedSankalpa);
    return updatedSankalpa;
  }

  // Delete sankalpa
  Future<void> deleteSankalpa(String sankalpaId) async {
    final sankalpas = await getSankalpas();
    final filteredSankalpas = sankalpas.where((s) => s.id != sankalpaId).toList();
    
    await _saveSankalpas(filteredSankalpas);
  }

  // Get sankalpa by id
  Future<Sankalpa?> getSankalpaById(String sankalpaId) async {
    final sankalpas = await getSankalpas();
    try {
      return sankalpas.firstWhere((s) => s.id == sankalpaId);
    } catch (e) {
      return null;
    }
  }

  // Get progress statistics
  Future<Map<String, dynamic>> getProgressStats() async {
    final sankalpas = await getSankalpas();
    final active = sankalpas.where((s) => s.status == SankalpaStatus.active).length;
    final completed = sankalpas.where((s) => s.status == SankalpaStatus.completed).length;
    final paused = sankalpas.where((s) => s.status == SankalpaStatus.paused).length;
    final failed = sankalpas.where((s) => s.status == SankalpaStatus.failed).length;
    
    // Calculate total rounds across all sankalpas
    final totalRounds = sankalpas.fold<int>(0, (sum, s) => sum + s.progress.currentRounds);
    
    // Calculate average progress for sankalpas with targets
    final sankalpasWithTargets = sankalpas.where((s) => s.progress.targetRounds > 0);
    double averageProgress = 0.0;
    
    if (sankalpasWithTargets.isNotEmpty) {
      averageProgress = sankalpasWithTargets
          .map((s) => s.progress.progressPercentage)
          .reduce((a, b) => a + b) / sankalpasWithTargets.length;
    }
    
    return {
      'total': sankalpas.length,
      'active': active,
      'completed': completed,
      'paused': paused,
      'failed': failed,
      'totalRounds': totalRounds,
      'averageProgress': averageProgress,
    };
  }

  // Check for expired sankalpas and update their status
  Future<void> checkAndUpdateExpiredSankalpas() async {
    final sankalpas = await getSankalpas();
    final now = DateTime.now();
    bool hasUpdates = false;
    
    for (int i = 0; i < sankalpas.length; i++) {
      final sankalpa = sankalpas[i];
      
      if (sankalpa.status == SankalpaStatus.active && !sankalpa.period.isActive) {
        // Check if the period has expired
        if (sankalpa.period.type == SankalpaPeriodType.dateRange &&
            sankalpa.period.endDate != null &&
            now.isAfter(sankalpa.period.endDate!)) {
          
          // Mark as completed if goal is met, otherwise failed
          final newStatus = sankalpa.progress.isCompleted 
              ? SankalpaStatus.completed 
              : SankalpaStatus.failed;
          
          sankalpas[i] = sankalpa.copyWith(
            status: newStatus,
            completedAt: DateTime.now(),
            lastUpdated: DateTime.now(),
          );
          
          hasUpdates = true;
        }
      }
    }
    
    if (hasUpdates) {
      await _saveSankalpas(sankalpas);
    }
  }

  // Private helper methods
  Future<void> _saveSankalpa(Sankalpa sankalpa) async {
    final sankalpas = await getSankalpas();
    final index = sankalpas.indexWhere((s) => s.id == sankalpa.id);
    
    if (index >= 0) {
      sankalpas[index] = sankalpa;
    } else {
      sankalpas.add(sankalpa);
    }
    
    await _saveSankalpas(sankalpas);
  }

  Future<void> _saveSankalpas(List<Sankalpa> sankalpas) async {
    await initialize();
    
    final sankalpasJson = json.encode(sankalpas.map((s) => s.toJson()).toList());
    await _prefs?.setString(_sankalpasKey, sankalpasJson);
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  bool _isInCurrentWeek(DateTime date, DateTime weekStart) {
    final startOfWeek = weekStart.subtract(Duration(days: weekStart.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  // Get sample sankalpas for demonstration
  Future<void> createSampleSankalpas() async {
    final sankalpas = await getSankalpas();
    if (sankalpas.isNotEmpty) return; // Don't create samples if data exists
    
    final now = DateTime.now();
    
    // Daily sankalpa
    await createSankalpa(
      title: 'Daily 16 Rounds',
      description: 'Complete 16 rounds of japa every day',
      period: SankalpaPeriod(
        type: SankalpaPeriodType.daily,
        startDate: now,
      ),
      targetRounds: 16,
    );
    
    // Weekly sankalpa
    await createSankalpa(
      title: 'Weekly 108 Rounds',
      description: 'Complete 108 rounds in this week',
      period: SankalpaPeriod(
        type: SankalpaPeriodType.weekly,
        startDate: now,
      ),
      targetRounds: 108,
    );
    
    // Forever sankalpa - no target, just tracking
    await createSankalpa(
      title: 'Lifelong Japa Practice',
      description: 'Commit to daily japa practice for life',
      period: SankalpaPeriod(
        type: SankalpaPeriodType.forever,
        startDate: now,
      ),
      targetRounds: 0, // No target, just tracking
    );
    
    // Date range sankalpa
    await createSankalpa(
      title: 'Kartik Month Special',
      description: 'Extra rounds during Kartik month',
      period: SankalpaPeriod(
        type: SankalpaPeriodType.dateRange,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
      ),
      targetRounds: 500,
    );
  }
} 