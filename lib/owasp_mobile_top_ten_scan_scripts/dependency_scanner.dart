import 'dart:io';
import 'dart:convert';
import 'package:yaml/yaml.dart';
import 'package:http/http.dart' as http;

import 'package:console_bars/console_bars.dart';
import 'package:dart_tabulate/dart_tabulate.dart';

import '../project_path_script/project_path.dart' as pp;

Table dependency_table = Table();

List<MapEntry<String, dynamic>> directDependencies = [];
List<MapEntry<String, dynamic>> transitiveDependencies = [];

final dependency_scanner_console_bar = FillingBar(desc: "Loading", total: 1000, time: true, percentage:true);

Future<void> main() async {
  // Step 1: Check whether the provided Flutter project path is a valid path
  String? projectPath = pp.projectPath;
  if (projectPath == null || projectPath.isEmpty) {
    print('Invalid path provided.');
    return;
  }

  // Step 2: Locate the pubspec.lock file in the provided path
  File lockFile = File('$projectPath/pubspec.lock');

  if (!lockFile.existsSync()) {
    print('pubspec.lock not found in the provided directory: $projectPath');
    return;
  } 
  
  // else { 
  //   print("\n======================================================================================");
  //   print("[+][+][+] Flutter Sentinel: Static Application Security Testing Started !!! [+][+][+]");
  //   print("========================================================================================");
  // }

  String content = lockFile.readAsStringSync();

  // Step 3: Parse YAML content to get dependencies
  final yamlMap = loadYaml(content);
  final dependencies = yamlMap['packages'] as Map;

  // Step 4: Separate direct and transitive dependencies
  dependencies.forEach((key, value) {
    if (value['dependency'] == 'direct main') {
      directDependencies.add(MapEntry(key, value));
    } else {
      transitiveDependencies.add(MapEntry(key, value));
    }
  });

  print('\n');
  dependency_scanner_console_bar.desc = "[+] Checking for latest versions on pub.dev";
  dependency_scanner_console_bar.fill = "█";

  for (var i = 0; i < 1000; i++) {
    dependency_scanner_console_bar.increment();
    await Future.delayed(Duration(milliseconds: 1));
  }

  // Step 5: Check each dependency on pub.dev
  dependency_table.addRow(["Dependencies", "Dependency Type" ,"Current Version", "Latest Version", "Suggestion"]);
  for (var dependency in dependencies.entries) {
    String packageName = dependency.key;
    String currentVersion = dependency.value['version'];
    await checkPackageVersion(packageName, currentVersion);
  }

  print('\n');
  print('[+][+][+] Dependency Scanning Completed !!! [+][+][+]');
}

Future<void> checkPackageVersion(String packageName, String currentVersion) async {
  final pubDevUrl = 'https://pub.dev/api/packages/$packageName';

  try {
    final response = await http.get(Uri.parse(pubDevUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String latestVersion = data['latest']['version'];

      // Compare current version with latest version
      if (currentVersion == latestVersion) {
        for (var dependency in directDependencies) {
          if(dependency.key == packageName){
            dependency_table.addRow(["$packageName", "Direct", "$currentVersion", " - ", "Up to date"]);
          } 
        }
        for (var dependency in transitiveDependencies) {
          if(dependency.key == packageName){
            dependency_table.addRow(["$packageName", "Transitive", "$currentVersion", " - ", "Up to date"]);
          } 
        }
      } else {
        for (var dependency in directDependencies) {
          if(dependency.key == packageName){
            dependency_table.addRow(["$packageName", "Direct", "$currentVersion", "$latestVersion", "Outdated. Update recommended!"]);
          } 
        }
        for (var dependency in transitiveDependencies) {
          if(dependency.key == packageName){
            dependency_table.addRow(["$packageName", "Transitive", "$currentVersion", "$latestVersion", "Outdated. Update recommended!"]);
          } 
        }
      }
    } else {
      // print('\n Failed to fetch details for $packageName (HTTP ${response.statusCode})');
    }
  } catch (e) {
    print('Error checking $packageName: $e');
  }
}