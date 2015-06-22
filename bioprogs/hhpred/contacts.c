// Read in a pdb file and output a list of atom-atom contacts (distance <10 A)
//   i j pi R(i,j,pi)
// Here i and j are residue indices, 
// pi=1 for CB-CB, 2 for CB-N, 3 for N-CB, 4 for CB-O, 5 for O-CB,
// and R(i,j,pi) is the distance of the atoms in Angstroem 
// Usage: contacts infile outfile


#include <iostream.h> // cin, cout, cerr
#include <fstream.h>  // ofstream, ifstream 
#include <stdio.h>    // printf
#include <stdlib.h>   // exit
#include <string.h>   // strcmp, strstr
#include <limits.h>   // INT_MIN
#include <float.h>    // FLT_MIN
#include <math.h>     // sqrt, pow

class Vector 
{
 public:
  float x,y,z;
  friend Vector operator+(Vector A, Vector B);
  friend Vector operator-(Vector A, Vector B);
  friend Vector operator^(Vector A, Vector B);
  friend Vector operator*(float s, Vector A);
  friend Vector operator*(Vector A,float s);
  friend Vector operator/(Vector A,float s);
  friend Vector Unit(Vector A) {return A/Len(A);}
  friend float operator*(Vector A, Vector B) {return A.x*B.x+A.y*B.y+A.z*B.z;}
  friend float Len(Vector A) {return sqrt(A.x*A.x+A.y*A.y+A.z*A.z);}
};

Vector operator+(Vector A, Vector B)
{
  Vector C;
  C.x=A.x+B.x;
  C.y=A.y+B.y;
  C.z=A.z+B.z;
  return C;
}

Vector operator-(Vector A, Vector B)
{
  Vector C;
  C.x=A.x-B.x;
  C.y=A.y-B.y;
  C.z=A.z-B.z;
  return C;
}

Vector operator^(Vector A, Vector B)
{
  Vector C;
  C.x=A.y*B.z-A.z*B.y;
  C.y=A.z*B.x-A.x*B.z;
  C.z=A.x*B.y-A.y*B.x;
  return C;
}

Vector operator*(float s, Vector A)
{
  Vector C;
  C.x=s*A.x;
  C.y=s*A.y;
  C.z=s*A.z;
  return C;
}

Vector operator*(Vector A, float s)
{
  Vector C;
  C.x=s*A.x;
  C.y=s*A.y;
  C.z=s*A.z;
  return C;
}

Vector operator/(Vector A, float s)
{
  Vector C;
  C.x=A.x/s;
  C.y=A.y/s;
  C.z=A.z/s;
  return C;
}

inline void Print(FILE* file,int i, int j, int pair, float d, int aa1, int aa2);
inline char Three2i(char* str);
inline int imin(int x, int y) { return (x<y? x : y);}

///////////////////////////////////////////////////////////////////////////////
//// Main Program

int main(int argc,char **argv)
{  

//// handling command line input. 

  const float MAXDIST=8.0;      // maximum spatial distance in Angstrom
  const int MINSEP=2;           // minimum separation in sequence between residues in contact
  const int MAXSEP=10000;       // minimum separation in sequence between residues in contact
  const int MAXRES=5000;        // maximum number of residues
  const int LINELEN=100;
  const int NAMELEN=50;
  const float DCTR=0.0;         // position of side chain centroid = CB plus DCTR Angstrom times CA->CB unit Vector 
  const int v=2;                // verbose mode
  char infile[NAMELEN];
  char outfile[NAMELEN];
  char line[LINELEN];
  struct Vector CA[MAXRES], CB[MAXRES], N[MAXRES], O[MAXRES], C[MAXRES], Cctr[MAXRES];
  char aa[MAXRES];              // amino acids code; -1 if not listed in pdb file 
  int countaa[22];              // amino acids code; -1 if not listed in pdb file 
  int L;                        // number of residues in pdb file (=highest index) 
  int i=0, j;                   // residue indices
  int linesread=0;
  float d;                      // spatial distance between two atoms
  int Nc=0;                     // number of contacts found


  for (int a=0; a<22; a++) countaa[a]=0;

  // Process command line input
  if (argc<3) 
    {
      printf("\n");
      printf(" Read a pdb file and output a list of atom-atom contacts\n");
      printf(" i    j    pair  R(i,j,pair)   AA1   AA2\n");
      printf(" Here i and j are residue indices and pair=1 for CB-CB, 2 for CB-N, 3 for N-CB, 4 for CB-O, 5 for O-CB.\n");
      printf(" R(i,j,pi) is the distance of the atoms in Angstroms (<%.1f). \n",MAXDIST);
      printf(" Usage: contacts infile outfile \n");
      return 1;
    }
  strcpy(infile,argv[1]);
  strcpy(outfile,argv[2]);


  // Read coordinates from infile
  // ----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
  // ATOM      1  N   PRO A   1      65.491  89.150  38.629  1.00 56.41           N
  // ATOM      4  O   PRO A   1      67.122  86.441  38.833  1.00 61.58           O
  // ATOM      5  CB  PRO A   1      67.580  88.742  37.410  1.00 50.41           C
  // ...
  FILE* inf;
  inf=fopen(infile,"r");
  if (!inf) {fprintf(stderr,"Error: could not open %s\n",infile); return 1;}


  char atom[5];      // atom name 
  char residue[5];   // residue name
  j=0;
  while (fgets(line,LINELEN,inf))
    {
      if (!strncmp("TER",line,3)) break;
      if (!strncmp("ATOM",line,4))
	{
	  strncpy(atom, line+13,2);
	  atom[3]='\0';
	  strncpy(residue,line+17,3);
	  residue[4]='\0';
	  i = atoi(line+22);
	  if (i>=MAXRES) {fprintf(stderr,"WARNING: maximum number %i of residues exceeded\n",MAXRES); break;}
	  // Set coordinates not appearing in pdb file to zero
	  for (j++; j<i; j++) aa[j]=21;
	  if (!strcmp(atom,"CA") )
	    {
	      CA[i].x=atof(line+30);
	      CA[i].y=atof(line+38);
	      CA[i].z=atof(line+46);
	      linesread++;
	      aa[i]=Three2i(residue);
	      countaa[(int)aa[i]]++;
	    }
	  else if (!strcmp(atom,"CB")) // || (aa[i]==7 && !strcmp(atom,"CA")) )
	    {
	      CB[i].x=atof(line+30);
	      CB[i].y=atof(line+38);
	      CB[i].z=atof(line+46);
	      linesread++;
	    }
	  else if (!strcmp(atom,"C "))
	    {
	      C[i].x=atof(line+30);
	      C[i].y=atof(line+38);
	      C[i].z=atof(line+46);
	      linesread++;
	    }
	  else if (!strcmp(atom,"N "))
	    {
	      N[i].x=atof(line+30);
	      N[i].y=atof(line+38);
	      N[i].z=atof(line+46);
	      linesread++;
	    }
	  else if (!strcmp(atom,"O "))
	    {
	      O[i].x=atof(line+30);
	      O[i].y=atof(line+38);
	      O[i].z=atof(line+46);
	      linesread++;
	    }
	}
    } // end while

  L=i; // number of residues
  if (linesread==0) cerr<<"\nWARNING: no lines read\n\n";
  else if (v>=2) cerr<<"Read "<<linesread<<" lines from "<<infile<<"\n";
  fclose(inf);
  
  const float a1=sin(54.5/360.*6.283);
  const float a2=cos(54.5/360.*6.283);

  // Print out list of contacts
  
  FILE* outf;
  if (strcmp(outfile,"stdout")) 
    {
      outf=fopen(outfile,"w");
      if (!outf) {fprintf(stderr,"Error: could not open %s\n",outfile); return 1;}
    } 
  else outf=stdout;

  // Calculate Cctr[i]
  Vector R1,R2,RAC,RAN;
  for (i=1; i<=L; i++) // for all CB atoms
    {
      if (aa[i]==7) 
	{
	  Cctr[i]=CA[i];
	  RAC=C[i]-CA[i];
	  RAN=N[i]-CA[i];
	  R1=Unit(RAN^RAC);
	  R2=Unit(RAN+RAC);
	  Cctr[i]=CA[i]+(DCTR+1.5)*(a1*R1-a2*R2);
	} else if (aa[i]<=20) {
	  Cctr[i]=CB[i]+DCTR*Unit(CB[i]-CA[i]);
	}

    }

  for (i=1; i<=L; i++) // for all CB atoms
    {
      if (aa[i]>20) continue;
        for (j=i+MINSEP; j<=imin(L,i+MAXSEP); j++) // for all CB atoms at least two residues after i
	  {
	    if (aa[j]>20) continue;
	    if ( (d=Len(Cctr[i]-Cctr[j]))< MAXDIST) {Print(outf,i,j,0,d,aa[i],aa[j]); Nc++;}
/* 	    if ( (d=Len(Cctr[i]-N[j])) < MAXDIST) {Print(outf,i,j,1,d,aa[i],aa[j]); Nc++;} */
/* 	    if ( (d=Len(N[i]-Cctr[j])) < MAXDIST) {Print(outf,i,j,2,d,aa[i],aa[j]); Nc++;} */
/* 	    if ( (d=Len(Cctr[i]-O[j])) < MAXDIST) {Print(outf,i,j,3,d,aa[i],aa[j]); Nc++;} */
/* 	    if ( (d=Len(O[i]-Cctr[j])) < MAXDIST) {Print(outf,i,j,4,d,aa[i],aa[j]); Nc++;} */
	  }
    }

  fprintf(outf,"AA counts: ");
  for (int a=0; a<20; a++) fprintf(outf,"%i ",countaa[a]);
  fprintf(outf,"\n");

  fclose(outf);
  if (v>=2) cerr<<"Written "<<Nc<<" contacts into "<<outfile<<"\n";
}


// Print the contact parameters
inline void Print(FILE* file, int i, int j, int pair, float d, int aa1, int aa2)
{
  fprintf(file,"%i\t%i\t%i\t%i\t%i\t%i\n",i,j,pair,int(floor(d)),aa1,aa2);
  return;
}

// Transform the three-letter amino acid code into an integer between 0 and 19
inline char Three2i(char* str)
{
  //A  R  N  D  C  Q  E  G  H  I  L  K  M  F  P  S  T  W  Y  V
  if (!strcmp(str,"ALA")) return 0;
  else if (!strcmp(str,"ARG")) return 1;
  else if (!strcmp(str,"ASN")) return 2;
  else if (!strcmp(str,"ASP")) return 3;
  else if (!strcmp(str,"CYS")) return 4;
  else if (!strcmp(str,"GLN")) return 5;
  else if (!strcmp(str,"GLU")) return 6;
  else if (!strcmp(str,"GLY")) return 7;
  else if (!strcmp(str,"HIS")) return 8;
  else if (!strcmp(str,"ILE")) return 9;
  else if (!strcmp(str,"LEU")) return 10;
  else if (!strcmp(str,"LYS")) return 11;
  else if (!strcmp(str,"MET")) return 12;
  else if (!strcmp(str,"MSE")) return 12;
  else if (!strcmp(str,"PHE")) return 13;
  else if (!strcmp(str,"PRO")) return 14;
  else if (!strcmp(str,"SER")) return 15;
  else if (!strcmp(str,"THR")) return 16;
  else if (!strcmp(str,"TRP")) return 17;
  else if (!strcmp(str,"TYR")) return 18;
  else if (!strcmp(str,"VAL")) return 19;
  else if (!strcmp(str,"SEC")) return 4;
  else if (!strcmp(str,"ASX")) return 3;
  else if (!strcmp(str,"GLX")) return 6;
  else if (!strcmp(str,"UNK")) return 20;
  else return 21;
}
