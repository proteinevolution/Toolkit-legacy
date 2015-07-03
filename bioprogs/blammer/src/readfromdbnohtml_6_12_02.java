/*
 * readfromdb.java
 *
 * Created on February 12, 2002, 1:44 PM
 */
import java.lang.*;
import java.io.*;
import java.util.*;
/**
 *
 * @author  noname
 * @version 
 */
public class readfromdbnohtml_6_12_02 {

    File[] dbarr;
    HashMap tax;
    HashMap seqnames;
    //boolean checktax;
    boolean verbose;
    int cpu;
    int numberofentries=0;
    
    /** Creates new readfromdb */
    //public readfromdbnohtml(File[] dbarr, HashMap tax, float cpu, boolean checktax, boolean verbose) {
    public readfromdbnohtml_6_12_02(File[] dbarr, HashMap tax, float cpu, boolean verbose) {
        this.dbarr=dbarr;
        this.tax=tax;
        this.cpu=(int)cpu;
        //this.checktax=checktax;
        this.verbose=verbose;
        this.numberofentries=0;
        seqnames=new HashMap();
    }

    //boolean extractseqs(File[] infiles,boolean checktax,String extending){
    boolean extractseqs(File[] infiles,String extending){
        seqnames=new HashMap();
        numberofentries=0;
        int nofiles=java.lang.reflect.Array.getLength(infiles);
        Vector linesvec=new Vector();//will hold the lines read from hdd
        filesseqs[] myfiles=new filesseqs[nofiles];//will hold data about which file wants which seqs
        for(int i=0;i<nofiles;i++){
            myfiles[i]=new filesseqs();
        }// end for i
        Vector namesseqs=new Vector();//will hold String[] with the sequence data
        readthread[] myreads=new readthread[cpu];//number of threads that read data from hdd
        for(int i=0;i<cpu;i++){
            myreads[i]=new readthread(seqnames,tax,this);
        }// end for i
        int findex=0;
        for(int i=0;i<nofiles;i++){
            if((findex=(infiles[i].getName()).lastIndexOf("."))>-1){
                myfiles[i].name=infiles[i].getName().substring(0,findex)+extending;
            }
            if((findex==-1)){
                myfiles[i].name=infiles[i].getName()+extending;
            }
            //if(verbose){
            //    System.out.println("doing "+infiles[i].getName());
            //}
            if(verbose){
                System.out.print(".");
            }
//            System.out.println("read file "+myfiles[i].name);
            //assigned the new outfilename
            //start new thread and read the seqnames from the current file
            int currfree=-1;
            OUTLOOP:while (currfree==-1){
                synchronized (this){
                    for(int j=0;j<cpu;j++){
                        if(myreads[j].isidle){
                            currfree=j;
                            break OUTLOOP;//exit for loop
                        }
                    }//end for j
                    if(currfree==-1){
                        try{
                            this.wait();
                            //System.out.println("end wait()");
                        }catch (InterruptedException e){
                            System.err.println("interrupted wait");
                            e.printStackTrace();
                        }
                    }
                }// end synchronized this
            }// end while waiting on threads
            myreads[currfree]=new readthread(seqnames,tax,this);
            myreads[currfree].readfile=infiles[i];
            myreads[currfree].seqsholder=myfiles[i];
            myreads[currfree].isidle=false;
            myreads[currfree].start();
        //    System.out.println("myreads.start");
        }// end for i
        //check that all threads have finished reading
        boolean allfree=false;
        while (allfree==false){
            synchronized (this){
                allfree=true;
                for(int j=0;j<cpu;j++){
                    if(myreads[j].isidle==false){
                        allfree=false;
                    }
                }//end for j
                if(allfree==false){
                    try{
                        //System.out.println("waiting on thread to finish");
                        this.wait();
                        //System.out.println("end wait()");
                    }catch (InterruptedException e){
                        System.err.println("interrupted wait");
                        e.printStackTrace();
                    }
                }
            }// end synchronized this
        }// end while waiting on threads
        //end checking read status of threads
//        System.out.println();
        //now all the orgfiles should have been read
        if(cpu<=1){//if there is only one (or less) cpu's, still run two threads
            cpu=2;
        }
        readhddthread hddread=new readhddthread(dbarr,linesvec,this);
        getseqs[] mygets=new getseqs[cpu-1];//number of threads that will be checking linesvec
        boolean alldone=false;
        for(int i=0;i<cpu-1;i++){
            mygets[i]=new getseqs(linesvec,tax,seqnames,this);
            mygets[i].cputhread=i;
            mygets[i].start();//this thread starts and the waits for hddread to start supplying data
        //    System.out.println("start gets");
        }
        hddread.start();//this reads the database(s) and supplied the data for the analyzing mygets threads
        //System.out.println("start read");
        while(alldone==false){
            //System.out.println("in while alldone==false");
            //boolean readdone=hddread.isdone;
            boolean getdone=true;
            for(int i=0;i<cpu-1;i++){//check the mygets threads for completion
                //System.out.print(",");
                if(hddread.isdone){//(readdone)){//If i am done reading the db (though might still have some lines in memory)
                    mygets[i].doneread=true;
                    numberofentries=hddread.numberofentries;
                }
                synchronized (mygets[i]){
                    mygets[i].notify();
                }
                if(mygets[i].isdone==false){
                    getdone=false;
                }
            }
            if((getdone)&&(hddread.isdone)){
                //System.out.print("alltrue");
                alldone=true;
                for(int i=0;i<cpu-1;i++){
                    mygets[i].killthread=true;
                }// end for i
            }//if all is done
            if(alldone==false){
                try{
                    synchronized (this){
                        //re-check mygets to see if done, this time in synchr. loop
                        getdone=true;
                        for(int i=0;i<cpu-1;i++){
                            if(mygets[i].isdone==false){
                                getdone=false;
                            }
                        }// end for 
                        if(((getdone==false)&&(hddread.isdone==false))){
                            //System.out.print("dw"+hddread.isdone);
                            this.wait();
                        }
                        //readdone=hddread.isdone;//true;
                    }// end synchronized this
                }catch (InterruptedException e){
                    System.err.println("Interrupted wait in readfromdb");
                    e.printStackTrace();
                }
            }//end if  alldone ==false
        }//end while alldone==false
        //now I need to loop through the outfiles, writing the right seqs to the right files
//        System.out.println("writing to files");
        for(int i=0;i<nofiles;i++){
            try{
                PrintWriter outfile=new PrintWriter(new BufferedWriter(new FileWriter(myfiles[i].name)));
                for(int j=0;j<java.lang.reflect.Array.getLength(myfiles[i].seqnames);j++){
                    if(seqnames.containsKey(myfiles[i].seqnames[j])){
                        seqobj currfasta=(seqobj)seqnames.get(myfiles[i].seqnames[j]);
                        if(currfasta.name.equals("")==false){
                            outfile.println(currfasta.name);
                            outfile.println(currfasta.seq.toUpperCase());
//                            System.out.println(currfasta.name);
//                            System.out.println(currfasta.seq);
                        }
                    }//end if containskey
                }// end for j
                if(verbose){
                    System.out.print(".");
                }
                outfile.close();
            }catch (IOException e){
                System.err.println("ERROR in writing to outfile "+myfiles[i].name);
                e.printStackTrace();
            }
        }// end for i
        mygets=new getseqs[0];
        return true;
    }// end extractseqs
    
    //------------------------------------------------------------------------------------------------------------
    class getseqs extends Thread{
        
        boolean isdone=false;
        boolean killthread=false;
        boolean doneread=false;
        Vector linevec;
        HashMap tax;
        HashMap seqnames;
        Object parent;
        int cputhread;
        
        getseqs(Vector invec,HashMap intax,HashMap outseqs,Object parent){
            this.linevec=invec;
            this.tax=intax;
            this.seqnames=outseqs;
            this.parent=parent;
        }// end init
        
        public void run(){
            isdone=false;
            killthread=false;
            String nameline;
            String[] readarr=new String[0];
            String dummyname="dummyname";
            String seqline;
            doneread=false;
            while(killthread==false){
//                System.out.print("'");
                while(linevec.size()>0){
 //                   System.out.print("|");
                    isdone=false;
                    boolean readnew=false;
                    while (readnew==false){
                        if((doneread)&&(linevec.size()==0)){//if reading of db is done and there is no data left in memory to read
                            readnew=true;//exit while loop
                            break;
                        }
                        synchronized (linevec){
                            if(linevec.size()>0){//if there is sth. to be read
                                readarr=(String[])linevec.remove(0);//get the next fasta entry
                                //System.out.print("-");
                                readnew=true;
                            }
                        }// end synchronized
                        if(readnew==false){
                            try{
                                synchronized (this){
//                                    System.out.print("w2");
                                    this.wait(10);
                                }
                            }catch (InterruptedException e){
                                System.err.println("interrupted wait in getseqs");
                                e.printStackTrace();
                            }
                        }// end if
                    }// end while
                    if(readnew){//if I have read in some new data from the input vector
                        boolean foundnext=true;
                        int pos=0;
                        while (foundnext){
                            foundnext=false;
                            int begin;
                            nameline="";
                            if((begin=readarr[0].indexOf("gi|",pos))>-1){
                                int end;
                                if((end=readarr[0].indexOf("|",begin+3))>-1){
                                    nameline=readarr[0].substring(begin+3,end);
                                    pos=end;
                                    foundnext=true;
                                }
                            }
                            if((foundnext==false)&&((begin=readarr[0].indexOf("gt|",pos))>-1)){
                                int end;
                                if((end=readarr[0].indexOf("|",begin+3))>-1){
                                    nameline="t"+readarr[0].substring(begin+3,end);
                                    pos=end;
                                    foundnext=true;
                                }
                            }
                            //nameline=extractname(dummyname,readarr[0]);
                            if((foundnext)&&(nameline.equals("")==false)){
                                if(seqnames.containsKey(nameline)){
                                    seqobj currobj=(seqobj)seqnames.get(nameline);
                                    if(currobj.name.equals("")){//if it is still a virgin element
                                        String currseq="";
                                        for (int i=1;i<java.lang.reflect.Array.getLength(readarr);i++){
                                            currseq+=readarr[i].trim();
                                        }
                                        currobj.name=readarr[0];//here is where the name that will be printed is put
                                        currobj.seq=currseq;
                                        seqnames.put(nameline,currobj);
                                    }//end if name==""
                                    break;// end while foundnext
                                }//end if haskey nameline
                            }// end if name=""
                        }// end while foundnext
                    }// end if readnew
                }// end while linevec.size>0
                if((doneread)&&(linevec.size()==0)){//if the reading of the db is done and no data in memory
                    isdone=true;
                    killthread=true;
                    synchronized (parent){
                        parent.notify();
                    }
                    break;//exit the while killthread loop
                }else{
                    synchronized (this){
                        try{
 //                           System.out.print(doneread+"-"+linevec.size());
                            this.wait(10);
                        }catch (InterruptedException e){
                            System.err.println("interrupted wait in getseqs");
                        }
                    }
                }
            }// end while killthread
        }// end run
        
    }// end class getseqs
    //-----------------------------------------------------------------------------------------------------------
    
    class readhddthread extends Thread{
        
        File[] dbarr;
        Vector outvec;
        boolean isdone=false;
        //boolean dowait=false;
        String currdb="";
        int linecount=0;
        int numberofentries=0;
        Object parent;
        
        readhddthread(File[] dbarr,Vector outvec,Object parent){
            this.dbarr=dbarr;
            this.outvec=outvec;
            this.parent=parent;
            this.numberofentries=0;
        }
        
        public void run(){
            isdone=false;
            Vector currseqs=new Vector();
            String[] currarr;
            BufferedReader reader;
            String inline;
            numberofentries=0;
            try{
                for(int i=0;i<java.lang.reflect.Array.getLength(dbarr);i++){
                    currseqs.clear();
                    currdb=dbarr[i].getName();
                    if(verbose){
                        System.out.println("reading db "+dbarr[i].getName());
                    }
                    linecount=0;
                    reader=new BufferedReader(new FileReader(dbarr[i]));
                    while((inline=reader.readLine())!=null){
 //                       System.out.print("-");
                        linecount+=1;
//                        if(dowait){
//                            try{
//                                synchronized (this){
//                                    this.wait(20);
//                                }
//                            }catch (InterruptedException e){
//                                System.out.println("interrupted wait in readhdd");
//                                e.printStackTrace();
//                            }
//                        }
                        if(inline.startsWith(">")){
                            numberofentries+=1;
                            if(currseqs.size()>0){
                                currarr=new String[currseqs.size()];
                                currseqs.copyInto(currarr);
                                while(outvec.size()>3000){//check to see that the other threads keep up with readhdd
                                    try{
                                        synchronized (this){
                                            wait(10);
                                        }
                                    }catch (InterruptedException e){
                                        System.err.println("Interrupted wait in readhddthread");
                                        e.printStackTrace();
                                    }
                                }// end while vecsize>3000
                                synchronized (outvec){//if the linevec is smaller than 3000 entries
 //                                   System.out.print("+");
                                    outvec.addElement(currarr);
                                    //System.out.print("+");
                                }// end synchronized
                            }//end if size>0
                            currseqs.clear();
                            currseqs.addElement(inline);//make it the first element
                            continue;
                        }// end if line begins with a >
                        currseqs.addElement(inline);
                    }// end while !=null
                    if(currseqs.size()>0){
                        currarr=new String[currseqs.size()];
                        currseqs.copyInto(currarr);
                        synchronized (outvec){
//                            System.out.println("+e");
                            outvec.addElement(currarr);
                            //System.out.print("+");
                        }// end synchronized
                    }// end final currseq.size
                    reader.close();
 //                   System.out.println();
                    if(verbose){
                        System.out.println("Done reading "+dbarr[i].getName());
                    }
                }// end for i
            }catch (IOException e){
                System.err.println("IOError in readthread");
                e.printStackTrace();
            }
            isdone=true;
            synchronized (parent){
                //System.out.println("done "+linecount+" lines read");
                parent.notify();
            }
        }// end run
        
    }// END CLASS READHDDTHREAD
    //-----------------------------------------------------------------------------------------------------------
    /*
    String extractname(String queryname,String instr){
        Vector tmpvec=new Vector();
        boolean foundnext=true;
        boolean foundspec=false;
        int currpos=0;
        String outstr=new String("");
        int ns=0;
        while (foundnext){
            if((ns=instr.indexOf("gi|",currpos))>-1){
                int ne;
                if((ne=instr.indexOf("|",(ns+3)))>0){
                    outstr=instr.substring((ns+3),ne);
                }
                String specstr=getspecname(instr,ne,tax);
                if((checktax==false)||(specstr.indexOf("unknown taxonomy")==-1)){//if the species name was found in taxonomy
                    outstr=outstr+" "+specstr;
                    tmpvec.addElement(outstr);
                    foundspec=true;
                }
                currpos=ne;
                continue;
            }// end if gi
            if((ns=instr.indexOf("gt|",currpos))>-1){
                int ne;
                if((ne=instr.indexOf("|",(ns+3)))>0){
                    outstr="t"+instr.substring((ns+3),ne);
                }
                String specstr=getspecname(instr,ne,tax);
                if((checktax==false)||(specstr.indexOf("unknown taxonomy")==-1)){//if the species name was found in taxonomy
                    outstr=outstr+" "+specstr;
                    tmpvec.addElement(outstr);
                    foundspec=true;
                }
                currpos=ne;
                continue;
            }// end if gt
            foundnext=false;
        }// end while
        boolean hasquery=false;
        if((foundspec==false)&&(tmpvec.size()>0)){
            foundspec=true;
        }
        for(int i=0;i<tmpvec.size();i++){
            if((((String)tmpvec.elementAt(i)).indexOf(queryname))>-1){
                return ((String) tmpvec.elementAt(i));
            }
        }
        if(foundspec){
            return ((String)tmpvec.elementAt(0));
        }
        return outstr+" [unknown taxonomy]";
    }
    //-----------------------------------------------------------------------------------------------------//
    String getspecname(String instr, int inpos,HashMap intax){
        boolean foundnext=true;
        Vector tmpvec=new Vector();
        int begin;
        int end;
        while ((foundnext)&&(inpos<instr.length())){
            if((begin=instr.indexOf("[",inpos))>-1){
                if((end=instr.indexOf("]",begin))>-1){
                    inpos=end;
                    tmpvec.addElement(instr.substring(begin+1,end));
                    //System.out.println("added "+instr.substring(begin+1,end));
                    continue;
                }
                foundnext=false;
            }
            foundnext=false;
        }// end while
        String currstr="";
        for(int i=0;i<tmpvec.size();i++){
            //get rid of extra spaces and tabs
            currstr="";
            boolean dospace=true;
            for(int j=0;j<((String)tmpvec.elementAt(i)).length();j++){
                if(Character.isWhitespace((((String)tmpvec.elementAt(i)).charAt(j)))==false){
                    currstr+=((String)tmpvec.elementAt(i)).charAt(j);
                    dospace=true;
                    continue;
                }
                if((dospace)&&(Character.isWhitespace(((String)tmpvec.elementAt(i)).charAt(j)))){
                    currstr+=" ";
                    dospace=false;
                }
            }// end for j
            //System.out.println(i+"--"+currstr);
            //check to see if this is a species in taxonomy
             if((checktax)&&(intax.containsKey(currstr))&&(currstr.equals("")==false)){
                return "["+currstr+"]";
             }
             //
        }// end for i
        if(checktax){
            //System.out.println();
            //System.out.println("unknown taxonomy for "+currstr+" fed "+instr);
        }
        //System.out.println("returning "+currstr);
        return "[unknown taxonomy]";
    }// end getspecname
    
    //-----------------------------------------------------------------------------------------------------------
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
    */
   //------------------------------------------------------------------------------------------------------------
    
    class readthread extends Thread{
        
        HashMap seqnames;
        Object parent;
        File readfile;
        HashMap tax;
        boolean isidle;
        filesseqs seqsholder=new filesseqs();
        
        public readthread(HashMap inhash,HashMap intax,Object inparent){
            this.seqnames=inhash;
            this.parent=inparent;
            this.tax=intax;
            isidle=true;
        }
        
        public void run(){
            //System.out.println("extracting sequences for "+readfile.getName());
            isidle=false;
            Vector seqnamesvec=new Vector();
            try{
                BufferedReader inread=new BufferedReader(new FileReader(readfile));
                String inline="";
                boolean doname=false;
                boolean readquery=false;
                String namestr="";
                //String queryname="";
                //boolean donereadquery=false;
                while((inline=inread.readLine())!=null){
                    if(inline.indexOf("Query=")>-1){
                        readquery=true;
                    }
                    if(inline.indexOf("letters)")>-1){
                        //if(readquery){
                        //    donereadquery=true;
                        //}
                        readquery=false;
                        //queryname=extractqueryname(queryname);
                        continue;
                    }
                    if(readquery){
                        //queryname+=" "+inline.trim();
                        continue;
                    }
                    //if(inline.indexOf("><a name =")>-1){
                    if((inline.indexOf(">gi|")>-1)||(inline.indexOf(">gt|")>-1)){
                        doname=true;
                        namestr="";
                    }
                    if(inline.indexOf("Length =")>-1){
                        doname=false;
                        int begin;
                        String currname="";
                        if((begin=namestr.indexOf("gi|"))>-1){
                            currname=namestr.substring(begin+3,namestr.indexOf("|",begin+3));
                        }// end if gi
                        if((begin=namestr.indexOf("gt|"))>-1){
                            currname="t"+namestr.substring(begin+3,namestr.indexOf("|",begin+3));
                        }// end if gi
                        //String currname=extractname(queryname,namestr);
                        if(currname.equals("")==false){
                            seqnamesvec.addElement(currname);
                            synchronized (seqnames){
                                if(seqnames.containsKey(currname)==false){
                                    seqnames.put(currname,new seqobj());
                                }
                            }//end synchronized seqnames
                        }// end if name = ""
                    }// end if length
                    if(doname){
                        namestr+=" "+inline.trim();
                    }
                }// end while readline
                //remove identical elements from seqnamesvec
                seqsholder.seqnames=new String[seqnamesvec.size()];
                seqnamesvec.copyInto(seqsholder.seqnames);
                seqnamesvec.clear();
                for(int i=0;i<java.lang.reflect.Array.getLength(seqsholder.seqnames);i++){
                    boolean hassame=false;
                    for(int j=0;j<seqnamesvec.size();j++){
                        if(seqsholder.seqnames[i].equals((String)seqnamesvec.elementAt(j))){
                            hassame=true;
                            break;
                        }
                    }// end for j
                    if(hassame==false){
                        seqnamesvec.addElement(seqsholder.seqnames[i]);
                    }// end if hassame
                }// end for i
                seqsholder.seqnames=new String[seqnamesvec.size()];
                seqnamesvec.copyInto(seqsholder.seqnames);
                inread.close();
            }catch(IOException e){
                System.err.println("cannot read from "+readfile.getName());
                e.printStackTrace();
                isidle=true;
                synchronized (parent){
                    parent.notify();
                }
                return;
            }
            //System.out.println("done readthread"+readfile.getName());
            //System.out.println("extracting "+seqnamesvec.size()+" sequences");
            isidle=true;
            synchronized (parent){
                parent.notify();
            }
        }// end run
        
    }// end readthread
    
   
    
   //------------------------------------------------------------------------------------------------------------
    class seqobj{
        String name;
        String seq;
        seqobj(){   
            name="";
            seq="";
        }
    }// end class seqobj
    
    //-----------------------------------------------------------------------------------------------------------
    
    class filesseqs{
        String name;
        String[] seqnames;
        
        filesseqs(){
            name="";
            seqnames=new String[0];
        }
    }// end class filesseqs
    
}// end class readfromdb
