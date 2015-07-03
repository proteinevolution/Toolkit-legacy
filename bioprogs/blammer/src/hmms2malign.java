/*
 * hmms2malign.java
 *
 * Created on February 8, 2002, 12:48 PM
 */
import java.io.*;
import java.lang.*;
import java.util.*;
/**
 *
 * @author  noname
 * @version 
 */
public class hmms2malign {

    //should read the sequences from hmmsearch adn return them in a String[]
    
    /** Creates new hmms2malign */
    public hmms2malign() {
    }

    static String[] malign(BufferedReader inread){
        //this should read from bufferedreader and return all hit sequences pieced back together
        //NOT a multiple alignment!!!
        Vector tmpvec=new Vector();
        String currline="";
        hmmpair currhit=new hmmpair();
        try{
            boolean nextisquery=false;
            boolean endquery=true;
            READLINE:while((currline=inread.readLine())!=null){
                if((currline.trim()).equals("")){
                    continue;
                }
                if(currline.indexOf(": domain ")>-1){
                    int domposstart=currline.indexOf(": domain ")+9;//put pos at end of this string
                    int domposend=currline.indexOf(" of ",domposstart);//find end of the number following
                    String currprefix="";
                    if((domposstart>-1)&&(domposend>-1)){
                        currprefix=currline.substring(domposstart,domposend);
                    }
                    if(currhit.name.equals("")==false){//if I have a hit in memory
                        tmpvec.addElement(currhit);
                    }
                    currhit=new hmmpair();
                    int end=currline.indexOf(": domain ");
                    currhit.orgname=currline.substring(0,end);
                    if(currprefix.equals("1")==false){// if this is sth else than the first domain
                        currhit.orgname=currprefix+"_"+currhit.orgname;
                    }
                    if(end>10){//only the first 10 chars are used later on in the hmmsearch file
                        end=10;
                    }
                    currhit.name=(currline.substring(0,end)).trim();
                    nextisquery=true;
                    continue READLINE;
                }// end if ": domain "
                if(currhit.name.equals("")){
                    nextisquery=false;
                    continue READLINE;
                }
                if(currline.indexOf(currhit.name)>-1){//if currline has currname
                    String[] tmparr=currline.split("\\s+",0);// is name,start,seq,end
                    if(tmparr[2].equals("-")==false){
                        currhit.seq+=tmparr[3];
                    }
                    nextisquery=true;
                    continue READLINE;
                }// end if currline has currname
                if(nextisquery){
                    currline=currline.trim();
                    if(endquery==false){
                        currhit.hmm+=currline;
                        if(currhit.hmm.endsWith("<-*")){
                            endquery=true;
                            currhit.hmm=currhit.hmm.substring(currhit.hmm.indexOf("*->")+3,currhit.hmm.indexOf("<-*"));
                        }
                        nextisquery=false;
                        continue READLINE;
                    }// end if endquery==false
                    if(endquery){
                        if(currline.startsWith("*->")){
                            endquery=false;
                            currhit.hmm=currline.trim();
                            nextisquery=false;
                            continue READLINE;
                        }
                    }// end if endquery
                }// end if nextisquery
            }// end while inread!=null READLINE
            tmpvec.addElement(currhit);
            tmpvec=removesames(tmpvec);
            String[] out=convertmainvec(tmpvec);//convert tmpvec into and array of Strings
            //each hmm-domain hit is returned as a separate sequence
            return out;
        }catch (IOException e){
            System.err.println("IOError reading hmmsearch outfile");
            e.printStackTrace();
            return new String[0];
        }
    }// end malign
    
    //--------------------------------------------------------------------------------------------------------
    
    static String[] convertmainvec(Vector invec){
        //take the input vector and convert all elements to separate ungapped fasta sequences
        //the multiple alignment is later on restored via hmmalign
        int vecsize=invec.size();
        int maxseqlength=0;
        String[] out=new String[vecsize*3];
        for(int i=0;i<vecsize;i++){//do the following for each of the hmm hits(in invec)
            hmmpair curr=(hmmpair) invec.elementAt(i);
            out[(i*3)+2]=curr.seq.replaceAll("[\\.-]","");//remove all gaps
            out[i*3]=curr.orgname;
            out[(i*3)+1]=new String();//spacer
        }
        return out;
    }// end convertmainvec
    
    //--------------------------------------------------------------------------------------------------------
    
    static String[] removeallallgaps(String[] inarr){
        //check to see if the sequences (hits) have position with all gaps
        int noseqs=java.lang.reflect.Array.getLength(inarr);
        StringBuffer[] tmparr=new StringBuffer[noseqs];
        for(int i=0;i<(noseqs-2);i+=3){
            tmparr[i+1]=new StringBuffer();
            tmparr[i+2]=new StringBuffer();
        }// end for i
        //init done;
        int seqlength=inarr[1].length();//all sequences should have the same length!
        int countgap=0;
        LOOPSEQ:for(int i=0;i<seqlength;i++){
            boolean allgaps=true;
            //if(inarr[1].charAt(i)=='-'){
                //System.out.print("ingap1 "+countgap+ "'-");
                countgap+=1;
                //allgaps=true;
                for(int j=0;j<(noseqs-2);j+=3){
                    //System.out.print("'"+inarr[j+2].charAt(i));
                    if((inarr[j+2].charAt(i)!='-')){
                        allgaps=false;
                        break;
                    }
                }// end for j
                //System.out.println();
            //}//end if inarr[1].charAt(i)!=-
            if(allgaps==false){
                for(int j=0;j<(noseqs-2);j+=3){
                    tmparr[j+1].append(inarr[j+1].charAt(i));
                    tmparr[j+2].append(inarr[j+2].charAt(i));
                }
                //continue;
            }
            //System.out.println("removed allgap at "+i);
        }// end for i
        for(int i=0;i<(noseqs-2);i+=3){
            inarr[i+1]=tmparr[i+1].toString();
            inarr[i+2]=tmparr[i+2].toString();
        }// end for i
        return inarr;
    }// end removeallallgaps
    
    //--------------------------------------------------------------------------------------------------------
    
    static Vector removesames(Vector invec){
        //renames multiple occurances of a sequence with name, to 1_name, 2_name...
        hmmpair[] tmparr=new hmmpair[invec.size()];
        invec.copyInto(tmparr);
        //invec=new Vector();
        invec.clear();
        for(int i=0;i<java.lang.reflect.Array.getLength(tmparr);i++){
            int counter=0;
            String currname=tmparr[i].name;
            for(int j=0;j<invec.size();j++){
                if(currname.equals(((hmmpair)invec.elementAt(j)).name)){
                    counter+=1;
                    currname=counter+"_"+tmparr[i].name;
                }
            }
            tmparr[i].name=currname;
            invec.addElement(tmparr[i]);
        }
        return invec;
    }
    
    //--------------------------------------------------------------------------------------------------------
    
   static class hmmpair{
        
        void hmmpair(){
            orgname="";
            name="";
            seq="";
            hmm="";
        }
        
        String orgname="";
        String name="";
        String seq="";
        String hmm="";
        
    }// end class hmmpair
}// end mhhs2malign
