/*
 * main.java
 *
 *Copyright (C) 2004 Tancred Frickey
 *Distributed under the GNU General Public Licence
 *This program is free software; you can redistribute it and/or modify
 *it under the terms of the GNU General Public License as published by
 *the Free Software Foundation.
 *
 *This program is distributed in the hope that it will be useful,
 *but WITHOUT ANY WARRANTY; without even the implied warranty of
 *MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *GNU General Public License for more details.
 *
 *
 */
import java.io.*;
import java.lang.*;
import java.util.*;
/**
 *
 * @author  noname
 * @version
 */
public class main {
    
    /** Creates new main */
    public main() {
    }
    
    /**
     * @param args the command line arguments
     */
    //assign defaults
    float dbfilesizemultiplier=(float)0.0025;//what sizeof(dbfile) is multiplied with to set the initial hashMap size
    float dbloadfactor=(float)0.85;
    //
    //boolean dodbclustal=false;
    boolean dochecktax=false;
    boolean taxid=false;//do I want to get the taxonomic designation from the ncbi taxid file?
    boolean doextractseq=true;
    boolean dohmmbuild=true;
    boolean dohmmsearch=true;
    boolean dohmmalign=true;
    boolean dohmmcalibrate=false;
    boolean doclustal=true;
    boolean dostrictextract=true;
    boolean redo=false;
    boolean allfiles=false;//do I want to print out all temp files
    boolean errorless=true;
    boolean addhmmszval=false;
    boolean lowmem=true;//should always be true, now this is faster than reading db into hash
    boolean html=true;
    boolean getdissim=true;
    boolean changehmmbuild=false;
    boolean changehmmsearch=false;
    boolean changehmmcalibrate=false;
    boolean changehmmalign=false;
    boolean checkquery=true;
    String hmmalignstring="";
    String hmmcalibratestring="";
    String hmmsearchstring="";
    String hmmbuildstring="";
    String fname="infile.txt";
    String conffname="blammer.conf";
    String cluextens=".cln";
    String hmmextens=".hmm";
    String extrextens=".fas";
    String strictextens=".fass";
    String hmmsextens=".hms";
    String hlnextens=".hln";
    String command="";
    String[] blastdb;
    String clustring="clustalw";
    File taxdir=new File(".");
    File homedir=new File(".");
    File hmmer=new File(".");
    File[] infiles;
    float coverage=(float)0;
    float maxsim=(float)1;
    float minsim=(float)0;//minimum sequence identity
    float cpu=1;
    float filesblocks=1; //in how many blocks should the complete file[] be subdivided before extraction
    float simstep=(float)0.1;
    float maxhmmsim=(float)0.7;
    double blastmax=0.00001;
    double scval=-1;//minimum score per collumn; -1=not set (default)
    double blastmin=10;
    double hmmseval=blastmax;
    double hmmszval;
    int cluwidth=5;//how many collumns without gaps are necessary to not be fed into clustal anymore
    int seqs=100;
    int hmmseqs=-1;//how many sequences to use for hmmbuild alignment -1=unlimited
    int numberofentries=0;
    int hmmcalnum=5000;//default for hmmcalibrate
    int oformat=0;//output format for the alignments (0=fasta, 1=clustal,rest=later?)
    int verbose=10;//verbose level
    int taxlevel=3;//do I want to use no tax (0) or genus(1) or species(2) or all (3) to check for maxsim
    HashMap tax;//ncbi taxonomy file (maps names to id's)
    HashMap idtax;//inverse of tax (maps id's to names)
    taxid mytaxid;//ncbi taxid file
    readfromdb readdb;
    readfromdbnohtml readdbno;
    String[] args;
    
    //-------------------------------------------------------------------------------------------------------
    
    main(String args[]) {
        this.args=args;
    }
    
    void run(){
        numberofentries=0;
        //defaults are set, read conf file (supercedes defaults);
        //check to see if -conf is set in command line
        String[] argsarr=args;
        int argslength=java.lang.reflect.Array.getLength(argsarr);
        int argsverbose=1;
        for(int i=0;i<argslength;i++){
            //System.out.println(argsarr[i]);
            if((argsarr[i].equalsIgnoreCase("-conf"))||(argsarr[i].equalsIgnoreCase("-c"))){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -conf, missing argument!");
                    return ;
                }
                conffname=argsarr[i];
                //System.out.println("conffname="+argsarr[i]);
            }// end if -conf
            if((argsarr[i].equalsIgnoreCase("-verbose"))||(argsarr[i].equalsIgnoreCase("-v"))){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -verbose, missing argument!");
                    return ;
                }
                try{
                    verbose=java.lang.Integer.parseInt(argsarr[i]);
                    argsverbose=java.lang.Integer.parseInt(argsarr[i]);
                }catch (NumberFormatException e){
                    System.err.println("Error; unable to parse int from "+argsarr[i]);
                    verbose=1;
                    return;
                }
                //System.out.println("conffname="+argsarr[i]);
            }// end if -conf
        }// end for i
        //System.out.println("verbose="+verbose);
        if(readconf(conffname)==false){//read in the default values
            System.err.println("Error; unable to read "+conffname+"; using defaults");
        }else if(verbose>0){
            if(argsverbose!=0){
                System.out.println("done readconf");
            }
        }
        //read args (supercede conf-file settings);
        if(readargs(argsarr)==false){
            System.err.println("Error; unable to read args");
            return;
        }
        b2malign myalign=new b2malign();
        clualign myclu=new clualign();
        tax=new HashMap();
        String basename="";
        if(dochecktax){//see if I can read the taxonomy files and read them
            boolean canreadall=false;
            if((new File(taxdir,"names.dmp").canRead())&&(new File(taxdir,"nodes.dmp").canRead())){
                canreadall=true;
                tax=gettaxonomy(taxdir);//as a side effect this also stores values in idtax
            }
            if(canreadall==false){
                dochecktax=false;
                System.err.println("Error unable to read *.dmp files in "+taxdir.getAbsolutePath());
            }
            if(taxid){//if I want to use the ncbi taxid file
                if(verbose>1){
                    System.out.println("reading taxid file");
                }
                mytaxid=new taxid();
                if(mytaxid.readfile(new File(taxdir,"gi_taxid_prot.dmp"),verbose)){
                    if(verbose>1){
                        System.out.println("-taxid read-");
                    }
                }else{
                    System.err.println("Error reading taxid from "+taxdir.getAbsolutePath()+" file:gi_taxid_prot.dmp");
                    mytaxid.taxhash.clear();
                    taxid=false;
                }
                
            }//end if taxid
        }// end if dochecktax
        //HashMap seqhash=new HashMap(1,1);//init hashes
        if(doextractseq){// see if I can read the database files and read them
            int goodread=0;
            boolean readerrors=false;
            for(int i=0;i<java.lang.reflect.Array.getLength(blastdb);i++){
                doextractseq=true;
                if(new File(blastdb[i]).canRead()==false){
                    doextractseq=false;
                    System.err.println("Error unable to find database "+blastdb[i]);
                }
            }// end for i
            //check to see if you can read from all databases, exclude those you cannot read from
            Vector tmpvec=new Vector();
            for(int i=0;i<java.lang.reflect.Array.getLength(blastdb);i++){
                File tmpfile=new File(blastdb[i]);
                if(tmpfile.canRead()){
                    tmpvec.addElement(tmpfile);
                    continue;
                }
                System.err.println("Error unable to read from db:"+blastdb[i]);
            }// end for i
            if(tmpvec.size()==0){
                System.err.println("Warning no databases to read from, setting -doextr to false");
                doextractseq=false;
            }
            if(tmpvec.size()>0){
                File[] tmparr=new File[tmpvec.size()];//tmparr holds the db filenames to read through
                tmpvec.copyInto(tmparr);
                if(html){//if the input is in html format
                    readdb=new readfromdb(tmparr,cpu,verbose);
                }else{
                    readdbno=new readfromdbnohtml(tmparr,cpu,verbose);
                }
            }
        }// end if doextractseq
        //get all files with filename in them
        //System.out.println("-----------------------looking for filenames :"+fname);
        String[] filenames=getfilenames(fname);//get all filenames of the files you want to read
        int filesnumtmp=java.lang.reflect.Array.getLength(filenames);
        if(filesnumtmp==0){
            System.err.println("Error; no "+fname+" files found");
            return;
        }
        if(filesnumtmp<filesblocks){//if I have more blocks to do than files
            filesblocks=filesnumtmp;//do one file per block
        }
        Vector extfilesvec=new Vector();//holds the filenames I can read and want to extract sequences from
        if(verbose>0){
            System.out.println(java.lang.reflect.Array.getLength(filenames)+" files to do in "+filesblocks+" blocks");
        }
        if(filesblocks<=1){
            for(int i=0;i<filesnumtmp;i++){
                if((new File(filenames[i]).canRead())&&(filenames[i].equals("")==false)){
                    //System.out.println("assigning "+filenames[i]+" to file");
                    extfilesvec.addElement(new File(filenames[i]));
                }else{
                    System.err.println("Error; cannot read from "+filenames[i]);
                }
            }
            File[] extfiles=new File[extfilesvec.size()];//extfiles holds the filenames of which I want to extract the seqs
            extfilesvec.copyInto(extfiles);
            if(doextractseq){
                //System.out.println("starting extraction");
                if(html){//if blast in html format
                    //readdb.extractseqs(extfiles,dochecktax,extrextens);
                    readdb.extractseqs(extfiles,extrextens);
                    numberofentries=readdb.numberofentries;
                }else{//if blast not in html format
                    //readdbno.extractseqs(extfiles,dochecktax,extrextens);
                    readdbno.extractseqs(extfiles,extrextens);
                    numberofentries=readdbno.numberofentries;
                }
                if(verbose>0){
                    System.out.println("done extract; "+numberofentries+" sequences in database");
                }
                //readdb=new readfromdb(new File[0],tax,cpu,dochecktax,verbose);//clear a bit of memory
            }
        }// end if filesblocks==1
        if(filesblocks>1){
            int nofiles=filesnumtmp;
            int filesperblock=(int)(nofiles/filesblocks);
            int currfile=0;
            for(int block=0;block<(filesblocks-1);block++){//the last block is outside this loop and does until end
                extfilesvec.clear();
                for(int i=0;i<filesperblock;i++){
                    if((new File(filenames[i+(block*filesperblock)]).canRead())&&(filenames[i+(block*filesperblock)].equals("")==false)){
                        //System.out.println("assigning "+filenames[i]+" to file");
                        extfilesvec.addElement(new File(filenames[i+(block*filesperblock)]));
                    }
                }
                File[] extfiles=new File[extfilesvec.size()];
                extfilesvec.copyInto(extfiles);
                if(doextractseq){
                    if(verbose>0){
                        System.out.println("starting extraction of block "+(block+1));
                    }
                    if(html){
                        //readdb.extractseqs(extfiles,dochecktax,extrextens);
                        readdb.extractseqs(extfiles,extrextens);
                    }else{
                        //readdbno.extractseqs(extfiles,dochecktax,extrextens);
                        readdbno.extractseqs(extfiles,extrextens);
                    }
                    if(verbose>0){
                        System.out.println("done block "+(block+1));
                    }
                }
            }//end for block
            //do the last block
            extfilesvec.clear();
            for(int i=(int)((filesblocks-1)*filesperblock);i<java.lang.reflect.Array.getLength(filenames);i++){//do the rest of the files
                if((new File(filenames[i]).canRead())&&(filenames[i].equals("")==false)){
                    //System.out.println("assigning "+filenames[i]+" to file");
                    extfilesvec.addElement(new File(filenames[i]));
                }
            }
            File[] extfiles=new File[extfilesvec.size()];
            extfilesvec.copyInto(extfiles);
            if(doextractseq){
                if(verbose>0){
                    System.out.println("starting extraction of block "+filesblocks);
                }
                if(html){
                    //readdb.extractseqs(extfiles,dochecktax,extrextens);
                    readdb.extractseqs(extfiles,extrextens);
                    numberofentries=readdb.numberofentries;//how many sequences were searched through
                }else{
                    //readdbno.extractseqs(extfiles,dochecktax,extrextens);
                    readdbno.extractseqs(extfiles,extrextens);
                    numberofentries=readdb.numberofentries;
                }
                if(verbose>0){
                    System.out.println("done extraction; "+numberofentries+" sequences in database");
                }
            }
        }// end if filesblocks>1
        if(html){
            readdb=new readfromdb(new File[0],cpu,verbose);//clear a bit of memory
        }else{
            readdbno=new readfromdbnohtml(new File[0],cpu,verbose);//clear some memory
        }
        extfilesvec.clear();//free memory
        
        //-------done extracting database sequences
        
        //init of threads
        Vector statusvec=new Vector();
        int numberoffiles=java.lang.reflect.Array.getLength(filenames);
        blammerthread[] currthreads=new blammerthread[(int)cpu];
        int filesstarted=0;
        int filesdone=0;
        //init the first round of threads
        //        System.out.println("nofiles="+numberoffiles);
        for(int i=0;((i<cpu)&&(i<numberoffiles));i++){
            //            System.out.print(",");
            currthreads[i]=new blammerthread(filenames[i],i,this,dochecktax,tax,maxsim,taxlevel,maxhmmsim,numberofentries,seqs,doextractseq,getdissim,dostrictextract,redo);
            if(verbose>0){
                System.out.println("Starting "+filenames[i]+" at "+i+" done:0 of "+numberoffiles);
            }
            currthreads[i].start();
            filesstarted+=1;
        }// end for i
        boolean dowait=false;
        while (filesstarted<numberoffiles){
            try{
                dowait=true;
                synchronized(this){
                    for(int i=0;((i<cpu)&&(i<numberoffiles));i++){
                        if(currthreads[i].isdone){
                            dowait=false;
                            break;
                        }
                    }//end for
                    if(dowait){
                        if(verbose>2){
                            for(int i=0;i<cpu&&(i<numberoffiles);i++){
                                System.out.println(currthreads[i].cpunum+" "+currthreads[i].fname+" status="+currthreads[i].status);
                            }//end for i
                        }
                        this.wait(60000);
                    }
                }// end synchronized
                //System.out.println("after wait in main");
            }catch (InterruptedException e){
                System.err.println("Error interrupted main wait()");
                e.printStackTrace();
                return;
            }
            for(int i=0;((i<cpu)&&(i<numberoffiles));i++){
                if(currthreads[i].isdone){
                    statusvec.addElement(currthreads[i].cpunum+" "+currthreads[i].fname+" status="+currthreads[i].status);//add status of old thread
                    if(currthreads[i].atend==false){
                        filesdone++;
                        currthreads[i].atend=true;
                    }
                    if(verbose>2){
                        System.out.println("files started="+filesstarted+" files done="+filesdone+" of "+numberoffiles);
                    }
                    //currthreads[i].isdone=false;
                    if(filesstarted<numberoffiles){
                        currthreads[i]=new blammerthread(filenames[filesstarted],i,this,dochecktax,tax,maxsim,taxlevel,maxhmmsim,numberofentries,seqs,doextractseq,getdissim,dostrictextract,redo);
                        currthreads[i].fname=filenames[filesstarted];
                        currthreads[i].cpunum=i;
                        if(verbose>0){
                            System.out.println("starting "+filenames[filesstarted]+" at "+i+", done: "+filesdone+" of "+numberoffiles);
                        }
                        currthreads[i].start();
                        filesstarted++;
                    }// end if filesdone<nuoffiles
                }//end if currthread.isdone
            }// end for i
        }// end while filesdone<numberoffiles
        while(filesdone<numberoffiles){
            try{
                synchronized(this){
                    for(int i=0;((i<cpu)&&(i<numberoffiles));i++){
                        if(currthreads[i].isdone){
                            if(currthreads[i].atend==false){
                                currthreads[i].atend=true;
                                statusvec.addElement(currthreads[i].cpunum+" "+currthreads[i].fname+" status="+currthreads[i].status);//add status of old thread
                                filesdone++;
                            }
                            currthreads[i].isdone=false;
                        }
                    }// end for i
                    if(filesdone<numberoffiles){
                        if(verbose>1){
                            System.out.println("waiting at end, done:"+filesdone+" of "+numberoffiles);
                            for(int i=0;i<cpu&&(i<numberoffiles);i++){
                                if(currthreads[i].atend==false){
                                    System.out.println(currthreads[i].cpunum+" "+currthreads[i].fname+" status="+currthreads[i].status);
                                }
                            }//end for i
                        }
                        this.wait(60000);
                        //System.out.print(">");
                    }
                }//end synchronized this
            }catch (InterruptedException e){
                System.err.println("Error interrupted main wait()");
                e.printStackTrace();
                return;
            }
        }// end while fdone<numfiles
        if(verbose>0){
            System.out.println("DONE all "+filesdone+" of "+numberoffiles);
        }
        if(verbose>3){
            for(int i=0;i<statusvec.size();i++){
                System.out.println((String)statusvec.elementAt(i));
            }//end for i
        }else if(verbose>1){
            String tmpstr;
            for(int i=0;i<statusvec.size();i++){
                tmpstr=(String)statusvec.elementAt(i);
                if(tmpstr.indexOf("status=done")==-1){
                    System.out.println(tmpstr);
                }
            }//end for i
        }
    }// end main
    
    //-----------------------------------------------------------------------------------------------------------
    
    String[] getfilenames(String inname){
        //get all the relevant files
        int lastsep=inname.lastIndexOf(File.separator);
        String[] outarr=new String[0];
        if(lastsep>-1){
            String dirname=".";
            String filesearch=inname;
            if(lastsep>0){
                dirname=inname.substring(0,lastsep);
                filesearch=inname.substring(lastsep+1);
            }
            File dirfile=new File(dirname);
            ffilter filter=new ffilter(filesearch);
            if(dirfile.isDirectory()==false){
                System.err.println("Error unable to read from "+dirname);
                errorless=false;
                return outarr;
            }
            outarr=dirfile.list(filter);
            dirname=dirfile.getAbsolutePath();
            for(int i=0;i<java.lang.reflect.Array.getLength(outarr);i++){
                outarr[i]=dirname+File.separator+outarr[i];
                //System.out.println("FILENAME="+outarr[i]);
            }
            return outarr;
        }else{
            //System.out.println("lastsep==-1");
            ffilter filter=new ffilter(inname);
            File dirfile=new File(".");
            if(dirfile.isDirectory()==false){
                System.err.println("Error unable to read from '.'");
                errorless=false;
                return outarr;
            }
            outarr=dirfile.list(filter);
            String dirname=dirfile.getAbsolutePath();
            for(int i=0;i<java.lang.reflect.Array.getLength(outarr);i++){
                outarr[i]=dirname+File.separator+outarr[i];
                //System.out.println("FILENAME2="+outarr[i]);
            }
            return outarr;
        }
    }//end getfilenames
    
    class ffilter implements FilenameFilter{
        String[] filter;
        boolean hasstar=false;
        
        ffilter(String instring){
            this.filter=instring.split("\\*",0);//split on star characters
            if(java.lang.reflect.Array.getLength(this.filter)>1){
                hasstar=true;
            }
        }
        
        public boolean accept(File infile,String inname){
            int pos=0;
            if(hasstar){
                for(int i=0;i<java.lang.reflect.Array.getLength(filter);i++){
                    if(inname.indexOf(filter[i])==-1){
                        return false;
                    }
                }
            }else{
                if(inname.equals(filter[0])==false){
                    return false;
                }
            }
            //if all elements exist in the name
            return true;
        }// end accept
    }// end class filenamefilter
    
    //-----------------------------------------------------------------------------------------------------------
    
    String[] extractsequences(String[] inarr, String[] dbarr){
        //loop through dbarr and read each file.
        //while reading each file try to get the sequences that match inarr
        Vector tmpvec=new Vector();
        //remove the "t" from gt names and put to new fast check array
        String[] fastarr=new String[java.lang.reflect.Array.getLength(inarr)];
        for(int i=0;i<java.lang.reflect.Array.getLength(inarr);i++){
            fastarr[i]=inarr[i];
            if(inarr[i].startsWith("t")){
                fastarr[i]=inarr[i].substring(1);//remove the first char (t)
            }
        }
        try{
            BufferedReader currread;
            String currstring;
            String currname="";
            String currseq="";
            int dbnum=java.lang.reflect.Array.getLength(dbarr);
            int namesnum=java.lang.reflect.Array.getLength(inarr);
            int donenames=0;
            boolean seqread=false;
            for(int i=0;i<dbnum;i++){
                currread=new BufferedReader(new FileReader(dbarr[i]));
                while((donenames<namesnum)&&((currstring=currread.readLine())!=null)){
                    if(currstring.indexOf(">")>-1){
                        if(seqread){
                            seqread=false;
                            tmpvec.addElement(currseq);
                        }
                        //if this is a sequence name, get the gi/gt number
                        for(int j=0;j<namesnum;j++){
                            if((currstring.indexOf(fastarr[j]))>-1){//if this might be the name I'm looking for
                                String [] currnametmp=extractnamefromdb(currstring);
                                if(currnametmp[0].equals(inarr[j])){
                                    boolean isunique=true;
                                    for(int k=0;k<tmpvec.size();k++){
                                        if(((String)tmpvec.elementAt(k)).equals((">"+currnametmp[0]+" ["+currnametmp[1]+"]"))){
                                            isunique=false;
                                        }
                                    }
                                    if(isunique){
                                        tmpvec.addElement((">"+currnametmp[0]+" ["+currnametmp[1]+"]"));
                                        tmpvec.addElement(currstring);
                                        if(verbose>2){
                                            System.out.println(currnametmp[0]+" ["+currnametmp[1]+"]");
                                        }
                                        //donenames+=1;
                                        currseq="";
                                        seqread=true;
                                    }// end if isunique
                                }// end if names are equal
                            }//end if maybe equal
                        }// end for j
                        continue;
                    }//end if currstring equals >
                    if(seqread){
                        currseq+=currstring;
                    }
                }// end while
                currread.close();
            }// end for i
        }catch (IOException e){
            System.err.println("Error extracting sequences");
            e.printStackTrace();
        }
        String[] outarr=new String[tmpvec.size()];
        tmpvec.copyInto(outarr);
        return outarr;
    }// end extractsequences
    
    
    //-----------------------------------------------------------------------------------------------------------
    
    String[] extractnamefromdb(String instr){
        //edited so that it doesn't chomp the names to gi/gt number
        String[] outarr=new String[2];//contains name and species
        boolean specdone=false;
        int currpos=0;
        int maxpos=0;
        int endpos=0;
        String prefix="";
        int strlength=instr.length();
        //System.out.println("searching through "+instr);
        while((((currpos=instr.indexOf("gi|",maxpos))>-1)||((currpos=instr.indexOf("gt|",maxpos))>-1))&&(specdone==false)){
            prefix="";
            if(instr.substring(currpos,currpos+2).equals("gt")){//if this is a customized database
                prefix="t";
            }
            if((endpos=instr.indexOf("|",currpos+3))>-1){
                outarr[0]=prefix+instr.substring(currpos+3,endpos);
            }else{
                outarr[0]=prefix+instr.substring(currpos+3);
            }
            // now look for a [ ]
            if(maxpos<endpos){
                maxpos=endpos;
            }
            //if I get here the data in outarr[0] starts either with a "t" if it was a customized database
            //and the following numebr is not a gi number, or it is only a gi number and then it doesn't have
            //this "t". No other cases should occurr.
            if(taxid){//if I have and want to use ncbi taxid files
                if(outarr[0].startsWith("gi|")){//if this is a gi number
                    try{
                        String ginumstr=outarr[0].substring(3,outarr[0].indexOf("|",3));
                        System.out.println("ginum='"+ginumstr+"'");
                        
                        int ginum=Integer.parseInt(outarr[0]);
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
                        System.err.println("unable to parse gi number (main extractnamefromdb) from '"+outarr[0]+"'");
                        specdone=false;
                    }
                }
            }// end if taxid
            if(specdone==false){
                if((currpos=instr.indexOf("[",currpos))>-1){
                    if((endpos=instr.indexOf("]",currpos))>-1){
                        outarr[1]=instr.substring(currpos+1,endpos);
                        if(outarr[1].length()>0){
                            specdone=true;
                            //System.out.println("found "+outarr[0]+" "+outarr[1]);
                        }
                        if(dochecktax){
                            if((specdone)&&(tax.containsKey(outarr[1])==false)){
                                specdone=false;
                                if(currpos<endpos){
                                    currpos=endpos;
                                }
                            }//end if this taxonomy doesn't exist
                        }//end if dochecktax
                    }// end if ]
                }// end if [
            }//end if specdone==false
        }// end while next gi or gt
        if(dochecktax){
            if(tax.containsKey(outarr[1])==false){//if this species doesn't exist
                outarr[1]="unknown taxonomy";//output the whole thing
            }
        }
        return outarr;
    }// end extractnamefromdb
    
    //-----------------------------------------------------------------------------------------------------------
    
    boolean readargs(String[] args){
        int argslength=java.lang.reflect.Array.getLength(args);
        for(int i=0;i<argslength;i++){
            if((args[i].equalsIgnoreCase("-blastdb"))||(args[i].equalsIgnoreCase("-db"))||(args[i].equalsIgnoreCase("-d"))){
                int quotesfound=0;
                String tmpstr="";
                boolean done=false;
                if(args[i+1].indexOf("\"")==-1){// if the next elem is not in quotes
                    i+=1;
                    tmpstr=args[i];
                    done=true;
                }
                if(done==false){
                    while (quotesfound<2){
                        i+=1;
                        if(i>=argslength){
                            System.err.println("Error at -blastdb, Syntax error or missing argument");
                            return false;
                        }
                        String curr=args[i];
                        int qindex;
                        if((qindex=curr.indexOf("\""))>-1){
                            quotesfound+=1;
                            if(quotesfound==1){
                                tmpstr=curr.substring(qindex+1);
                            }
                            if(quotesfound==2){
                                tmpstr+=" "+curr.substring(0,qindex);
                            }
                            //now check if the second quote is somewhere in tmpstr
                            if((qindex=tmpstr.indexOf("\""))>-1){//if I only have one element, both quotes are in the same string
                                quotesfound+=1;
                                tmpstr=tmpstr.substring(0,tmpstr.indexOf("\""));
                                continue;
                            }
                            continue;
                        }// end if index1
                        if((quotesfound>0)&&(quotesfound<2)){
                            tmpstr=tmpstr+" "+curr;
                        }
                    }// end while quotesfound
                }// end if done == false
                blastdb=tmpstr.split("\\s+",0);
                continue;
            }// end if -blastdb
            if(args[i].equalsIgnoreCase("-cmd")){
                int quotesfound=0;
                command="";
                if(args[i+1].indexOf("\"")==-1){// if the next elem is not in quotes
                    i+=1;
                    command=args[i];
                    continue;
                }
                if(args[i+1].indexOf("\"")>-1){
                    while (quotesfound<2){
                        i+=1;
                        if(i>=argslength){
                            System.err.println("Error at -cmd, Syntax error or missing argument "+argslength);
                            return false;
                        }
                        String curr=args[i];
                        //System.out.println(i+" "+curr+" "+quotesfound);
                        int qindex;
                        if((qindex=curr.indexOf("\""))>-1){
                            quotesfound+=1;
                            if(quotesfound==1){
                                command+=curr.substring(qindex+1);
                            }
                            if(quotesfound==2){
                                command+=" "+curr.substring(0,qindex);
                            }
                            //now check if the second quote is somewhere in command
                            if((qindex=command.indexOf("\""))>-1){
                                quotesfound+=1;
                                command=command.substring(0,command.indexOf("\""));
                                continue;
                            }
                            continue;
                        }// end if index1
                        if((quotesfound>0)&&(quotesfound<2)){
                            command=command+" "+curr;
                        }
                    }// end while quotesfound
                }// end if firstelem had quotes
                continue;
            }// end if -cmd
            if((args[i].equalsIgnoreCase("-hmmbuild"))||(args[i].equalsIgnoreCase("-hmmb"))){
                int quotesfound=0;
                hmmbuildstring="";
                changehmmbuild=true;
                if(args[i+1].indexOf("\"")==-1){// if the next elem is not in quotes
                    i+=1;
                    hmmbuildstring=args[i];
                    continue;
                }else if(args[i+1].indexOf("\"")>-1){
                    while (quotesfound<2){
                        i+=1;
                        if(i>=argslength){
                            System.err.println("Error at -hmmbuild, Syntax error or missing argument "+argslength);
                            return false;
                        }
                        String curr=args[i];
                        //System.out.println(i+" "+curr+" "+quotesfound);
                        int qindex;
                        if((qindex=curr.indexOf("\""))>-1){
                            quotesfound+=1;
                            if(quotesfound==1){
                                hmmbuildstring+=curr.substring(qindex+1);
                            }
                            if(quotesfound==2){
                                hmmbuildstring+=" "+curr.substring(0,qindex);
                            }
                            //now check if the second quote is somewhere in hmmbuildstring itself
                            if((qindex=hmmbuildstring.indexOf("\""))>-1){
                                quotesfound+=1;
                                hmmbuildstring=hmmbuildstring.substring(0,hmmbuildstring.indexOf("\""));
                            }
                            continue;
                        }// end if index1
                        if((quotesfound>0)&&(quotesfound<2)){
                            hmmbuildstring=hmmbuildstring+" "+curr;
                        }
                        //System.out.println("hmmbuildstring="+hmmbuildstring);
                    }// end while quotesfound
                    //System.out.println("changing hmmbuild to "+hmmbuildstring);
                }// end if firstelem had quotes
                continue;
            }// end if -hmmbuild
            if((args[i].equalsIgnoreCase("-hmmsearch"))||(args[i].equalsIgnoreCase("-hmms"))){
                int quotesfound=0;
                hmmsearchstring="";
                changehmmsearch=true;
                if(args[i+1].indexOf("\"")==-1){// if the next elem is not in quotes
                    i+=1;
                    hmmsearchstring=args[i];
                    continue;
                }
                if(args[i+1].indexOf("\"")>-1){
                    while (quotesfound<2){
                        i+=1;
                        if(i>=argslength){
                            System.err.println("Error at -hmmsearch, Syntax error or missing argument "+argslength);
                            return false;
                        }
                        String curr=args[i];
                        //System.out.println(i+" "+curr+" "+quotesfound);
                        int qindex;
                        if((qindex=curr.indexOf("\""))>-1){
                            quotesfound+=1;
                            if(quotesfound==1){
                                hmmsearchstring+=curr.substring(qindex+1);
                            }
                            if(quotesfound==2){
                                hmmsearchstring+=" "+curr.substring(0,qindex);
                            }
                            //now check if the second quote is somewhere in command
                            if((qindex=hmmsearchstring.indexOf("\""))>-1){
                                quotesfound+=1;
                                hmmsearchstring=hmmsearchstring.substring(0,hmmsearchstring.indexOf("\""));
                                continue;
                            }
                            continue;
                        }// end if index1
                        if((quotesfound>0)&&(quotesfound<2)){
                            hmmsearchstring=hmmsearchstring+" "+curr;
                        }
                    }// end while quotesfound
                }// end if firstelem had quotes
                continue;
            }// end if -hmmsearch
            if((args[i].equalsIgnoreCase("-hmmcalibrate"))||(args[i].equalsIgnoreCase("-hmmc"))){
                int quotesfound=0;
                hmmcalibratestring="";
                changehmmcalibrate=true;
                if(args[i+1].indexOf("\"")==-1){// if the next elem is not in quotes
                    i+=1;
                    hmmcalibratestring=args[i];
                    continue;
                }
                if(args[i+1].indexOf("\"")>-1){
                    while (quotesfound<2){
                        i+=1;
                        if(i>=argslength){
                            System.err.println("Error at -hmmcalibrate, Syntax error or missing argument "+argslength);
                            return false;
                        }
                        String curr=args[i];
                        //System.out.println(i+" "+curr+" "+quotesfound);
                        int qindex;
                        if((qindex=curr.indexOf("\""))>-1){
                            quotesfound+=1;
                            if(quotesfound==1){
                                hmmcalibratestring+=curr.substring(qindex+1);
                            }
                            if(quotesfound==2){
                                hmmcalibratestring+=" "+curr.substring(0,qindex);
                            }
                            //now check if the second quote is somewhere in command
                            if((qindex=hmmcalibratestring.indexOf("\""))>-1){
                                quotesfound+=1;
                                hmmcalibratestring=hmmcalibratestring.substring(0,hmmcalibratestring.indexOf("\""));
                                continue;
                            }
                            continue;
                        }// end if index1
                        if((quotesfound>0)&&(quotesfound<2)){
                            hmmcalibratestring=hmmcalibratestring+" "+curr;
                        }
                    }// end while quotesfound
                }// end if firstelem had quotes
                continue;
            }// end if -hmmcalibrate
            if((args[i].equalsIgnoreCase("-hmmalign"))||(args[i].equalsIgnoreCase("-hmma"))){
                int quotesfound=0;
                hmmalignstring="";
                changehmmalign=true;
                if(args[i+1].indexOf("\"")==-1){// if the next elem is not in quotes
                    i+=1;
                    hmmalignstring=args[i];
                    continue;
                }
                if(args[i+1].indexOf("\"")>-1){
                    while (quotesfound<2){
                        i+=1;
                        if(i>=argslength){
                            System.err.println("Error at -hmmalign, Syntax error or missing argument "+argslength);
                            return false;
                        }
                        String curr=args[i];
                        //System.out.println(i+" "+curr+" "+quotesfound);
                        int qindex;
                        if((qindex=curr.indexOf("\""))>-1){
                            quotesfound+=1;
                            if(quotesfound==1){
                                hmmalignstring+=curr.substring(qindex+1);
                            }
                            if(quotesfound==2){
                                hmmalignstring+=" "+curr.substring(0,qindex);
                            }
                            //now check if the second quote is somewhere in command
                            if((qindex=hmmalignstring.indexOf("\""))>-1){
                                quotesfound+=1;
                                hmmalignstring=hmmalignstring.substring(0,hmmalignstring.indexOf("\""));
                                continue;
                            }
                            continue;
                        }// end if index1
                        if((quotesfound>0)&&(quotesfound<2)){
                            hmmalignstring=hmmalignstring+" "+curr;
                        }
                    }// end while quotesfound
                }// end if firstelem had quotes
                continue;
            }// end if -hmmalign
            if((args[i].equalsIgnoreCase("-infile"))||(args[i].equalsIgnoreCase("-i"))){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -infile, missing argument!");
                    return false;
                }
                fname=args[i];
                continue;
            }// end if -infile
            if((args[i].equalsIgnoreCase("-conf"))||(args[i].equalsIgnoreCase("-c"))){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -conf, missing argument!");
                    return false;
                }
                conffname=args[i];
                continue;
            }// end if -conf
            if(args[i].equalsIgnoreCase("-clustalw")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -clustalw, missing argument!");
                    return false;
                }
                clustring=args[i];
                continue;
            }// end if -clustalw
            if(args[i].equalsIgnoreCase("-hmmer")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -hmmer, missing argument!");
                    return false;
                }
                hmmer=new File(args[i]);
                continue;
            }// end if -hmmer
            if(args[i].equalsIgnoreCase("-taxdir")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -taxdir, missing argument!");
                    return false;
                }
                taxdir=new File(args[i]);
                continue;
            }// end if -taxdir
            if((args[i].equalsIgnoreCase("-oformat"))||(args[i].equalsIgnoreCase("-of"))){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -oformat, missing argument!");
                    return false;
                }
                String tmpformat=args[i];
                if(tmpformat.equalsIgnoreCase("clustal")){
                    oformat=1;
                }else if(tmpformat.equalsIgnoreCase("fasta")){
                    oformat=0;
                }else{
                    System.err.println("unknown output format "+tmpformat);
                    return false;
                }
                continue;
            }// end if -conf
            if(args[i].equalsIgnoreCase("-html")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -html, missing argument!");
                    return false;
                }
                if((args[i].equalsIgnoreCase("f"))||(args[i].equalsIgnoreCase("false"))){
                    html=false;
                    continue;
                }
                html=true;//default
                continue;
            }// end if -html
            if(args[i].equalsIgnoreCase("-dostrict")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -dostrict, missing argument!");
                    return false;
                }
                if((args[i].equalsIgnoreCase("f"))||(args[i].equalsIgnoreCase("false"))){
                    dostrictextract=false;
                    continue;
                }
                dostrictextract=true;//default
                continue;
            }// end if -dotax
            if(args[i].equalsIgnoreCase("-dotax")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -dotax, missing argument!");
                    return false;
                }
                if((args[i].equalsIgnoreCase("t"))||(args[i].equalsIgnoreCase("true"))){
                    dochecktax=true;
                    continue;
                }
                dochecktax=false;//default
                continue;
            }// end if -dotax
            if(args[i].equalsIgnoreCase("-taxid")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -taxid, missing argument!");
                    return false;
                }
                if((args[i].equalsIgnoreCase("t"))||(args[i].equalsIgnoreCase("true"))){
                    taxid=true;
                    continue;
                }
                taxid=false;//default
                continue;
            }// end if -taxid
            if(args[i].equalsIgnoreCase("-doclu")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -doclu, missing argument!");
                    return false;
                }
                if((args[i].equalsIgnoreCase("f"))||(args[i].equalsIgnoreCase("false"))){
                    doclustal=false;
                    continue;
                }
                doclustal=true;//default
                continue;
            }// end if -doclu
            if(args[i].equalsIgnoreCase("-allfiles")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -allfiles, missing argument!");
                    return false;
                }
                if((args[i].equalsIgnoreCase("t"))||(args[i].equalsIgnoreCase("true"))){
                    allfiles=true;
                    continue;
                }
                allfiles=false;//default
                continue;
            }// end if -allfiles
            if(args[i].equalsIgnoreCase("-redo")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -redo, missing argument!");
                    return false;
                }
                if((args[i].equalsIgnoreCase("t"))||(args[i].equalsIgnoreCase("true"))){
                    redo=true;
                    continue;
                }
                redo=false;//default
                continue;
            }// end if -redo
            if((args[i].equalsIgnoreCase("-doext"))||(args[i].equalsIgnoreCase("-doextract"))){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -doext, missing argument!");
                    return false;
                }
                if((args[i].equalsIgnoreCase("t"))||(args[i].equalsIgnoreCase("true"))){
                    doextractseq=true;
                    continue;
                }
                doextractseq=false;//default
                continue;
            }// end if -doext
            if(args[i].equalsIgnoreCase("-dohmmb")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -dohmmb, missing argument!");
                    return false;
                }
                if((args[i].equalsIgnoreCase("t"))||(args[i].equalsIgnoreCase("true"))){
                    dohmmbuild=true;
                    continue;
                }
                dohmmbuild=false;//default
                continue;
            }// end if -dohmmb
            if(args[i].equalsIgnoreCase("-dohmms")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -dohmms, missing argument!");
                    return false;
                }
                if((args[i].equalsIgnoreCase("t"))||(args[i].equalsIgnoreCase("true"))){
                    dohmmsearch=true;
                    continue;
                }
                dohmmsearch=false;//default
                continue;
            }// end if -dohmms
            if(args[i].equalsIgnoreCase("-dohmma")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -dohmma, missing argument!");
                    return false;
                }
                if((args[i].equalsIgnoreCase("t"))||(args[i].equalsIgnoreCase("true"))){
                    dohmmalign=true;
                    continue;
                }
                dohmmalign=false;//default
                continue;
            }// end if -dohmma
            if(args[i].equalsIgnoreCase("-getdissim")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -getdissim, missing argument!");
                    return false;
                }
                if((args[i].equalsIgnoreCase("f"))||(args[i].equalsIgnoreCase("false"))){
                    getdissim=false;
                    continue;
                }
                getdissim=true;//default
                continue;
            }// end if -dohmma
            if(args[i].equalsIgnoreCase("-dohmmc")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -dohmmc, missing argument!");
                    return false;
                }
                if((args[i].equalsIgnoreCase("t"))||(args[i].equalsIgnoreCase("true"))){
                    dohmmcalibrate=true;
                    continue;
                }
                dohmmcalibrate=false;//default
                continue;
            }// end if -dohmmc
            if(args[i].equalsIgnoreCase("-checkquery")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -checkquery, missing argument!");
                    return false;
                }
                if((args[i].equalsIgnoreCase("f"))||(args[i].equalsIgnoreCase("false"))){
                    checkquery=false;
                    continue;
                }
                checkquery=true;//default
                continue;
            }// end if -checkquery
            if(args[i].equalsIgnoreCase("-hmmcalnum")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -hmmcalnum, missing argument!");
                    return false;
                }
                try{
                    hmmcalnum=Integer.parseInt(args[i]);
                    if(hmmcalnum<1000){//if it was less than the recommended minimum
                        hmmcalnum=1000;
                        System.out.println("hmmcalnum was less than 1000; setting to 1000 (recommended minimum)");
                    }
                }catch(NumberFormatException e){
                    System.err.println("unable to parse int from "+args[i]);
                    hmmcalnum=5000;
                }
                continue;
            }// end if -hmmcalnum
            if((args[i].equalsIgnoreCase("-verbose"))||(args[i].equalsIgnoreCase("-v"))){
                //System.out.println("verbose hit!");
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -verbose, missing argument!");
                    return false;
                }
                try{
                    verbose=Integer.parseInt(args[i]);
                }catch(NumberFormatException e){
                    System.err.println("unable to parse int from "+args[i]);
                    verbose=10;
                }
                continue;
            }// end if -verbose
            if(args[i].equalsIgnoreCase("-coverage")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -coverage, missing argument!");
                    return false;
                }
                try{
                    coverage=Float.parseFloat(args[i]);
                    if(coverage>1){//if it was entered as percent
                        coverage=coverage/100;
                    }
                }catch(NumberFormatException e){
                    System.err.println("unable to parse float from "+args[i]);
                    coverage=0;
                }
                continue;
            }// end if -coverage
            if(args[i].equalsIgnoreCase("-simstep")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -simstep, missing argument!");
                    return false;
                }
                try{
                    simstep=Float.parseFloat(args[i]);
                    if(simstep>1){//if it was entered as percent
                        simstep=simstep/100;
                    }
                }catch(NumberFormatException e){
                    System.err.println("unable to parse float from "+args[i]);
                    simstep=(float)0.1;
                }
                continue;
            }// end if -coverage
            if(args[i].equalsIgnoreCase("-blocks")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -blocks, missing argument!");
                    return false;
                }
                try{
                    filesblocks=Float.parseFloat(args[i]);
                }catch(NumberFormatException e){
                    System.err.println("unable to parse float from "+args[i]);
                    filesblocks=1;
                }
                continue;
            }// end if -blocks
            if(args[i].equalsIgnoreCase("-seqs")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -seqs, missing argument!");
                    return false;
                }
                try{
                    seqs=Integer.parseInt(args[i]);
                }catch(NumberFormatException e){
                    System.err.println("unable to parse int from "+args[i]);
                    seqs=100;
                }
                continue;
            }// end if -blocks
            if(args[i].equalsIgnoreCase("-hmmseqs")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -hmmseqs, missing argument!");
                    return false;
                }
                try{
                    hmmseqs=Integer.parseInt(args[i]);
                }catch(NumberFormatException e){
                    System.err.println("unable to parse int from "+args[i]);
                    hmmseqs=-1;//default
                }
                continue;
            }// end if -blocks
            if(args[i].equalsIgnoreCase("-blastmin")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -blastmin, missing argument!");
                    return false;
                }
                try{
                    blastmin=Double.parseDouble(args[i]);
                }catch(NumberFormatException e){
                    System.err.println("unable to parse float from "+args[i]);
                    blastmin=10;
                }
                continue;
            }// end if -blastmin
            if(args[i].equalsIgnoreCase("-blastmax")||args[i].equalsIgnoreCase("-eval")||args[i].equalsIgnoreCase("-e")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -blastmax, missing argument!");
                    return false;
                }
                try{
                    blastmax=Double.parseDouble(args[i]);
                }catch(NumberFormatException e){
                    System.err.println("unable to parse float from "+args[i]);
                    blastmax=0.00001;
                }
                continue;
            }// end if -blastmax
            if(args[i].equalsIgnoreCase("-s/c")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -e/c, missing argument!");
                    return false;
                }
                try{
                    scval=Double.parseDouble(args[i]);
                }catch(NumberFormatException e){
                    System.err.println("unable to parse float from "+args[i]);
                    scval=-1;//(default)
                }
                continue;
            }// end if -hmmsE
            if(args[i].equalsIgnoreCase("-hmmsE")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -hmmsE, missing argument!");
                    return false;
                }
                try{
                    hmmseval=Double.parseDouble(args[i]);
                }catch(NumberFormatException e){
                    System.err.println("unable to parse float from "+args[i]);
                    hmmseval=blastmax;
                }
                continue;
            }// end if -hmmsE
            if(args[i].equalsIgnoreCase("-hmmsZ")){
                i+=1;
                addhmmszval=true;
                if(i>=argslength){
                    System.err.println("Error at -hmmsZ, missing argument!");
                    return false;
                }
                try{
                    hmmszval=Double.parseDouble(args[i]);
                }catch(NumberFormatException e){
                    System.err.println("unable to parse float from "+args[i]);
                    addhmmszval=false;
                }
                continue;
            }// end if -hmmsZ
            if(args[i].equalsIgnoreCase("-maxsim")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -maxsim, missing argument!");
                    return false;
                }
                try{
                    maxsim=Float.parseFloat(args[i]);
                    if(maxsim>1){//if it was entered as percent
                        maxsim=((float)maxsim)/100;
                    }
                }catch(NumberFormatException e){
                    System.err.println("unable to parse float from "+args[i]);
                    maxsim=1;//set back to default
                }
                continue;
            }// end if -maxsim
            if(args[i].equalsIgnoreCase("-taxlevel")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -taxlevel, missing argument!");
                    return false;
                }
                try{
                    taxlevel=Integer.parseInt(args[i]);
                    if(taxlevel<0){
                        taxlevel=0;
                    }else if(taxlevel>3){
                        taxlevel=3;
                    }
                }catch(NumberFormatException e){
                    System.err.println("unable to parse int from "+args[i]);
                    taxlevel=3;//set back to default
                }
                continue;
            }// end if -maxsim
            if(args[i].equalsIgnoreCase("-minsim")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -minsim, missing argument!");
                    return false;
                }
                try{
                    minsim=Float.parseFloat(args[i]);
                    if(minsim>1){//if it was entered as percent
                        minsim=((float)minsim)/100;
                    }
                }catch(NumberFormatException e){
                    System.err.println("unable to parse float from "+args[i]);
                    minsim=0;//set back to default
                }
                continue;
            }// end if -minsim
            if(args[i].equalsIgnoreCase("-maxhmmsim")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -maxhmmsim, missing argument!");
                    return false;
                }
                try{
                    maxhmmsim=Float.parseFloat(args[i]);
                    if(maxhmmsim>1){//if it was entered as percent
                        maxhmmsim=((float)maxhmmsim)/100;
                    }
                }catch(NumberFormatException e){
                    System.err.println("unable to parse float from "+args[i]);
                    maxhmmsim=(float)0.7;//set back to default
                }
                continue;
            }// end if -maxsim
            if(args[i].equalsIgnoreCase("-cpu")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -cpu, missing argument!");
                    return false;
                }
                try{
                    cpu=Integer.parseInt(args[i]);
                }catch(NumberFormatException e){
                    System.err.println("unable to parse int from "+args[i]);
                    cpu=1;//set back to default
                }
                continue;
            }// end if -cpu
            if(args[i].equalsIgnoreCase("-cluwidth")){
                i+=1;
                if(i>=argslength){
                    System.err.println("Error at -cluwidth, missing argument!");
                    return false;
                }
                try{
                    cluwidth=Integer.parseInt(args[i]);
                }catch(NumberFormatException e){
                    System.err.println("unable to parse int from "+args[i]);
                    cluwidth=5;//set back to default
                }
                continue;
            }// end if -cluwidth
            System.err.println("unknown command "+args[i]);
            return false;
        }// end for i
        return true;
    }// end readargs
    
    //----------------------------------------------------------------------------------------------------------
    
    boolean readconf(String conffile){
        // System.out.println("readconf="+conffile);
        if((new File(conffile).canRead())==false){
            System.err.println("Error; unable to read from "+conffile);
            return false;
        }
        try{
            BufferedReader inread=new BufferedReader(new FileReader(new File(conffile)));
            String currstr;
            String[] comarr;
            while((currstr=inread.readLine())!=null){
                if(currstr.indexOf("#")>-1){// if this is a comment
                    continue;
                }
                comarr=currstr.split("\\s",0);
                if(java.lang.reflect.Array.getLength(comarr)<2){//if I have only one or less parameters on a line
                    continue;
                }
                //the commands different between command line and .conf file
                if(currstr.indexOf("-blastdb")>-1){
                    blastdb=new String[java.lang.reflect.Array.getLength(comarr)-1];
                    for(int i=1;i<java.lang.reflect.Array.getLength(comarr);i++){
                        blastdb[i-1]=comarr[i];
                    }// end for i
                    continue;//while loop
                }// end if blastdb
                if(readargs(comarr)==false){
                    System.err.println("Error unknown command '"+currstr+"'");
                    return false;
                }
            }// end while
            inread.close();
        }catch (IOException e){
            System.err.println("ERROR reading "+conffname);
            e.printStackTrace();
            return false;
        }
        return true;
    }// end readconf
    
    //----------------------------------------------------------------------------------------------------------
    
    HashMap gettaxonomy(File dir){//heavily edited for blammer. original in lattransfer
        // read the names.dmp into a HashMap from the ncbi *.dmp-files
        if(verbose>0){
            System.out.println("Reading taxonomy files");
        }
        HashMap mytax=new HashMap();
        HashMap tmpidtax=new HashMap();
        boolean namestrue=false;
        boolean nodestrue=false;
        File namesfile=new File(dir,"names.dmp");
        if(namesfile.canRead()){
            namestrue=true;
        }
        if((namestrue==false)){
            System.err.println("Error unable to find "+namesfile.getName());
        }
        if((namestrue)){// if all prerequisites are met
            boolean sciname=false;
            try{
                BufferedReader namesread=new BufferedReader(new FileReader(namesfile));
                String line="";
                String id="";
                String name="";
                String info="";
                int counter=0;
                String[] tmparr;
                //System.out.println("doing readnames");
                while((line=namesread.readLine())!=null){
                    //read the name id
                    line=line.trim();
                    if(line.length()==0){
                        continue;
                    }//else{
                    //    System.out.println("doing line '"+line+"'");
                    //}
                    counter+=1;
                    tmparr=line.split("\\|");
                    //for(int i=0;i<java.lang.reflect.Array.getLength(tmparr);i++){
                    //    System.out.println(i+"='"+tmparr[i]+"'");
                    //}//end for i
                    if(java.lang.reflect.Array.getLength(tmparr)!=4){
                        System.err.println("unable to read names.dmp for line "+line);
                        continue;
                    }
                    if((counter%10000)==0){
                        if(verbose>0){
                            System.out.print(".");//counter);
                        }
                        //System.out.println(id+","+name);
                    }//*/
                    //id=line.substring(0,line.indexOf("|")-1);
                    id=tmparr[0].trim();
                    //id=id.trim();
                    //line=line.substring(line.indexOf("|")+1);//remove linedata to after the first "|"
                    try{
                        int testid=Integer.parseInt(id);
                    }catch (NumberFormatException e){
                        System.err.println("Error unable to parse int from '"+id+"' names");
                    }
                    // now read the name
                    //name=line.substring(0,line.indexOf("|"));
                    name=tmparr[1].trim();
                    //name=name.trim();
                    //line=line.substring(line.indexOf("|")+1);//remove linedata to after the first "|"
                    // now skip one field
                    //line=line.substring(line.indexOf("|")+1);//remove linedata to after the first "|"
                    //now comes the info field ("scientific name" or other)
                    //if((line.indexOf("scientific name"))!=-1){// if the rest of the string contains "scientific name"
                    //    mytax.idstonames.put(id,name);
                    //}
                    if(tmparr[3].trim().equalsIgnoreCase("scientific name")){
                        sciname=true;
                    }else{
                        sciname=false;
                    }
                    mytax.put(name,id);
                    if((sciname)||(tmpidtax.containsKey(id)==false)){
                        tmpidtax.put(id,name);
                    }
                }// end while namesread
                namesread.close();
                
            }catch (IOException e){
                System.err.println("Error reading ncbitaxdata");
                e.printStackTrace();
            }
        }// end if all is true
        if(verbose>0){
            System.out.println("-taxonomy read-");
        }
        idtax=tmpidtax;
        return mytax;
    }// end gettaxonomy
    
    
    //--------------------------------------------------------------------------------------------------------------
    
    static aaseq[] toaaseq(String[] namesseqs){
        //this should convert the String [] I have been working with so far to an aaseq[] that I can print out
        int namesseqslength=java.lang.reflect.Array.getLength(namesseqs);
        //first element is the seqname, second is the query, third is the sequence
        aaseq[] outarr=new aaseq[(int)(namesseqslength/3)];
        int currint=0;
        for(int i=0;i<namesseqslength;i+=3){
            //System.out.println("doing seq "+i+" of "+namesseqslength);
            currint=(int)(i/3);
            outarr[currint]=new aaseq();
            outarr[currint].setname(namesseqs[i]);
            outarr[currint].setseq(namesseqs[i+2]);
        }
        return outarr;
    }// end toaaseq
    
    //--------------------------------------------------------------------------------------------------------------
    //--------------------------------------------------------------------------------------------------------------
    
    class blammerthread extends java.lang.Thread {
        
        boolean killthread=false;
        boolean isdone=false;
        int cpunum;
        String fname;
        main parent;
        boolean dochecktax;
        HashMap tax;
        float maxsim;
        int taxlevel;//check all tax (3) or only species(2) or genus(1) or disregard tax(0)
        float maxhmmsim;
        int numberofentries;
        int myseqs;//how many sequences should (maximally) be present in alignment
        boolean didext;//did I extract the sequences from the db (i.e. do I know the size of db)
        boolean mygetdissim;
        boolean dostrict;
        boolean myredo;
        boolean atend=false;
        long starttime;
        String status;
        
        
        public blammerthread(String infname,int incpunum,main parent,boolean dochecktax,HashMap tax,float maxsim,int taxlevel,float maxhmmsim,int numberofentries, int seqs, boolean didext, boolean getdissim, boolean dostrictextract, boolean redo){
            this.fname=infname;
            this.cpunum=incpunum;
            this.parent=parent;
            this.dochecktax=dochecktax;
            this.tax=tax;
            this.maxsim=maxsim;
            this.taxlevel=taxlevel;
            this.numberofentries=numberofentries;
            this.myseqs=seqs;
            this.didext=didext;
            this.maxhmmsim=maxhmmsim;
            this.mygetdissim=getdissim;
            this.dostrict=dostrictextract;
            this.myredo=redo;
            this.starttime=System.currentTimeMillis();
            this.status="pre-start";
        }
        
        public void run(){
            //the part of the program that reads in the blast files, generates alignments, does hmm searches, etc..
            this.setPriority(MIN_PRIORITY);//min=1;norm=5; max=10
            status="started";
            killthread=false;
            isdone=false;
            int round=-1;
            HashMap tmphash;
            // in this method keep checking the flags stopaction and killthread to see if you need to exit the thread
            if(killthread){
                isdone=true;
                status="killed";
                synchronized(parent){
                    if(verbose>2){
                        System.out.println("notifying parent for "+fname);
                    }
                    parent.notify();
                }
                return;
            }
            NEWSEARCH:
                while(round<0){
                    round++;
                    try{
                        status="converting blast";
                        b2malign myalign=new b2malign();
                        b2malignnohtml myalignno=new b2malignnohtml();
                        clualign myclu=new clualign();
                        checktax mycheck=new checktax(tax,maxsim,taxlevel);
                        errorless=true;
                        if(verbose>2){
                            System.out.println("infile: "+fname+" running on "+cpunum);
                        }
                        int lastdotpos=fname.lastIndexOf(".");
                        String basename=fname;
                        if(lastdotpos>-1){
                            basename=fname.substring(0,lastdotpos);
                        }
                        String idstring=basename;
                        int lastseparatorpos=idstring.lastIndexOf(java.io.File.separator);
                        if(lastseparatorpos>-1){
                            idstring=idstring.substring(lastseparatorpos+1);
                        }
                        String extfname=basename+extrextens;
                        String strictextfname=basename+strictextens;
                        String outfname=basename+cluextens;
                        if(new File(outfname).exists()){
                            if(myredo==false){
                                if(verbose>2){
                                    System.out.println("found "+outfname+" ; skipping blast to cln step");
                                }
                                //skip the rest. the check doing that is further on down; no need to do that here
                            }else{
                                new File(outfname).delete();
                            }
                        }
                        if(killthread){
                            isdone=true;
                            status="killed";
                            synchronized(parent){
                                if(verbose>2){
                                    System.out.println("notifying parent for "+fname);
                                }
                                parent.notify();
                            }
                            return;
                        }
                        //check to see if the fasta file has more than one sequence; if only one, skip rest
                        File tmpfasttest=new File(extfname);
                        if(tmpfasttest.canRead()&&(dohmmbuild||dohmmsearch||dohmmalign)){//if I have a *.fas file with extracted sequences and i want to use it
                            try{
                                BufferedReader inread=new BufferedReader(new FileReader(tmpfasttest));
                                int seqsnum=0;
                                String currline;
                                while (((currline=inread.readLine())!=null)&&(seqsnum<2)){//read in the file to see if there are a least two sequences
                                    if(currline.indexOf(">")>-1){
                                        seqsnum+=1;
                                    }
                                }
                                inread.close();
                                if(seqsnum<2){//skip the rest of the stuff if less than two seqs in .fas file
                                    isdone=true;
                                    if(verbose>2){
                                        System.out.println("notifying parent for "+fname);
                                        System.out.println("-------------only one fasta seq for "+fname+"-------------");
                                    }
                                    killthread=true;
                                    status="aborting, 1 seq only";
                                    synchronized(parent){
                                        parent.notify();
                                    }
                                    return;
                                }
                            }catch (IOException e){
                                System.err.println("IOError in tmpfasttest");
                                e.printStackTrace();
                            }
                        }// end canread
                        //now see if the output file exists or you want to redo
                        if((new File(outfname).exists()==false)||(myredo)){
                            if(new File(outfname).exists()){
                                new File(outfname).delete();
                            }
                            BufferedReader freader=new BufferedReader(new FileReader(fname));
                            String[] namesseqs;
                            if(verbose>2){
                                System.out.println("aligning BLAST HSP's for "+fname);
                            }
                            status="re-aligning";
                            if(html){
                                namesseqs=myalign.malign(freader,coverage,blastmax,scval,minsim);
                            }else{
                                namesseqs=myalignno.malign(freader,coverage,blastmax,scval,minsim);
                            }
                            freader.close();
                            //if no sequences are returned (i.e. no hits above coverage and eval) shouldn't happen, but did once to me
                            if(java.lang.reflect.Array.getLength(namesseqs)<=1){
                                if(verbose>0){
                                    System.out.println("number of sequences extracted from blast: "+java.lang.reflect.Array.getLength(namesseqs)+" "+fname);
                                }
                                isdone=true;
                                killthread=true;
                                status="aborting, no sequences found";
                                synchronized(parent){
                                    if(verbose>2){
                                        System.out.println("notifying parent for "+fname);
                                    }
                                    parent.notify();
                                }
                                return;
                            }
                            PrintWriter outfile2;
                            if(allfiles){
                                //testing!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                                outfile2=new PrintWriter(new BufferedWriter(new FileWriter(basename+".bls.org")));
                                for (int i=0;i<(java.lang.reflect.Array.getLength(namesseqs)-2);i+=3){//i=nameofhit i+1=queryofhit i+2=seqofhit
                                    outfile2.println(">"+namesseqs[i]);
                                    //outfile2.println(namesseqs[i+1]);
                                    outfile2.println(namesseqs[i+2]);
                                }// end for
                                outfile2.close();
                                //end testing!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                            }
                            //do I want to do a hmmsearch on all blast seqs or only the ones used to create the hmm?
                            if(dostrict){//does not change the sequences in namesseqs, but those in the .fas (fass) file!
                                if(strictextract.reextract(namesseqs,extfname,strictextfname)==false){
                                    System.err.println("ERROR in strictextract for "+extfname);
                                    isdone=true;
                                    killthread=true;
                                    status="Aborting, error in strictextract";
                                    synchronized(parent){
                                        if(verbose>2){
                                            System.out.println("notifying parent for "+fname);
                                        }
                                        parent.notify();
                                    }
                                    return;
                                }
                            }
                            File tmpextfile=new File(extfname);
                            //check the sequences for max allowed similarity when building hmm models
                            if(dochecktax==false){//if false do not take into account the species info when filtering
                                if(dohmmbuild){//if I later want to build a hmm from this
                                    if(maxhmmsim>maxsim){//watch out what I replace
                                        maxhmmsim=maxsim;
                                    }
                                }else{
                                    maxhmmsim=maxsim;
                                }
                            }// end if dochecktax==false
                            if((dohmmbuild==false)&&(dohmmsearch==false)&&(dohmmalign==false)){
                                //in this case I want to limit the number of sequences I output to seqs sequences
                                //this can be solved by setting hmmseqs to seqs
                                //in this case I actually want to limit the sequences ALWAYS to seqs
                                hmmseqs=myseqs;
                                mygetdissim=false;//in this case I don't want to get the most dissimilar sequences
                            }// end if I don't do hmm searches
                            if(hmmseqs<=0){//i.e. I want no limit on the number of sequences
                                //check the hmmsequences for maximum sequence similarity
                                if((maxhmmsim<1)&&(maxhmmsim>0)){
                                    if(verbose>2){
                                        System.out.println("---------doing check----------- inseqs="+(java.lang.reflect.Array.getLength(namesseqs)/3));
                                    }
                                    namesseqs=hmmcheck.docheck(namesseqs,maxhmmsim,verbose);
                                    if(verbose>2){
                                        System.out.println(" outseqs="+(java.lang.reflect.Array.getLength(namesseqs)/3));
                                    }
                                }
                            }else{//if hmmseqs>0//if I want to limit the maximum number of sequences used to build a hmm
                                //check the sequences for maximum sequence similarity and maximum number of sequences
                                if(verbose>2){
                                    System.out.println("---------doing compcheck-----------inseqs="+(java.lang.reflect.Array.getLength(namesseqs)/3));
                                }
                                namesseqs=hmmcheck.docompcheck(namesseqs,maxhmmsim,hmmseqs,verbose,mygetdissim,simstep);
                                if(verbose>2){
                                    System.out.println(" outseqs="+(java.lang.reflect.Array.getLength(namesseqs)/3));
                                }
                            }
                            if(allfiles){
                                //testing!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                                outfile2=new PrintWriter(new BufferedWriter(new FileWriter(basename+".bls.chk")));
                                for (int i=0;i<(java.lang.reflect.Array.getLength(namesseqs)-2);i+=3){//i=nameofhit i+1=queryofhit i+2=seqofhit
                                    outfile2.println(">"+namesseqs[i]);
                                    //outfile2.println(namesseqs[i+1]);
                                    outfile2.println(namesseqs[i+2]);
                                }// end for
                                outfile2.close();
                                //end testing!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                            }
                            //check if the sequences have species names
                            status="checking taxonomy1";
                            if((dochecktax)&&(tmpextfile.canRead())){
                                if(taxid){
                                    namesseqs=mycheck.dochecktaxid(namesseqs,tmpextfile,mytaxid,idtax);//check the taxonomy info
                                }else{
                                    namesseqs=mycheck.docheck(namesseqs,tmpextfile);//docheck in checktax
                                }
                            }
                            //System.out.println("did first dochecktaxid");
                            //BufferedReader tmpread=new BufferedReader(new InputStreamReader(System.in));
                            //String tmpstr=tmpread.readLine();
                            if(allfiles){
                                //testing!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                                outfile2=new PrintWriter(new BufferedWriter(new FileWriter(basename+".bls.cnt")));
                                for (int i=0;i<(java.lang.reflect.Array.getLength(namesseqs)-2);i+=3){//i=nameofhit i+1=queryofhit i+2=seqofhit
                                    outfile2.println(">"+namesseqs[i]);
                                    //outfile2.println(namesseqs[i+1]);
                                    outfile2.println(namesseqs[i+2]);
                                }// end for
                                outfile2.close();
                                //end testing!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                            }
                            
                            //-----now I have done all before clustal alignment of the hsp alignment
                            
                            if(verbose>2){
                                System.out.println("Performing clustalw alignment of sequence parts");
                            }
                            if(doclustal){
                            status="preparing clustalw alignment";
                                if(verbose>0){
                                    if(verbose>2){
                                        System.out.print(".clustal.");
                                    }else{
                                        System.out.print(".");
                                    }
                                }
                                boolean longnames=false;
                                String[] namesarr=new String[0];
                                //see if any of the sequence names are longer than 30 characters (maximum clustal can cope with)
                                int seqnum=java.lang.reflect.Array.getLength(namesseqs);
                                for(int i=0;i<seqnum;i+=3){
                                    if(namesseqs[i].length()>30){//if I need to assign numbers to the names
                                        longnames=true;
                                    }
                                }
                                if(longnames){//put the names into an array and rename the sequences accordingly
                                    namesarr=new String[(int)(seqnum/3)];
                                    for(int i=0;i<(seqnum/3);i++){
                                        namesarr[i]=namesseqs[i*3];
                                        namesseqs[i*3]=String.valueOf(i);
                                    }
                                }//end renameing the sequences
                                
                                String clucommand=command+" "+clustring;
                                //System.out.println("basename="+basename);
                                status="clustalw aligning";
                                namesseqs=myclu.align(clucommand,namesseqs,cluwidth,verbose,cpunum,basename);
                                status="post-clustalw";
                                //now the alignment part is done, rename the sequences to their original names
                                if(longnames){
                                    for(int i=0;i<seqnum;i+=3){
                                        namesseqs[i]=namesarr[Integer.parseInt(namesseqs[i])];
                                    }// end for i
                                }// end if longnames
                                if(allfiles){
                                    //testing!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                                    outfile2=new PrintWriter(new BufferedWriter(new FileWriter(basename+".cln.pcheck2")));
                                    for (int i=0;i<(java.lang.reflect.Array.getLength(namesseqs)-2);i+=3){//i=nameofhit i+1=queryofhit i+2=seqofhit
                                        outfile2.println(">"+namesseqs[i]);
                                        //outfile2.println(namesseqs[i+1]);
                                        outfile2.println(namesseqs[i+2]);
                                    }// end for
                                    outfile2.close();
                                    //end testing!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                                }
                                if((maxhmmsim<1)&&(maxhmmsim>0)){//(re-)check the sequences for maximum similarity
                                    if(verbose>2){
                                        System.out.println("---------doing check2----------- inseqs="+(java.lang.reflect.Array.getLength(namesseqs)/3));
                                    }
                                    namesseqs=hmmcheck.docheck(namesseqs,maxhmmsim,verbose);
                                    if(verbose>2){
                                        System.out.println(" outseqs="+(java.lang.reflect.Array.getLength(namesseqs)/3));
                                    }
                                }
                                File outfnamefile=new File(outfname);
                                PrintWriter outfile=new PrintWriter(new BufferedWriter(new FileWriter(outfnamefile)));
                                if(verbose>2){
                                    System.out.println("clustal output file="+outfnamefile.getAbsolutePath());
                                }
                                if(oformat==0){//if I want fasta format
                                    for (int i=0;i<java.lang.reflect.Array.getLength(namesseqs);i+=3){//i=nameofhit i+1=queryofhit i+2=seqofhit
                                        outfile.println(">"+namesseqs[i]);
                                        //outfile.println(namesseqs[i+1]);
                                        outfile.println(namesseqs[i+2]);
                                        if(verbose>5){
                                            System.out.println(">"+namesseqs[i]);
                                            System.out.println(namesseqs[i+2]);
                                        }
                                    }// end for
                                }else{//if I want clustal format
                                    aaseq[] outseqs=toaaseq(namesseqs);//convert the namesseqs objects to aaseq objects I can work with
                                    writealn.clustal(outseqs,outfile);
                                }
                                outfile.close();
                            }
                        }//end if outfname exists
                        
                        //now I have written the *.cln file and if I don't do hmm stuff that's the end
                        status="done cln";
                        if(killthread){
                            isdone=true;
                            status="killed";
                            synchronized(parent){
                                if(verbose>2){
                                    System.out.println("notifying parent for "+fname);
                                }
                                parent.notify();
                            }
                            return;
                        }
                        
                        String hmmfname=basename+hmmextens;
                        File filetest=new File(hmmfname);
                        if((filetest.exists())&&(myredo)){
                            filetest.delete();
                        }
                        if((new File(hmmfname).exists())&&(myredo==false)){
                            if(verbose>2){
                                System.out.println("found "+hmmfname+" skipping hmmbuild");
                            }
                            status="skipped hmmbuild";
                        }
                        if(((new File(hmmfname).exists()==false)||(myredo))&&(dohmmbuild)&&(errorless)){
                            if(verbose>2){
                                System.out.println("doing hmmbuild");
                            }
                            try{
                                String currstr;
                                Vector cmdvec=new Vector();
                                String hmmcommand=command+" "+hmmer.getAbsolutePath()+File.separator+"hmmbuild ";
                                cmdvec.addElement(hmmer.getAbsolutePath()+File.separator+"hmmbuild");
                                if(changehmmbuild){//if I want to use a different version or args
                                    //System.out.println("changing hmmbuild to "+hmmbuildstring);
                                    hmmcommand=command+" "+hmmbuildstring+" ";
                                    cmdvec.clear();
                                    cmdvec.addElement(hmmbuildstring);
                                }
                                cmdvec.addElement(hmmfname);
                                cmdvec.addElement(outfname);
                                if(command.length()>0){
                                    String[] tmparr=command.split("\\s+");
                                    int arrl=java.lang.reflect.Array.getLength(tmparr);
                                    for(int i=arrl-1;i>=0;i--){
                                        cmdvec.insertElementAt(tmparr[i],0);
                                    }
                                }
                                if(verbose>2){
                                    System.out.println("doing command "+hmmcommand+" "+hmmfname+" "+outfname);
                                }
                                String[] cmdarr=new String[cmdvec.size()];
                                cmdvec.copyInto(cmdarr);
                                String tmpstr="";
                                for(int i=0;i<java.lang.reflect.Array.getLength(cmdarr);i++){
                                    tmpstr+=cmdarr[i]+";";
                                }//endf or i
                                if(verbose>0){
                                    System.out.println("trying "+tmpstr);
                                }
                                status="creating HMM";
                                Process p=Runtime.getRuntime().exec(cmdarr);//hmmcommand+" "+hmmfname+" "+outfname);
                                BufferedReader perr=new BufferedReader(new InputStreamReader(p.getErrorStream()));
                                BufferedReader pin=new BufferedReader(new InputStreamReader(p.getInputStream()));
                                StringBuffer errout=new StringBuffer();
                                StringBuffer inout=new StringBuffer();
                                //note: threadstreamreader closes the input bufferedreader
                                threadstreamreader perrread=new threadstreamreader(perr,errout);
                                threadstreamreader pinread=new threadstreamreader(pin,inout);
                                try{
                                    perrread.start();
                                    pinread.start();
                                    p.waitFor();
                                    if(p.exitValue()!=0){
                                        System.err.println("Error, non-perfect exit from "+hmmcommand+" in hmmbuild for "+basename);
                                    }
                                }catch (InterruptedException e){
                                    System.err.println("Error Interrupted process "+hmmcommand+" "+hmmfname+" "+outfname);
                                }
                                perr=new BufferedReader(new StringReader(errout.toString()));
                                while ((currstr=perr.readLine())!=null){
                                    System.err.println(currstr);
                                    if(currstr.length()>1){
                                        errorless=false;
                                    }
                                }
                                pin=new BufferedReader(new StringReader(inout.toString()));
                                while ((currstr=pin.readLine())!=null){
                                    if(verbose>3){
                                        System.out.println(currstr);
                                    }
                                }
                            }catch (IOException e){
                                System.err.println("IOError in hmmbuild");
                                e.printStackTrace();
                                errorless=false;
                            }
                            if(verbose>0){
                                if(errorless==false){
                                    System.err.println("ERROR in hmmbuild");
                                }
                                if(errorless){
                                    if(verbose>2){
                                        System.out.println("done hmmbuild -->"+hmmfname);
                                    }
                                }
                            }
                            //now i have built the hmm model
                            //do I want to calibrate the hmm model?
                            if((dohmmcalibrate)&&(errorless)){
                                if(verbose>2){
                                    System.out.println("calibrating hmm "+hmmfname);
                                }else{
                                    if(verbose>0){
                                        System.out.print(".");
                                    }
                                }
                                status="calibrating HMM";
                                try{
                                    String currstr;
                                    Vector cmdvec=new Vector();
                                    String calibratecommand=command+" "+hmmer.getAbsolutePath()+File.separator+"hmmcalibrate --num "+hmmcalnum+" "+hmmfname;
                                    cmdvec.addElement(hmmer.getAbsolutePath()+File.separator+"hmmcalibrate");
                                    cmdvec.addElement("--num");
                                    cmdvec.addElement(String.valueOf(hmmcalnum));
                                    cmdvec.addElement(hmmfname);
                                    if(changehmmcalibrate){//if I want to change hmmcalibratecommand
                                        calibratecommand=command+" "+hmmcalibratestring+" --num "+hmmcalnum+" "+hmmfname;
                                        cmdvec.setElementAt(hmmcalibratestring, 0);
                                    }
                                    if(verbose>2){
                                        System.out.println("doing command "+calibratecommand);
                                    }
                                    if(command.length()>0){
                                        String[] tmparr=command.split("\\s+");
                                        int arrl=java.lang.reflect.Array.getLength(tmparr);
                                        for(int i=arrl-1;i>=0;i--){
                                            cmdvec.insertElementAt(tmparr[i],0);
                                        }
                                    }
                                    String[] cmdarr=new String[cmdvec.size()];
                                    cmdvec.copyInto(cmdarr);
                                    String tmpstr="";
                                    for(int i=0;i<java.lang.reflect.Array.getLength(cmdarr);i++){
                                        tmpstr+=cmdarr[i]+";";
                                    }//endf or i
                                    Process p=Runtime.getRuntime().exec(cmdarr);//calibratecommand);
                                    BufferedReader perr=new BufferedReader(new InputStreamReader(p.getErrorStream()));
                                    BufferedReader pin=new BufferedReader(new InputStreamReader(p.getInputStream()));
                                    StringBuffer errout=new StringBuffer();
                                    StringBuffer inout=new StringBuffer();
                                    //note: threadstreamreader closes the input bufferedreader
                                    threadstreamreader perrread=new threadstreamreader(perr,errout);
                                    threadstreamreader pinread=new threadstreamreader(pin,inout);
                                    try{
                                        perrread.start();
                                        pinread.start();
                                        p.waitFor();
                                        if(p.exitValue()!=0){
                                            System.err.println("Error, non-perfect exit from hmmcalibrate for "+basename);
                                        }
                                    }catch (InterruptedException e){
                                        System.err.println("Interrupted process hmmcalibrate "+hmmfname);
                                    }
                                    perr=new BufferedReader(new StringReader(errout.toString()));
                                    while ((currstr=perr.readLine())!=null){
                                        System.err.println(currstr);
                                        if(currstr.length()>1){
                                            errorless=false;
                                        }
                                    }
                                    pin=new BufferedReader(new StringReader(inout.toString()));
                                    while ((currstr=pin.readLine())!=null){
                                        if(verbose>3){
                                            System.out.println(currstr);
                                        }
                                    }
                                    perr.close();
                                    pin.close();
                                }catch (IOException e){
                                    System.err.println("IOError in hmmbuild");
                                    e.printStackTrace();
                                    errorless=false;
                                }
                            }// end if errorless
                        }
                        //hmm model is built and (if so specified) calibrated
                        if(killthread){
                            isdone=true;
                            status="killed";
                            synchronized(parent){
                                if(verbose>2){
                                    System.out.println("notifying parent for "+fname);
                                }
                                parent.notify();
                            }
                            return;
                        }
                        
                        //now do the hmmsearch
                        
                        String hmmsfname=basename+hmmsextens;
                        filetest=new File(hmmsfname);
                        if((filetest.exists())&&(myredo)){
                            filetest.delete();
                        }
                        if((new File(hmmsfname).exists())&&(myredo==false)&&(new File(hmmsfname).length()>0)){
                            if(verbose>2){
                                System.out.println("found "+hmmsfname+" skipping hmmsearch");
                            }
                            status="skipping hmmsearch";
                        }
                        if(((new File(hmmsfname).exists()==false)||(new File(hmmsfname).length()==0)||(myredo))&&(dohmmsearch)&&(errorless)){
                            if(verbose>0){
                                System.out.print(".");
                                if(verbose>2){
                                    if(dostrict){
                                        System.out.println("doing hmmsearch with "+hmmfname+" of "+strictextfname);
                                    }else{
                                        System.out.println("doing hmmsearch with "+hmmfname+" of "+extfname);
                                    }
                                }
                            }
                            try{
                                String currstr;
                                Vector cmdvec=new Vector();
                                String currcommand=command+" "+hmmer.getAbsolutePath()+File.separator+"hmmsearch -E "+hmmseval;//+" -A "+seqs;//-E sets E value, -A sets how many hits should be displayed; but I don't want to only show 50 because of (potentially) identical hits
                                cmdvec.addElement(hmmer.getAbsolutePath()+File.separator+"hmmsearch");
                                cmdvec.addElement("-E");
                                cmdvec.addElement(String.valueOf(hmmseval));
                                if(changehmmsearch){//if I want to change the hmmsearch executable of pass args
                                    currcommand=command+" "+hmmsearchstring+" -E "+hmmseval;
                                    cmdvec.setElementAt(hmmsearchstring,0);
                                }
                                if((addhmmszval==false)&&(didext)){//if no specific z value was entered use the number of entries in the db searched as zval
                                    currcommand+=" -Z "+numberofentries;
                                    cmdvec.addElement("-Z");
                                    cmdvec.addElement(String.valueOf(numberofentries));
                                }
                                if(addhmmszval){
                                    currcommand+=" -Z "+String.valueOf((int)hmmszval);
                                    cmdvec.addElement("-Z");
                                    cmdvec.addElement(String.valueOf(hmmszval));
                                }
                                PrintWriter outwri=new PrintWriter(new BufferedWriter(new FileWriter(hmmsfname)));
                                String teststring=currcommand+" "+hmmfname;
                                cmdvec.addElement(hmmfname);
                                if(dostrict){
                                    teststring=teststring+" "+strictextfname;
                                    cmdvec.addElement(strictextfname);
                                }else{
                                    teststring=teststring+" "+extfname;
                                    cmdvec.addElement(extfname);
                                }
                                if(verbose>2){
                                    System.out.println("doing hmms command "+teststring);
                                }
                                StringBuffer errout=new StringBuffer();
                                StringBuffer inout=new StringBuffer();
                                int redid=0;
                                if(command.length()>0){
                                    String[] tmparr=command.split("\\s+");
                                    int arrl=java.lang.reflect.Array.getLength(tmparr);
                                    for(int i=arrl-1;i>=0;i--){
                                        cmdvec.insertElementAt(tmparr[i],0);
                                    }
                                }
                                String[] cmdarr=new String[cmdvec.size()];
                                cmdvec.copyInto(cmdarr);
                                String tmpstr="";
                                for(int i=0;i<java.lang.reflect.Array.getLength(cmdarr);i++){
                                    tmpstr+=cmdarr[i]+";";
                                }//endf or i
                                System.out.println("trying hmms '"+tmpstr+"'");
                                status="HMM-searching";
                                while ((((inout.toString()).trim()).length()==0)&&(redid<5)){
                                    redid+=1;
                                    Process p=Runtime.getRuntime().exec(cmdarr);//teststring);
                                    BufferedReader pin=new BufferedReader(new InputStreamReader(p.getInputStream()));
                                    BufferedReader perr=new BufferedReader(new InputStreamReader(p.getErrorStream()));
                                    threadstreamreader errread=new threadstreamreader(perr,errout);
                                    threadstreamreader inread=new threadstreamreader(pin,inout);
                                    //System.out.println("started command");
                                    try{
                                        errread.start();
                                        inread.start();
                                        p.waitFor();
                                        if(p.exitValue()!=0){
                                            System.err.println("Error, non perfect return from hmmsearch for "+basename);
                                            System.err.print("'"+errout.toString()+"'");
                                        }
                                    }catch (InterruptedException e){
                                        if(dostrict){
                                            System.err.println("Interrupted process hmmsearch "+hmmfname+" "+strictextfname);
                                        }else{
                                            System.err.println("Interrupted process hmmsearch "+hmmfname+" "+extfname);
                                        }
                                    }
                                }// end while inout.length==0
                                if(redid>=5){
                                    System.err.println("ERROR, Empty stdin buffer returned from hmmsearch 5 times, skipping this file");
                                    isdone=true;
                                    status="aborting, hmmsearch eror 5 times";
                                    synchronized(parent){
                                        if(verbose>2){
                                            System.out.println("notifying parent for "+fname);
                                        }
                                        parent.notify();
                                    }
                                    return;
                                }
                                System.err.print(errout.toString());
                                if(verbose>3){
                                    System.out.println(inout.toString());
                                }
                                outwri.println(inout.toString());//write the hmmsearch results to file *.hms
                                outwri.close();
                            }catch (IOException e){
                                System.err.println("IOError in hmmsearch");
                                e.printStackTrace();
                                errorless=false;
                            }
                            if(verbose>2){
                                System.out.println("done hmmsearch --> "+hmmsfname);
                            }
                        }// end if hmmsfname
                        //hmmsearch is done and the results are in *.hms
                        if(killthread){
                            isdone=true;
                            status="killed";
                            synchronized(parent){
                                if(verbose>2){
                                    System.out.println("notifying parent for "+fname);
                                }
                                parent.notify();
                            }
                            return;
                        }
                        //now read the hms file and realign the sequences to the hmm.
                        String hlnfname=basename+hlnextens;
                        filetest=new File(hlnfname);
                        if((filetest.exists())&&(myredo)){
                            filetest.delete();
                        }
                        if((new File(hlnfname).exists())&&(myredo==false)){
                            //if I already have a file of that name
                            if(verbose>2){
                                System.out.println("found "+hlnfname+" skipping hmmsearch realignment");
                            }
                            status="skipping hmmalign";
                        }
                        if(((new File(hlnfname).exists()==false)||(myredo))&&(new File(hmmsfname).exists())&&(errorless)){//dohmmsearch is right here, since this extracts the hmmsearch sequences to a malign file
                            if(verbose>2){
                                System.out.println("converting "+hmmsfname+" to multiple alignment");
                            }
                            try{
                                BufferedReader freader=new BufferedReader(new FileReader(hmmsfname));
                                String[] retarr=hmms2malign.malign(freader);//,basename);//here the sequences are read from the hmmsearch file
                                //System.out.println("hmms sequences found:"+java.lang.reflect.Array.getLength(retarr));
                                freader.close();
                                //now I have the hmm seqs in fasta format in retarr[0] and [2]
                                if(allfiles){
                                    //testing!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                                    PrintWriter outfile2=new PrintWriter(new BufferedWriter(new FileWriter(basename+".hmms.ext")));
                                    for (int i=0;i<(java.lang.reflect.Array.getLength(retarr)-2);i+=3){//i=nameofhit i+1=queryofhit i+2=seqofhit
                                        outfile2.println(">"+retarr[i]);
                                        outfile2.println(retarr[i+2]);
                                    }// end for
                                    outfile2.close();
                                    //end testing!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                                }
                                //now align all sequences to the hmm
                                String prealignname=basename+".pln";
                                try{
                                    PrintWriter outtest=new PrintWriter(new BufferedWriter(new FileWriter(prealignname)));
                                    for(int i=0;i<(java.lang.reflect.Array.getLength(retarr));i+=3){
                                        outtest.println(">"+retarr[i]);
                                        outtest.println(retarr[i+2]);
                                        outtest.println();
                                    }
                                    outtest.close();
                                }catch (IOException e){
                                    System.err.println("IOError");
                                }
                                Vector cmdvec=new Vector();
                                String currcommand=command+" "+hmmer.getAbsolutePath()+File.separator+"hmmalign "+hmmfname+" "+prealignname;
                                cmdvec.addElement(hmmer.getAbsolutePath()+File.separator+"hmmalign");
                                cmdvec.addElement(hmmfname);
                                cmdvec.addElement(prealignname);
                                if(changehmmalign){//if I want to use different hmmalign executable or pass args
                                    currcommand=command+" "+hmmalignstring+" "+hmmfname+" "+prealignname;
                                    cmdvec.setElementAt(hmmalignstring,0);
                                }
                                if(verbose>2){
                                    System.out.println("doing hmmalign with command "+currcommand);
                                }
                                StringBuffer errout=new StringBuffer();
                                StringBuffer inout=new StringBuffer();
                                int redid=0;
                                if(command.length()>0){
                                    String[] tmparr=command.split("\\s+");
                                    int arrl=java.lang.reflect.Array.getLength(tmparr);
                                    for(int i=arrl-1;i>=0;i--){
                                        cmdvec.insertElementAt(tmparr[i],0);
                                    }
                                }
                                String[] cmdarr=new String[cmdvec.size()];
                                cmdvec.copyInto(cmdarr);
                                String tmpstr="";
                                for(int i=0;i<java.lang.reflect.Array.getLength(cmdarr);i++){
                                    tmpstr+=cmdarr[i]+";";
                                }//endf or i
                                //System.out.println("trying "+tmpstr);
                                status="HMM-align";
                                while ((((inout.toString()).trim()).length()==0)&&(redid<5)){
                                    redid++;
                                    Process p=Runtime.getRuntime().exec(cmdarr);//currcommand);
                                    BufferedReader pin=new BufferedReader(new InputStreamReader(p.getInputStream()));
                                    BufferedReader perr=new BufferedReader(new InputStreamReader(p.getErrorStream()));
                                    threadstreamreader errread=new threadstreamreader(perr,errout);
                                    threadstreamreader inread=new threadstreamreader(pin,inout);
                                    //System.out.println("started command");
                                    try{
                                        errread.start();
                                        inread.start();
                                        p.waitFor();
                                        if(p.exitValue()!=0){
                                            System.err.println("Error, non perfect return from hmmalign for "+basename);
                                        }
                                        if(errout.length()>0){
                                            System.err.println(errout.toString());
                                        }
                                    }catch (InterruptedException e){
                                        System.err.println("Interrupted process hmmalign "+hmmfname+" "+extfname);
                                        status="interrupted HMM-align";
                                    }
                                }// end while inout.length ==0
                                if(redid>=5){
                                    System.err.println("ERROR, Empty stdin buffer returned from hmmalign 5 times for "+basename);
                                    status="aborting, error in hmmalign 5 times ";
                                    if(errout.length()>0){
                                        System.err.println(errout.toString());
                                    }
                                    isdone=true;
                                    killthread=true;
                                    synchronized(parent){
                                        if(verbose>2){
                                            System.out.println("notifying parent for "+fname);
                                        }
                                        parent.notify();
                                    }
                                    return;
                                }
                                if(allfiles){
                                    PrintWriter prereadhmmalign=new PrintWriter(new BufferedWriter(new FileWriter(basename+".phmmln.org")));
                                    prereadhmmalign.println(inout.toString());
                                    prereadhmmalign.close();
                                }
                                retarr=readhmmalign.read(inout,retarr);
                                if(allfiles==false){
                                    new File(prealignname).delete();
                                }
                                PrintWriter outfile2;
                                if(allfiles){
                                    //testing!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                                    outfile2=new PrintWriter(new BufferedWriter(new FileWriter(basename+".hmmln.org")));
                                    boolean allempty=true;
                                    for (int i=0;i<(java.lang.reflect.Array.getLength(retarr)-2);i+=3){//i=nameofhit i+1=queryofhit i+2=seqofhit
                                        outfile2.println(">"+retarr[i]);
                                        //outfile2.println(namesseqs[i+1]);
                                        outfile2.println(retarr[i+2]);
                                        if(retarr[i+2].trim().length()>0){
                                            allempty=false;
                                        }
                                    }// end for
                                    if(allempty){
                                        System.err.println("EMPTY hmmalign file for "+basename+".hmmln.org");
                                    }
                                    outfile2.close();
                                    //end testing!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                                }
                                //remove multiple occurances of the same seqname (keep the first)
                                Vector tmpvec=new Vector();
                                int retarrl=java.lang.reflect.Array.getLength(retarr);
                                boolean exists=false;
                                tmphash=new HashMap();
                                for (int i=0;i<retarrl;i+=3){//the first element is the seqname
                                    exists=false;
                                    if(tmphash.containsKey(retarr[i])){
                                        exists=true;
                                    }else{
                                        tmphash.put(retarr[i],"");
                                    }
                                    //for(int j=0;j<tmpvec.size();j+=3){
                                    //    if(retarr[i].equals((String)tmpvec.elementAt(j))){
                                    //        exists=true;
                                    //        break;
                                    //    }
                                    //}// end for j
                                    if(exists==false){
                                        tmpvec.addElement(retarr[i]);
                                        tmpvec.addElement(retarr[i+1]);
                                        tmpvec.addElement(retarr[i+2]);
                                    }
                                }// end for i
                                retarr=new String[tmpvec.size()];
                                tmpvec.copyInto(retarr);
                                //get the original sequence names from the extrfname file (.fas extension)
                                File tmpextfile=new File(extfname);
                                if((dochecktax)&&(tmpextfile.canRead()==false)){//if the extractfile is not present or unreadable but should be used
                                    System.err.println("unable to read from tmpextfile.getName()");
                                    isdone=true;
                                    killthread=true;
                                    status="aborting, unreadable input file "+extfname;
                                    synchronized(parent){
                                        parent.notify();
                                    }
                                    return;
                                }
                                status="checking taxonomy2";
                                if(taxid){
                                    retarr=mycheck.dochecktaxid(retarr,tmpextfile,mytaxid,idtax);
                                }else{
                                    retarr=mycheck.docheck(retarr,tmpextfile);
                                }
                                if(allfiles){
                                    //testing!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                                    outfile2=new PrintWriter(new BufferedWriter(new FileWriter(basename+".hmmln.cnt")));
                                    for (int i=0;i<(java.lang.reflect.Array.getLength(retarr)-2);i+=3){//i=nameofhit i+1=queryofhit i+2=seqofhit
                                        outfile2.println(">"+retarr[i]);
                                        //outfile2.println(namesseqs[i+1]);
                                        outfile2.println(retarr[i+2]);
                                    }// end for
                                    outfile2.close();
                                    //end testing!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                                }
                                //now check how many sequences you have in retarr
                                if(myseqs>0){//if I want to limit the number of sequences
                                    if(java.lang.reflect.Array.getLength(retarr)>(myseqs*3)){//if I have more sequences than I want
                                        String[] tmparr=new String[myseqs*3];//remove all the superfluous ones
                                        for(int i=0;i<(myseqs*3);i++){
                                            tmparr[i]=retarr[i];
                                        }
                                        retarr=tmparr;
                                        //get maximum sequence length
                                        int maxseqlength=0;
                                        for(int i=0;i<myseqs;i++){
                                            if(maxseqlength<retarr[(i*3)+2].length()){
                                                maxseqlength=retarr[(i*3)+2].length();
                                            }
                                        }
                                        //now loop through the sequences and remove the gap only collumns
                                        boolean allgap;
                                        String str1;
                                        String str2;
                                        for(int pos=0;pos<maxseqlength;pos++){
                                            allgap=true;
                                            for(int i=0;((i<myseqs)&&(allgap));i++){
                                                if(retarr[(i*3)+2].charAt(pos)!='-'){
                                                    allgap=false;
                                                }
                                            }// end for i
                                            if(allgap){//if this is a gap in all seqs remove this collumn
                                                for(int i=0;i<myseqs;i++){//for each seq remove char at pos
                                                    if(pos<retarr[(i*3)+2].length()){
                                                        str1=retarr[(i*3)+2].substring(0,pos);
                                                        str2=retarr[(i*3)+2].substring(pos+1);
                                                        retarr[(i*3)+2]=str1+str2;
                                                    }
                                                }
                                                pos-=1;
                                                maxseqlength-=1;
                                            }// end if allgap
                                        }// end for pos
                                    }// end if more seqs that allowed
                                }//end if I want to limit the number of sequences
                                if(parent.checkquery){
                                    //now see if the query is still present in this alignment
                                    boolean foundquery=false;
                                    int seqnum=java.lang.reflect.Array.getLength(retarr)/3;
                                    if(verbose>1){
                                        System.out.println("checking for query '"+idstring+"'");
                                    }
                                    for(int i=0;i<seqnum;i++){
                                        //System.out.println("searching through '"+retarr[i*3]+"' for '"+idstring+"'");
                                        if(retarr[i*3].indexOf(idstring)>-1){
                                            //System.out.println("*****found "+idstring);
                                            foundquery=true;
                                            break;
                                        }
                                    }//end for i
                                    if((foundquery==false)&&(mygetdissim==true)){
                                        System.err.println("***"+idstring+" not found in alignment, repeating search with getdissim=false;");
                                        round--;
                                        myredo=true;
                                        mygetdissim=false;
                                        continue NEWSEARCH;
                                    }else if(foundquery==true){
                                        if(verbose>1){
                                            System.out.println("found '"+idstring+"'");
                                        }
                                    }else if((foundquery==false)&&(mygetdissim==false)&&(dostrict==false)){
                                        System.err.println("***"+idstring+" not found in alignment, repeating search with getdissim=false & dostrict=true;");
                                        round--;
                                        myredo=true;
                                        mygetdissim=false;
                                        dostrict=true;
                                        continue NEWSEARCH;
                                    }else if((foundquery==false)&&(myseqs>0)){
                                        System.err.println("***"+idstring+" not found in alignment, repeating search without sequence limitations (seq=-1, dostrict=true, getdissim=false)");
                                        round--;
                                        myredo=true;
                                        mygetdissim=false;
                                        dostrict=true;
                                        myseqs=-1;
                                        continue NEWSEARCH;
                                    }else{
                                        System.err.println("***"+idstring+" not found in alignment; no repeat this time (already getdissim=fasle & dostrict=true).");
                                    }
                                }//end if checkquery
                                PrintWriter outfile=new PrintWriter(new BufferedWriter(new FileWriter(hlnfname)));
                                if(oformat==0){//if output format is fasta
                                    for(int i=0;i<java.lang.reflect.Array.getLength(retarr)-2;i+=3){
                                        outfile.println(">"+retarr[i]);
                                        outfile.println(retarr[i+2]);
                                    }
                                }else{//if output format should be clustal
                                    //convert the stuff to aaseq objects
                                    int seqnums=(int)(java.lang.reflect.Array.getLength(retarr)/3);
                                    aaseq[] printarr=new aaseq[seqnums];
                                    for(int i=0;i<seqnums;i++){
                                        printarr[i]=new aaseq();
                                        printarr[i].setname(retarr[i*3]);
                                        printarr[i].setseq(retarr[(i*3)+2]);
                                    }// end for i
                                    //and now print the sequences
                                    writealn.clustal(printarr,outfile);
                                }
                                outfile.close();
                            }catch (IOException e){
                                System.err.println("IOError in hmmsearch realignment");
                                e.printStackTrace();
                            }
                            if(verbose>2){
                                System.out.println("done hmmsearch conversion --> "+hlnfname);
                            }
                        }// end if hmmsfname
                        if(verbose>1){
                            System.out.println("DONE "+fname);
                        }
                    }catch (IOException e){
                        System.err.println("IOERROR in blammerthread");
                        e.printStackTrace();
                    }
                }//end while round<0
                status="done";
                isdone=true;
                killthread=true;
                synchronized(parent){
                    if(verbose>2){
                        System.out.println("notifying parent for "+fname);
                    }
                    parent.notify();
                }
                return;
        }// end run
    }// end blammerthread
    
}// end class
