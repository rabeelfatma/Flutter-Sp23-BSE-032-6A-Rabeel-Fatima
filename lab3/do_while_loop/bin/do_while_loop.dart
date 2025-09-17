import 'dart:io';
void main(){
  int count=0,num;
  do {
    num = int.parse(stdin.readLineSync()!);
    if (num != 0) {
      count++;
    }
  }
  while(num!=0);
      print("Total numbers entered:$count");
}