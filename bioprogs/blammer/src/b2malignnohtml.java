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
public class b2malignnohtml {
    
    //conver the blast files to multiple alignments
    //this is for the non-html version of blast outputs
    
    /** Creates new b2malign */
    public b2malignnohtml() {
        
    }
    
    int begintmp=0;
    int endtmp=0;
    int querygaps=0;
    float coveragetmp=1;
    String queryname;
    int querylength=1;
    
    public String[] malign(BufferedReader inread,float coverage,double blastmax,double scval,float minsim){
        //this reads in a blast file and spits out an array containing name, search seq and hitseq for each blast hit
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
        String tmpstr="";
        queryname="";
        boolean readname=false;
        boolean readseq=false;
        boolean readquery=false;
        boolean querydone=false;
        boolean stopread=false;//a way of stopping the read other than reaching EOF
        boolean scoreread=false;//used for multi hits in blast
        double edef=(double)100;
        double evalue=edef;
        double score=1;
        int linecount=0;//for debugging
        int subjectlength=1;
        Vector tmpvec=new Vector();
        float myident=0;
        String myidentstr;
        try{
            while (((str=inread.readLine())!=null)&&(stopread==false)){
                linecount+=1;
                if(querydone==false){//if I have not yet read in a query, skip everything (headers, etc.) that is not the query
                    if(str.indexOf("Query=")>-1){
                        readquery=true;
                    }
                    int endql;
                    if((endql=str.indexOf("letters)"))>-1){
                        //queryname goes from <b>Query=</b> to last "(" before "letters)"
                        //here i also get the query length from the last line read.
                        int startql;
                        if((startql=str.lastIndexOf("("))>-1){
                            try{
                                tmpstr=(str.substring(startql+1,endql)).trim();
                                tmpstr=tmpstr.replaceAll("\\D", "");
                                querylength=Integer.parseInt(tmpstr);
                            }catch (NumberFormatException e){
                                System.err.println("error in parsing query length:"+str.substring(startql+1,endql));
                            }
                        }// end if startql
                        querydone=true;
                        queryname=extractqueryname(queryname);
                        continue;
                    }//end if endql
                    if(readquery){
                        queryname=queryname+str;
                        continue;
                    }
                }// end if querydone==false
                if(str.startsWith(">")){//this is the beginning of a seqname
                    //If I have read some seqdata, do as if </pre> in html format
                    currquery=extractquery(currquery);
                    currpair.query=currquery;
                    currpair.beginq=begintmp;
                    currpair.endq=endtmp;
                    currseq=extractseq(currseq);
                    currpair.beginseq=begintmp;
                    currpair.endseq=endtmp;
                    currpair.seq=currseq;
                    currpair.coverage=coveragetmp;
                    scoreread=false;
                    if(((blastmax==-1)||(evalue<=blastmax))&&((scval==-1)||(scval<(score/subjectlength)))&&((minsim<=0)||(minsim<=myident))){//blastmax==-1 = don't check
                        tmpvec.addElement(currpair);
                    }
                    currpair=new blastpair();//need to make new blastpair because tmpvec is still referencing this element
                    currseq="";
                    readseq=false;
                    readname=true;
                    if(tmpvec.size()>0){
                        blastpair[] testpair=collapsetmpvec(tmpvec);
                        for(int i=java.lang.reflect.Array.getLength(testpair)-1;i>=0;i--){
                            if(testpair[i].coverage>=coverage){
                                vec.addElement(testpair[i]);
                            }
                            evalue=edef;
                        }
                    }
                    tmpvec.clear();
                    currname="";
                    currseq="";
                    currquery="";
                    myident=0;
                }//end if nameline
                if(readname==true){
                    int strs;
                    if((strs=str.indexOf("Length ="))>-1){
                        String lengthstring=(str.substring(strs+8)).trim();
                        try{
                            //blast puts commas as 1000 separators, this messes up parsing
                            lengthstring=lengthstring.replaceAll("\\D","");
                            subjectlength=Integer.parseInt(lengthstring);
                        }catch (NumberFormatException e){
                            System.err.println("unable to parse int from "+subjectlength+" for "+currname);
                            subjectlength=1;
                        }
                        readname=false;
                        currname=extractname(currname);
                        continue;
                    }
                    //if this currstr has no "Length =" just add it to the current namestr.
                    currname+="\u0001"+str;
                    continue;
                }
                int strs;
                if((strs=str.indexOf("Score ="))>-1){
                    if(scoreread==true){//if this is a second hit for this sequence
                        currquery=extractquery(currquery);//extract the query sequence
                        currpair.query=currquery;
                        currpair.beginq=begintmp;
                        currpair.endq=endtmp;
                        currseq=extractseq(currseq);//extract the hit sequence
                        currpair.beginseq=begintmp;
                        currpair.endseq=endtmp;
                        currpair.seq=currseq;
                        currpair.coverage=coveragetmp;
                        if(((blastmax==-1)||(evalue<=blastmax))&&((scval==-1)||(scval<(score/subjectlength)))&&((minsim<=0)||(minsim<=myident))){//blastmax==-1 = don't check
                            tmpvec.addElement(currpair);
                        }
                        currpair=new blastpair();//need to make new blastpair because tmpvec is still referencing this element
                        currseq="";
                        readseq=false;
                        
                    }else{
                        scoreread=true;
                    }
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
                    //now get the information about how many seqs were identical
                    //format: Identities = 12/28 (42%), Positives = 19/28 (67%)
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
                if(str.indexOf("Frame =")>-1){
                    //if this is a tblastn run I have an extra Frame = line
                    continue;
                }
                if(readseq){
                    if(str.indexOf("Query:")>-1){
                        currquery=currquery+str;
                        continue;
                    }
                    if(str.indexOf("Sbjct:")>-1){
                        currseq=currseq+str;
                        continue;
                    }
                    if(str.indexOf("Database:")>-1){//if I am at the end of the file
                        //add the last element read
                        //if((str.indexOf("</PRE>")>-1)||(str.indexOf("</pre>")>-1)){// if </PRE> is on the line /PRE for blast /pre for psyblast
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
                        readseq=false;
                        //}// end if </PRE>
                    }// end if database
                }// end if readseq
            }// end while readline
            //System.out.println("DONE fileread");
        }catch (IOException e){
            System.err.println("IOError in malign reading");
            e.printStackTrace();
        }
        if(tmpvec.size()>0){//if I have one or more hsp in tmpvec
            blastpair[] testpair=collapsetmpvec(tmpvec);//collapse them to one or more sequences
            for(int i=java.lang.reflect.Array.getLength(testpair)-1;i>=0;i--){
                if(testpair[i].coverage>=coverage){
                    vec.addElement(testpair[i]);
                }
            }
        }// end if tmpvec.size==0
        vec=removeidenticals(vec);
        //now put the name that contains queryname to position 0 in the vector
        int vecsize=vec.size();
        blastpair tmppair;
        for(int i=0;i<vecsize;i++){
            tmppair=(blastpair)vec.elementAt(i);
            if((tmppair.name.indexOf(queryname)>-1)||(queryname.indexOf(tmppair.name)>-1)){//if either of the names contains the other
                vec.removeElementAt(i);
                vec.insertElementAt(tmppair,0);
            }
        }//end for i
        String[] outarr=convertmainvec(vec);
        return outarr;
    }// end malign
    
    
    //-------------------------------------------------------------------------------------------------------
    
    String extractqueryname(String instr){
        //get the query name from the top of the blast file
        //Query= testpsyname
        //            (298 letters)
        String outstr=new String("");
        int ns=0;
        String[] tmparr=instr.split("uery=\\s*",2);//split at first ocurrance, get Q as first String
        if(tmparr[0].equals("Q")){
            //now split at the frist whitespace you find in the name
            tmparr=tmparr[1].split("\\s+",2);
            //System.out.println("queryname='"+tmparr[0]+"'");
            outstr=tmparr[0].trim();
        }else{//if I could not split on this regex
            System.err.println("ERROR extractqueryname:unable to get queryname for "+instr);
            outstr=instr;
        }
        return outstr;
    }//end extractqueryname
    
    //------------------------------------------------------------------------------------------------------
    
    String extractname(String instr){
        //System.out.println("extracting name for "+instr);
        //get the sequence description from instr (all of them, to compare against queryname)
        Vector tmpvec=new Vector();
        boolean foundnext=true;
        int currpos=0;
        String outstr=new String("");
        int ns=0;
        //look for the formatting text from blast/psyblast
        //should be: >NAME CORRESPONDING TEXT
        //                  more text
        //            next_name text etc..
        //split on newline or return char
        String[] namearr=instr.split("\u0001",0);//split all on the former newlines which I replaced with \u0001
        //now see if the elements in the namearr start with > or one space
        //(if more than one space it is a continuation of a name)
        String[] tmparr;
        for(int i=0;i<java.lang.reflect.Array.getLength(namearr);i++){
            if(namearr[i].length()>2){
                if(namearr[i].startsWith(">")){//if this is the first name
                    tmparr=(namearr[i].substring(1).trim()).split("\\s+",2);//get the name from the second char to first space
                    tmpvec.addElement(tmparr[0]);
                    continue;
                }
                if(namearr[i].startsWith("  ")){//if the line starts with more than one space
                    continue;
                }else{//this should be an alternate name
                    tmparr=(namearr[i].trim()).split("\\s+",2);//skip the spaces at the start char and get everything to the next space
                    if(tmparr[0].length()>0){
                        tmpvec.addElement(tmparr[0]);
                    }
                }
            }// end if length>2
        }// end for i
        for(int i=0;i<tmpvec.size();i++){
            //System.out.println("checking "+(String)tmpvec.elementAt(i));
            //now see if any of this sequences names correspond to the queryname
            if((((String)tmpvec.elementAt(i)).indexOf(queryname))>-1){//if this name contains the query
                return ((String) tmpvec.elementAt(i));
            }
            if(queryname.indexOf(((String)tmpvec.elementAt(i)))>-1){
                return queryname;
            }
        }
        if(tmpvec.size()<1){
            System.err.println("ERROR extractname: unable to get names from "+instr);
            return instr;
        }
        //String allnames=String.valueOf(java.lang.reflect.Array.getLength(namearr));
        //for(int i=0;i<tmpvec.size();i++){
        //    allnames=allnames+"_"+((String)tmpvec.elementAt(i));
        //}// end for i
        //return allnames;
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
                                    querygaps++;
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
                        querygaps++;
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
    }//end extractquery
    
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
        //coveragetmp=(float)((float)outstr.length()-(float)(gapcounter+querygaps))/(float)querylength;
        coveragetmp=(float)((float)outstr.length()-(float)(querygaps))/(float)querylength;
        //coveragetmp=(float)((outstr.replaceAll("-","")).length()-querygaps)/(float)querylength;
        return outstr;
    }
    
    //------------------------------------------------------------------------------------------------------
    
    
    blastpair[] collapsetmpvec(Vector invec){
        int vecsize=invec.size();
        blastpair[] tmparr=new blastpair[vecsize];
        invec.copyInto(tmparr);
        //as alternative sort by begin of blastquery
        java.util.Arrays.sort(tmparr,new beginqcompare());//sort by start of query sequence to take circular perm. into account
        blastpair curr;
        blastpair tmp=tmparr[0];
        vecsize=java.lang.reflect.Array.getLength(tmparr);
        invec.clear();
        for(int i=0;i<vecsize;i++){
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
                outvec.addElement(invec.elementAt(i));
            }
        }// end for i
        return outvec;
    }//end removeidenticals
    
    //------------------------------------------------------------------------------------------------------
    
    String[] convertmainvec(Vector invec){
        //this takes a vector with pairwise alignments and converts it to a multiple alignment
        int vecsize=invec.size();
        //System.out.println("vecsize="+vecsize);
        String[][] seqarr=new String[vecsize][2];// holds query in 0 and seq in 1
        int [][] startarr=new int[vecsize][2]; //holds start position for query 0 and hitseq 1
        String[] namesarr=new String[vecsize+1];//holds hitnames+queryname;
        namesarr[vecsize]=queryname;//last element=queryname
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
        // info about where the start of each query+sequence is
        // the sequence names
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
