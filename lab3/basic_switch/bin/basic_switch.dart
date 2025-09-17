import 'dart:io';
void main(){
  stdout.write("please enter any number from 1 to 7:");
  int n=int.parse(stdin.readLineSync()!);
  switch(n) {
    case 1:
      print("Monday");
      break;
    case 2:
      print("Tuesday");
      break;
    case 3:
      print("Wednesday");
      break;
    case 4:
      print("Thursday");
      break;
    case 5:
      print("Friday");
      break;
    case 6:
      print("Saturday");
      break;
    case 7:
      print("Sunday");
      break;
    default:
      print("invalid.");
  }
}
