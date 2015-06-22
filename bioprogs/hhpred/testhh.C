#include <iostream>   // cin, cout, cerr
#include <fstream>    // ofstream, ifstream 
#include <stdio.h>    // printf
#include <stdlib.h>   // exit
using std::cout;
using std::cerr;
using std::endl;
using std::ios;
using std::ifstream;
using std::ofstream;
#include "list.C"        // list data structure
#include "hash.C"        // hash data structure

const int IDLEN=32;       // max length of scop hierarchy id and pdb-id
int v=2;

void InvertMatrix(float** A, int N);
void TransposeMatrix(float** V, int N);
void SVD(float **A, int n, float w[], float **V);
inline float pythag(float a, float b);

void PrintMatrix(float** V, int N)
{
  int k,l;
  for (k=0; k<N; k++)
    {
      printf("k=%4i \n",k);
      for (l=0; l<N; l++)
	{
	  printf("%4i:%6.3f ",l,V[k][l]);
	  if ((l+1)%10==0) printf("\n");
	}
      printf("\n");
    }
  printf("\n");
}

int main(int argc, char **argv)
{  
  float** Z;
  float** C;
  int N;
  int k,l;
  char name[128];
  Hash<int> index(10000);
  

  FILE* wfile;
  wfile = fopen("test.hhc","rb");
  fread(&N,sizeof(int),1,wfile);
  printf("Number of HMMs in weight matrix = %i\n",N);

  for (k=0; k<N; k++) 
    {
      fread(name,sizeof(char),IDLEN,wfile);
      printf("%4i name = %s\n",k,name);
      index.Add(name);
    }

  Z = new(float*[N]);
  for (k=0; k<N; k++) 
    {
      Z[k] = new(float[N]);
      int status = fread(Z[k],sizeof(float),N,wfile);
      printf("%i: status fread = %i\n",k,status);
    }

  C = new(float*[N]);
  for (k=0; k<N; k++) 
    {
      C[k] = new(float[N]);
      for (l=0; l<k; l++) C[k][l] = C[l][k];
      int status = fread(C[k]+k,sizeof(float),N-k,wfile);
      printf("%i: status fread = %i\n",k,status);
    }

  fclose(wfile);

  for (k=0; k<N; k++) 
    for (l=0; l<N; l++) 
      Z[k][l] = C[k][l];
  
  InvertMatrix(C,N);

  printf("\nMatrix C\n");
  PrintMatrix(Z,N);
  printf("\nMatrix C-1\n");
  PrintMatrix(C,N);
  
  for (k=0; k<N; k++) 
    {
      for (l=0; l<N; l++) 
	{
	  float sum = 0.0;
	  for (int m=0; m<N; m++) 
	    sum += C[k][m]*Z[m][l];
	  printf("%3i:%-6.2f ",l,sum);
	}
      printf("\n");
    }

  return 1;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
void TransposeMatrix(float** V, int N)
{
  int k,l;
  for (k=0; k<N; k++) // transpose Z for efficiency of ensuing matrix multiplication
    for (l=0; l<k; l++) 
      {
	float buf = V[k][l];
	V[k][l] = V[l][k];
	V[l][k] = buf;
      }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
void InvertMatrix(float** A, int N)
{
  int k,l,m;
  float** V = new(float*[N]);
  float* s  = new(float[N]);
  for (k=0; k<N; k++) V[k] = new(float[N]);

  SVD(A, N, s, V);  // U replaces A on output; s[] contains singluar values
  
  // Calculate inverse of A: A^-1 = V * diag(1/s) * U^t
  if (v>=2) printf("\nCalculating  inverse of A: A^-1 = V * diag(1/s) * U^t\n");
  float** U = A;
  // Calculate V[k][m] -> V[k][m] *diag(1/s)
  for (k=0; k<N; k++) 
    for (m=0; m<N; m++) 
      if (s[m]!=0.0) V[k][m] /= s[m]; else V[k][m] = 0.0;
  // Calculate V[k][l] -> (V * U^t)_kl
  for (k=0; k<N; k++) 
    {
      if (v>=4 && k%100==0) printf("%i\n",k); 
      for (l=0; l<N; l++) 
	{
	  s[l] = 0.0; // use s[] as temporary memory to avoid overwriting A[k][] as long as it is needed
	  for (m=0; m<N; m++) 
	    s[l] += V[k][m]*U[l][m];
	}
      for (l=0; l<N; l++) V[k][l]=s[l];
    }  
  for (k=0; k<N; k++) 
    for (l=0; l<N; l++) 
      A[k][l] = V[k][l];

  for (k=0; k<N; k++) delete[](V[k]);
  delete[](V);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
static float sqrarg;
#define SQR(a) ((sqrarg=(a)) == 0.0 ? 0.0 : sqrarg*sqrarg) 
static float maxarg1,maxarg2;
#define FMAX(a,b) (maxarg1=(a),maxarg2=(b),(maxarg1) > (maxarg2) ? (maxarg1) : (maxarg2)) 
static int iminarg1,iminarg2;
#define IMIN(a,b) (iminarg1=(a),iminarg2=(b),(iminarg1) < (iminarg2) ? (iminarg1) : (iminarg2)) 
#define SIGN(a,b) ((b) >= 0.0 ? fabs(a) : -fabs(a)) 

// This is a version of the Golub and Reinsch algorithm for singular value decomposition for a quadratic 
// (n x n) matrix A. It is sped up by transposing A amd V matrices at various places in the algorithm.
// On a 400x400 matrix it runs in 1.6 s or 2.3 times faster than the original (n x m) version.
// On a 4993x4993 matrix it runs in 2h03 or 4.5 times faster than the original (n x m) version.

// Given a matrix a[0..n-1][0..n-1], this routine computes its singular value decomposition, A = U · W · V^t . 
// The matrix U replaces a on output. The diagonal matrix of singular values W is out-put as a vector w[0..n-1]. 
// The matrix V (not the transpose V^t) is output as V[0..n-1][0..n-1] ./
void SVD(float **A, int n, float w[], float **V)
{
  int m=n; // in general algorithm A is an (m x n) matrix instead of (n x n)
 
  float pythag(float a, float b);
  int flag,i,its,j,jj,k,l=1,nm=1;
  float anorm,c,f,g,h,s,scale,x,y,z,*rv1;
  rv1=new(float[n]);
  g=scale=anorm=0.0;    
  
  // Householder reduction to bidiagonal form.
  if (v>=3) printf("\nHouseholder reduction to bidiagonal form\n");
  for (i=0;i<n;i++) {
    if (v>=4 && i%100==0) printf("i=%i\n",i);
    if (v>=4) fprintf(stderr,".");
    l=i+1;
    rv1[i]=scale*g;
    g=s=scale=0.0;
    if (i < m) {
      for (k=i;k<m;k++) scale += fabs(A[k][i]);
      if (scale) {
	for (k=i;k<m;k++) {
	  A[k][i] /= scale;
	  s += A[k][i]*A[k][i];
	}
	f=A[i][i];
	g = -SIGN(sqrt(s),f);
	h=f*g-s;
	A[i][i]=f-g;
	for (j=l;j<n;j++) {
	  for (s=0.0,k=i;k<m;k++) s += A[k][i]*A[k][j];
	  f=s/h;
	  for (k=i;k<m;k++) A[k][j] += f*A[k][i];
	}
	for (k=i;k<m;k++) A[k][i] *= scale;
      }
    }
    w[i]=scale *g;
    g=s=scale=0.0;
    if (i < m && i != n-1) {
      for (k=l;k<n;k++) scale += fabs(A[i][k]);
      if (scale) {
	for (k=l;k<n;k++) {
	  A[i][k] /= scale;
	  s += A[i][k]*A[i][k];
	}
	f=A[i][l];
	g = -SIGN(sqrt(s),f);
	h=f*g-s;
	A[i][l]=f-g;
	for (k=l;k<n;k++) rv1[k]=A[i][k]/h;
	for (j=l;j<m;j++) {
	  for (s=0.0,k=l;k<n;k++) s += A[j][k]*A[i][k];
	  for (k=l;k<n;k++) A[j][k] += s*rv1[k];
	}
	for (k=l;k<n;k++) A[i][k] *= scale;
      }
    }
    anorm=FMAX(anorm,(fabs(w[i])+fabs(rv1[i])));
  }
  // Accumulation of right-hand transformations.
  if (v>=3) printf("\nAccumulation of right-hand transformations\n");
  TransposeMatrix(V,n);
  for (i=n-1;i>=0;i--) {
    if (v>=4 && i%100==0) printf("i=%i\n",i);
    if (v>=4) fprintf(stderr,".");
    if (i < n-1) {
      if (g) {
	// Float division to avoid possible underflow.
	for (j=l;j<n;j++)
	  V[i][j]=(A[i][j]/A[i][l])/g;
	for (j=l;j<n;j++) {
	  for (s=0.0,k=l;k<n;k++) s += A[i][k]*V[j][k];
	  for (k=l;k<n;k++) V[j][k] += s*V[i][k];
	}
      }
      for (j=l;j<n;j++) V[j][i]=V[i][j]=0.0;
    }
    V[i][i]=1.0;
    g=rv1[i];
    l=i;
  }
  // Accumulation of left-hand transformations.
  if (v>=3) printf("\nAccumulation of left-hand transformations\n");
  TransposeMatrix(A,n);
  for (i=IMIN(m,n)-1;i>=0;i--) {
    if (v>=4 && i%100==0) printf("i=%i\n",i);
    if (v>=4) fprintf(stderr,".");
    l=i+1;
    g=w[i];
    for (j=l;j<n;j++) A[j][i]=0.0;
    if (g) {
      g=1.0/g;
      for (j=l;j<n;j++) {
	for (s=0.0,k=l;k<m;k++) s += A[i][k]*A[j][k];
	f=(s/A[i][i])*g;
	for (k=i;k<m;k++) A[j][k] += f*A[i][k];
      }
      for (j=i;j<m;j++) A[i][j] *= g;
    } else for (j=i;j<m;j++) A[i][j]=0.0;
    ++A[i][i];
  }

  // Diagonalization of the bidiagonal form: Loop over singular values, and over allowed iterations.
  if (v>=3) printf("\nDiagonalization of the bidiagonal form\n");
  for (k=n-1;k>=0;k--) {
    if (v>=4 && k%100==0) printf("k=%i\n",k);
    if (v>=4) fprintf(stderr,".");
    for (its=1;its<=30;its++) {
      flag=1;
      // Test for splitting. Note that rv1[1] is always zero.
      for (l=k;l>=0;l--) {
	nm=l-1;
	if ((float)(fabs(rv1[l])+anorm) == anorm) {
	  flag=0;
	  break;
	}
	if ((float)(fabs(w[nm])+anorm) == anorm) break;
      }
      if (flag) {
	// Cancellation of rv1[l], if l > 1.
	c=0.0;
	s=1.0;
	for (i=l;i<=k;i++) {
	  f=s*rv1[i];
	  rv1[i]=c*rv1[i];
	  if ((float)(fabs(f)+anorm) == anorm) break;
	  g=w[i];
	  h=pythag(f,g);
	  w[i]=h;
	  h=1.0/h;
	  c=g*h;
	  s = -f*h;
	  for (j=0;j<m;j++) {
	    y=A[nm][j];
	    z=A[i][j];
	    A[nm][j]=y*c+z*s;
	    A[i][j]=z*c-y*s;
	  }
	}
      }
      z=w[k];
      // Convergence.
      if (l == k) {
	// Singular value is made nonnegative.
	if (z < 0.0) {
	  w[k] = -z;
	  for (j=0;j<n;j++) V[k][j] = -V[k][j];
	}
	break;
      }
      if (its == 30) {printf("Error in SVD: no convergence in 30 iterations\n"); exit(1);}
      // Shift from bottom 2-by-2 minor.
      x=w[l];
      nm=k-1;
      y=w[nm];
      g=rv1[nm];
      h=rv1[k];
      f=((y-z)*(y+z)+(g-h)*(g+h))/(2.0*h*y);
      g=pythag(f,1.0);
      f=((x-z)*(x+z)+h*((y/(f+SIGN(g,f)))-h))/x;
      // Next QR transformation:
      c=s=1.0;
      for (j=l;j<=nm;j++) {
	i=j+1;
	g=rv1[i];
	y=w[i];
	h=s*g;
	g=c*g;
	z=pythag(f,h);
	rv1[j]=z;
	c=f/z;
	s=h/z;
	f=x*c+g*s;
	g = g*c-x*s;
	h=y*s;
	y *= c;
	for (jj=0;jj<n;jj++) {
	  x=V[j][jj];
	  z=V[i][jj];
	  V[j][jj]=x*c+z*s;
	  V[i][jj]=z*c-x*s;
	}
	z=pythag(f,h);
	// Rotation can be arbitrary if z = 0.
	w[j]=z;
	if (z) {
	  z=1.0/z;
	  c=f*z;
	  s=h*z;
	}
	f=c*g+s*y;
	x=c*y-s*g;
	
	for (jj=0;jj<m;jj++) {
	  y=A[j][jj];
	  z=A[i][jj];
	  A[j][jj]=y*c+z*s;
	  A[i][jj]=z*c-y*s;
	}
      }
      rv1[l]=0.0;
      rv1[k]=f;
      w[k]=x;
    }
  }
  TransposeMatrix(V,n);
  TransposeMatrix(A,n);
  delete[](rv1);
}

// Computes (a2 + b2 )^1/2 without destructive underflow or overflow.
inline float pythag(float a, float b)
{
  float absa,absb;
  absa=fabs(a);
  absb=fabs(b);
  if (absa > absb) 
    return absa*sqrt(1.0+SQR(absb/absa));
  else 
    return (absb == 0.0 ? 0.0 : absb*sqrt(1.0+SQR(absa/absb)));
}



