void main(){
  List <int> nums = [12,9,5,8,3,9];
  print ("largest number is:${nums.reduce((a,b)=>a>b?a:b)}");
  print ("Smallest number is:${nums.reduce((a,b)=>a<b?a:b)}");
}
