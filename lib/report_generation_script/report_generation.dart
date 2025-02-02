import 'package:intl/intl.dart';
import 'package:console_bars/console_bars.dart';

import '../owasp_mobile_top_ten_scan_scripts/dependency_scanner.dart' as ds;
import '../owasp_mobile_top_ten_scan_scripts/vulnerability_detection.dart' as vd;
import 'package:flutter_sentinel/owasp_mobile_top_ten_scan_scripts/improper_credential_usage.dart' as icu;
import 'package:flutter_sentinel/owasp_mobile_top_ten_scan_scripts/insecure_authentication_authorization.dart' as iaa;
import 'package:flutter_sentinel/owasp_mobile_top_ten_scan_scripts/insufficient_input_output_validation.dart' as iiov;
import 'package:flutter_sentinel/owasp_mobile_top_ten_scan_scripts/inadequate_privacy_controls.dart' as ipc;
import 'package:flutter_sentinel/owasp_mobile_top_ten_scan_scripts/security_misconfiguration.dart' as sm;
import 'package:flutter_sentinel/owasp_mobile_top_ten_scan_scripts/insecure_data_storage.dart' as ids;
import 'package:flutter_sentinel/owasp_mobile_top_ten_scan_scripts/insufficient_cryptography.dart' as ic;

final report_generation_bar = FillingBar(desc: "[+] Generating Report", total: 1000, time: true, percentage:true);

Future<void> main(List<String> arguments) async {
  print('\n');

  for (var i = 0; i < 1000; i++) {
    report_generation_bar.increment();
    await Future.delayed(Duration(milliseconds: 1));
  }

  print('\x1B[2J\x1B[H'); // Clear the console before printing the report

  print('\n');

  print("====== Static Analysis Security Testing (SAST) Report ======\n");
  print("Date: ${DateTime.now()}\n");
  // print("Summary of Detected Issues:\n");

  print("============ Tabular Summary of Detected Issues ============\n");

  if (arguments.contains('--ds')){
    print("===========================================================");
    print("[+][+][+] Summary of Scanned Dependency:");
    print("===========================================================\n");
    print(ds.dependency_table);

    print(vd.vulnerability_table);

    final endTimeFormatter = DateFormat('HH:mm:ss');
    final DateTime endTime = DateTime.now();
    final scanEndTime = endTimeFormatter.format(endTime);
  
    print('\nScan End Time: ' + scanEndTime + '\n');

    return;
  }

  if (arguments.contains('--cs')){
    print("\n=============== OWASP Mobile Top 10 Summary ===============\n");

    print("=======================================================================");
    print("[+][+][+] Vulnerabilities Identifed for M1: Improper Credential Usage:");
    print("=======================================================================\n");
    print(icu.improper_credential_usage_table);

    // print("\n============================================================================");
    // print("[+][+][+] Vulnerabilities Identifed for M2: Inadequate Supply Chain Security:");
    // print("=============================================================================\n");
    // print(vd.vulnerability_table);

    print("\n==================================================================================");
    print("[+][+][+] Vulnerabilities Identifed for M3: Insecure Authentication/Authorization:");
    print("==================================================================================\n");
    print(iaa.insecure_authentication_authorization_table);

    print("\n===============================================================================");
    print("[+][+][+] Vulnerabilities Identifed for M4: Insufficient Input/Output Validation:");
    print("=================================================================================\n");
    print(iiov.insufficient_input_output_validation_table);

    print("\n======================================================================");
    print("[+][+][+] Vulnerabilities Identifed for M6: Inadequate Privacy Controls:");
    print("========================================================================\n");
    print(ipc.inadequate_privacy_controls_table);

    print("\n====================================================================");
    print("[+][+][+] Vulnerabilities Identifed for M8: Security Misconfiguration:");
    print("======================================================================\n");
    print(sm.security_misconfiguration_table);

    print("\n=================================================================");
    print("[+][+][+] Vulnerabilities Identifed for M9: Insecure Data Storage:");
    print("===================================================================\n");
    print(ids.insecure_data_storage_table);

    print("\n=====================================================================");
    print("[+][+][+] Vulnerabilities Identifed for M10: Insufficient Cryptography:");
    print("=======================================================================\n");
    print(ic.insufficient_cryptography_table);

    final endTimeFormatter = DateFormat('HH:mm:ss');
    final DateTime endTime = DateTime.now();
    final scanEndTime = endTimeFormatter.format(endTime);
  
    print('\nScan End Time: ' + scanEndTime + '\n');

    return;
  }

  print("===========================================================");
  print("[+][+][+] Summary of Scanned Dependency:");
  print("===========================================================\n");
  print(ds.dependency_table);

  print("\n===== OWASP Mobile Top 10 Summary =====\n");

  print("=======================================================================");
  print("[+][+][+] Vulnerabilities Identifed for M1: Improper Credential Usage:");
  print("=======================================================================\n");
  print(icu.improper_credential_usage_table);

  print("\n============================================================================");
  print("[+][+][+] Vulnerabilities Identifed for M2: Inadequate Supply Chain Security:");
  print("=============================================================================\n");
  print(vd.vulnerability_table);

  print("\n==================================================================================");
  print("[+][+][+] Vulnerabilities Identifed for M3: Insecure Authentication/Authorization:");
  print("==================================================================================\n");
  print(iaa.insecure_authentication_authorization_table);

  print("\n===============================================================================");
  print("[+][+][+] Vulnerabilities Identifed for M4: Insufficient Input/Output Validation:");
  print("=================================================================================\n");
  print(iiov.insufficient_input_output_validation_table);

  print("\n======================================================================");
  print("[+][+][+] Vulnerabilities Identifed for M6: Inadequate Privacy Controls:");
  print("========================================================================\n");
  print(ipc.inadequate_privacy_controls_table);

  print("\n====================================================================");
  print("[+][+][+] Vulnerabilities Identifed for M8: Security Misconfiguration:");
  print("======================================================================\n");
  print(sm.security_misconfiguration_table);

  print("\n=================================================================");
  print("[+][+][+] Vulnerabilities Identifed for M9: Insecure Data Storage:");
  print("===================================================================\n");
  print(ids.insecure_data_storage_table);

  print("\n=====================================================================");
  print("[+][+][+] Vulnerabilities Identifed for M10: Insufficient Cryptography:");
  print("=======================================================================\n");
  print(ic.insufficient_cryptography_table);

  final endTimeFormatter = DateFormat('HH:mm:ss');
  final DateTime endTime = DateTime.now();
  final scanEndTime = endTimeFormatter.format(endTime);
  
  print('\nScan End Time: ' + scanEndTime + '\n');

  // print("\n===========================================================\n");

  // print("Detailed report saved to sast_report.txt");
}
