import 'dart:io';
import 'package:dart_tabulate/dart_tabulate.dart';
import 'package:console_bars/console_bars.dart';

import '../project_path_script/project_path.dart' as pp;

Table insufficient_input_output_validation_table = Table();
final insufficient_input_output_validation_console_bar = FillingBar(desc: "Loading", total: 1000, time: true, percentage:true);

Future<void> main() async {
  // Step 1: Check whether the provided Flutter project path is a valid path
  String? projectPath = pp.projectPath;

  if (projectPath != null && Directory(projectPath).existsSync()) {
    final libPath = Directory('$projectPath/lib');
    if (libPath.existsSync()) {

      insufficient_input_output_validation_table.theme.setWidth(70);
      insufficient_input_output_validation_table.addRow(["File", "Issue" ,"Mitigation"]);

      insufficient_input_output_validation_console_bar.desc = "[+] M4: Scanning for insufficient input/output validation";
      for (var i = 0; i < 1000; i++) {
          insufficient_input_output_validation_console_bar.increment();
          sleep(Duration(milliseconds: 1));
      }

      print('\n');

      scanForValidationIssues(libPath);

      print('[+][+][+] Insufficient Input/Output Validation Scanning Completed !!! [+][+][+]\n');

    } else {
      print('No lib folder found in the project directory.');
    }
  } else {
    print('Invalid project path. Please enter a valid directory path.');
  }
}

void scanForValidationIssues(Directory directory) {
  final issuePatterns = {
    'SQL Injection Vulnerability': {
      'pattern': RegExp(r"(rawQuery|execute|rawInsert|rawDelete|rawUpdate)\(.*\)"),
      'mitigation': 'Use parameterized queries to prevent SQL injection.'
    },
    'Cross-Site Scripting (XSS) Vulnerability': {
      'pattern': RegExp(r"(HtmlElement|setInnerHtml|dart:html)"),
      'mitigation': 'Sanitize outputs and avoid unsafe HTML rendering.'
    },
    'Command Injection Vulnerability': {
      'pattern': RegExp(r"(Process\.run|Process\.start)"),
      'mitigation': 'Validate and sanitize command inputs to avoid command injection.'
    },
    'Path Traversal Vulnerability': {
      'pattern': RegExp(r"(File|Directory|getTemporaryDirectory|getApplicationDocumentsDirectory)\(.*\)"),
      'mitigation': 'Validate and sanitize file paths to prevent path traversal.'
    },
    'Unvalidated User Input': {
      'pattern': RegExp(r"(TextField|TextFormField|Controller)\(.*\)"),
      'mitigation': 'Add input validation logic to sanitize and validate user inputs.'
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
          final mitigation = entry.value['mitigation'];
          fileIssues[issueName] = [];
          matches.forEach((match) {
            final lineNumber = _getLineNumber(content, match.start);
            fileIssues[issueName]!.add('Line $lineNumber: ${_getLineContent(content, match.start)}');
          });
          for (var issue in fileIssues[issueName]!) {
            insufficient_input_output_validation_table.addRow(["${entity.path}", "$issueName ($issue)" ,"$mitigation"]);
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