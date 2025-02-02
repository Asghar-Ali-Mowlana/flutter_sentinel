import 'dart:io';
import 'package:dart_tabulate/dart_tabulate.dart';
import 'package:console_bars/console_bars.dart';

import '../project_path_script/project_path.dart' as pp;

Table insecure_authentication_authorization_table = Table();
final insecure_authentication_authorization_console_bar = FillingBar(desc: "Loading", total: 1000, time: true, percentage:true);

Future<void> main() async {
  // Step 1: Check whether the provided Flutter project path is a valid path
  final projectPath = pp.projectPath;

  if (projectPath == null || projectPath.isEmpty) {
    print('Invalid path provided.');
    return;
  }

  final libDirectory = Directory('$projectPath/lib');
  if (!libDirectory.existsSync()) {
    print('The lib folder does not exist in the provided directory.');
    return;
  }

  insecure_authentication_authorization_table.theme.setWidth(70);
  insecure_authentication_authorization_table.addRow(["File", "Issue" ,"Mitigation"]);

  insecure_authentication_authorization_console_bar.desc = "[+] M3: Scanning for insecure authentication or authorization";

  for (var i = 0; i < 1000; i++) {
      insecure_authentication_authorization_console_bar.increment();
      await Future.delayed(Duration(milliseconds: 1));
  }

  print('\n');

  scanForAuthIssues(libDirectory);

  print('[+][+][+] Insecure Authentication or Authorization Scanning Completed !!! [+][+][+]\n');
}

void scanForAuthIssues(Directory directory) {
  final issuePatterns = {
    'Client-Side Authentication': {
      'pattern': RegExp(r'(LocalAuthentication|BiometricAuthentication)'),
      'mitigation': 'Ensure authentication is verified server-side to prevent bypass vulnerabilities.'
    },
    'Insecure Direct Object References (IDOR)': {
      'pattern': RegExp(r'(userId|roleId|permissionId)'),
      'mitigation': 'Avoid exposing sensitive identifiers in client requests. Use server-side validation and access controls.'
    },
    'Weak Authorization Checks': {
      'pattern': RegExp(r'''(if\s*\(\s*userRole\s*==\s*[\'"].+?[\'"]\s*\))'''),
      'mitigation': 'Perform role-based authorization checks on the server side instead of relying on client-side logic.'
    },
    'Insecure Hidden Endpoints': {
      'pattern': RegExp(r'(http[s]?:\/\/[^\s]+\/hiddenEndpoint)'),
      'mitigation': 'Ensure all backend endpoints are protected with proper authentication and authorization mechanisms.'
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

          for (final match in matches) {
            final lineNumber = _getLineNumber(content, match.start);
            fileIssues[issueName]!.add(
              'Line $lineNumber: ${_getLineContent(content, match.start)}',
            );
          }

          for (var issue in fileIssues[issueName]!) {
            insecure_authentication_authorization_table.addRow(["${entity.path}", "$issueName ($issue)" ,"$mitigation"]);
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