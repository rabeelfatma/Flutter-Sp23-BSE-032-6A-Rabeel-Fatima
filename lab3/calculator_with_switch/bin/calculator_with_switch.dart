import 'dart:io';
void main() {
  stdout.write("Enter first number: ");
  double a = double.parse(stdin.readLineSync()!);
  stdout.write("Enter second number: ");
  double b = double.parse(stdin.readLineSync()!);
  stdout.write("Enter operator (+,-,*,/): ");
  String op = stdin.readLineSync()!;
  switch (op) {
    case "+":
      print("Result = ${a + b}");
      break;
    case "-":
      print("Result = ${a - b}");
      break;
    case "*":
      print("Result = ${a * b}");
      break;
    case "/":
      print(b != 0 ? "Result = ${a / b}" :
      "Cannot divide by zero");
      break;
    default: print("Invalid operator");
  }
}