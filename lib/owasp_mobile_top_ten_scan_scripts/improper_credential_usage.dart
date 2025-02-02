import 'dart:io';
import 'package:dart_tabulate/dart_tabulate.dart';
import 'package:console_bars/console_bars.dart';

import '../project_path_script/project_path.dart' as pp;

Table improper_credential_usage_table = Table();
final improper_credential_usage_console_bar = FillingBar(desc: "Loading", total: 1000, time: true, percentage:true);

Future<void> main() async {

  // Step 1: Check whether the provided Flutter project path is a valid path
  final projectPath = pp.projectPath;
  if (projectPath == null || projectPath.isEmpty) {
    print("Invalid project path. Exiting.");
    return;
  }
  final directory = Directory(projectPath);

  improper_credential_usage_table.theme.setWidth(70);
  improper_credential_usage_table.addRow(["File", "Issue" ,"Mitigation"]);
  print('\n');
  improper_credential_usage_console_bar.desc = "[+] M1: Scanning for improper credential usage";
  for (var i = 0; i < 1000; i++) {
      improper_credential_usage_console_bar.increment();
      sleep(Duration(milliseconds: 1));
  }
  print('\n');

  scanForImproperCredentialUsage(directory);

  print('[+][+][+] Improper Credential Usage Scanning Completed !!! [+][+][+]\n');
}

void scanForImproperCredentialUsage(Directory directory) {

  // Step 2: Scan the project files that end with .dart
  final dartFiles = directory
      .listSync(recursive: true)
      .where((file) => file is File && file.path.endsWith('.dart'))
      .cast<File>();

  // print('\n=== Improper Credential Usage Scan Report ===\n');

  // Step 3: Scan for improper credential usage
  for (var file in dartFiles) {
    final content = file.readAsStringSync();
    final issues = <String, String>{};

    // Check for hardcoded credentials (basic regex for common patterns)
    final hardcodedPatterns = {
      'Hardcoded password': RegExp(r'''password\s*=\s*["\'].*?["\']''', caseSensitive: false),
      'Hardcoded API key': RegExp(r'''\bAIza[0-9A-Za-z_-]{35}\b''', caseSensitive: false),
      'Hardcoded secret': RegExp(r'''['\"]secret['\"]\s*[:=]\s*['\"].+['\"]''', caseSensitive: false),
      'Hardcoded username': RegExp(r'''['\"]username['\"]\s*[:=]\s*['\"].+['\"]''', caseSensitive: false),
      'Hardcoded token': RegExp(r'''token\s*=\s*["\'].*?["\']''', caseSensitive: false),
    };

    for (var entry in hardcodedPatterns.entries) {
      if (entry.value.hasMatch(content)) {
        content.split('\n').asMap().forEach((lineNumber, line) {
          if (entry.value.hasMatch(line)) {
            issues['${entry.key} (Line ${lineNumber + 1})'] =
                'Avoid hardcoding sensitive data like ${entry.key.toLowerCase()}. Use secure mechanisms such as environment variables, encrypted storage, or a secure API gateway.';
          }
        });
      }
    }

    // Check for insecure storage using SharedPreferences
    if (content.contains('SharedPreferences')) {
      issues['Insecure storage with SharedPreferences'] =
          'SharedPreferences is not secure for sensitive data. Use a secure storage library like flutter_secure_storage to encrypt data.';
    }

    // Check for insecure transmission (HTTP instead of HTTPS)
    final insecureTransmissionPattern = RegExp(r'http://');
    if (insecureTransmissionPattern.hasMatch(content)) {
      content.split('\n').asMap().forEach((lineNumber, line) {
        if (insecureTransmissionPattern.hasMatch(line)) {
          issues['Insecure transmission (Line ${lineNumber + 1})'] =
              'Avoid using HTTP for data transmission. Always use HTTPS to secure communication between the app and backend.';
        }
      });
    }

    // Generate report for the file
    if (issues.isNotEmpty) {
      for (var issue in issues.entries) {
        improper_credential_usage_table.addRow(["${file.path}", "${issue.key}" ,"${issue.value}"]);
      }
    }
  }
  // print('=== Scan Complete ===');
}
