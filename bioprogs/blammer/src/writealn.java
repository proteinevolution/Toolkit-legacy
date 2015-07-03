/*
 * writealn.java
 *
 * Created on December 2, 2002, 3:14 PM
 */
import java.io.*;
/**
 *
 * @author  tancred
 */
public class writealn {
    
    /** Creates a new instance of writealn */
    public writealn() {
    }
    //this should hold methods that take aaseq objects and write them to file in different formats
    
    static void clustal(aaseq[] outseqs, PrintWriter outfile){
        //write the data in outseqs to outfile in clustal format
        int blocksize=100;
        int currpos=0;
        int maxnamelength=30;
        outfile.println("CLUSTAL");
        outfile.println();
        int seqs=java.lang.reflect.Array.getLength(outseqs);
        int seqlength=0;
        if(seqs>0){
            seqlength=outseqs[0].getlength();
        }else{
            System.err.println("Error in writealn.clustal, nothing to write");
            return;
        }
        StringBuffer seqblock=new StringBuffer();
        int namelength=0;
        for(int i=0;i<seqs;i++){
            if(outseqs[i].getname().length()>namelength){
                namelength=outseqs[i].getname().length();
            }
        }
        if(namelength>maxnamelength){
            namelength=maxnamelength;
        }
        for(currpos=0;currpos<seqlength;currpos+=blocksize){
            for(int i=0;i<seqs;i++){
                //see if the name is longer than maxnamelength chars. If so, truncate
                if(outseqs[i].getname().length()>maxnamelength){
                    outfile.print(outseqs[i].getname().substring(0,maxnamelength)+"  ");
                }else{
                    int spacers=namelength-outseqs[i].getname().length();
                    StringBuffer spacer=new StringBuffer();
                    for(int k=0;k<spacers;k++){
                        spacer.append(" ");
                    }
                    outfile.print(outseqs[i].getname()+spacer.toString()+"  ");
                }
                //now print the seq
                seqblock.setLength(0);
                if((currpos+blocksize)<seqlength){
                    seqblock.append(outseqs[i].getseq(),currpos,blocksize);
                }else{
                    seqblock.append(outseqs[i].getseq(),currpos,(seqlength-currpos));
                }
                outfile.println(seqblock.toString());
            }
            outfile.println();
            outfile.println();
        }
        return;
    }// end clustal
    
    
}// end class
