import 'dart:io';
import 'package:intl/intl.dart';

import 'package:flutter_sentinel/project_path_script/project_path.dart' as pp;

import 'package:flutter_sentinel/owasp_mobile_top_ten_scan_scripts/dependency_scanner.dart' as ds;
import 'package:flutter_sentinel/owasp_mobile_top_ten_scan_scripts/vulnerability_detection.dart' as vd;
import 'package:flutter_sentinel/owasp_mobile_top_ten_scan_scripts/improper_credential_usage.dart' as icu;
import 'package:flutter_sentinel/owasp_mobile_top_ten_scan_scripts/insecure_authentication_authorization.dart' as iaa;
import 'package:flutter_sentinel/owasp_mobile_top_ten_scan_scripts/insufficient_input_output_validation.dart' as iiov;
import 'package:flutter_sentinel/owasp_mobile_top_ten_scan_scripts/inadequate_privacy_controls.dart' as ipc;
import 'package:flutter_sentinel/owasp_mobile_top_ten_scan_scripts/security_misconfiguration.dart' as sm;
import 'package:flutter_sentinel/owasp_mobile_top_ten_scan_scripts/insecure_data_storage.dart' as ids;
import 'package:flutter_sentinel/owasp_mobile_top_ten_scan_scripts/insufficient_cryptography.dart' as ic;
import 'package:flutter_sentinel/report_generation_script/report_generation.dart' as rg;

void main(List<String> arguments) async {

  final startTimeFormatter = DateFormat('HH:mm:ss');
  final DateTime startTime = DateTime.now();
  final scanStartTime = startTimeFormatter.format(startTime);
  
  pp.main();

  print('\nScan Start Time: ' + scanStartTime);

  if (pp.projectPath == null || pp.projectPath!.isEmpty) {
    print('Invalid path provided.\n');
    return;
  } 
  
  File lockFile = File('${pp.projectPath}/pubspec.lock');

  if (!lockFile.existsSync()) {

    print('pubspec.lock not found in the provided directory: ${pp.projectPath}\n');
    return;

  } else { 

    print("\n======================================================================================");
    print("[+][+][+] Flutter Sentinel: Static Application Security Testing Started !!! [+][+][+]");
    print("========================================================================================");

    if (arguments.contains('--ds')){
      await ds.main();
      await vd.main();

      await rg.main(arguments);
      return;
    }

    if (arguments.contains('--cs')){
      await vd.main();
      await icu.main();
      await iaa.main();
      await iiov.main();
      await ipc.main();
      await sm.main();
      await ids.main();
      await ic.main();

      await rg.main(arguments);
      return;
    }

    await ds.main();
    await vd.main();
    await icu.main();
    await iaa.main();
    await iiov.main();
    await ipc.main();
    await sm.main();
    await ids.main();
    await ic.main();

    await rg.main(arguments);
  }
}
