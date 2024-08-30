import 'dart:io';

void exitWith(int code) {
  print('');
  print('Program exited with code $code');
  print('Press Enter to exit');
  stdin.readLineSync();
  exit(code);
}
