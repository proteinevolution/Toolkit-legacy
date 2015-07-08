#include <iostream>   // cin, cout, cerr
#include <ios>
#include <fstream>    // ofstream, ifstream 
#include <string>     // strcmp, strstr
#include <stdio.h>    // printf
#include <stdlib.h>   // exit
#include <math.h>     // sqrt, pow
#include <limits.h>   // INT_MIN
#include <float.h>    // FLT_MIN

// Fast pow2 routine
// Makes use of the binary representation of a the representation of floats in memory:
//   x = (-1)^s * 1.mmmmmmmmmmmmmmmmmmmmmm * 2^(eeeeeee-127) 
// is represented as  
// 31        23                   7654 3210
//  seee eeee emmm mmmm mmmm mmmm mmmm mmmm
// s is the sign, the 8 bits eee eee e are the exponent + 127 (in hex: 0x7f), 
// and the following 23 bits m give the mantisse.

inline float fpow2(float x)
{
  if (x>=128) return FLT_MAX;
  if (x<=-128) return FLT_MIN;
  int *px = (int*)(&x);                     // store address of float as pointer to long
  const float tx = (x-0.5f) + (3<<22);        // temporary value for truncation: x-0.5 is added to a large integer (3<<22)
  const int lx = *((int*)&tx) - 0x4b400000; // integer value of x
  const float dx = x-(float)(lx);             // float remainder of x
  x = 1.0f + dx*(0.6960656421638072f        // cubic apporoximation of 2^x
	   + dx*(0.224494337302845f        // for x in the range [0, 1]
           + dx*(0.07944023841053369f)));
  *px += (lx<<23);                            // add integer power of 2 to exponent
  return x;
}
//End of fast pow2 routine



// Fast pow2 routine
// 20% faster than fpow2()
// Makes use of the binary representation of floats in memory:
//   x = (-1)^s * 1.mmmmmmmmmmmmmmmmmmmmmm * 2^(eeeeeee-127) 
// is represented as
// 31        23                   7654 3210
//  seee eeee emmm mmmm mmmm mmmm mmmm mmmm
// s is the sign, the 8 bits eee eee e are the exponent + 127 (in hex: 0x7f), 
// and the following 23 bits m give the mantisse.
// We decompose the argument x = a + b, with integer a and 1 <= b < 2
// Therefore 2^x = 2^a * 2^b. Here a is the binary exponent of 2^x and 2^a determines 
// the mantisse uniquely. 2^b can be precomputed in a lookup table.

inline float fast_pow2(float x) 
{
  if (x<=-128) return FLT_MIN;
  if (x>=128) return FLT_MAX;
  static char initialized;
  static unsigned int pow2[1025];
  if (!initialized)   //First fill in the pow2-vector
    {
      initialized=1;
      float *f=new(float);
      for (int b=0; b<1024; b++) {
	*f=pow(2.0,1.0+float(b)/1024.0);
	pow2[b]=(*((unsigned int *)(f)) & 0x7FFFFF);  // store the mantisse of 2^(1+b/1024)
      }
      pow2[1024]=0x7FFFFF;
    }  
      
  int *px = (int *)(&x);                              // store address of float as pointer to long
  int E=((*px & 0x7F800000)>>23)-127;                 // E is exponent of x and is <=6
  unsigned int M=(*px & 0x007FFFFF) | 0x00800000;     // M is the mantisse 1.mmm mmmm mmmm mmmm mmmm mmmm
  int a,b;
  if (x>=0) 
    {
      if (E>=0) {
	a = 0x3F800000 + ((M<<E) & 0x7F800000);       // a is exponent of 2^x, beginning at bit 23 
	b = ((M<<E) & 0x007FFFFF)>>13;                
      } else {
	a =  0x3F800000;                              // a = exponent of 2^x = 0
	b = ((M>>(-E)) & 0x007FFFFF)>>13;          
      }
    } 
  else 
    {
      if (E>=0) {
	a = 0x3F000000 - ((M<<E) & 0x7F800000);       // a is exponent of 2^x
	b = (-((M<<E) & 0x007FFFFF)+0x00800000) >>13;          
      } else {
	a = 0x3F000000;                               // a = exponent of 2^x = -1
	b = (-((M>>(-E)) & 0x007FFFFF)+0x00800000) >>13;          
      }
    }
  printf("x=%0X\n",*px);
  printf("E=%0X\n",E);
  printf("M=%0X\n",M);
  printf("a=%0X\n",a);
  printf("b=%0X\n",b);
  *px = a | pow2[b];
  printf("2^x=%0X\n",*px);
  return *((float*)(px));
}


inline float fast_log2(float x) 
{
  static float lg2[1025];         // lg2[i]=log2[i+1024]
  static char initialized;
  if (x<=0) return -INT_MAX;
  if (!initialized)   //First fill in the log2-vector
    {
      initialized=1;
      for (int i=0; i<=1024; i++) lg2[i]=log(float(i+1024))/log(2);
    }  
  int n = 10 - ( ((  (*(int *)&x) & 0x7F800000 ) >>23 )-0x7f );
  return (lg2[ ((((*(int *)&x) & 0x7FF000 ) >> 12 )+1 >>1)]-n);
}


/////////////////////////////////////////////////////////////////////////////////////
// Fast lookup of log2(1+2^(-x)) for x>=0 (precision < 0.3%)
/////////////////////////////////////////////////////////////////////////////////////
inline float fast_addscore(float x) 
{
  static float val[1001];         // val[i]=log2(1+2^(-x))
  static char initialized;
  if (x>10) return 0.0;
  if (x<0) 
    {
      fprintf(stderr,"Error in function fast_addscore: argument %g is negative\n",x);
      exit(1);
    }
  if (!initialized)   //First fill in the log2-vector
    {
      initialized=1;
      for (int i=0; i<=1000; i++) val[i]=log2(1.0+pow(2,-0.01*i));
    }  
  return val[int(100.0*x+0.5)];
}

int main()
{
  float* x=new(float);
  float sum=0;
  do {
    scanf("%f",x);
    printf("Input=%f  exact=%G  fpow2=%G  fast_pow2=%G\n",*x,pow(2.0,*x),fpow2(*x),fast_pow2(*x));
  } while (*x!=0.0);


/*   for (float f=0; f<20000000; f+=1.11) sum+=1/f; */
//   for (int i=0; i<40000000; i++) sum+=fpow2(0.25e-5*i);
//   for (int i=0; i<40000000; i++) sum+=fast_pow2(0.25e-5*i); 
//   for (int i=0; i<40000000; i++) sum+=pow(2.0,0.25e-5*i);
//   for (float f=-100; f<100; f+=0.000005) sum+=pow(2.0,f);
//   for (float f=-100; f<100; f+=0.000005) sum+=fast_log2(f); 

/*    for (int i=0; i<2050; i++) */
/*      { */
/*        printf("x=%6.3f  exact=%7.4f  approx=%7.4f\n",0.005*i,log(1+pow(2,-0.005*i))*1.442695,fast_addscore(0.005*i));  */
/*      } */
/*    printf("sum=%G",sum); */

  exit(1);
}
