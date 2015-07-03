/*
 * aaseq.java
 *
 * Created on August 14, 2000, 11:39 AM
 */

//package rates;

/**
 *
 * @author  noname
 * @version 
 */
public class aaseq extends Object {

    public String getname(){
        return seqname;
    }
    public void setname(String name){
        seqname=name;
    }
    public void savename(String name){
        seqname = name;
    }
    
    public char getseq(int i){
        return seqseq[i];
    }
    public char[] getseq(){
        return seqseq;
    }
    
    public void saveseq(int i, char c){
        seqseq[i]=c;
    }
    public void saveseq(char c, int i){
        seqseq[i]=c;
    }
    public void setseq(char c,int i){
        seqseq[i]=c;
    }
    public void setseq(int i, char c){
        seqseq[i]=c;
    }
    public void setseq(char[] seq){
        seqseq=seq;
    }
    public void saveseq(char[] seq){
        seqseq = seq;
    }
    public void setseq(String inseq){
        seqseq=inseq.toCharArray();
    }
    
    public int getlength(){
        return java.lang.reflect.Array.getLength(seqseq);
    }
    public void savelength(int length){
        seqlength=length;
    }
    
    
    
    private String seqname = new String();
    private int seqlength=0;
    private char[] seqseq=new char[0];
}
 