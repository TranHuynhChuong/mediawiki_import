import 'package:flutter/material.dart';
import '../services/check_auth.dart';

class WikiSettingsForm extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onCheckCompleted;

  const WikiSettingsForm({super.key, this.onCheckCompleted});

  @override
  State<WikiSettingsForm> createState() => _WikiSettingsFormState();
}

class _WikiSettingsFormState extends State<WikiSettingsForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();


  bool _isProcessing = false;


  Map<String, dynamic>? _result = {
    'login': {'status': '-', 'username': '-', 'password': '-'},
    'siteInfo': {'sitename': '-', 'base_url': '-'},
    'userRights': <String, bool>{},
  };

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  void _checkWiki() async {

    setState(() => _isProcessing = true);

    final service = CheckAuthService(
      baseUrl: _baseUrlController.text,
      username: _usernameController.text,
      password: _passwordController.text,
    );

    try {
      final result = await service.init();
      setState(() => _result = result);
      widget.onCheckCompleted?.call(result);
    } catch (e) {
      print('Error checking wiki: $e');
      final errorResult = {
        'login': {'status': 'error', 'username': null, 'password': null},
        'siteInfo': {'sitename': '', 'base_url': ''},
        'userRights': <String, bool>{},
      };
      setState(() => _result = errorResult);
      widget.onCheckCompleted?.call(errorResult);
    }finally { setState(() => _isProcessing = false); }
  }

  Widget _buildResult(Map<String, dynamic> result) {
    final login = result['login'] as Map<String, dynamic>;
    final siteInfo = result['siteInfo'] as Map<String, dynamic>;
    final userRights = Map<String, bool>.from(result['userRights'] ?? {});

    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Wiki Info & User Rights',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Status: ${login['status']}'),
            Text('Username: ${login['username'] ?? '-'}'),
            const SizedBox(height: 10),
            const Text('Wiki site info', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Site name: ${siteInfo['sitename']}'),
            Text('API URL: ${siteInfo['base_url']}'),
            const SizedBox(height: 10),
            const Text('User rights', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: userRights.entries.map((e) {
                return Chip(
                  label: Text('${e.key}: ${e.value}'),
                  backgroundColor: e.value ? Colors.green[300] : Colors.red[300],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Wiki Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập username' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập password' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _baseUrlController,
                decoration: const InputDecoration(
                  labelText: 'Base URL',
                  hintText: 'http://localhost/mediawiki/',
                ),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập Base URL' : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, // full width
                child: ElevatedButton(
                  onPressed: _isProcessing  ? null : _checkWiki,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // màu nền
                    foregroundColor: Colors.white, // màu chữ
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // bo tròn
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Check',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildForm(),
        const SizedBox(height: 8),
        _buildResult(_result!),
      ],
    );
  }
}
