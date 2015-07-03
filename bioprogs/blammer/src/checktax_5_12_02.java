/*
 * checktax.java
 *
 * Created on February 14, 2002, 5:18 PM
 */
import java.lang.*;
import java.util.*;
import java.io.*;
/**
 *
 * @author  noname
 * @version
 */
public class checktax_5_12_02 {
    
    float maxsim;
    HashMap tax;
    HashMap seqnames=new HashMap();
    /** Creates new checktax */
    public checktax_5_12_02(HashMap tax, float maxsim) {
        this.maxsim=maxsim;
        this.tax=tax;
    }
    
    //--------------------------------------------------------------------------
    
    String[] docheck(String[] inarr,File extfile){
        //System.out.println("in docheck");
        seqnames.clear();
        int arrlength=java.lang.reflect.Array.getLength(inarr);
        String queryname=extfile.getName();
        queryname=queryname.substring(0,queryname.indexOf(".fas"));
        //testing input
        //System.out.println("--------------------INSEQSTAXCHECK---------------------");
        //System.out.println("queryname="+queryname);
        //for(int i=0;i<java.lang.reflect.Array.getLength(inarr);i+=3){
        //    System.out.println(inarr[i]);
        //}// end for i
        //try{
        //    String tmptest=(new BufferedReader(new InputStreamReader(System.in))).readLine();
        //}catch (IOException e){}
        //end testing input
        
        try{
            BufferedReader reader=new BufferedReader(new FileReader(extfile));
            String inline;
            int pos;
            int begin;
            String info;
            while((inline=reader.readLine())!=null){//read the extfile
                if(inline.startsWith(">")){
                    pos=0;
                    boolean foundnext=true;
                    while (foundnext){//add all gi&gt numbers (keys) with the current line as value to hash
                        foundnext=false;
                        if((begin=inline.indexOf("gi|",pos))>-1){
                            int end;
                            if((end=inline.indexOf("|",begin+3))>-1){
                                info=inline.substring(begin+3,end);
                                pos=end;
                                foundnext=true;
                                if(seqnames.containsKey(info)==false){
                                    seqnames.put(info,inline);
                                }
                            }// end if |
                        }// end if gi|
                        if((begin=inline.indexOf("gt|",pos))>-1){
                            int end;
                            if((end=inline.indexOf("|",begin+3))>-1){
                                info="t"+inline.substring(begin+3,end);
                                pos=end;
                                foundnext=true;
                                if(seqnames.containsKey(info)==false){
                                    seqnames.put(info,inline);
                                }
                            }// end if |
                        }// end if gt|
                    }// end while foundnext
                }// end if startswith
            }// end while inline!=null
            reader.close();
        }catch (IOException e){
            System.err.println("IOError reading from "+extfile.getName());
            e.printStackTrace();
        }
        //now all the info seqnames + their fasta nameline should be in seqnames hash
        for(int i=0;i<arrlength-2;i+=3){//loop through the inarr names and get rid of prefixes (i.e. 1_, 2_ etc
            //elems: 0=name,1=query,2=seq
            String currname=inarr[i];
            if(currname.indexOf("_")>-1){// if this name has a prefix
                currname=currname.substring(inarr[i].indexOf("_")+1);
            }
            if(seqnames.containsKey(currname)){
                inarr[i]+=gettaxname((String)seqnames.get(currname));
            }
            if(seqnames.containsKey(currname)==false){
                inarr[i]+=" [unknown taxonomy]";
            }
            //System.out.println("currname="+inarr[i]);
        }// end for i looping through inarr 3 at a time
        //now all the id's should have a species assigned, next=check for maxsim in each species
        //System.out.println("--------------------INSEQSTAXTEMPCHECK---------------------");
        //System.out.println("queryname="+queryname);
        //for(int i=0;i<java.lang.reflect.Array.getLength(inarr);i+=3){
        //    System.out.println(inarr[i]);
        //}// end for i
        //try{
        //    String tmptest=(new BufferedReader(new InputStreamReader(System.in))).readLine();
        //}catch (IOException e){}
        //end testing input
        
        if(maxsim<1){//if I want to check for maximum similarity
            Vector tmpvec=new Vector();
            boolean isquery=false;
            for(int i=0;i<arrlength-2;i+=3){//only look at every 3rd element; 2nd element is the query seq
                //if two species are the same and their sequences are more similar than maxsim --> remove the shorter?; check that you don't remove the query seq
                isquery=false;
                String spec1=inarr[i].substring(inarr[i].indexOf("["));//get whatever is in brackets
                if(inarr[i].indexOf(queryname)>-1){//if this is the query
                    isquery=true;
                }
                boolean hassame=false;
                boolean doaddtovec=true;
                boolean donofurther=false;
                boolean isquery2=false;
                for(int j=0;((j<tmpvec.size()-2)&&(donofurther==false));j+=3){
                    String spec2=((String)tmpvec.elementAt(j)).substring(((String)tmpvec.elementAt(j)).indexOf("["));//get whatever is in brackets
                    isquery2=false;
                    if(((String)tmpvec.elementAt(j)).indexOf(queryname)>-1){
                        isquery2=true;
                    }
                    float currsim;
                    //System.out.println("comparing "+spec2+" and "+spec1);
                    if(spec2.equalsIgnoreCase(spec1)){//if this is the same species
                        hassame=true;
                        //System.out.println(spec2+" same "+spec1);
                        currsim=getsim((String)tmpvec.elementAt(j+2),inarr[i+2]);
                        //if(currsim<=maxsim){//if similarity is not a problem--> enable add to vector
                        //    tmpvec.addElement(inarr[i]);
                        //    tmpvec.addElement(inarr[i+1]);
                        //    tmpvec.addElement(inarr[i+2]);
                        //}
                        if((currsim>maxsim)&&(isquery==false)&&(isquery2==false)){//if it is a problem and neither of the sequences is the query
                            doaddtovec=false;
                            //get the number of non-gaps in each seq
                            int nongi=getnogaps(inarr[i+2]);
                            int nongj=getnogaps((String)tmpvec.elementAt(j));
                            if(nongj<nongi){// if inarr has less gaps, replace the tmpvec element
                                //System.out.println("replacing "+((String)tmpvec.elementAt(j))+" with "+inarr[i]);
                                tmpvec.setElementAt(inarr[i],j);
                                tmpvec.setElementAt(inarr[i+1],j+1);
                                tmpvec.setElementAt(inarr[i+2],j+2);
                                donofurther=true;
                            }// end if tmpvec is smaller
                        }// end if currsim>maxsim
                    }// end if both spec are equal
                }// end for tmpvec j
                if((hassame)&&(doaddtovec)){
                    //System.out.println("adding to vec same"+inarr[i]);
                    tmpvec.addElement(inarr[i]);
                    tmpvec.addElement(inarr[i+1]);
                    tmpvec.addElement(inarr[i+2]);
                }
                if(hassame==false){
                    //System.out.println("adding to vec diff"+inarr[i]);
                    tmpvec.addElement(inarr[i]);
                    tmpvec.addElement(inarr[i+1]);
                    tmpvec.addElement(inarr[i+2]);
                }
            }// end for inarr i
            inarr=new String[tmpvec.size()];
            tmpvec.copyInto(inarr);
        }// end if maxsim<1
        //System.out.println();
        //System.out.println("--------------------OUTSEQSTAXCHECK---------------------");
        //System.out.println();
        //for(int i=0;i<java.lang.reflect.Array.getLength(inarr);i+=3){
        //    System.out.println(inarr[i]);
        //}// end for i
        //try{
        //    String tmptest=(new BufferedReader(new InputStreamReader(System.in))).readLine();
        //}catch (IOException e){}
        return inarr;
    }// end docheck
    
    //--------------------------------------------------------------------------
    
    String[] dochecktaxid(String[] inarr,File extfile,taxid mytaxid,HashMap idtax){
        //get taxonomic data from the input names using the taxid files
        //apart from that the same thing as docheck
        //System.out.println("in docheck");
        seqnames.clear();
        int arrlength=java.lang.reflect.Array.getLength(inarr);
        String queryname=extfile.getName();
        queryname=queryname.substring(0,queryname.indexOf(".fas"));
        //testing input
        //System.out.println("--------------------INSEQSTAXCHECK---------------------");
        //System.out.println("queryname="+queryname);
        //for(int i=0;i<java.lang.reflect.Array.getLength(inarr);i+=3){
        //    System.out.println(inarr[i]);
        //}// end for i
        //try{
        //    String tmptest=(new BufferedReader(new InputStreamReader(System.in))).readLine();
        //}catch (IOException e){}
        //end testing input
        
        try{
            BufferedReader reader=new BufferedReader(new FileReader(extfile));
            String inline;
            int pos;
            int begin;
            String info;
            while((inline=reader.readLine())!=null){//read the extfile
                if(inline.startsWith(">")){
                    pos=0;
                    boolean foundnext=true;
                    while (foundnext){//add all gi&gt numbers (keys) with the current line as value to hash
                        foundnext=false;
                        if((begin=inline.indexOf("gi|",pos))>-1){
                            int end;
                            if((end=inline.indexOf("|",begin+3))>-1){
                                info=inline.substring(begin+3,end);
                                pos=end;
                                foundnext=true;
                                if(seqnames.containsKey(info)==false){
                                    seqnames.put(info,inline);
                                }
                            }// end if |
                        }// end if gi|
                        if((begin=inline.indexOf("gt|",pos))>-1){
                            int end;
                            if((end=inline.indexOf("|",begin+3))>-1){
                                info="t"+inline.substring(begin+3,end);
                                pos=end;
                                foundnext=true;
                                if(seqnames.containsKey(info)==false){
                                    seqnames.put(info,inline);
                                }
                            }// end if |
                        }// end if gt|
                    }// end while foundnext
                }// end if startswith
            }// end while inline!=null
            reader.close();
        }catch (IOException e){
            System.err.println("IOError reading from "+extfile.getName());
            e.printStackTrace();
        }
        //now all the info seqnames + their fasta nameline should be in seqnames hash
        for(int i=0;i<arrlength-2;i+=3){//loop through the inarr names and get rid of prefixes (i.e. 1_, 2_ etc
            String currname=inarr[i];
            if(currname.indexOf("_")>-1){// if this name has a prefix
                currname=currname.substring(inarr[i].indexOf("_")+1);
            }
            if(seqnames.containsKey(currname)){
                if(currname.startsWith("gi|")){//if this is a gi number
                    try{
                        String ginumstr=currname.substring(4,currname.indexOf("|",4));
                        System.out.println("ginum="+ginumstr);
                        
                        int ginum=Integer.parseInt(ginumstr);
                        ginum=mytaxid.gettaxid(ginum);//assign the taxonomic id number to ginum
                        String tmpstr=String.valueOf(ginum);
                        if(ginum>-1){//if gettaxid returned a taxonomy number
                            if(idtax.containsKey(tmpstr)){
                                outarr[1]=(String)idtax.get(tmpstr);//get the name for this id and put it in outarr[1]
                                System.out.println("got "+outarr[1]+" for "+tmpstr);
                                specdone=true;
                            }
                        }
                    }catch (NumberFormatException e){
                        System.err.println("unable to parse gi number from '"+currname+"'");
                        //specdone=false;
                    }
                }else{//end if is gi number
                    inarr[i]+=gettaxname((String)seqnames.get(currname));
                }
            }else{
                //System.out.println("------------NOT seqnames.containskey "+currname);
                /*old stuff
                 if(currname.startsWith("t")==false){//if I have a gi number I can use the taxid files
                    //steps are: find if this gi number has a taxonomyc designation associated with it
                    //next get the taxonomy number
                    //get the taxonomy string for the number
                    int taxnum=mytaxid.gettaxid(currname);
                    if(taxnum>0){//if I did get a valid taxid
                        if(idtax.containsKey(String.valueOf(taxnum))){//if I have this taxnumber
                            inarr[i]+=" ["+(String)idtax.get(String.valueOf(taxnum))+"]";
                        }else{
                            inarr[i]+=" [unknown taxonomy]";
                        }
                    }else{
                        inarr[i]+=" [unknown taxonomy]";
                    }
                }*/
                if(currname.startsWith("gi|")){//if this is a gi number
                    try{
                        String ginumstr=currname.substring(3,currname.indexOf("|",3));
                        System.out.println("ginum=-"+ginumstr+"-");
                        
                        int ginum=Integer.parseInt(ginumstr);
                        ginum=mytaxid.gettaxid(ginum);//assign the taxonomic id number to ginum
                        /*String tmpstr=String.valueOf(ginum);
                        if(ginum>-1){//if gettaxid returned a taxonomy number
                            if(idtax.containsKey(tmpstr)){
                                outarr[1]=(String)idtax.get(tmpstr);//get the name for this id and put it in outarr[1]
                                System.out.println("got "+outarr[1]+" for "+tmpstr);
                                specdone=true;
                            }
                        }
                         */
                    }catch (NumberFormatException e){
                        System.err.println("unable to parse gi (checktax) number from '"+currname+"'");
                        //specdone=false;
                    }
                }else{
                    inarr[i]+=" [unknown taxonomy]";
                }
            }
            //if(seqnames.containsKey(currname)==false){
            //    inarr[i]+=" [unknown taxonomy]";
            //}
            //System.out.println("currname="+inarr[i]);
        }// end for i looping through inarr 3 at a time
        //now all the id's should have a species assigned, next=check for maxsim in each species
        //System.out.println("--------------------INSEQSTAXTEMPCHECK---------------------");
        //System.out.println("queryname="+queryname);
        //for(int i=0;i<java.lang.reflect.Array.getLength(inarr);i+=3){
        //    System.out.println(inarr[i]);
        //}// end for i
        //try{
        //    String tmptest=(new BufferedReader(new InputStreamReader(System.in))).readLine();
        //}catch (IOException e){}
        //end testing input
        
        if(maxsim<1){//if I want to check for maximum similarity
            Vector tmpvec=new Vector();
            boolean isquery=false;
            for(int i=0;i<arrlength-2;i+=3){//only look at every 3rd element; 2nd element is the query seq
                //if two species are the same and their sequences are more similar than maxsim --> remove the shorter?; check that you don't remove the query seq
                isquery=false;
                String spec1=inarr[i].substring(inarr[i].indexOf("["));//get whatever is in brackets
                if(inarr[i].indexOf(queryname)>-1){//if this is the query
                    isquery=true;
                }
                boolean hassame=false;
                boolean doaddtovec=true;
                boolean donofurther=false;
                boolean isquery2=false;
                for(int j=0;((j<tmpvec.size()-2)&&(donofurther==false));j+=3){
                    String spec2=((String)tmpvec.elementAt(j)).substring(((String)tmpvec.elementAt(j)).indexOf("["));//get whatever is in brackets
                    isquery2=false;
                    if(((String)tmpvec.elementAt(j)).indexOf(queryname)>-1){
                        isquery2=true;
                    }
                    float currsim;
                    //System.out.println("comparing "+spec2+" and "+spec1);
                    if(spec2.equalsIgnoreCase(spec1)){//if this is the same species
                        hassame=true;
                        //System.out.println(spec2+" same "+spec1);
                        currsim=getsim((String)tmpvec.elementAt(j+2),inarr[i+2]);
                        //if(currsim<=maxsim){//if similarity is not a problem--> enable add to vector
                        //    tmpvec.addElement(inarr[i]);
                        //    tmpvec.addElement(inarr[i+1]);
                        //    tmpvec.addElement(inarr[i+2]);
                        //}
                        if((currsim>maxsim)&&(isquery==false)&&(isquery2==false)){//if it is a problem and neither of the sequences is the query
                            doaddtovec=false;
                            //get the number of non-gaps in each seq
                            int nongi=getnogaps(inarr[i+2]);
                            int nongj=getnogaps((String)tmpvec.elementAt(j));
                            if(nongj<nongi){// if inarr has less gaps, replace the tmpvec element
                                //System.out.println("replacing "+((String)tmpvec.elementAt(j))+" with "+inarr[i]);
                                tmpvec.setElementAt(inarr[i],j);
                                tmpvec.setElementAt(inarr[i+1],j+1);
                                tmpvec.setElementAt(inarr[i+2],j+2);
                                donofurther=true;
                            }// end if tmpvec is smaller
                        }// end if currsim>maxsim
                    }// end if both spec are equal
                }// end for tmpvec j
                if((hassame)&&(doaddtovec)){
                    //System.out.println("adding to vec same"+inarr[i]);
                    tmpvec.addElement(inarr[i]);
                    tmpvec.addElement(inarr[i+1]);
                    tmpvec.addElement(inarr[i+2]);
                }
                if(hassame==false){
                    //System.out.println("adding to vec diff"+inarr[i]);
                    tmpvec.addElement(inarr[i]);
                    tmpvec.addElement(inarr[i+1]);
                    tmpvec.addElement(inarr[i+2]);
                }
            }// end for inarr i
            inarr=new String[tmpvec.size()];
            tmpvec.copyInto(inarr);
        }// end if maxsim<1
        //System.out.println();
        //System.out.println("--------------------OUTSEQSTAXCHECK---------------------");
        //System.out.println();
        //for(int i=0;i<java.lang.reflect.Array.getLength(inarr);i+=3){
        //    System.out.println(inarr[i]);
        //}// end for i
        //try{
        //    String tmptest=(new BufferedReader(new InputStreamReader(System.in))).readLine();
        //}catch (IOException e){}
        return inarr;
    }// end dochecktaxid
    
    //--------------------------------------------------------------------------
    
    int getnogaps(String instr){
        int length=instr.length();
        int nogaps=0;
        char c;
        for(int i=0;i<length;i++){
            c=instr.charAt(i);
            if((c=='-')==false){
                nogaps+=1;
            }
        }// end for i
        return nogaps;
    }//end getnogaps
    
    //--------------------------------------------------------------------------
    
    float getsim(String seq1,String seq2){
        int l1=seq1.length();
        int l2=seq2.length();
        int ident=0;
        int nongaps=0;
        for(int i=0;i<l1;i++){
            char c1=seq1.charAt(i);
            if((c1=='-')==false){
                char c2=seq2.charAt(i);
                if((c2=='-')==false){
                    nongaps+=1;
                    if(c2==c1){
                        ident+=1;
                    }
                }// end if c2!=-
            }// end if c != -
        }// end for i
        float sim=((float)ident)/((float)nongaps);
        return sim;
    }// end getsim
    
    //--------------------------------------------------------------------------
    
    String gettaxname(String inline){
        boolean foundnext=true;
        int pos=0;
        int begin;
        int end;
        while (foundnext){
            foundnext=false;
            if((begin=inline.indexOf("[",pos))>-1){
                if((end=inline.indexOf("]",begin))>-1){
                    foundnext=true;
                    pos=end;
                    String currtest=inline.substring(begin+1,end);
                    if(tax.containsKey(currtest)){
                        return " ["+currtest+"]";
                    }
                }// end if ]
            }// end if [
        }// end while foundnext
        return " [unknown taxonomy]";
    }// end gettaxname
    
}// end checktax
