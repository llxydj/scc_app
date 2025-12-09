import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/access_code_service.dart';
import '../../../core/services/auth_service.dart';

class AccessCodesScreen extends StatefulWidget {
  const AccessCodesScreen({super.key});

  @override
  State<AccessCodesScreen> createState() => _AccessCodesScreenState();
}

class _AccessCodesScreenState extends State<AccessCodesScreen> {
  final _accessCodeService = AccessCodeService();
  final _authService = AuthService();
  Map<String, String> _accessCodes = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccessCodes();
  }

  Future<void> _loadAccessCodes() async {
    setState(() => _isLoading = true);
    try {
      final codes = await _accessCodeService.getAccessCodesForClass();
      setState(() {
        _accessCodes = codes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading access codes: $e')),
        );
      }
    }
  }

  Future<void> _generateCodeForStudent(String studentId) async {
    try {
      final code = await _accessCodeService.generateAccessCodeForStudent(studentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Access code generated: $code'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadAccessCodes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parent Access Codes')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _accessCodes.isEmpty
                ? const Center(child: Text('No students found in your class'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _accessCodes.length,
                    itemBuilder: (context, index) {
                      final entry = _accessCodes.entries.elementAt(index);
                      final studentId = entry.key;
                      final displayText = entry.value;
                      final parts = displayText.split(': ');
                      final studentName = parts[0];
                      final accessCode = parts.length > 1 ? parts[1] : '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(studentName),
                          subtitle: Text(
                            accessCode.isNotEmpty ? 'Code: $accessCode' : 'No code generated',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (accessCode.isEmpty)
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => _generateCodeForStudent(studentId),
                                  tooltip: 'Generate Code',
                                )
                              else
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: () => _copyToClipboard(accessCode),
                                  tooltip: 'Copy Code',
                                ),
                              if (accessCode.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () => _generateCodeForStudent(studentId),
                                  tooltip: 'Regenerate',
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

