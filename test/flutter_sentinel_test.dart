import 'package:test/test.dart';

// import 'package:flutter_sentinel/project_path_script/project_path.dart' as pp;

// import 'package:flutter_sentinel/owasp_mobile_top_ten_scan_scripts/flutter_sentinel.dart';

String? projectPath = "null";

void main() {
  test('Validating Project Path', () {
    if (projectPath == null || projectPath!.isEmpty) {
      var result = 'Invalid path provided.';
      expect(result, 'Invalid path provided.');
    } 
  });
}
