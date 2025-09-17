import 'dart:io';
void main(){
  List <int> nums=[2,4,6,8,10];
  stdout.write("Please enter the number:");
  int n = int.parse(stdin.readLineSync()!);
 print(nums.contains(n) ? "Found":"Not Found");
}