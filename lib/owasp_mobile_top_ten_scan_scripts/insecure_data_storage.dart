import 'dart:io';
import 'package:dart_tabulate/dart_tabulate.dart';
import 'package:console_bars/console_bars.dart';

import '../project_path_script/project_path.dart' as pp;

Table insecure_data_storage_table = Table();
final insecure_data_storage_console_bar = FillingBar(desc: "Loading", total: 1000, time: true, percentage:true);

Future<void> main() async {
  // Step 1: Check whether the provided Flutter project path is a valid path
  String? projectPath = pp.projectPath;

  if (projectPath != null && projectPath.isNotEmpty) {

    insecure_data_storage_table.theme.setWidth(70);

    insecure_data_storage_table.addRow(["File", "Issue" ,"Mitigation"]);

    insecure_data_storage_console_bar.desc = "[+] M9: Scanning for insecure data storage";
    for (var i = 0; i < 1000; i++) {
        insecure_data_storage_console_bar.increment();
        sleep(Duration(milliseconds: 1));
    }

    print('\n');

    scanForInsecureDataStorage(Directory(projectPath));

    print('[+][+][+] Insecure Data Storage Scanning Completed !!! [+][+][+]\n');
  } else {
    print('Invalid project path.');
  }
}

void scanForInsecureDataStorage(Directory directory) {
  final issuePatterns = {
    'Unencrypted Sensitive Data': {
      'pattern': RegExp(r'(SharedPreferences|File|getApplicationDocumentsDirectory)'),
      'mitigation': 'Avoid storing sensitive data in plaintext. Use encrypted storage like flutter_secure_storage.'
    },
    'Insecure Logging': {
      'pattern': RegExp(r'log\(|print\('),
      'mitigation': 'Avoid logging sensitive information. Sanitize logs to prevent exposure of sensitive data.'
    },
    'Hardcoded Keys or Secrets': {
      'pattern': RegExp(r'''(apiKey|secret|password)\s*[:=]\s*['\"].+['\"]''', caseSensitive: false),
      'mitigation': 'Avoid hardcoding sensitive information. Use secure mechanisms such as environment variables.'
    },
    'Misconfigured Permissions': {
      'pattern': RegExp(r'(FileMode.writeOnly|FileMode.writeOnlyAppend|worldReadable|worldWritable)'),
      'mitigation': 'Restrict file permissions to prevent unauthorized access.'
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
          final mitigation = entry.value['mitigation']!;
          fileIssues[issueName] = [];
          matches.forEach((match) {
            final lineNumber = _getLineNumber(content, match.start);
            fileIssues[issueName]!.add('Line $lineNumber: ${_getLineContent(content, match.start)}');
          });

          for (var issue in fileIssues[issueName]!) {
            insecure_data_storage_table.addRow(["${entity.path}", "$issueName ($issue)" ,"$mitigation"]);
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