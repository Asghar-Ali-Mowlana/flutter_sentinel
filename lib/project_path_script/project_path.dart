import 'dart:io';

String? projectPath;

void main () {
  stdout.write("\nEnter the path to your Flutter project: ");
  projectPath = stdin.readLineSync()?.trim();
}