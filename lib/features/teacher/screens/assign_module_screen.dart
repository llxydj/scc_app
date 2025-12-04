import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/assignment_model.dart';
import '../../../data/repositories/assignment_repository.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/sync_service.dart';

class AssignModuleScreen extends StatefulWidget {
  final String moduleId;
  final String moduleType; // 'quiz' or 'flashcard'

  const AssignModuleScreen({
    super.key,
    required this.moduleId,
    required this.moduleType,
  });

  @override
  State<AssignModuleScreen> createState() => _AssignModuleScreenState();
}

class _AssignModuleScreenState extends State<AssignModuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _assignmentRepository = AssignmentRepository();
  final _authService = AuthService();
  final _syncService = SyncService();
  final Uuid _uuid = const Uuid();

  final _titleController = TextEditingController();
  final _instructionsController = TextEditingController();
  DateTime? _dueDate;
  bool _assignToAll = true;

  @override
  void dispose() {
    _titleController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _assignModule() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = await _authService.getCurrentUser();
      if (user == null || user.classCode == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User or class code not found')),
        );
        return;
      }

      final assignment = Assignment(
        id: _uuid.v4(),
        teacherId: user.id,
        classCode: user.classCode!,
        moduleId: widget.moduleId,
        moduleType: widget.moduleType,
        title: _titleController.text.trim(),
        instructions: _instructionsController.text.trim().isEmpty
            ? null
            : _instructionsController.text.trim(),
        dueDate: _dueDate,
        assignedTo: _assignToAll ? 'all' : [],
        createdAt: DateTime.now(),
      );

      await _assignmentRepository.saveAssignment(assignment);
      await _syncService.enqueue('assignments', assignment.id, data: assignment.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Module assigned successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error assigning module: $e')),
        );
      }
    }
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Module')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Assignment Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 16),
              
              ListTile(
                title: const Text('Assign to All Students'),
                trailing: Switch(
                  value: _assignToAll,
                  onChanged: (value) {
                    setState(() => _assignToAll = value);
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              ListTile(
                title: Text(_dueDate == null
                    ? 'No due date'
                    : 'Due: ${_dueDate!.toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDueDate,
              ),
              
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _assignModule,
                child: const Text('Assign Module'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

