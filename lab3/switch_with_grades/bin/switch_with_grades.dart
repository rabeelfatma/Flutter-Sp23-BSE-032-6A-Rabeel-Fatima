import 'dart:io';
void main(){
  stdout.write("please enter any Grade from A to F:");
  String g = stdin.readLineSync()!;
  switch(g) {
    case 'A':
      print("Excellent");
      break;
    case' B':
      print("Good");
      break;
    case 'C':
      print("Average");
      break;
    case 'D':
      print("Fair");
      break;
    case 'E':
      print("poor");
      break;
    case 'F':
      print("Fail");
      break;
    default:
      print("invalid.");
  }
}
