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
public class hmms2malign_5_12_02 {

    /** Creates new hmms2malign */
    public hmms2malign_5_12_02() {
    }

    static String[] malign(BufferedReader inread,String basename){// basename is the gi id of the sequence I searched with
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
                    if(currhit.name.equals("")==false){
                        tmpvec.addElement(currhit);
                        //System.out.println(currhit.name+" "+currhit.seq+" +++++ "+currhit.hmm);
                    }
                    currhit=new hmmpair();
                    int end=currline.indexOf(": domain ");
                    currhit.orgname=currline.substring(0,end);
                    if(currprefix.equals("1")==false){// if this is sth else than the first domain
                        currhit.orgname=currprefix+"_"+currhit.orgname;
                    }
                    if(end>10){//only the first 10 chars are used later on in the file
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
            //System.out.println(currhit.name+" "+currhit.seq+" +++++ "+currhit.hmm);
            tmpvec=removesames(tmpvec);
            String[] out=convertmainvec(tmpvec);
            //System.out.println("testing out in hmms2malign");
            //for(int i=0;i<java.lang.reflect.Array.getLength(out);i+=3){
            //    System.out.println(i+"-----"+out[i]);
            //    System.out.println("    "+out[i+2]);//i+2 is the sequence
            //}// end for out
            //now look through out for identical sequences, remove those from the same species above maxsim similarity;
            //check to see that the search sequence is included in out
            return out;
        }catch (IOException e){
            System.err.println("IOError reading hmmsearch outfile");
            e.printStackTrace();
            return new String[0];
        }
    }// end malign
    
    //--------------------------------------------------------------------------------------------------------
    
    static String[] convertmainvec(Vector invec){
        //System.out.println("in convertmainvec");
        //this takes a vector with pairwise hmm hits and converts it to a multiple alignment of the sequence parts
        int vecsize=invec.size();
        int maxseqlength=0;
        String[][] seqarr=new String[vecsize][2];// holds query in 0 and seq in 1
        String[] namesarr=new String[vecsize];//holds hitnames+queryname;
        int[][] startarr=new int[vecsize][2];//[0]=hmm [1]=seq
        for(int i=0;i<vecsize;i++){
            hmmpair curr=(hmmpair) invec.elementAt(i);
            seqarr[i][0]=curr.hmm.replace('.','-');
            seqarr[i][1]=curr.seq.replace('.','-');
            for(int j=0;(j<seqarr[i][1].length())&&(seqarr[i][1].charAt(j)=='-');j++){
                startarr[i][1]=j;
            }
            for(int j=0;(j<seqarr[i][0].length())&&(seqarr[i][0].charAt(j)=='-');j++){
                startarr[i][0]=j;
            }
            namesarr[i]=curr.orgname;
            //System.out.println("-"+curr.orgname+"-");
        }
        // now I have arrays with:  pairs of query&hit sequences
        //                          info about where the start of each hmm and sequence is
        //                          the sequence names
        for(int i=0;i<vecsize;i++){
            //get maximum sequence length
            if(seqarr[i][0].length()>maxseqlength){
                maxseqlength=seqarr[i][0].length();
            }
        }// end for i
        //try seq by seq, looping through pos
        int addmaxdash=0;
        for(int pos=0;pos<(maxseqlength+addmaxdash);pos++){
            //loop through the positions
            for(int i=0;i<vecsize;i++){
                // loop through the sequences
                if((pos<seqarr[i][0].length())&&(pos>startarr[i][0])&&(pos>startarr[i][1])&&(seqarr[i][0].charAt(pos)=='-')){
                    addmaxdash+=1;
                    //if I have a gap in this seq
                    for(int j=0;j<vecsize;j++){
                        //loop through the other sequences
                        if((pos<seqarr[j][0].length())&&(seqarr[j][0].charAt(pos)!='-')&&(seqarr[j][0].charAt(pos)!='_')){
                            //if the other seq doesn't have a gap at this position
                            seqarr[j][0]=seqarr[j][0].substring(0,pos)+"_"+seqarr[j][0].substring(pos);
                            if(pos<seqarr[j][1].length()){
                                seqarr[j][1]=seqarr[j][1].substring(0,pos)+"_"+seqarr[j][1].substring(pos);
                            }
                        }
                    }// end for j
                }// end if - && beginseq
            }// end for pos
        }// end for i
        // now fill up all sequences with dashes until they are the same length as maxseqlength
        for(int i=0;i<vecsize;i++){
            //int tmp=seqarr[i][0].length();
            //if(tmp>maxseqlength){
            //    maxseqlength=tmp;
            //}
            int tmp=seqarr[i][1].length();
            if(tmp>maxseqlength){
                maxseqlength=tmp;
            }
        }
        for(int i=0;i<vecsize;i++){
            int fillup=maxseqlength-seqarr[i][1].length();
            StringBuffer fillstr=new StringBuffer();
            while (fillup>0){
                fillup-=1;
                fillstr=fillstr.append("-");
            }
            //seqarr[i][0]=seqarr[i][0]+fillstr;
            seqarr[i][1]=seqarr[i][1]+fillstr.toString();
        }// end for i
        //System.out.println("-------------done fillup-------------"+maxseqlength);
        String[] out=new String[vecsize*3];
        for (int i=0;i<vecsize;i++){
            out[i*3]=namesarr[i];
            out[(i*3)+1]=seqarr[i][0].replace('_','-');
            out[(i*3)+2]=seqarr[i][1].replace('_','-');
        }
        //out=removeallallgaps(out);
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
