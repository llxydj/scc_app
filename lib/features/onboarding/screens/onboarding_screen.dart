import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/validators.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  
  String _selectedRole = 'student';
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _classCodeController = TextEditingController();
  int _selectedGrade = 4;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _pinController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _classCodeController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_selectedRole == 'student') {
        await _authService.registerStudent(
          name: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          pin: _pinController.text.trim(),
          gradeLevel: _selectedGrade,
          classCode: _classCodeController.text.trim(),
        );
        if (mounted) {
          context.go(AppRoutes.studentHome);
        }
      } else if (_selectedRole == 'teacher') {
        await _authService.registerTeacher(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          classCode: _classCodeController.text.trim(),
        );
        if (mounted) {
          context.go(AppRoutes.teacherDashboard);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.width < 360 ? 16 : 24,
          ),
          child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Role Selection
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'student', label: Text('Student')),
                  ButtonSegment(value: 'teacher', label: Text('Teacher')),
                ],
                selected: {_selectedRole},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedRole = newSelection.first;
                  });
                },
              ),
              
              const SizedBox(height: 32),
              
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => Validators.validateRequired(value, 'Name'),
              ),
              
              const SizedBox(height: 16),
              
              // Student fields
              if (_selectedRole == 'student') ...[
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.alternate_email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => Validators.validateRequired(value, 'Username'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pinController,
                  decoration: const InputDecoration(
                    labelText: 'PIN (4-6 digits)',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  validator: Validators.validatePin,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedGrade,
                  decoration: const InputDecoration(
                    labelText: 'Grade Level',
                    border: OutlineInputBorder(),
                  ),
                  items: [1, 2, 3, 4, 5, 6]
                      .map((grade) => DropdownMenuItem(
                            value: grade,
                            child: Text('Grade $grade'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedGrade = value);
                    }
                  },
                ),
              ],
              
              // Teacher fields
              if (_selectedRole == 'teacher') ...[
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: Validators.validatePassword,
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Class Code
              TextFormField(
                controller: _classCodeController,
                decoration: const InputDecoration(
                  labelText: 'Class Code',
                  prefixIcon: Icon(Icons.class_),
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validateClassCode,
              ),
              
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Register'),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

