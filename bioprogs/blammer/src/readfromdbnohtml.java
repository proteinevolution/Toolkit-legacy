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
public class readfromdbnohtml {
    
    //extract all sequences from all databases and write to separate files
    //this version reads the sequence names from a non-html format blast file

    File[] dbarr;
    HashMap seqnames;
    int verbose;
    int cpu;
    int numberofentries=0;
    
    /** Creates new readfromdb */
    public readfromdbnohtml(File[] dbarr, float cpu, int verbose) {
        this.dbarr=dbarr;
        this.cpu=(int)cpu;
        this.verbose=verbose;
        this.numberofentries=0;
        seqnames=new HashMap();
    }
    
    boolean extractseqs(File[] infiles,String extending){
        //read from non-html format blast file
        //called by main thread to get all sequences present in infiles[] as full length sequences from dbarr
        seqnames.clear();//better than new hashmap, saves some garbage collection but doesn't free the memory already used
        numberofentries=0;
        int nofiles=java.lang.reflect.Array.getLength(infiles);
        Vector linesvec=new Vector();//will hold the lines read from hdd
        filesseqs[] myfiles=new filesseqs[nofiles];//will hold data about which file wants which seqs
        for(int i=0;i<nofiles;i++){
            myfiles[i]=new filesseqs();
        }// end for i
        Vector namesseqs=new Vector();//will hold String[] with the sequence data
        readthread[] myreads=new readthread[cpu];//number of threads that read data from the blast files
        for(int i=0;i<cpu;i++){
            myreads[i]=new readthread(seqnames,this);
        }// end for i
        int findex=0;
        for(int i=0;i<nofiles;i++){
            if((findex=(infiles[i].getName()).lastIndexOf("."))>-1){
                myfiles[i].name=infiles[i].getName().substring(0,findex)+extending;//set the myfiles names to *.fas or so
            }
            if((findex==-1)){
                myfiles[i].name=infiles[i].getName()+extending;
            }
            if(verbose>0){
                System.out.print(".");
            }
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
                        }catch (InterruptedException e){
                            System.err.println("interrupted wait");
                            e.printStackTrace();
                        }
                    }
                }// end synchronized this
            }// end while waiting on threads
            myreads[currfree]=new readthread(seqnames,this);
            myreads[currfree].readfile=infiles[i];//filename to read
            myreads[currfree].seqsholder=myfiles[i];//what sequences were in this file
            myreads[currfree].isidle=false;
            myreads[currfree].start();
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
        //now all the orgfiles should have been read
        if(cpu<=1){//if there is only one (or less) cpu's, still run two threads
            cpu=2;//one to read from hdd and one to analyze the data read
        }
        readhddthread hddread=new readhddthread(dbarr,linesvec,this);
        getseqs[] mygets=new getseqs[cpu-1];//number of threads that will be checking linesvec
        boolean alldone=false;
        for(int i=0;i<cpu-1;i++){
            mygets[i]=new getseqs(linesvec,seqnames,this);
            mygets[i].cputhread=i;
            mygets[i].start();//this thread starts and the waits for hddread to start supplying data
        }
        hddread.start();//this reads the database(s) and supplied the data for the analyzing mygets threads
        while(alldone==false){
            boolean getdone=true;
            for(int i=0;i<cpu-1;i++){//check the mygets threads for completion
                if(hddread.isdone){//(readdone)){//If i am done reading the db (though might still have some lines in memory)
                    mygets[i].doneread=true;//tell the analyzing threads that all has been read
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
                            this.wait();
                        }
                    }// end synchronized this
                }catch (InterruptedException e){
                    System.err.println("Interrupted wait in readfromdb");
                    e.printStackTrace();
                }
            }//end if  alldone ==false
        }//end while alldone==false
        //now I need to loop through the outfiles, writing the right seqs to the right files
        for(int i=0;i<nofiles;i++){
            try{
                PrintWriter outfile=new PrintWriter(new BufferedWriter(new FileWriter(myfiles[i].name)));
                for(int j=0;j<java.lang.reflect.Array.getLength(myfiles[i].seqnames);j++){
                    if(seqnames.containsKey(myfiles[i].seqnames[j])){
                        seqobj currfasta=(seqobj)seqnames.get(myfiles[i].seqnames[j]);
                        if(currfasta.name.equals("")==false){
                            outfile.println(currfasta.name);
                            outfile.println(currfasta.seq.toUpperCase());
                        }
                    }//end if containskey
                }// end for j
                if(verbose>0){
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
        
        //this takes the data from invec one element at a time and compares it to what is present in the seqnames
        //hashmap. if the sequence is present save it to memory, else discard it
        
        boolean isdone=false;
        boolean killthread=false;
        boolean doneread=false;
        Vector linevec;
        HashMap seqnames;
        Object parent;
        int cputhread;
        
        getseqs(Vector invec,HashMap outseqs, Object parent){
            this.linevec=invec;
            this.seqnames=outseqs;
            this.parent=parent;
        }// end init
        
        public void run(){
            //get data from invec adn see if the sequence is present in seqnames hashmap
            //if so, assign the sequence to the corresponding name
            isdone=false;
            killthread=false;
            String nameline;
            String[] readarr=new String[0];
            String dummyname="dummyname";
            String seqline;
            doneread=false;
            while(killthread==false){//do until I say stop
                while(linevec.size()>0){
                    isdone=false;
                    boolean readnew=false;
                    while (readnew==false){
                        if((doneread)&&(linevec.size()==0)){//if reading of db is done (doneread==true)and there is no data left in memory to read
                            readnew=true;//exit while loop
                            break;
                        }
                        synchronized (linevec){
                            if(linevec.size()>0){//if there is sth. to be read
                                readarr=(String[])linevec.remove(0);//get the next fasta entry
                                readnew=true;
                            }
                        }// end synchronized
                        if(readnew==false){
                            try{
                                synchronized (this){
                                    this.wait(10);
                                }
                            }catch (InterruptedException e){
                                System.err.println("interrupted wait in getseqs");
                                e.printStackTrace();
                            }
                        }// end if
                    }// end while
                    if(readnew){//if I have read in some new data from the input vector
                        nameline=readarr[0];
                        if(nameline.startsWith(">")){//remove the > character
                            nameline=nameline.substring(1);
                        }
                        nameline=nameline.trim();
                        //now split everything in nameline on (\u0001 is for ncbi nr format)
                        String[] potnames=nameline.split("\u0001",0);//this splits the nameline into multiple gi entries
                        int potnamesnum=java.lang.reflect.Array.getLength(potnames);
                        int tmpint;
                        String[] tmparr;
                        for(int i=0;i<potnamesnum;i++){
                            tmparr=potnames[i].split("\\s+",2);
                            //see if tmparr[0] name appears in the nameshash seqnames
                            //System.out.println("checking "+tmparr[0]);
                            if(seqnames.containsKey(tmparr[0])){
                                seqobj currobj=(seqobj)seqnames.get(tmparr[0]);
                                if(currobj.name.equals("")){//if it is still a virgin element
                                    String currseq="";
                                    for (int j=1;j<java.lang.reflect.Array.getLength(readarr);j++){
                                        currseq+=readarr[j].trim();
                                    }
                                    currobj.name=readarr[0];//here is where the name that will be printed is put
                                    currobj.seq=currseq;
                                    seqnames.put(tmparr[0],currobj);
                                }//end if name==""
                            }else{//if the hashmap doesn't have this key (if blast was done without gi| output)
                                //if this is not the key, remove the gi and number and retry
                                //first see if this has a gi start
                                if(tmparr[0].startsWith("gi|")){//if that is the case do a more thorough test
                                    if((tmpint=tmparr[0].indexOf("|",4))!=-1){//if I have a valid subname
                                        nameline=tmparr[0].substring(tmpint+1);
                                        //now test the subname
                                        if((nameline.length()>0)&&(seqnames.containsKey(nameline))){
                                            //System.out.println("checking "+nameline);
                                            seqobj currobj=(seqobj)seqnames.get(nameline);
                                            if(currobj.name.equals("")){//if it is still a virgin element
                                                String currseq="";
                                                for (int j=1;j<java.lang.reflect.Array.getLength(readarr);j++){
                                                    currseq+=readarr[j].trim();
                                                }
                                                currobj.name=readarr[0];//here is where the name that will be printed is put
                                                currobj.seq=currseq;
                                                seqnames.put(nameline,currobj);
                                            }//end if name==""
                                        }
                                    }
                                }//end if startswith gi|
                            }
                        }// end for i
                    }// end if readnew new version
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
        
        //reads the database files and puts what was read into outvec
        
        File[] dbarr;
        Vector outvec;
        boolean isdone=false;
        //boolean dowait=false;
        String currdb="";
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
                //now read each of the database files in turn
                for(int i=0;i<java.lang.reflect.Array.getLength(dbarr);i++){
                    currseqs.clear();
                    currdb=dbarr[i].getName();
                    if(verbose>0){
                        System.out.println("reading db "+dbarr[i].getName());
                    }
                    reader=new BufferedReader(new FileReader(dbarr[i]));
                    while((inline=reader.readLine())!=null){
                        if(inline.startsWith(">")){//if this is the start of the next sequence
                            numberofentries++;
                            if(currseqs.size()>0){//if this is not the first sequence
                                currarr=new String[currseqs.size()];
                                currseqs.copyInto(currarr);//put all that belongs to this sequence into an array
                                while(outvec.size()>10000){//check to see that the other threads keep up with readhdd
                                    try{
                                        synchronized (this){
                                            wait(10);
                                        }
                                    }catch (InterruptedException e){
                                        System.err.println("Interrupted wait in readhddthread");
                                        e.printStackTrace();
                                    }
                                }// end while vecsize>3000
                                synchronized (outvec){//if the linevec is smaller than 10000 entries
                                    outvec.addElement(currarr);
                                }// end synchronized
                            }//end if size>0
                            currseqs.clear();
                            currseqs.addElement(inline);//make it the first element
                            continue;
                        }// end if line begins with a >
                        currseqs.addElement(inline);
                    }// end while !=null
                    if(currseqs.size()>0){//do the same for the last element at the end of file
                        currarr=new String[currseqs.size()];
                        currseqs.copyInto(currarr);
                        synchronized (outvec){
                            outvec.addElement(currarr);
                        }// end synchronized
                    }// end final currseq.size
                    reader.close();
                    if(verbose>0){
                        System.out.println("Done reading "+dbarr[i].getName());
                    }
                }// end for i
            }catch (IOException e){
                System.err.println("IOError in readthread");
                e.printStackTrace();
            }
            isdone=true;
            synchronized (parent){
                parent.notify();
            }
        }// end run
        
    }// END CLASS READHDDTHREAD
    //-----------------------------------------------------------------------------------------------------------
    
    class readthread extends Thread{
        
        //read in a given file and tries to extract all sequence names from the file into inhash
        
        HashMap seqnames;
        HashMap myseqnames;
        Object parent;
        File readfile;
        boolean isidle;
        filesseqs seqsholder=new filesseqs();
        
        public readthread(HashMap inhash,Object inparent){
            this.seqnames=inhash;
            this.parent=inparent;
            isidle=true;
            myseqnames=new HashMap();
        }
        
        public void run(){
            //System.out.println("extracting sequences for "+readfile.getName());
            //read the blast file and get the sequence names (NOT HTML FORMAT BLAST FILE)
            System.out.println("starting read for "+readfile.getName());
            isidle=false;
            Vector seqnamesvec=new Vector();
            myseqnames.clear();
            try{
                BufferedReader inread=new BufferedReader(new FileReader(readfile));
                String inline="";
                boolean doname=false;
                boolean readquery=false;
                String namestr="";
                while((inline=inread.readLine())!=null){
                    //System.out.println("inline="+inline);
                    if(inline.indexOf("Query=")>-1){
                        readquery=true;
                        //System.out.println("QUERY=TRUE");
                    }
                    if(inline.indexOf("letters)")>-1){
                        readquery=false;
                        //System.out.println("ENDQUERY");
                        continue;
                    }
                    if(readquery){
                        continue;
                    }
                    if(inline.startsWith(">")){//if this is the start of the nameline
                        doname=true;
                        namestr="";
                        //System.out.println("DONAME");
                    }
                    if(inline.indexOf("Length =")>-1){
                        //System.out.println("DONAME FOR "+namestr);
                        namestr=namestr.trim();
                        doname=false;
                        int begin;
                        String currname="";
                        //get the first name for this sequence from namestr
                        //only need one name for this sequence as I later on get the full name from the blasted database
                        if(namestr.startsWith(">")){//if I have a valid name
                            //remove the ">" and any whitespaces before the name
                            namestr=namestr.substring(1).trim();
                            //System.out.println("namestring="+namestr);
                            //now the sequence name is everything up to the first whitespace
                            String[] tmparr=namestr.split("\\s",2);
                            currname=tmparr[0];
                        }
                        if(currname.equals("")==false){
                            //System.out.println("Adding name="+currname);
                            seqnamesvec.addElement(currname);//will get put into filesseqs object that remembers which file had what seqs
                            if(myseqnames.containsKey(currname)==false){
                                myseqnames.put(currname,new seqobj());//put the name into a local hash and later add that hash to the global one
                            }
                        }// end if name = ""
                        //System.out.println("CURRNAME='"+currname+"'");
                    }// end if length
                    if(doname){
                        namestr+=" "+inline.trim();
                        //System.out.println("namestr="+namestr);
                    }
                }// end while readline
                //int elements=myseqnames.size();
                //now add the local hash to the global one (only one synchronized call)
                synchronized (seqnames){//now add the stuff in myseqnames to the seqnames hash
                    seqnames.putAll(myseqnames);//if seqnames has the key already defined it gets replaced.
                }//end synchronized seqnames
                //remove identical elements from seqnamesvec
                seqsholder.seqnames=new String[seqnamesvec.size()];
                seqnamesvec.copyInto(seqsholder.seqnames);
                myseqnames.clear();//clear the local hash
                seqnamesvec.clear();//clear the temporary vector
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
                //now I have unique sequence names in seqsholder.seqnames
            }catch(IOException e){
                System.err.println("cannot read from "+readfile.getName());
                e.printStackTrace();
                isidle=true;
                synchronized (parent){
                    parent.notify();
                }
                return;
            }
            System.out.println("done readthread"+readfile.getName());
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
