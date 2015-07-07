/*
 * clustalread.java
 *
 * Created on February 5, 2002, 2:14 PM
 */
import java.io.*;
import java.util.*;

/**
 *
 * @author  noname
 * @version 
 */
public class clustalread {

    /** Creates new clustalread */
    public clustalread() {
    }

    //*************************************************************
//clustalintread reads seqs in clustal interleaved format

public static aaseq[] clustalintread(File filenamein)
throws IOException{
        Vector seqvector=new Vector();//will hold the aaseq objects, number unknown
        //BufferedReader alignread = dataf.in(filenamein);
        BufferedReader alignread=new BufferedReader(new FileReader(filenamein));
        int seqlength=0;//needed for the aaseq object
        int speciesnumber=0;
        int seqposition=0;
        char readchar=0;
        aaseq[] seqarrayout=new aaseq[0];
        boolean readon=true;
        boolean newline=false;
        Character[] aasequence;
        String header= new String();
        try{
            header=alignread.readLine().trim();//should be clustal + some other noninformative stuff
        }catch (NullPointerException e){
            System.err.println("File:"+filenamein+" is NOT in clustal format! Exiting.");
            return seqarrayout;
        }
        try{
            if((header.indexOf("clustal")==-1)&&(header.indexOf("Clustal")==-1)&&(header.indexOf("CLUSTAL")==-1)){
                System.err.println("Alignment not in Clustal Format");
                return seqarrayout;
            }
        }catch (java.lang.StringIndexOutOfBoundsException e){
            System.err.println("Alignment not in correct Clustal Format");
        }
        newline=true;
        //System.out.println("starting clustalseqread");
        try{                                    //see if there is more to read
            boolean readable=alignread.ready();
            if(readable!=true){
                readon=false;
            }
        }catch (IOException e){
            readon=false;
            System.err.println("EOF reached");
            e.printStackTrace();
        }
        //System.out.println("can read sth");
        while (readon){
            alignread.mark(2);
            readchar=(char)alignread.read();
            while((Character.isWhitespace(readchar))||(readchar=='.')||(readchar=='*')||(readchar==':')){//if there was a newline or a space or "." or ":" or "*".
                    alignread.mark(2);//save the current position
                readchar=(char)alignread.read();
                newline=true;
            }//if another newline repeat loop
            alignread.reset();//if not, start reading after the last mark;
        
            if(newline==true){
                aaseq currentread=new aaseq();
                newline=false;//I' reading a new species
                Vector seqname=new Vector();
                try{                                    //see if there is more to read
                    boolean readable=alignread.ready();
                    if(readable!=true){
                        readon=false;
                    }
                }catch (IOException e){
                    readon=false;
                    System.err.println("EOF reached");
                    e.printStackTrace();
                }
                readchar=(char)alignread.read();
                while(((Character.isWhitespace(readchar))!=true)){//&&(readchar!='.')&&(readchar!='*')&&(readchar!=':')){
                    Character namechar=new Character(readchar);
                    seqname.addElement(namechar);
                    readchar=(char) alignread.read();
                    
                }//end while
                Character[] dummyarray= new Character[seqname.size()];//need to do this because I can't copy straight into a char array
                char[] namechararr= new char[java.lang.reflect.Array.getLength(dummyarray)];
                seqname.copyInto(dummyarray);
                for (int i=0;i<(java.lang.reflect.Array.getLength(dummyarray));i++){//convert the Character array to char array
                    namechararr[i]=dummyarray[i].charValue();
                }//end for
                String aaseqname = new String(namechararr);//make a string out of it
                currentread.savename(aaseqname);
                //System.out.println("name=\""+currentread.getname()+"\"");
                //*************************done namereadin*************************************
                alignread.mark(2);
                readchar=(char)alignread.read();
                while((Character.isWhitespace(readchar))||(readchar=='.')||(readchar=='*')){//if there was a newline or a space
                    alignread.mark(2);//save the current position
                    readchar=(char)alignread.read();
                    newline=true;
                }//if another newline repeat loop
                alignread.reset();//if not, start reading after the last mark;
                
                readchar=(char)alignread.read();
                Vector aaseqvector=new Vector();
                seqlength=0;
                while (((Character.isWhitespace(readchar))!=true)&&(readchar!='*')&&(readchar!='.')){
                    Character seqaa=new Character(readchar);
                    aaseqvector.addElement(seqaa);
                    readchar=(char)alignread.read();
                    seqlength+=1;
                }//end while
                currentread.savelength(seqlength);
                Character[] dummyseqarr=new Character[aaseqvector.size()];
                aaseqvector.copyInto(dummyseqarr);
                char[] seqchararray=new char[java.lang.reflect.Array.getLength(dummyseqarr)];
                for(int i=0;i<(java.lang.reflect.Array.getLength(dummyseqarr));i++){
                    seqchararray[i]=dummyseqarr[i].charValue();
                }//end for
                currentread.saveseq(seqchararray);
                seqvector.addElement(currentread);
        
            try{                                    //see if there is more to read
                boolean readable=alignread.ready();
                if(readable!=true){
                    readon=false;
                }
            }catch (IOException e){
                readon=false;
                System.err.println("EOF reached");
                e.printStackTrace();
            }
        
            }//end if newline==true
            alignread.mark(2);
            readchar=(char)alignread.read();
            while((Character.isWhitespace(readchar))||(readchar=='.')||(readchar=='*')||(readchar==':')){//if there was a newline or a space
                alignread.mark(2);//save the current position
                readchar=(char)alignread.read();
                newline=true;
            }//if another newline repeat loop
            alignread.reset();//if not, start reading after the last mark;
        
            try{                                    //see if there is more to read
                boolean readable=alignread.ready();
                if(readable!=true){
                    readon=false;
                }
            }catch (IOException e){
                readon=false;
                System.err.println("EOF reached");
                e.printStackTrace();
            }
            //System.out.println("can read sth");
        
            }//end while readon 
            aaseq[] seqarraytmp=new aaseq[seqvector.size()];
            seqvector.copyInto(seqarraytmp);
        
            alignread.close();
            //************************read all the stuff from the seqfile*******************
            //now I have to concatenate the diff seq parts from the seqarraytmp array
            Vector convertvector=new Vector();
            String startname=seqarraytmp[0].getname();
            String firstname=startname;
            int assignloop=0;
            for (int i=0;(i<java.lang.reflect.Array.getLength(seqarraytmp));i++){//move through the array one by one
                firstname=seqarraytmp[i].getname();
                if(firstname.equalsIgnoreCase(startname)){
                    assignloop+=1;}
                for(int j=i+1;(j<java.lang.reflect.Array.getLength(seqarraytmp))&&(assignloop<2);j++){
                    String secondname=seqarraytmp[j].getname();
                    //System.out.println("i="+i+" j="+j);
                    if(firstname.equalsIgnoreCase(secondname)==true){
                        int length1=seqarraytmp[i].getlength();
                        int length2=seqarraytmp[j].getlength();
                        int newlength=length1+length2;
                        char[] tmparray=new char[newlength];
                        for(int k=0;k<newlength;k++){
                            if(k<length1){
                                tmparray[k]=seqarraytmp[i].getseq(k);
                            }
                            if((k>=length1)&&(k<newlength)){
                                tmparray[k]=seqarraytmp[j].getseq(k-length1);
                            }
                        }//end for
                        seqarraytmp[i].saveseq(tmparray);
                        seqarraytmp[i].savelength(newlength);
                        
                    }//end if firstname==secondname
                    
                }//end for j
                if (assignloop<2){
                convertvector.addElement(seqarraytmp[i]);
                //System.out.println("name:"+seqarraytmp[i].getname()+" length:"+seqarraytmp[i].getlength());
                }//end if
            }//end for i
                
            
        seqarrayout=new aaseq[convertvector.size()]; 
        convertvector.copyInto(seqarrayout);
        //testseqvector(seqarrayout);
        return seqarrayout;
        
}//end clustalintread

    
}
