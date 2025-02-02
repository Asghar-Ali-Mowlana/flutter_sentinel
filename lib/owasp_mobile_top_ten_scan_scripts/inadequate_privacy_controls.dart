import 'dart:io';
import 'package:dart_tabulate/dart_tabulate.dart';
import 'package:console_bars/console_bars.dart';

import '../project_path_script/project_path.dart' as pp;

Table inadequate_privacy_controls_table = Table();
final inadequate_privacy_controls_console_bar = FillingBar(desc: "Loading", total: 1000, time: true, percentage:true);

Future<void> main() async {
  // Step 1: Check whether the provided Flutter project path is a valid path
  final projectPath = pp.projectPath;

  if (projectPath == null || projectPath.isEmpty) {
    print("Invalid project path. Exiting.");
    return;
  }

  // Set this to the root folder of your Flutter project.
  final directoryPath = '$projectPath/lib'; 

  inadequate_privacy_controls_table.theme.setWidth(70);
  inadequate_privacy_controls_table.addRow(["File", "Issue" ,"Mitigation"]);

  inadequate_privacy_controls_console_bar.desc = "[+] M6: Scanning for inadequate privacy controls";

  for (var i = 0; i < 1000; i++) {
      inadequate_privacy_controls_console_bar.increment();
      sleep(Duration(milliseconds: 1));
  }

  print('\n');

  scanForPrivacyIssues(Directory(directoryPath));

  print('[+][+][+] Inadequate Privacy Controls Scanning Completed !!! [+][+][+]\n');
}

void scanForPrivacyIssues(Directory directory) {
  final issuePatterns = {
    'Excessive Data Collection': {
      'pattern': RegExp(r'''get\((["\'].*\1)\)'''),
      'description': 'Detects HTTP GET requests that might fetch unnecessary PII.',
      'mitigation': 'Ensure only required data is collected and avoid unnecessary PII retrieval.'
    },
    'Improper Data Handling': {
      'pattern': RegExp(r'(SharedPreferences|getApplicationDocumentsDirectory)'),
      'description': 'Detects improper storage methods for sensitive data.',
      'mitigation': 'Store sensitive data using secure libraries like flutter_secure_storage.'
    },
    'Unencrypted Data Transmission': {
      'pattern': RegExp(r'(http://|String.fromEnvironment)'),
      'description': 'Detects use of unencrypted transmission methods or hardcoded sensitive values.',
      'mitigation': 'Use HTTPS for secure transmission and avoid hardcoding sensitive values.'
    },
    'Lack of User Consent': {
      'pattern': RegExp(r'(AnalyticsService|logEvent|trackEvent)'),
      'description': 'Detects usage of analytics without explicit user consent.',
      'mitigation': 'Ensure users are informed and have provided explicit consent for data tracking.'
    },
    'PII in Logs': {
      'pattern': RegExp(r'print\((.*)\)'),
      'description': 'Detects potential logging of sensitive data.',
      'mitigation': 'Avoid logging sensitive information and use masked or anonymized data for debugging.'
    },
  };

  for (var entity in directory.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      final fileIssues = <String, List<String>>{};

      for (var entry in issuePatterns.entries) {
        final matches = entry.value['pattern']!.allMatches(content);
        if (matches.isNotEmpty) {
          final issueName = entry.key;
          // final description = entry.value['description'];
          final mitigation = entry.value['mitigation'];
          fileIssues[issueName] = [];
          matches.forEach((match) {
            final lineNumber = _getLineNumber(content, match.start);
            fileIssues[issueName]!.add('Line $lineNumber: ${_getLineContent(content, match.start)}');
          });
          for (var issue in fileIssues[issueName]!) {
            inadequate_privacy_controls_table.addRow(["${entity.path}", "$issueName ($issue)" ,"$mitigation"]);
          }
        }
      }
    }
  }
}

/// Get the line number for a given match position in the content.
int _getLineNumber(String content, int matchStart) {
  return content.substring(0, matchStart).split('\n').length;
}

/// Extract the specific line content where a match occurred.
String _getLineContent(String content, int matchStart) {
  final lines = content.split('\n');
  final lineNumber = _getLineNumber(content, matchStart);
  return lines[lineNumber - 1].trim();
}