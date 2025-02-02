import 'dart:io';
import 'package:dart_tabulate/dart_tabulate.dart';
import 'package:console_bars/console_bars.dart';

import '../project_path_script/project_path.dart' as pp;

Table security_misconfiguration_table = Table();
final security_misconfiguration_console_bar = FillingBar(desc: "Loading", total: 1000, time: true, percentage:true);

Future<void> main() async {
  // Step 1: Check whether the provided Flutter project path is a valid path
  String? projectPath = pp.projectPath;

  if (projectPath == null || projectPath.isEmpty) {
    print("Invalid path. Please provide a valid Flutter project path.");
    return;
  }

  final libDirectory = Directory(projectPath);
  if (!libDirectory.existsSync()) {
    print("The provided path does not exist or is not a directory.");
    return;
  }

  security_misconfiguration_table.theme.setWidth(70);
  security_misconfiguration_table.addRow(["File", "Issue" ,"Mitigation"]);

  security_misconfiguration_console_bar.desc = "[+] M8: Scanning for security misconfiguration";

  for (var i = 0; i < 1000; i++) {
    security_misconfiguration_console_bar.increment();
    sleep(Duration(milliseconds: 1));
  }

  print('\n');

  scanForSecurityMisconfigurations(libDirectory);

  print('[+][+][+] Security Misconfiguration Scanning Completed !!! [+][+][+]\n');
}

void scanForSecurityMisconfigurations(Directory directory) {
  final issuePatterns = {
    'Debugging Features Enabled': {
      'pattern': RegExp(r'(debugPrint|assert|debugShowCheckedModeBanner\s*:\s*true)', caseSensitive: false),
      'mitigation': 'Remove debugging features and ensure release builds do not include debug code.'
    },
    'Unnecessary Permissions': {
      'pattern': RegExp(r'(ACCESS_FINE_LOCATION|ACCESS_COARSE_LOCATION|READ_CONTACTS|WRITE_CONTACTS)'),
      'mitigation': 'Remove unused permissions from the AndroidManifest.xml and Info.plist files.'
    },
    'Insecure Communication': {
      'pattern': RegExp(r'(http:\/\/|allowClearTextTraffic\s*:\s*true)', caseSensitive: false),
      'mitigation': 'Ensure all network communications use HTTPS and disable clear text traffic.'
    },
    'Hardcoded Sensitive Data': {
      'pattern': RegExp(r'''(apiKey|secret|password)\s*[:=]\s*["\'].*["\']''', caseSensitive: false),
      'mitigation': 'Do not hardcode sensitive data. Use secure storage mechanisms like flutter_secure_storage.'
    },
    'World-Readable/Writable Files': {
      'pattern': RegExp(r'(File\s*\(.*mode:\s*"[rw]{1,2}")'),
      'mitigation': 'Ensure file permissions are set securely and avoid world-readable/writable files.'
    },
    'Insecure Session Management': {
      'pattern': RegExp(r'''(sharedPreferences.*\.setString\(\s*["\']session["\'])''', caseSensitive: false),
      'mitigation': 'Store session data securely using encrypted storage libraries.'
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
            security_misconfiguration_table.addRow(["${entity.path}", "$issueName ($issue)" ,"$mitigation"]);
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