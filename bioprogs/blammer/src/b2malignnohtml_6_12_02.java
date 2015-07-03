/*
 * b2malign.java
 *
 * Created on February 1, 2002, 9:01 AM
 */
import java.util.*;
import java.lang.*;
import java.io.*;
/**
 *
 * @author  noname
 * @version
 */
public class b2malignnohtml_6_12_02 {
    
    /** Creates new b2malign */
    public b2malignnohtml_6_12_02() {
        
    }
    
    int begintmp=0;
    int endtmp=0;
    int querygaps=0;
    float coveragetmp=1;
    String queryname;
    int querylength=1;
    
    //overload main for most possible calls
    //public String[] malign(BufferedReader inread){
    //    return malign(inread,(float)0,(double)-1);
    //}
    //public String[] malign(BufferedReader inread,float coverage){
    //    return malign(inread,coverage,(double)-1);
    //}
    
    public String[] malign(BufferedReader inread,float coverage,double blastmax,double scval,float minsim){
        //this reads in a blast file and spits an array containing name, search seq and hitseq for each blast hit
        //also removes all identical sequences (for the same species);
        String str;
        blastpair currpair=new blastpair();
        Vector vec=new Vector();
        int ns; //name start
        int ne; //name end
        int ss; //sequence start
        int se; //sequence end
        int qs; //query start
        int qe; //query end
        String currname="";
        String currseq="";
        String currquery="";
        queryname="";
        boolean readname=false;
        boolean readseq=false;
        boolean readquery=false;
        boolean querydone=false;
        boolean stopread=false;//a way of stopping the read other than reaching EOF
        double edef=(double)100;
        double evalue=edef;
        double score=1;
        int linecount=0;//for debugging
        int subjectlength=1;
        Vector tmpvec=new Vector();
        float myident=0;
        String myidentstr;
        //System.out.println("startveclength="+tmpvec.size());
        try{
            while (((str=inread.readLine())!=null)&&(stopread==false)){
                linecount+=1;
                //System.out.println(linecount+" vecsize="+vec.size());
                //System.out.println(str);
                if(querydone==false){
                    if(str.indexOf("Query=")>-1){
                        readquery=true;
                    }
                    int endql;
                    if((endql=str.indexOf("letters)"))>-1){
                        int startql;
                        if((startql=str.indexOf("("))>-1){
                            try{
                                querylength=Integer.parseInt((str.substring(startql+1,endql)).trim());
                                //System.out.println("qlength="+querylength);
                            }catch (NumberFormatException e){
                                System.err.println("error in parsing query length:"+str.substring(startql+1,endql));
                            }
                        }// end if startql
                        querydone=true;
                        queryname=extractqueryname(queryname);
                        //System.out.println("query done "+queryname);
                        continue;
                    }//end if endql
                    if(readquery){
                        queryname=queryname+str;
                        continue;
                    }
                }// end if querydone
                if((str.indexOf(">gi|")> -1)||(str.indexOf(">gt|")> -1)){//if this substring exists
                    //if(str.indexOf("</PRE>")>-1){// if </PRE> is on the line
                    currquery=extractquery(currquery);
                    currpair.query=currquery;
                    currpair.beginq=begintmp;
                    currpair.endq=endtmp;
                    currseq=extractseq(currseq);
                    currpair.beginseq=begintmp;
                    currpair.endseq=endtmp;
                    currpair.seq=currseq;
                    currpair.coverage=coveragetmp;
                    if(((blastmax==-1)||(evalue<=blastmax))&&((scval==-1)||(scval<(score/subjectlength)))&&((minsim<=0)||(minsim<=myident))){//blastmax==-1 = don't check
                        tmpvec.addElement(currpair);
                    }
                    currpair=new blastpair();//need to make new blastpair because tmpvec is still referencing this element
                    currseq="";
                    myident=0;
                    readseq=false;
                    //System.out.println("end of pre");
                    //continue;
                    //}// end if >gi or >gt
                    readname=true;
                    if(tmpvec.size()>0){
                        blastpair[] testpair=collapsetmpvec(tmpvec);
                        for(int i=0;i<java.lang.reflect.Array.getLength(testpair);i++){
                            if(testpair[i].coverage>=coverage){
                                //System.out.println("1>"+testpair[i].name);
                                //System.out.println(testpair[i].beginq+" "+testpair[i].query+" "+testpair[i].endq);
                                //System.out.println(testpair[i].beginseq+" "+testpair[i].seq+" "+testpair[i].endseq);
                                vec.addElement(testpair[i]);
                            }
                            evalue=edef;//default value
                        }
                    }
                    tmpvec.clear();
                    currname="";
                    currseq="";
                    currquery="";
                }//end if ><a name =
                if(readname==true){
                    int strs;
                    if((strs=str.indexOf("Length ="))>-1){
                        String lengthstring=(str.substring(strs+8)).trim();
                        try{
                            subjectlength=Integer.parseInt(lengthstring);
                        }catch (NumberFormatException e){
                            System.err.println("unable to parse int from "+subjectlength+" for "+currname);
                            subjectlength=1;
                        }
                        //System.out.println("in length; name="+currname);
                        readname=false;
                        currname=extractname(currname);
                        continue;
                    }
                    currname=currname+str;
                    continue;
                }
                int strs;
                if((strs=str.indexOf("Score ="))>-1){
                    int endstrs;
                    if((endstrs=str.indexOf("bits",strs+7))>-1){
                        String scorestring=(str.substring(strs+7,endstrs)).trim();
                        try{
                            score=Double.parseDouble(scorestring);
                        }catch (NumberFormatException e){
                            System.err.println("Error parsing Score "+scorestring+" for "+currname);
                            score=1;
                        }
                    }
                }// end if Score
                if(str.indexOf("Expect =")>-1){
                    String[] tmparr=str.split("\\s",0);
                    if(tmparr[java.lang.reflect.Array.getLength(tmparr)-1].charAt(0)=='e'){
                        tmparr[java.lang.reflect.Array.getLength(tmparr)-1]="1"+tmparr[java.lang.reflect.Array.getLength(tmparr)-1];
                    }
                    try{
                        evalue=Double.parseDouble(tmparr[java.lang.reflect.Array.getLength(tmparr)-1]);
                    }catch (NumberFormatException e){
                        System.err.println("Error parsing E-value "+tmparr[java.lang.reflect.Array.getLength(tmparr)-1]+" for "+currname);
                        evalue=edef;
                    }
                }// end if expect
                if(str.indexOf("Identities =")>-1){
                    //System.out.println("name done ="+currname);
                    int begin=-1;
                    int end=-1;
                    if((begin=str.indexOf("("))>-1){//find the first bracket
                        if((end=str.indexOf("%"))>-1){//find the first percent sign
                            myidentstr=str.substring(begin+1,end);
                            try{
                                myident=Float.parseFloat(myidentstr);
                            }catch(NumberFormatException e){
                                System.err.println("unable to parse float from "+myidentstr);
                            }
                            myident=myident/100;
                        }
                    }
                    currpair.name=currname;
                    readseq=true;
                    continue;
                }// end if identities
                if(readseq){
                    if(str.indexOf("Query:")>-1){
                        currquery=currquery+str;
                        continue;
                    }
                    if(str.indexOf("Sbjct:")>-1){
                        currseq=currseq+str;
                        continue;
                    }
                    /*if(str.indexOf("</PRE>")>-1){// if </PRE> is on the line
                        currquery=extractquery(currquery);
                        currpair.query=currquery;
                        currpair.beginq=begintmp;
                        currpair.endq=endtmp;
                        currseq=extractseq(currseq);
                        currpair.beginseq=begintmp;
                        currpair.endseq=endtmp;
                        currpair.seq=currseq;
                        currpair.coverage=coveragetmp;
                        if((blastmax==-1)||(evalue<=blastmax)){//blastmax==-1 = don't check
                            tmpvec.addElement(currpair);
                        }
                        currpair=new blastpair();//need to make new blastpair because tmpvec is still referencing this element
                        currseq="";
                        readseq=false;
                        //System.out.println("end of pre");
                        continue;
                    }// end if </PRE>
                     */
                }// end if readseq
            }// end while readline
            //once I have read in everything I need to add the last sequence read here
            if(currquery.length()>0){//see if i have a hit in memory and if so, add it to tmpvec
                currquery=extractquery(currquery);
                currpair.query=currquery;
                currpair.beginq=begintmp;
                currpair.endq=endtmp;
                currseq=extractseq(currseq);
                currpair.beginseq=begintmp;
                currpair.endseq=endtmp;
                currpair.seq=currseq;
                currpair.coverage=coveragetmp;
                if(((blastmax==-1)||(evalue<=blastmax))&&((scval==-1)||(scval<(score/subjectlength)))&&((minsim<=0)||(minsim<=myident))){//blastmax==-1 = don't check
                    tmpvec.addElement(currpair);
                }
                currpair=new blastpair();
                if(tmpvec.size()>0){
                    blastpair[] testpair=collapsetmpvec(tmpvec);
                    for(int i=0;i<java.lang.reflect.Array.getLength(testpair);i++){
                        if(testpair[i].coverage>=coverage){
                            //System.out.println("1>"+testpair[i].name);
                            //System.out.println(testpair[i].beginq+" "+testpair[i].query+" "+testpair[i].endq);
                            //System.out.println(testpair[i].beginseq+" "+testpair[i].seq+" "+testpair[i].endseq);
                            vec.addElement(testpair[i]);
                        }
                        evalue=edef;//default value
                    }
                }
            }
            //System.out.println("DONE fileread");
        }catch (IOException e){
            System.err.println("IOError in malign reading");
            e.printStackTrace();
        }
        //System.out.println("tmpveclength="+tmpvec.size());
        if(tmpvec.size()>0){
            blastpair[] testpair=collapsetmpvec(tmpvec);
            //System.out.println(testpair.name+" cover="+testpair.coverage);
            for(int i=0;i<java.lang.reflect.Array.getLength(testpair);i++){
                if(testpair[i].coverage>=coverage){
                    //System.out.println("2>"+testpair[i].name);
                    //System.out.println(testpair[i].beginq+" "+testpair[i].query+" "+testpair[i].endq);
                    //System.out.println(testpair[i].beginseq+" "+testpair[i].seq+" "+testpair[i].endseq);
                    vec.addElement(testpair[i]);
                }
            }
        }// end if tmpvec.size==0
        vec=removeidenticals(vec);
        String[] outarr=convertmainvec(vec);
        return outarr;
    }// end malign
    
    
    //-------------------------------------------------------------------------------------------------------
    
    String extractqueryname(String instr){
        String outstr=new String("");
        int ns=0;
        if((ns=instr.indexOf("gi|"))>-1){
            int ne;
            if((ne=instr.indexOf("|",(ns+3)))>0){
                outstr=instr.substring((ns+3),ne);
            }
        }// end if gi
        if((ns=instr.indexOf("gt|"))>-1){
            int ne;
            if((ne=instr.indexOf("|",(ns+3)))>0){
                outstr="t"+instr.substring((ns+3),ne);
            }
        }// end if gt
        return outstr;
    }
    
    //------------------------------------------------------------------------------------------------------
    
    String extractname(String instr){
        //System.out.println("in extractname "+instr);
        Vector tmpvec=new Vector();
        boolean foundnext=true;
        int currpos=0;
        String outstr=new String("");
        int ns=0;
        while (foundnext){
            if((ns=instr.indexOf("gi|",currpos))>-1){
                int ne=ns+3;
                if((ne=instr.indexOf("|",(ns+3)))>0){//need to do this in case a gi number is missing the second | (causes an endless loop)
                    outstr=instr.substring((ns+3),ne);
                    tmpvec.addElement(outstr);
                    //System.out.println("added gi "+outstr+" ns,ne="+ns+" "+ne);
                    currpos=ne;
                    continue;
                }
            }// end if gi
            if((ns=instr.indexOf("gt|",currpos))>-1){
                int ne=ns+3;
                if((ne=instr.indexOf("|",(ns+3)))>0){
                    outstr="t"+instr.substring((ns+3),ne);
                    tmpvec.addElement(outstr);
                    //System.out.println("added gt "+outstr);
                    currpos=ne;
                    continue;
                }
            }// end if gt
            foundnext=false;
        }// end while foundnext
        for(int i=0;i<tmpvec.size();i++){
            if((((String)tmpvec.elementAt(i)).indexOf(queryname))>-1){
                //System.out.println("returning "+(String) tmpvec.elementAt(i));
                return ((String) tmpvec.elementAt(i));
            }
        }
        if(tmpvec.size()<1){
            System.err.println("error on "+instr);
            return instr;
        }
        return ((String)tmpvec.elementAt(0));
    }// end extractname
    
    //------------------------------------------------------------------------------------------------------
    
    String extractquery(String instr){
        boolean foundnext=true;
        boolean dostart=true;
        String outstr="";
        int currpos=0;
        int startquery=0;
        int endthis=0;
        int seqstart=Integer.MAX_VALUE;
        int tmpstart=0;
        int tmpend=0;
        querygaps=0;
        char c;
        while(foundnext){
            if(((startquery=instr.indexOf("Query:",currpos-1))>-1)&&((endthis=instr.indexOf("Query:",(startquery+1)))>-1)){
                forloop:
                    for(currpos=startquery+6;currpos<endthis;currpos+=1){
                        c=instr.charAt(currpos);
                        if(Character.isWhitespace(c)){
                            tmpstart=currpos;
                            continue forloop;
                        }
                        if(Character.isDigit(c)){
                            tmpstart=currpos;
                            while((Character.isDigit(c))&&(currpos<endthis)){
                                currpos+=1;
                                c=instr.charAt(currpos);
                            }
                            String tmpstr=(instr.substring(tmpstart,currpos)).trim();
                            int tmpval=Integer.parseInt(tmpstr);
                            if(dostart){
                                seqstart=tmpval;
                                dostart=false;
                            }
                            continue forloop;
                        }// end if isdigit
                        if((Character.isJavaIdentifierStart(c))||(c=='-')){
                            tmpstart=currpos;
                            while ((Character.isJavaIdentifierStart(c))||(c=='-')){
                                if(c=='-'){
                                    querygaps+=1;
                                }
                                currpos+=1;
                                c=instr.charAt(currpos);
                            }// end while
                            outstr=outstr+instr.substring(tmpstart,currpos);
                            continue forloop;
                        }// end isjavaidentifierstart
                    }// end for currpos
                    continue;
            }// end if two queries on same line
            foundnext=false;
        }// end while
        //int tmpval=currpos;
        int tmpval=instr.indexOf("Query:",currpos-1);
        for(currpos=tmpval+6;currpos<instr.length();currpos+=1){
            c=instr.charAt(currpos);
            if(Character.isWhitespace(c)){
                tmpstart=currpos;
                continue;
            }
            if(Character.isDigit(c)){
                tmpstart=currpos;
                while((Character.isDigit(c))&&(currpos<(instr.length()-1))){
                    currpos+=1;
                    c=instr.charAt(currpos);
                }
                try{
                    tmpval=Integer.parseInt(instr.substring(tmpstart,currpos));
                }catch (NumberFormatException e){
                    try{
                        tmpval=Integer.parseInt(instr.substring(tmpstart));
                    }catch (NumberFormatException e2){
                        System.err.println("numError at "+instr+" "+tmpstart+" "+currpos);
                        e2.printStackTrace();
                    }
                }
                if(dostart){
                    seqstart=tmpval;
                    dostart=false;
                }
                continue;
            }// end if isdigit
            if((Character.isJavaIdentifierStart(c))||(c=='-')){
                tmpstart=currpos;
                while ((Character.isJavaIdentifierStart(c))||(c=='-')){
                    if(c=='-'){
                        querygaps+=1;
                    }
                    currpos+=1;
                    c=instr.charAt(currpos);
                }// end while
                outstr=outstr+instr.substring(tmpstart,currpos);
                continue;
            }// end isjavaidentifierstart
        }// end for currpos
        begintmp=seqstart;
        endtmp=seqstart+outstr.length();
        return outstr;
    }
    
    //------------------------------------------------------------------------------------------------------
    
    String extractseq(String instr){
        boolean foundnext=true;
        boolean dostart=true;
        String outstr="";
        int currpos=0;
        int startquery=0;
        int endthis=0;
        int seqstart=Integer.MAX_VALUE;
        int tmpstart=0;
        int tmpend=0;
        int gapcounter=0;
        char c;
        while(foundnext){
            if(((startquery=instr.indexOf("Sbjct:",currpos-1))>-1)&&((endthis=instr.indexOf("Sbjct:",(startquery+1)))>-1)){
                forloop:
                    for(currpos=startquery+6;currpos<endthis;currpos+=1){
                        c=instr.charAt(currpos);
                        if(Character.isWhitespace(c)){
                            tmpstart=currpos;
                            continue forloop;
                        }
                        if(Character.isDigit(c)){
                            tmpstart=currpos;
                            while((Character.isDigit(c))&&(currpos<endthis)){
                                currpos+=1;
                                c=instr.charAt(currpos);
                            }
                            String tmpstr=(instr.substring(tmpstart,currpos)).trim();
                            int tmpval=Integer.parseInt(tmpstr);
                            if(dostart){
                                seqstart=tmpval;
                                dostart=false;
                            }
                            continue forloop;
                        }// end if isdigit
                        if((Character.isJavaIdentifierStart(c))||(c=='-')){
                            tmpstart=currpos;
                            while ((Character.isJavaIdentifierStart(c))||(c=='-')){
                                if(c=='-'){
                                    gapcounter+=1;
                                }
                                currpos+=1;
                                c=instr.charAt(currpos);
                            }// end while
                            outstr=outstr+instr.substring(tmpstart,currpos);
                            continue forloop;
                        }// end isjavaidentifierstart
                    }// end for currpos
                    continue;
            }// end if two queries on same line
            foundnext=false;
        }// end while
        //int tmpval=currpos;
        int tmpval=instr.indexOf("Sbjct:",currpos-1);
        for(currpos=tmpval+6;currpos<instr.length();currpos+=1){
            c=instr.charAt(currpos);
            if(Character.isWhitespace(c)){
                tmpstart=currpos;
                continue;
            }
            if(Character.isDigit(c)){
                tmpstart=currpos;
                while((Character.isDigit(c))&&(currpos<(instr.length()-1))){
                    currpos+=1;
                    c=instr.charAt(currpos);
                }
                try{
                    tmpval=Integer.parseInt(instr.substring(tmpstart,currpos));
                }catch (NumberFormatException e){
                    try{
                        tmpval=Integer.parseInt(instr.substring(tmpstart));
                    }catch (NumberFormatException e2){
                        System.err.println("numError at "+instr+" "+tmpstart+" "+currpos);
                        e2.printStackTrace();
                    }
                }
                if(dostart){
                    seqstart=tmpval;
                    dostart=false;
                }
                continue;
            }// end if isdigit
            if((Character.isJavaIdentifierStart(c))||(c=='-')){
                tmpstart=currpos;
                while ((Character.isJavaIdentifierStart(c))||(c=='-')){
                    if(c=='-'){
                        gapcounter+=1;
                    }
                    currpos+=1;
                    c=instr.charAt(currpos);
                }// end while
                outstr=outstr+instr.substring(tmpstart,currpos);
                continue;
            }// end isjavaidentifierstart
        }// end for currpos
        begintmp=seqstart;
        endtmp=seqstart+outstr.length();
        coveragetmp=(float)((float)outstr.length()-(float)(gapcounter+querygaps))/(float)querylength;
        //System.out.println("cover="+coveragetmp);
        return outstr;
    }
    
    //------------------------------------------------------------------------------------------------------
    
    
    blastpair[] collapsetmpvec(Vector invec){
        int vecsize=invec.size();
        blastpair[] tmparr=new blastpair[vecsize];
        invec.copyInto(tmparr);
        //java.util.Arrays.sort(tmparr,new beginseqcompare());//sorts by start of hit sequence
        //as alternative sort by begin of blastquery
        java.util.Arrays.sort(tmparr,new beginqcompare());//sort by start of query sequence to take circular perm. into account
        blastpair curr;
        blastpair tmp=tmparr[0];
        vecsize=java.lang.reflect.Array.getLength(tmparr);
        //invec=new Vector();
        invec.clear();
        for(int i=0;i<vecsize;i++){//was i=1
            if(i==0){
                continue;
            }
            curr=tmparr[i];
            //check if queries are overlapping or spaced
            int spacepos=curr.beginq-tmp.endq;
            int spaceseqpos=curr.beginseq-tmp.endseq;
            StringBuffer spacer=new StringBuffer();
            //if spaced create spacer String
            if((spacepos>=0)&&(spaceseqpos>=0)){//if both query and hit are non overlapping
                //concatenate the sequences (gapping by spacepos)
                while (spacepos>0){
                    spacer=spacer.append('-');
                    spacepos-=1;
                }
                tmp.query=tmp.query+spacer.toString()+curr.query;
                tmp.endq=curr.endq;
                //now do the queryline
                //spacepos=curr.beginseq-tmp.endseq;
                //spacer=new StringBuffer();
                //while (spaceseqpos>0){
                //    spacer=spacer.append('-');
                //    spaceseqpos-=1;
                //}
                tmp.seq=tmp.seq+spacer.toString()+curr.seq;
                tmp.endseq=curr.endseq;
            }else{//if either query or hit overlap previous seq, make new element
                //if(spacepos<0){//if overlap, create new element and add old to output
                invec.addElement(tmp);
                tmp=curr;
                continue;
            }
        }// end for
        invec.addElement(tmp);
        blastpair[] out=new blastpair[invec.size()];
        invec.copyInto(out);
        for(int i=0;i<java.lang.reflect.Array.getLength(out);i++){
            //System.out.println(">"+out[i].name);
            //System.out.println(out[i].beginq+" "+out[i].query+" "+out[i].endq);
            //System.out.println(out[i].beginseq+" "+out[i].seq+" "+out[i].endseq);
            if(i>0){
                out[i].name=(i+1)+"_"+out[i].name;
            }
        }
        return out;
    }// end collapsetmpvec
    
    //------------------------------------------------------------------------------------------------------
    
    Vector removeidenticals(Vector invec){
        Vector outvec=new Vector();
        for(int i=0;i<invec.size();i++){
            boolean newname=true;
            blastpair curri=(blastpair)invec.elementAt(i);
            //System.out.println("checking in remident "+curri.name);
            for(int j=0;((j<outvec.size())&&(newname));j++){
                blastpair currj=(blastpair)outvec.elementAt(j);
                if(curri.name.equals(currj.name)){
                    newname=false;
                }
            }
            if(newname){
                //System.out.println("adding as new in remident "+curri.name);
                outvec.addElement(invec.elementAt(i));
            }
        }// end for i
        return outvec;
    }//end removeidenticals
    
    //------------------------------------------------------------------------------------------------------
    
    String[] convertmainvec(Vector invec){
        //System.out.println("in convertmainvec");
        //this takes a vector with pairwise alignments and converts it to a multiple alignment
        int vecsize=invec.size();
        //System.out.println("vecsize="+vecsize);
        String[][] seqarr=new String[vecsize][2];// holds query in 0 and seq in 1
        int [][] startarr=new int[vecsize][2]; //holds start position for query 0 and hitseq 1
        String[] namesarr=new String[vecsize+1];//holds hitnames+queryname;
        namesarr[vecsize]=queryname;//last element=queryname
        //System.out.println("last elem="+namesarr[vecsize]);
        int minquerystart=Integer.MAX_VALUE;
        int maxseqlength=0;
        for(int i=0;i<vecsize;i++){
            blastpair curr=(blastpair) invec.elementAt(i);
            seqarr[i][0]=curr.query;
            seqarr[i][1]=curr.seq;
            startarr[i][0]=curr.beginq;
            if(curr.beginq<minquerystart){
                minquerystart=curr.beginq;
            }
            startarr[i][1]=curr.beginseq;
            namesarr[i]=curr.name;
        }
        // now I have arrays with:  pairs of query&hit sequences
        //                          info about where the start of each query+sequence is
        //                          the sequence names
        for(int i=0;i<vecsize;i++){
            //offset the sequences where the query starts later than minquerystart
            int offset=startarr[i][0]-minquerystart;
            StringBuffer tmpstr=new StringBuffer();
            while(offset>0){
                offset-=1;
                tmpstr=tmpstr.append("#");
            }
            seqarr[i][0]=tmpstr.toString()+seqarr[i][0];
            seqarr[i][1]=tmpstr.toString()+seqarr[i][1];
            if(seqarr[i][0].length()>maxseqlength){
                maxseqlength=seqarr[i][0].length();
            }
        }// end for i
        //try seq by seq, looping through pos
        int addmaxdash=0;
        for(int pos=0;pos<(maxseqlength+addmaxdash);pos++){
            //loop through the positions and space the sequences so that the queries are in order
            for(int i=0;i<vecsize;i++){
                // loop through the sequences
                if((pos<seqarr[i][0].length())&&(pos>startarr[i][0])&&(seqarr[i][0].charAt(pos)=='-')){
                    addmaxdash+=1;
                    //if I have a gap in this seq
                    for(int j=0;j<vecsize;j++){
                        //loop through the other sequences
                        if((pos<seqarr[j][0].length())&&(pos<seqarr[j][1].length())&&(seqarr[j][0].charAt(pos)!='-')&&(seqarr[j][0].charAt(pos)!='_')){
                            //if the other seq doesn't have a gap at this position
                            seqarr[j][0]=seqarr[j][0].substring(0,pos)+"_"+seqarr[j][0].substring(pos);
                            seqarr[j][1]=seqarr[j][1].substring(0,pos)+"_"+seqarr[j][1].substring(pos);
                        }
                    }// end for j
                }// end if - && beginseq
            }// end for i
        }// end for pos
        
        // now fill up all sequences with dashes until they are the same length as maxseqlength
        for(int i=0;i<vecsize;i++){
            if(seqarr[i][0].length()>maxseqlength){
                maxseqlength=seqarr[i][0].length();
            }
        }
        for(int i=0;i<vecsize;i++){
            int fillup=maxseqlength-seqarr[i][0].length();
            if(fillup>0){
                StringBuffer fillstr=new StringBuffer(fillup);
                while (fillup>fillstr.length()){
                    fillstr=fillstr.append('-');
                }
                seqarr[i][0]=seqarr[i][0]+fillstr.toString();
            }
            fillup=maxseqlength-seqarr[i][1].length();
            if(fillup>0){
                StringBuffer fillstr=new StringBuffer(fillup);
                while (fillup>fillstr.length()){
                    fillstr=fillstr.append('-');
                }
                seqarr[i][1]=seqarr[i][1]+fillstr.toString();
            }
        }// end for i
        //System.out.println("-------------done fillup-------------"+maxseqlength);
        String[] out=new String[vecsize*3];
        for (int i=0;i<vecsize;i++){
            out[i*3]=namesarr[i];
            //System.out.println("outarr.name="+out[i*3]);
            out[(i*3)+1]=seqarr[i][0].replace('_','-');
            out[(i*3)+2]=seqarr[i][1].replace('_','-');
            out[(i*3)+1]=out[(i*3)+1].replace('#','-');//"#"is the char I prepend to seq to have all start at the same position
            out[(i*3)+2]=out[(i*3)+2].replace('#','-');
        }
        //here i check to see how many sequences I have in out[]
        //if there are more than seqs*3 sequences in there, i need to shorten the array accordingly
        //remove all those sequences identical>maxhmmsim
        /*if((java.lang.reflect.Array.getLength(out)>(seqs*3))&&(seqs>0)){//if I want to check for the number of sequences
            String[] tmpout=new String[seqs*3];
            for(int i=0;i<(seqs*3);i++){
                tmpout[i]=out[i];
            }
            out=tmpout;
        }// end if out.size>seqs*3
         */
        return out;
    }// end convertmainvec
    
    //------------------------------------------------------------------------------------------------------
    
    class beginseqcompare implements Comparator{
        
        public int compare(java.lang.Object in1, java.lang.Object in2) {
            int ci1=((blastpair)in1).beginseq;
            int ci2=((blastpair)in2).beginseq;
            if(ci1<ci2){
                return -1;
            }
            if(ci2<ci1){
                return 1;
            }
            return 0;
        }// end compare
        
    }// end bpaircompare
    
    class beginqcompare implements Comparator{
        
        public int compare(java.lang.Object in1, java.lang.Object in2){
            int ci1=((blastpair)in1).beginq;
            int ci2=((blastpair)in2).beginq;
            if(ci1<ci2){
                return -1;
            }
            if(ci2<ci1){
                return 1;
            }
            return 0;
        }// end compare
        
    }// end class beginqcompare
    
    //------------------------------------------------------------------------------------------------------
    
    class blastpair {
        
        // this holds the blast pairwise hits
        
        /** Creates new seqobj */
        public blastpair() {
        }
        
        public void init(){
            seq="";
            query="";
            name="";
            beginseq=0;
            endseq=0;
            beginq=0;
            endq=0;
            coverage=1;
        }
        
        String seq="";
        String query="";
        String name="";
        int beginseq=0;
        int endseq=0;
        int beginq=0;
        int endq=0;
        float coverage=1;
        
    }// end class blastpair
    
    
}// end class b2malign
