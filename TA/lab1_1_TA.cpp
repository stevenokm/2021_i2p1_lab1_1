#include "math.h"
#include "stdio.h"

int add(int x, int y);
int msub(int x, int y);

int main() {
  int a = 0;
  int b = 0;
  int c = 0;
  int d = 0;
  printf("input a:");
  scanf("%d", &a);
  printf("input b:");
  scanf("%d", &b);
  printf("input c:");
  scanf("%d", &c);
  d = msub(add(a, b), c);
  printf("result = %d", d);
  //while(true);
  return 0;
}
int add(int x, int y) {
  return x + y;
}
int msub(int x, int y) {
  int large = (x >= y) ? x : y;
  int small = (x <= y) ? x : y;
  while (large >= small) {
    large = large - small;
  }
  return large;
}
