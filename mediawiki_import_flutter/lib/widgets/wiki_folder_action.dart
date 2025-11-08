import 'package:flutter/material.dart';

import '../services/run_python.dart';

class WikiFolderActions extends StatefulWidget {
  final bool enabled;
  final Map<String, dynamic>? wikiInfo;
  const WikiFolderActions({super.key, this.enabled = false, this.wikiInfo,});

  @override
  State<WikiFolderActions> createState() => _WikiFolderActionsState();
}

class _WikiFolderActionsState extends State<WikiFolderActions> {
  final TextEditingController _folderController = TextEditingController();

  bool _isProcessing = false;
  Map<String, dynamic>? _outputData;
  String? _lastAction; // "export" hoặc "import"
  bool _overwrite = false; // mặc định là false
  @override
  void dispose() {
    _folderController.dispose();
    super.dispose();
  }


  void _exportWikitext() async {
    final folderPath = _folderController.text;
    if (folderPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đường dẫn thư mục')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _outputData = null;
      _lastAction = 'export';
    });

    try {
      // Gọi Python exe để export
      final data = await runPythonExport(folderPath);

      setState(() {
        _outputData = data;
      });


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export Wikitext thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi export: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _importToWiki () async  {
    final folderPath = _folderController.text;
    if (folderPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đường dẫn thư mục')),
      );
      return;
    }
    if (widget.wikiInfo == null) return;

    final baseUrl = widget.wikiInfo!['siteInfo']?['base_url'] ?? '';
    final username = widget.wikiInfo!['login']?['username'] ?? '';
    final password = widget.wikiInfo!['login']?['password'] ?? ''; // Nếu lưu được password

    setState(() {
      _isProcessing = true;
      _outputData = null;
      _lastAction = 'import';
    });

    try {
      // Gọi Python exe để export
      final data = await runPythonImport(
        docsDir: folderPath,
        apiUrl: baseUrl,
        username: username,
        password: password,
        overwrite: _overwrite,
      );

      setState(() {
        _outputData = data;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import to Wiki thành công!')),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi import: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }


  Widget _buildOutputCard() {
    if (_outputData == null) return const SizedBox.shrink();

    if (_lastAction == 'import') {
      // Hiển thị danh sách các bản ghi import
      final importedList = _outputData!['results'] as List<dynamic>? ?? [];
      return Card(
        margin: const EdgeInsets.only(top: 16),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Import Result',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...importedList.map((item) {
                final status = item['status'] ?? '';
                final title = item['title'] ?? '';
                return Row(
                  children: [
                    Icon(
                      status == "🔄 Updated"
                          ? Icons.sync
                          : status == "✅ Created"
                          ? Icons.check_circle
                          : Icons.warning,
                      color: status == "🔄 Updated"
                          ? Colors.orange
                          : status == "✅ Created"
                          ? Colors.green
                          : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(title)),
                    Text(status),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      );
    } else {
      // Export
      final files = (_outputData!['files'] as List<dynamic>?) ?? [];
      final zip = _outputData!['zip'] ?? '';
      return SizedBox(
        width: double.infinity,
        child: Card(
          margin: const EdgeInsets.only(top: 16),
          color: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Export Result',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Exported files: ${files.length}'),
                const SizedBox(height: 4),
                if (zip.isNotEmpty) Text('Zip path: $zip'),
              ],
            ),
          ),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Center(
              child: Text(
                'Wiki Folder Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _folderController,
              decoration: const InputDecoration(
                labelText: 'Folder path',
                hintText: '/path/to/wiki/folder',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _overwrite,
                  onChanged: (val) {
                    setState(() {
                      _overwrite = val ?? true;
                    });
                  },
                ),
                const Text('Import overwrite existing pages'),
                const SizedBox(width: 8),
                const Icon(Icons.warning, color: Colors.red, size: 20),
                const SizedBox(width: 4),
                const Expanded(
                  child: Text(
                    'Existing pages will be overwritten!',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _exportWikitext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
                      'Export Wikitext',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing || !widget.enabled ? null : _importToWiki,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.enabled ? Colors.green : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
                        : Text(
                      widget.enabled ? 'Import to Wiki' : 'No permission',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            _buildOutputCard(),
          ],
        ),
      ),
    );
  }
}
