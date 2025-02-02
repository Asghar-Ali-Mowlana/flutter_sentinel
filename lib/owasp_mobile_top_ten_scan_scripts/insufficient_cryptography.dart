import 'dart:io';
import 'package:dart_tabulate/dart_tabulate.dart';
import 'package:console_bars/console_bars.dart';

import '../project_path_script/project_path.dart' as pp;

Table insufficient_cryptography_table = Table();
final insufficient_cryptography_console_bar = FillingBar(desc: "Loading", total: 1000, time: true, percentage:true);

Future<void> main() async {
  // Step 1: Check whether the provided Flutter project path is a valid path
  final directoryPath = pp.projectPath;

  if (directoryPath == null || directoryPath.isEmpty) {
    print("Invalid directory path.");
    return;
  }
  final directory = Directory(directoryPath);
  if (!directory.existsSync()) {
    print("Directory does not exist.");
    return;
  }

  insufficient_cryptography_table.theme.setWidth(70);

  insufficient_cryptography_table.addRow(["File", "Issue" ,"Mitigation"]);

  insufficient_cryptography_console_bar.desc = "[+] M10: Scanning for insufficient cryptography";
  for (var i = 0; i < 1000; i++) {
    insufficient_cryptography_console_bar.increment();
    sleep(Duration(milliseconds: 1));
  }

  print('\n');

  scanForCryptographyIssues(directory);

  print('[+][+][+] Insufficient Cryptography Scanning Completed !!! [+][+][+]\n');
}

void scanForCryptographyIssues(Directory directory) {
  final issuePatterns = {
    'Weak Encryption Algorithms': {
      'pattern': RegExp(r'(AES\.deprecated|DES|3DES|RC4|MD5|SHA1)', caseSensitive: false),
      'mitigation':
          'Avoid using weak algorithms like DES, 3DES, RC4, MD5, or SHA1. Use AES (256-bit) or SHA-256 for secure encryption and hashing.'
    },
    'Hardcoded Encryption Keys': {
      'pattern': RegExp(r'''(encryptionKey|secretKey|privateKey)\s*[:=]\s*['\"].+['\"]''', caseSensitive: false),
      'mitigation':
          'Do not hardcode encryption keys in the source code. Store keys securely in a key management service or environment variables.'
    },
    'Insecure Random Number Generation': {
      'pattern': RegExp(r'(Random\(\)|math\.Random)', caseSensitive: false),
      'mitigation':
          'Do not use insecure random number generators like Random(). Use secure random number generators like the dart:crypto package.'
    },
    'Deprecated Cryptographic Libraries': {
      'pattern': RegExp(r'(crypto|pointycastle)\b', caseSensitive: false),
      'mitigation':
          'Ensure cryptographic libraries are up to date. Avoid deprecated libraries and use well-maintained ones like "package:cryptography".'
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
            insufficient_cryptography_table.addRow(["${entity.path}", "$issueName ($issue)" ,"$mitigation"]);
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