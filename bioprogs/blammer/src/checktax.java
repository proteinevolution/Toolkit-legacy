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
public class checktax {
    
    float maxsim;
    int taxlevel;
    HashMap tax;
    HashMap seqnames=new HashMap();
    /** Creates new checktax */
    public checktax(HashMap tax, float maxsim, int taxlevel) {
        this.maxsim=maxsim;
        this.tax=tax;
        this.taxlevel=taxlevel;
    }
    
    //--------------------------------------------------------------------------
    
    String[] docheck(String[] inarr,File extfile){
        //get the taxonomic designations from the *.fas file for all names in inarr
        seqnames.clear();
        int arrlength=java.lang.reflect.Array.getLength(inarr);
        String queryname=extfile.getName();
        queryname=queryname.substring(0,queryname.indexOf(".fas"));
        try{
            BufferedReader reader=new BufferedReader(new FileReader(extfile));
            String inline;
            int pos;
            int begin;
            int tmpint;
            String info;
            String[] tmparr;
            while((inline=reader.readLine())!=null){//read the extfile and put all possible names into a hash
                if(inline.startsWith(">")){
                    inline=inline.substring(1).trim();//remove the ">"
                    tmparr=inline.split("\u0001");//split on the ncbi gi spacers
                    for(int i=0;i<java.lang.reflect.Array.getLength(tmparr);i++){//get the name and assign the infoline in a hash
                        tmpint=tmparr[i].indexOf(" ");
                        if(tmpint>0){
                            info=tmparr[i].substring(0,tmpint);//get the name up to the first whitespace
                        }else{
                            info=tmparr[i];
                        }
                        seqnames.put(info,inline);
                    }// end for i
                }// end if startswith
            }// end while inline!=null
            reader.close();
        }catch (IOException e){
            System.err.println("IOError reading from "+extfile.getName());
            e.printStackTrace();
        }
        //now all the info seqnames + their fasta nameline should be in seqnames hash
        int underscorepos;
        int pipepos;
        for(int i=0;i<arrlength;i+=3){//loop through the inarr names and get rid of prefixes (i.e. 1_, 2_ etc
            //elems: 0=name,1=query,2=seq
            String currname=inarr[i];
            underscorepos=currname.indexOf("_");
            pipepos=currname.indexOf("|");
            if((pipepos<0)||(pipepos>underscorepos)){
                if(underscorepos>-1){// if this name has a prefix
                    currname=currname.substring(underscorepos+1);//get the seqname without the prefix
                }
            }
            if(seqnames.containsKey(currname)){
                inarr[i]+=gettaxname((String)seqnames.get(currname));
            }else{
                //if(seqnames.containsKey(currname)==false){
                inarr[i]+=" [unknown taxonomy]";
            }
        }// end for i looping through inarr 3 at a time
        //now all the id's should have a species assigned, next=check for maxsim in each species
        String[] tmpstrarr;//temporary string array
        String tmpstr;
        int tmpint;
        if((maxsim<1)&&(maxsim>0)){//if I want to check for maximum similarity
            Vector tmpvec=new Vector();
            boolean isquery=false;
            for(int i=0;i<arrlength;i+=3){//only look at every 3rd element; 2nd element is the query seq
                //if two species are the same and their sequences are more similar than maxsim --> remove the shorter?; check that you don't remove the query seq
                isquery=false;
                String spec1=inarr[i].substring(inarr[i].indexOf("["));//get whatever is in brackets
                if(inarr[i].indexOf(queryname)>-1){//if this is the query
                    isquery=true;
                }
                if(taxlevel<3){
                    tmpstrarr=spec1.split("\\s+");//split on spaces
                    tmpstr="";
                    tmpint=java.lang.reflect.Array.getLength(tmpstrarr);
                    for(int j=0;j<taxlevel;j++){
                        if(tmpint>j){
                            tmpstr+=tmpstrarr[j]+" ";
                        }
                    }//end for j
                    spec1=tmpstr.trim();
                }
                boolean hassame=false;
                boolean doaddtovec=true;
                boolean donofurther=false;
                boolean isquery2=false;
                if(taxlevel>=3){
                    for(int j=0;((j<tmpvec.size()-2)&&(donofurther==false));j+=3){
                        String spec2=((String)tmpvec.elementAt(j)).substring(((String)tmpvec.elementAt(j)).indexOf("["));//get whatever is in brackets
                        isquery2=false;
                        if(((String)tmpvec.elementAt(j)).indexOf(queryname)>-1){
                            isquery2=true;
                        }
                        float currsim;
                        if(spec2.equalsIgnoreCase(spec1)){//if this is the same species
                            hassame=true;
                            currsim=getsim((String)tmpvec.elementAt(j+2),inarr[i+2]);
                            if((currsim>maxsim)){
                                if((isquery==false)&&(isquery2==false)){//if it is a problem and neither of the sequences is the query
                                    doaddtovec=false;
                                    //get the number of non-gaps in each seq
                                    int nongi=getnogaps(inarr[i+2]);
                                    int nongj=getnogaps((String)tmpvec.elementAt(j));
                                    if(nongj<nongi){// if inarr has less gaps, replace the tmpvec element
                                        tmpvec.setElementAt(inarr[i],j);
                                        tmpvec.setElementAt(inarr[i+1],j+1);
                                        tmpvec.setElementAt(inarr[i+2],j+2);
                                        donofurther=true;
                                    }// end if tmpvec is smaller
                                }else if(isquery2==false){
                                    //if seq1 is the query, then remove seq2 from the vector and add seq1
                                    tmpvec.setElementAt(inarr[i],j);
                                    tmpvec.setElementAt(inarr[i+1],j+1);
                                    tmpvec.setElementAt(inarr[i+2],j+2);
                                    donofurther=true;//no further checks for the sequence I removed
                                }else if(isquery==false){
                                    //if seq2 is the query, then do nothing, it is already in the vector.
                                }
                            }// end if currsim>maxsim
                        }// end if both spec are equal
                    }// end for tmpvec j
                }else{//if checkgenus==true
                    //in this case only compare the first words from the taxonomy descriptor
                    for(int j=0;((j<tmpvec.size()-2)&&(donofurther==false));j+=3){
                        String spec2=((String)tmpvec.elementAt(j)).substring(((String)tmpvec.elementAt(j)).indexOf("["));//get whatever is in brackets
                        isquery2=false;
                        if(((String)tmpvec.elementAt(j)).indexOf(queryname)>-1){
                            isquery2=true;
                        }
                        float currsim;
                        tmpstrarr=spec2.split("\\s+");//split on spaces
                        tmpstr="";
                        tmpint=java.lang.reflect.Array.getLength(tmpstrarr);
                        for(int k=0;k<taxlevel;k++){
                            if(k<tmpint){
                                tmpstr+=tmpstrarr[k]+" ";
                            }
                        }//end for k
                        spec2=tmpstr.trim();
                        if(spec2.equalsIgnoreCase(spec1)){//if this is the same genus
                            hassame=true;
                            currsim=getsim((String)tmpvec.elementAt(j+2),inarr[i+2]);
                            if((currsim>maxsim)){
                                if((isquery==false)&&(isquery2==false)){//if it is a problem and neither of the sequences is the query
                                    doaddtovec=false;
                                    //get the number of non-gaps in each seq
                                    int nongi=getnogaps(inarr[i+2]);
                                    int nongj=getnogaps((String)tmpvec.elementAt(j));
                                    if(nongj<nongi){// if inarr has less gaps, replace the tmpvec element
                                        tmpvec.setElementAt(inarr[i],j);
                                        tmpvec.setElementAt(inarr[i+1],j+1);
                                        tmpvec.setElementAt(inarr[i+2],j+2);
                                        donofurther=true;
                                    }// end if tmpvec is smaller
                                }else if(isquery2==false){
                                    //if seq1 is the query, then remove seq2 from the vector and add seq1
                                    tmpvec.setElementAt(inarr[i],j);
                                    tmpvec.setElementAt(inarr[i+1],j+1);
                                    tmpvec.setElementAt(inarr[i+2],j+2);
                                    donofurther=true;//no further checks for the sequence I removed
                                }else if(isquery==false){
                                    //if seq2 is the query, then do nothing, it is already in the vector.
                                }
                            }// end if currsim>maxsim
                        }// end if both spec are equal
                    }// end for tmpvec j
                }//end if checkgenus==true
                //}//end if spec1 starts with "unknown"
                if((hassame==false)||((hassame)&&(doaddtovec))){
                    tmpvec.addElement(inarr[i]);
                    tmpvec.addElement(inarr[i+1]);
                    tmpvec.addElement(inarr[i+2]);
                }
            }// end for inarr i
            inarr=new String[tmpvec.size()];
            tmpvec.copyInto(inarr);
        }// end if maxsim<1
        return inarr;
    }// end docheck
    
    //--------------------------------------------------------------------------
    
    String[] dochecktaxid(String[] inarr,File extfile,taxid mytaxid,HashMap idtax){
        //get taxonomic data from the input names using the taxid files
        //apart from that the same thing as docheck
        seqnames.clear();
        int arrlength=java.lang.reflect.Array.getLength(inarr);
        String queryname=extfile.getName();
        queryname=queryname.substring(0,queryname.indexOf(".fas"));
        try{
            BufferedReader reader=new BufferedReader(new FileReader(extfile));//read the .fas file
            String inline;
            int pos;
            int begin;
            String info;
            String[] tmparr;
            while((inline=reader.readLine())!=null){//read the extfile
                if(inline.startsWith(">")){
                    inline=inline.substring(1).trim();//remove the ">"
                    tmparr=inline.split("\u0001");//split on the ncbi gi spacers
                    for(int i=0;i<java.lang.reflect.Array.getLength(tmparr);i++){//get the name and assign the infoline in a hash
                        if(tmparr[i].indexOf(" ")>-1){
                            info=tmparr[i].substring(0,tmparr[i].indexOf(" "));//get the name up to the first whitespace
                        }else{
                            info=tmparr[i];
                        }
                        seqnames.put(info,inline);
                        //now see if the name is a ginumber and if so add another name without the gi
                        if(info.startsWith("gi|")){
                            info=info.substring(info.indexOf("|",3)+1);
                            seqnames.put(info,inline);//put the giless name version as well
                        }
                    }// end for i
                }// end if startswith
            }// end while inline!=null
            reader.close();
        }catch (IOException e){
            System.err.println("IOError reading from "+extfile.getName());
            e.printStackTrace();
        }
        //now all the info seqnames + their fasta nameline should be in seqnames hash
        int uscorepos,pipepos;
        for(int i=0;i<arrlength;i+=3){//loop through the inarr names and get rid of prefixes (i.e. 1_, 2_ etc
            String currname=inarr[i];
            pipepos=currname.indexOf("|");
            if((uscorepos=currname.indexOf("_"))>-1){// if this name has a prefix
                //be careful, some names contain underscores!! limit to 3 chars(=up to 999 overlapping blast hits)?
                if((pipepos<0)||(pipepos>uscorepos)){
                    currname=currname.substring(uscorepos+1);
                }
            }
            if(seqnames.containsKey(currname)){
                if(currname.startsWith("gi|")){//if this is a gi number
                    try{//see if you can read the species from idtax
                        String ginumstr=currname.substring(3,currname.indexOf("|",3));
                        int ginum=Integer.parseInt(ginumstr);
                        ginum=mytaxid.gettaxid(ginum);//assign the taxonomic id number to ginum
                        String tmpstr=String.valueOf(ginum);
                        if(ginum>-1){//if gettaxid returned a taxonomy number
                            if(idtax.containsKey(tmpstr)){
                                inarr[i]+=" ["+(String)idtax.get(tmpstr)+"]";//get the name for this id and put it in outarr[1]
                                //now i still have to check if this name is the scientific name!!!
                                
                            }else{//if idtax didn't have the gi number
                                inarr[i]+=" "+gettaxname((String)seqnames.get(currname));
                            }
                        }else{//if taxid didn't have any number
                            inarr[i]+=" "+gettaxname((String)seqnames.get(currname));
                        }
                    }catch (NumberFormatException e){
                        System.err.println("unable to parse gi number from '"+currname+"'");
                    }
                }else{//if this doesn't have a gi number
                    try{//see if the complete name is a gi number
                        int ginum=Integer.parseInt(currname.trim());
                        ginum=mytaxid.gettaxid(ginum);//assign the taxonomic id number to ginum
                        //System.out.println("'"+currname+"' IS a gi number");
                        String tmpstr=String.valueOf(ginum);
                        if(ginum>-1){//if gettaxid returned a taxonomy number
                            if(idtax.containsKey(tmpstr)){
                                inarr[i]+=" ["+(String)idtax.get(tmpstr)+"]";//get the name for this id and put it in outarr[1]
                                //now i still have to check if this name is the scientific name!!!
                            }else{//if idtax didn't have the gi number
                                //System.out.println("but "+tmpstr+" is not present in idtax");
                                inarr[i]+=" "+gettaxname((String)seqnames.get(currname));
                            }
                        }else{//if taxid didn't have any number
                            inarr[i]+=" "+gettaxname((String)seqnames.get(currname));
                        }
                    }catch(NumberFormatException ne){
                        //the name is not a gi number, try to get the species name anyhow
                        System.out.println("'"+currname+"' is not a gi number");
                        inarr[i]+=" "+gettaxname((String)seqnames.get(currname));
                    }
                }
            }else{//if the name was not found, I have no such sequence in the database
                inarr[i]+=" not in database [unknown taxonomy]";
            }
        }// end for i looping through inarr 3 at a time
        //now all the id's should have a species assigned, next=check for maxsim in each species
        String[] tmpstrarr;
        String tmpstr;
        int tmpint;
        if(maxsim<1){//if I want to check for maximum similarity
            Vector tmpvec=new Vector();
            boolean isquery=false;
            for(int i=0;i<arrlength;i+=3){//only look at every 3rd element; 2nd element is the query seq
                //if two species are the same and their sequences are more similar than maxsim --> remove the shorter?; check that you don't remove the query seq
                isquery=false;
                String spec1=inarr[i].substring(inarr[i].indexOf("["));//get whatever is in brackets
                if(inarr[i].indexOf(queryname)>-1){//if this is the query
                    isquery=true;
                }
                //System.out.println(inarr[i]+" isquery="+isquery);
                if(taxlevel<3){
                    tmpstrarr=spec1.split("\\s+");//split on spaces
                    tmpstr="";
                    tmpint=java.lang.reflect.Array.getLength(tmpstrarr);
                    for(int j=0;j<taxlevel;j++){
                        if(tmpint>j){
                            tmpstr+=tmpstrarr[j]+" ";
                        }
                    }//end for j
                    spec1=tmpstr.trim();
                }
                boolean hassame=false;
                boolean doaddtovec=true;
                boolean donofurther=false;
                boolean isquery2=false;
                //if(spec1.startsWith("unknown")){
                //don't check this sequences
                //}else{
                if(taxlevel>=3){
                    for(int j=0;((j<tmpvec.size()-2)&&(donofurther==false));j+=3){
                        String spec2=((String)tmpvec.elementAt(j)).substring(((String)tmpvec.elementAt(j)).indexOf("["));//get whatever is in brackets
                        isquery2=false;
                        if(((String)tmpvec.elementAt(j)).indexOf(queryname)>-1){
                            isquery2=true;
                        }
                        float currsim;
                        if(spec2.equalsIgnoreCase(spec1)){//if this is the same species
                            hassame=true;
                            currsim=getsim((String)tmpvec.elementAt(j+2),inarr[i+2]);
                            if((currsim>maxsim)){
                                //System.out.println("similarity for "+inarr[i]+" and "+((String)tmpvec.elementAt(j))+"= "+currsim);
                                if((isquery==false)&&(isquery2==false)){//if it is a problem and neither of the sequences is the query
                                    //System.out.println("removing shorter");
                                    doaddtovec=false;
                                    //get the number of non-gaps in each seq
                                    int nongi=getnogaps(inarr[i+2]);
                                    int nongj=getnogaps((String)tmpvec.elementAt(j));
                                    if(nongj<nongi){// if inarr has less gaps, replace the tmpvec element
                                        tmpvec.setElementAt(inarr[i],j);
                                        tmpvec.setElementAt(inarr[i+1],j+1);
                                        tmpvec.setElementAt(inarr[i+2],j+2);
                                        donofurther=true;
                                    }// end if tmpvec is smaller
                                }else if(isquery2==false){
                                    doaddtovec=false;
                                    //System.out.println(inarr[i]+" is query, removing "+((String)tmpvec.elementAt(j)));
                                    //if seq1 is the query, then remove seq2 from the vector and add seq1
                                    tmpvec.setElementAt(inarr[i],j);
                                    tmpvec.setElementAt(inarr[i+1],j+1);
                                    tmpvec.setElementAt(inarr[i+2],j+2);
                                    donofurther=true;//no further checks for the sequence I removed
                                }else{// if(isquery==false){ //or both are query, then do nothing
                                    doaddtovec=false;
                                    //System.out.println(((String)tmpvec.elementAt(j))+"is query, doing nothing");
                                    //if seq2 is the query, then do nothing, it is already in the vector.
                                }
                            }// end if currsim>maxsim
                        }// end if both spec are equal
                    }// end for tmpvec j
                }else{//if checkgenus==true
                    for(int j=0;((j<tmpvec.size()-2)&&(donofurther==false));j+=3){
                        String spec2=((String)tmpvec.elementAt(j)).substring(((String)tmpvec.elementAt(j)).indexOf("["));//get whatever is in brackets
                        isquery2=false;
                        if(((String)tmpvec.elementAt(j)).indexOf(queryname)>-1){
                            isquery2=true;
                        }
                        float currsim;
                        tmpstrarr=spec2.split("\\s+");//split on spaces
                        tmpint=java.lang.reflect.Array.getLength(tmpstrarr);
                        tmpstr="";
                        for(int k=0;k<taxlevel;k++){
                            tmpstr=tmpstrarr[k]+" ";
                        }//end for k
                        spec2=tmpstr.trim();
                        if(spec2.equalsIgnoreCase(spec1)){//if this is the same species
                            hassame=true;
                            currsim=getsim((String)tmpvec.elementAt(j+2),inarr[i+2]);
                            if((currsim>maxsim)){
                                //System.out.println("similarity for "+inarr[i]+" and "+((String)tmpvec.elementAt(j))+"= "+currsim);
                                if((isquery==false)&&(isquery2==false)){//if it is a problem and neither of the sequences is the query
                                    //System.out.println("removing shorter");
                                    doaddtovec=false;
                                    //get the number of non-gaps in each seq
                                    int nongi=getnogaps(inarr[i+2]);
                                    int nongj=getnogaps((String)tmpvec.elementAt(j));
                                    if(nongj<nongi){// if inarr has less gaps, replace the tmpvec element
                                        tmpvec.setElementAt(inarr[i],j);
                                        tmpvec.setElementAt(inarr[i+1],j+1);
                                        tmpvec.setElementAt(inarr[i+2],j+2);
                                        donofurther=true;
                                    }// end if tmpvec is smaller
                                }else if(isquery2==false){
                                    doaddtovec=false;
                                    //System.out.println(inarr[i]+" is query, removing "+((String)tmpvec.elementAt(j)));
                                    //if seq1 is the query, then remove seq2 from the vector and add seq1
                                    tmpvec.setElementAt(inarr[i],j);
                                    tmpvec.setElementAt(inarr[i+1],j+1);
                                    tmpvec.setElementAt(inarr[i+2],j+2);
                                    donofurther=true;//no further checks for the sequence I removed
                                }else{// if(isquery==false){ //or both are query, then do nothing
                                    doaddtovec=false;
                                    //System.out.println(((String)tmpvec.elementAt(j))+"is query, doing nothing");
                                    //if seq2 is the query, then do nothing, it is already in the vector.
                                }
                            }// end if currsim>maxsim
                        }// end if both spec are equal
                    }// end for tmpvec j
                }//end else checkgenus
                //}//end if spec1 starts with "unknown"
                if((hassame==false)||((hassame)&&(doaddtovec))){
                    tmpvec.addElement(inarr[i]);
                    tmpvec.addElement(inarr[i+1]);
                    tmpvec.addElement(inarr[i+2]);
                }
            }// end for inarr i
            inarr=new String[tmpvec.size()];
            tmpvec.copyInto(inarr);
        }// end if maxsim<1
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
        return "[unknown taxonomy]";
    }// end gettaxname
    
}// end checktax
