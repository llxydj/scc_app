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
      appBar: AppBar(
        title: const Text('Parent Access Codes'),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _accessCodes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No students found',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Students will appear here once they join your class',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Header info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: AppColors.primary.withOpacity(0.1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Access Codes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Generate unique codes for parents to view their child\'s progress',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // List of students
                      Expanded(
                        child: ListView.builder(
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
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: AppColors.primary.withOpacity(0.1),
                                          child: Icon(
                                            Icons.person,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                studentName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              if (accessCode.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.success.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(
                                                      color: AppColors.success.withOpacity(0.3),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.vpn_key,
                                                        size: 16,
                                                        color: AppColors.success,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        accessCode,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          color: AppColors.success,
                                                          letterSpacing: 1.2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              else
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.warning.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    'No code generated',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.warning,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (accessCode.isEmpty)
                                          ElevatedButton.icon(
                                            onPressed: () => _generateCodeForStudent(studentId),
                                            icon: const Icon(Icons.add, size: 18),
                                            label: const Text('Generate Code'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: Colors.white,
                                            ),
                                          )
                                        else ...[
                                          OutlinedButton.icon(
                                            onPressed: () => _copyToClipboard(accessCode),
                                            icon: const Icon(Icons.copy, size: 18),
                                            label: const Text('Copy'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppColors.primary,
                                              side: BorderSide(color: AppColors.primary),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          OutlinedButton.icon(
                                            onPressed: () => _generateCodeForStudent(studentId),
                                            icon: const Icon(Icons.refresh, size: 18),
                                            label: const Text('Regenerate'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppColors.warning,
                                              side: BorderSide(color: AppColors.warning),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

