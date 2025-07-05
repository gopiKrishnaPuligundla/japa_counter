import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/sankalpa_model.dart';
import 'services/sankalpa_service.dart';

class SankalpaScreen extends StatefulWidget {
  const SankalpaScreen({Key? key}) : super(key: key);

  @override
  State<SankalpaScreen> createState() => _SankalpaScreenState();
}

class _SankalpaScreenState extends State<SankalpaScreen> {
  final SankalpaService _sankalpaService = SankalpaService();
  
  List<Sankalpa> _sankalpas = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadSankalpas();
  }

  Future<void> _loadSankalpas() async {
    setState(() => _isLoading = true);
    
    try {
      await _sankalpaService.checkAndUpdateExpiredSankalpas();
      final sankalpas = await _sankalpaService.getSankalpas();
      
      setState(() {
        _sankalpas = sankalpas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sankalpas: $e')),
        );
      }
    }
  }

  List<Sankalpa> get _filteredSankalpas {
    switch (_selectedFilter) {
      case 'Active':
        return _sankalpas.where((s) => s.status == SankalpaStatus.active).toList();
      case 'Completed':
        return _sankalpas.where((s) => s.status == SankalpaStatus.completed).toList();
      case 'Paused':
        return _sankalpas.where((s) => s.status == SankalpaStatus.paused).toList();
      default:
        return _sankalpas;
    }
  }

  Future<void> _createSankalpa() async {
    await showDialog(
      context: context,
      builder: (context) => CreateSankalpaDialog(),
    );
    _loadSankalpas();
  }

  Future<void> _updateSankalpaStatus(Sankalpa sankalpa, SankalpaStatus status) async {
    try {
      await _sankalpaService.updateStatus(sankalpa.id, status);
      _loadSankalpas();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sankalpa ${status.name} successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating sankalpa: $e')),
        );
      }
    }
  }

  Future<void> _deleteSankalpa(String sankalpaId) async {
    try {
      await _sankalpaService.deleteSankalpa(sankalpaId);
      _loadSankalpas();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sankalpa deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting sankalpa: $e')),
        );
      }
    }
  }

  Future<void> _addProgress(Sankalpa sankalpa) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AddProgressDialog(sankalpa: sankalpa),
    );
    
    if (result != null && result > 0) {
      try {
        await _sankalpaService.addProgress(sankalpa.id, result);
        _loadSankalpas();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added $result rounds to progress')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating progress: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sankalpa'),
        backgroundColor: Colors.orange[300],
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _selectedFilter = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All')),
              const PopupMenuItem(value: 'Active', child: Text('Active')),
              const PopupMenuItem(value: 'Completed', child: Text('Completed')),
              const PopupMenuItem(value: 'Paused', child: Text('Paused')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedFilter, style: const TextStyle(fontSize: 16)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _createSankalpa,
        backgroundColor: Colors.orange[300],
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_filteredSankalpas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No sankalpas found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first sankalpa to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Summary card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[300]!, Colors.orange[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Spiritual Journey',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatChip('Total', _sankalpas.length.toString()),
                  _buildStatChip('Active', _sankalpas.where((s) => s.status == SankalpaStatus.active).length.toString()),
                  _buildStatChip('Completed', _sankalpas.where((s) => s.status == SankalpaStatus.completed).length.toString()),
                  _buildStatChip('Total Rounds', _sankalpas.fold<int>(0, (sum, s) => sum + s.progress.currentRounds).toString()),
                ],
              ),
            ],
          ),
        ),
        
        // Sankalpas list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredSankalpas.length,
            itemBuilder: (context, index) {
              final sankalpa = _filteredSankalpas[index];
              return SankalpaCard(
                sankalpa: sankalpa,
                onStatusChange: (status) => _updateSankalpaStatus(sankalpa, status),
                onDelete: () => _deleteSankalpa(sankalpa.id),
                onAddProgress: () => _addProgress(sankalpa),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class SankalpaCard extends StatelessWidget {
  final Sankalpa sankalpa;
  final Function(SankalpaStatus) onStatusChange;
  final VoidCallback onDelete;
  final VoidCallback onAddProgress;

  const SankalpaCard({
    Key? key,
    required this.sankalpa,
    required this.onStatusChange,
    required this.onDelete,
    required this.onAddProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    sankalpa.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(sankalpa.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    sankalpa.statusDescription,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            if (sankalpa.description != null) ...[
              const SizedBox(height: 8),
              Text(
                sankalpa.description!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Period and progress info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        sankalpa.period.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.track_changes, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        sankalpa.progress.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Progress bar (only if there's a target)
            if (sankalpa.progress.targetRounds > 0) ...[
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${(sankalpa.progress.progressPercentage * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: sankalpa.progress.progressPercentage,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[300]!),
                    minHeight: 6,
                  ),
                ],
              ),
            ],
            
            // Action buttons
            if (sankalpa.status == SankalpaStatus.active) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: onAddProgress,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Rounds'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[400],
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => onStatusChange(SankalpaStatus.paused),
                    icon: const Icon(Icons.pause, size: 16),
                    label: const Text('Pause'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[400],
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ] else if (sankalpa.status == SankalpaStatus.paused) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => onStatusChange(SankalpaStatus.active),
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Resume'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[400],
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
            
            // Created date
            const SizedBox(height: 8),
            Text(
              'Created: ${_formatDate(sankalpa.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(SankalpaStatus status) {
    switch (status) {
      case SankalpaStatus.active:
        return Colors.green;
      case SankalpaStatus.completed:
        return Colors.blue;
      case SankalpaStatus.paused:
        return Colors.orange;
      case SankalpaStatus.failed:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class CreateSankalpaDialog extends StatefulWidget {
  @override
  State<CreateSankalpaDialog> createState() => _CreateSankalpaDialogState();
}

class _CreateSankalpaDialogState extends State<CreateSankalpaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();
  final _durationController = TextEditingController();
  
  SankalpaPeriodType _selectedPeriodType = SankalpaPeriodType.dateRange;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  
  final SankalpaService _sankalpaService = SankalpaService();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  Future<void> _createSankalpa() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final targetRounds = _targetController.text.isNotEmpty 
          ? int.parse(_targetController.text) 
          : 0;
      final duration = _durationController.text.isNotEmpty 
          ? int.parse(_durationController.text) 
          : null;

      SankalpaPeriod period;
      switch (_selectedPeriodType) {
        case SankalpaPeriodType.dateRange:
          if (_endDate == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select an end date')),
            );
            return;
          }
          period = SankalpaPeriod(
            type: _selectedPeriodType,
            startDate: _startDate,
            endDate: _endDate,
          );
          break;
        case SankalpaPeriodType.days:
          if (duration == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please specify number of days')),
            );
            return;
          }
          period = SankalpaPeriod(
            type: _selectedPeriodType,
            startDate: _startDate,
            durationDays: duration,
          );
          break;
        default:
          period = SankalpaPeriod(
            type: _selectedPeriodType,
            startDate: _startDate,
          );
      }

      await _sankalpaService.createSankalpa(
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty 
            ? _descriptionController.text 
            : null,
        period: period,
        targetRounds: targetRounds,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sankalpa created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating sankalpa: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create New Sankalpa',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                
                // Target rounds
                TextFormField(
                  controller: _targetController,
                  decoration: const InputDecoration(
                    labelText: 'Target Rounds (optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Leave empty for no target',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),
                
                // Period Type
                const Text(
                  'Period Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<SankalpaPeriodType>(
                  value: _selectedPeriodType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: SankalpaPeriodType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getPeriodTypeDescription(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedPeriodType = value!);
                  },
                ),
                const SizedBox(height: 16),
                
                // Start Date
                const Text(
                  'Start Date',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectStartDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // End Date (for date range)
                if (_selectedPeriodType == SankalpaPeriodType.dateRange) ...[
                  const Text(
                    'End Date',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectEndDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_endDate != null 
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'Select end date'),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Duration (for days type)
                if (_selectedPeriodType == SankalpaPeriodType.days) ...[
                  TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Number of Days',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter number of days';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _createSankalpa,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[300],
                      ),
                      child: const Text('Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPeriodTypeDescription(SankalpaPeriodType type) {
    switch (type) {
      case SankalpaPeriodType.dateRange:
        return 'Date Range';
      case SankalpaPeriodType.forever:
        return 'Forever';
      case SankalpaPeriodType.daily:
        return 'Daily';
      case SankalpaPeriodType.weekly:
        return 'Weekly';
      case SankalpaPeriodType.monthly:
        return 'Monthly';
      case SankalpaPeriodType.rounds:
        return 'Specific Rounds';
      case SankalpaPeriodType.days:
        return 'Number of Days';
    }
  }
}

class AddProgressDialog extends StatefulWidget {
  final Sankalpa sankalpa;

  const AddProgressDialog({Key? key, required this.sankalpa}) : super(key: key);

  @override
  State<AddProgressDialog> createState() => _AddProgressDialogState();
}

class _AddProgressDialogState extends State<AddProgressDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Progress'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current: ${widget.sankalpa.progress.currentRounds} rounds'),
            if (widget.sankalpa.progress.targetRounds > 0)
              Text('Target: ${widget.sankalpa.progress.targetRounds} rounds'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Add Rounds',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a value';
                }
                final intValue = int.tryParse(value);
                if (intValue == null || intValue <= 0) {
                  return 'Please enter a valid positive number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final value = int.parse(_controller.text);
              Navigator.of(context).pop(value);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
} 