/*
 * readhmmalign.java
 *
 * Created on March 6, 2002, 1:26 PM
 */
import java.io.*;
import java.lang.*;
/**
 *
 * @author  tancred
 * @version 
 */
public class readhmmalign {

    /** Creates new readhmmalign */
    public readhmmalign() {
    }

    public static String[] read(StringBuffer inbuf,String[] inarr){
        //read the hmmalign file  adn return a multiple alignment
        int noelem=java.lang.reflect.Array.getLength(inarr);
        StringBuffer[] tmparr=new StringBuffer[noelem];
        try{
            BufferedReader inread=new BufferedReader(new StringReader(inbuf.toString()));
            for(int i=0;i<(noelem-2);i+=3){
                tmparr[i]=new StringBuffer(inarr[i]);
                tmparr[i+1]=new StringBuffer(inarr[i+1]);
                tmparr[i+2]=new StringBuffer();
            }// end for i
            //init done, now read data from inbuf
            String currstr;
            boolean startseqs=false;
            int currpos=0;//current sequence
            while(((currstr=inread.readLine())!=null)){//while I can read something
                if((currstr.trim()).length()<1){// if this is a spacer line
                    continue;
                }
                if(startseqs==false){
                    if(currstr.indexOf("#=")>-1){
                        startseqs=true;
                    }
                    continue;
                }// end if startseqs
                if(currstr.indexOf("#=")>-1){//if I am at the end of a sequence block
                    currpos=0;
                    continue;
                }
                if(currstr.indexOf("//")>-1){
                    break;
                }
                String[] tmpsplit=(currstr.split("\\s+",0));//split on whitespace, no null splits
                if(java.lang.reflect.Array.getLength(tmpsplit)==1){//if there is only one elem
                    tmparr[currpos+2]=tmparr[currpos+2].append(tmpsplit[0]);
                }
                if(java.lang.reflect.Array.getLength(tmpsplit)>1){//hmmalign output is either "seqname seq" or only "seq"; check!
                    tmparr[currpos+2]=tmparr[currpos+2].append(tmpsplit[1]);
                }
                currpos+=3;
            }
        }catch (IOException e){
            System.err.println("IOError in reading hmmalignment");
            e.printStackTrace();
        }
        //now convert the Stringbuffers back to strings
        for(int i=0;i<(noelem-2);i+=3){
            inarr[i+2]=(tmparr[i+2].toString()).replace('.','-');
        }// end for i
        return inarr;
    }// end read
    
}//end class readhmmalign
