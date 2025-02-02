import 'dart:io';

void main() async {
  print('Enter the path to your Flutter project:');
  String? projectPath = stdin.readLineSync();

  if (projectPath == null || projectPath.isEmpty) {
    print('Invalid path provided.');
    return;
  }

  // Directory libDir = Directory('$projectPath/lib');
  // if (!libDir.existsSync()) {
  //   print('No lib directory found at $projectPath.');
  //   return;
  // }

  // Step 6: Custom scanning for potential vulnerabilities
  print('\nCustom scanning for potential vulnerabilities...');
  // await performCustomScanning(projectPath);

  // print('\nScanning for improper credential usage...');
  // await checkForImproperCredentialUsage(projectPath);
  // -- await checkForInsecureAuthentication(projectPath);
  // await checkForInputOutputValidation(projectPath);
  // await checkForInsecureCommunication(projectPath);
  // await checkForPrivacyIssues(projectPath);
  // await checkForSecurityMisconfigurations(projectPath);
  // await checkForInsecureDataStorage(projectPath);
  // await checkForInsufficientCryptography(projectPath);
}

// Step 5: Perform custom scanning
Future<void> performCustomScanning(String projectPath) async {
  Directory libDir = Directory('$projectPath/lib');
  if (!libDir.existsSync()) {
    print('No lib directory found at $projectPath for custom scanning.');
    return;
  }

  List<FileSystemEntity> files =
      libDir.listSync(recursive: true).whereType<File>().toList();

  for (var file in files) {
    if (file.path.endsWith('.dart')) {
      String content = await File(file.path).readAsString();

      // Example of simple pattern matching
      if (content.contains('new RegExp(')) {
        print('Potential vulnerability found in ${file.path}:');
        print(
            '  - Use of "RegExp" detected. Ensure no insecure patterns are used.');
      }

      if (content.contains('new Random().nextInt')) {
        print('Potential vulnerability found in ${file.path}:');
        print(
            '  - Weak random number generation detected. Consider using a cryptographically secure RNG.');
      }
    }
  }
}

Future<void> checkForImproperCredentialUsage(String projectPath) async {
  Directory libDir = Directory('$projectPath/lib');
  if (!libDir.existsSync()) {
    print('No lib directory found at $projectPath for scanning.');
    return;
  }

  print('\nScanning for improper credential usage...');

  List<FileSystemEntity> files = libDir.listSync(recursive: true).whereType<File>().toList();

  for (var file in files) {
    if (file.path.endsWith('.dart')) {
      String content = await File(file.path).readAsString();

      // Regex patterns to identify potential hardcoded credentials
      final credentialPatterns = [
        RegExp(r'''password\s*=\s*["\'].*?["\']''', caseSensitive: false),
        RegExp(r'''apiKey\s*=\s*["\'].*?["\']''', caseSensitive: false),
        RegExp(r'''token\s*=\s*["\'].*?["\']''', caseSensitive: false),
      ];

      for (var pattern in credentialPatterns) {
        if (pattern.hasMatch(content)) {
          print('Potential hardcoded credentials found in ${file.path}:');
          final matches = pattern.allMatches(content);
          for (var match in matches) {
            print('  - ${match.group(0)}');
          }
        }
      }

      // Check for usage of insecure storage
      if (content.contains('SharedPreferences')) {
        print('Use of SharedPreferences detected in ${file.path}:');
        print('  - Ensure sensitive data is not stored insecurely.');
      }

      // Check for insecure hardcoded URLs
      if (RegExp(r'https?://').hasMatch(content)) {
        print('Hardcoded URL found in ${file.path}:');
        content.split('\n').asMap().forEach((lineNumber, line) {
          if (RegExp(r'https?://').hasMatch(line)) {
            print('  Line ${lineNumber + 1}: $line');
          }
        });
      }
    }
  }
}

Future<void> checkForInsecureAuthentication(String projectPath) async {
  Directory libDir = Directory('$projectPath/lib');
  if (!libDir.existsSync()) {
    print('No lib directory found at $projectPath for scanning.');
    return;
  }

  List<FileSystemEntity> files = libDir.listSync(recursive: true).whereType<File>().toList();

  for (var file in files) {
    if (file.path.endsWith('.dart')) {
      String content = await File(file.path).readAsString();

      // Check for hardcoded secrets
      final secretPatterns = [
        RegExp(r'''password\s*=\s*["\'].*?["\']''', caseSensitive: false),
        RegExp(r'''apiKey\s*=\s*["\'].*?["\']''', caseSensitive: false),
        RegExp(r'''token\s*=\s*["\'].*?["\']''', caseSensitive: false),
        RegExp(r'''authKey\s*=\s*["\'].*?["\']''', caseSensitive: false),
      ];

      for (var pattern in secretPatterns) {
        if (pattern.hasMatch(content)) {
          print('Hardcoded secret detected in ${file.path}:');
          final matches = pattern.allMatches(content);
          for (var match in matches) {
            print('  - ${match.group(0)}');
          }
        }
      }

      // Check for weak password-handling logic
      if (content.contains('password.length <') || content.contains('password.length <=') || content.contains('password ==')) {
        print('Potential weak password validation logic in ${file.path}:');
        print('  - Ensure strong password policies are enforced (e.g., length, complexity).');
      }

      // Check for absence of hashing in password storage
      if (content.contains('store(password') && !content.contains('hash')) {
        print('Potential insecure password storage in ${file.path}:');
        print('  - Ensure passwords are hashed using a strong algorithm (e.g., bcrypt, SHA-256).');
      }

      // Check for insecure token handling
      if (content.contains('Bearer ') && content.contains('http.get')) {
        print('Potential insecure token handling in ${file.path}:');
        print('  - Ensure tokens are validated and securely managed.');
      }
    }
  }
}

Future<void> checkForInputOutputValidation(String projectPath) async {
  Directory libDir = Directory('$projectPath/lib');
  if (!libDir.existsSync()) {
    print('No lib directory found at $projectPath for scanning.');
    return;
  }

  List<FileSystemEntity> files = libDir.listSync(recursive: true).whereType<File>().toList();

  for (var file in files) {
    if (file.path.endsWith('.dart')) {
      String content = await File(file.path).readAsString();
      List<String> lines = content.split('\n');

      // Check for potential SQL injection vulnerabilities
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'rawQuery\s*\(').hasMatch(lines[i]) || RegExp(r'execute\s*\(').hasMatch(lines[i])) {
          print('Potential SQL injection vulnerability detected in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Avoid using raw SQL queries or ensure proper parameterization.');
        }
      }

      // Check for command injection vulnerabilities
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'Process\.run\(').hasMatch(lines[i])) {
          print('Potential command injection vulnerability detected in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Ensure user inputs are sanitized before passing to system commands.');
        }
      }

      // Check for XSS vulnerabilities
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'Html\(').hasMatch(lines[i]) || RegExp(r'render\(').hasMatch(lines[i])) {
          print('Potential XSS vulnerability detected in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Avoid rendering unescaped user inputs directly.');
        }
      }

      // Check for unsafe string interpolation
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'"\$\{.*?\}"').hasMatch(lines[i]) || RegExp(r"'\$\{.*?\}'").hasMatch(lines[i])) {
          print('Unsafe string interpolation detected in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Validate and sanitize interpolated inputs.');
        }
      }
    }
  }
}

Future<void> checkForInsecureCommunication(String projectPath) async {
  Directory libDir = Directory('$projectPath/lib');
  if (!libDir.existsSync()) {
    print('No lib directory found at $projectPath for scanning.');
    return;
  }

  List<FileSystemEntity> files = libDir.listSync(recursive: true).whereType<File>().toList();

  for (var file in files) {
    if (file.path.endsWith('.dart')) {
      String content = await File(file.path).readAsString();
      List<String> lines = content.split('\n');

      // Check for HTTP usage
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'http://').hasMatch(lines[i])) {
          print('Insecure HTTP usage detected in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Use HTTPS instead of HTTP for secure communication.');
        }
      }

      // Check for insecure API calls
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'http\.get\(').hasMatch(lines[i]) ||
            RegExp(r'http\.post\(').hasMatch(lines[i]) ||
            RegExp(r'http\.put\(').hasMatch(lines[i]) ||
            RegExp(r'http\.delete\(').hasMatch(lines[i])) {
          print('Potential insecure API call detected in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Ensure secure endpoints and proper authentication.');
        }
      }

      // Check for potential weak TLS configurations
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'SecurityContext\(').hasMatch(lines[i])) {
          print('Potential weak TLS configuration detected in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Review your TLS/SSL settings to ensure strong configurations.');
        }
      }
    }
  }
}

Future<void> checkForPrivacyIssues(String projectPath) async {
  Directory libDir = Directory('$projectPath/lib');
  if (!libDir.existsSync()) {
    print('No lib directory found at $projectPath for scanning.');
    return;
  }

  List<FileSystemEntity> files = libDir.listSync(recursive: true).whereType<File>().toList();

  for (var file in files) {
    if (file.path.endsWith('.dart')) {
      String content = await File(file.path).readAsString();
      List<String> lines = content.split('\n');

      // Check for logging of sensitive data
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'print\(').hasMatch(lines[i]) ||
            RegExp(r'logger\.log\(').hasMatch(lines[i])) {
          print('Potential sensitive data logging detected in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Ensure sensitive data (PII) is not logged.');
        }
      }

      // Check for insecure storage of sensitive data
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('SharedPreferences') ||
            lines[i].contains('File(')) {
          print('Potential insecure storage of sensitive data detected in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Avoid storing PII in insecure locations such as SharedPreferences or plain text files.');
        }
      }

      // Check for exposure of sensitive data via network requests
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'http\.(post|get|put|delete)').hasMatch(lines[i]) &&
            RegExp(r'(password|token|email|creditCard)', caseSensitive: false).hasMatch(lines[i])) {
          print('Potential exposure of sensitive data in network request in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Ensure sensitive data is properly encrypted or sanitized before sending over the network.');
        }
      }
    }
  }
}

Future<void> checkForSecurityMisconfigurations(String projectPath) async {
  Directory libDir = Directory('$projectPath/lib');
  if (!libDir.existsSync()) {
    print('No lib directory found at $projectPath for scanning.');
    return;
  }

  List<FileSystemEntity> files = libDir.listSync(recursive: true).whereType<File>().toList();

  for (var file in files) {
    if (file.path.endsWith('.dart')) {
      String content = await File(file.path).readAsString();
      List<String> lines = content.split('\n');

      // Check for debug mode being enabled
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'(debug|isDebugMode)\s*=\s*true').hasMatch(lines[i])) {
          print('Debug mode detected in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Ensure debug mode is disabled in production.');
        }
      }

      // Check for weak permission checks (example: bypassing permissions)
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'permissionStatus\s*=\s*PermissionStatus\.granted').hasMatch(lines[i])) {
          print('Weak permission check detected in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Ensure permission logic is robust and cannot be bypassed.');
        }
      }

      // Check for exposure of sensitive configurations
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('Config(') && lines[i].contains('debug: true')) {
          print('Sensitive configuration exposed in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Ensure sensitive configurations are not exposed.');
        }
      }

      // Check for improper usage of exception handling exposing stack traces
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('catch') && lines[i].contains('print')) {
          print('Improper exception handling detected in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Avoid exposing stack traces or sensitive information in logs.');
        }
      }
    }
  }
}

Future<void> checkForInsecureDataStorage(String projectPath) async {
  Directory libDir = Directory('$projectPath/lib');
  if (!libDir.existsSync()) {
    print('No lib directory found at $projectPath for scanning.');
    return;
  }

  List<FileSystemEntity> files = libDir.listSync(recursive: true).whereType<File>().toList();

  for (var file in files) {
    if (file.path.endsWith('.dart')) {
      String content = await File(file.path).readAsString();
      List<String> lines = content.split('\n');

      // Check for use of SharedPreferences (insecure for sensitive data)
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('SharedPreferences')) {
          print('Insecure use of SharedPreferences detected in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Avoid storing sensitive data in SharedPreferences.');
        }
      }

      // Check for plaintext-sensitive data storage
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'''(password|token|apiKey|secret)\s*=\s*[\'"][^\'"]+[\'"]''').hasMatch(lines[i])) {
          print('Plaintext-sensitive data found in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Ensure sensitive data is encrypted or stored securely.');
        }
      }

      // Check for improper encryption (e.g., using weak algorithms)
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'AES\(').hasMatch(lines[i]) &&
            (lines[i].contains('AES(128)') || lines[i].contains('AES(64)'))) {
          print('Weak encryption detected in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Use stronger encryption algorithms like AES-256.');
        }
      }

      // Check for insecure file storage
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('File(') && lines[i].contains('writeAsString')) {
          print('Potential insecure file storage detected in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Ensure sensitive data is stored securely and encrypted.');
        }
      }
    }
  }
}

Future<void> checkForInsufficientCryptography(String projectPath) async {
  Directory libDir = Directory('$projectPath/lib');
  if (!libDir.existsSync()) {
    print('No lib directory found at $projectPath for scanning.');
    return;
  }

  List<FileSystemEntity> files = libDir.listSync(recursive: true).whereType<File>().toList();

  for (var file in files) {
    if (file.path.endsWith('.dart')) {
      String content = await File(file.path).readAsString();
      List<String> lines = content.split('\n');

      // Check for hardcoded cryptographic keys
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'''(["\']?key["\']?\s*[:=]\s*["\'][A-Za-z0-9+/=]{16,}["\'])''').hasMatch(lines[i])) {
          print('Hardcoded cryptographic key detected in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Avoid hardcoding cryptographic keys. Use secure key management solutions.');
        }
      }

      // Check for weak encryption algorithms
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('AES(') && (lines[i].contains('AES(128)') || lines[i].contains('AES(64)'))) {
          print('Weak encryption algorithm detected in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Use stronger encryption algorithms like AES-256.');
        }
      }

      // Check for insecure random number generation
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('Random().nextInt')) {
          print('Insecure random number generation detected in ${file.path} at line ${i + 1}:');
          print('  - ${lines[i].trim()}');
          print('  - Use cryptographically secure random number generators like Random.secure().');
        }
      }
    }
  }
}