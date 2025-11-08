import 'dart:io';
import 'dart:convert';

Future<Map<String, dynamic>>  runPythonExport(String docsDir) async {
  // Lấy đường dẫn file exe từ assets
  final exePath = '${Directory.current.path}\\python\\run.exe';

  // Chạy process
  final result = await Process.run(exePath, ['export', docsDir], stdoutEncoding: utf8,
    stderrEncoding: utf8,);

  if (result.exitCode != 0) {
    throw Exception('Error: ${result.stderr}');
  }

  final output = result.stdout as String;
  final cleanOutput = output.trim();
  try {
    final data = jsonDecode(cleanOutput) as Map<String, dynamic>;
    return data;
  } catch (e) {
    throw Exception('Invalid JSON from Python: $cleanOutput\nError: $e');
  }
}

Future<Map<String, dynamic>>  runPythonImport({
  required String docsDir,
  required String apiUrl,
  required String username,
  required String password,
  required bool overwrite,
}) async {
  final exePath = '${Directory.current.path}\\python\\run.exe';

  final result = await Process.run(exePath, [
    'import',
    docsDir,
    apiUrl,
    username,
    password,
    overwrite.toString() == 'false' ? 'False' : 'True'
  ], stdoutEncoding: utf8,
    stderrEncoding: utf8,);


  if (result.exitCode != 0) {
    throw Exception('Error: ${result.stderr}');
  }

  final output = result.stdout as String;
  final cleanOutput = output.trim();
  try {
    final data = jsonDecode(cleanOutput) as Map<String, dynamic>;
    return data;
  } catch (e) {
    throw Exception('Invalid JSON from Python: $cleanOutput\nError: $e');
  }
}
