/*
 * hmmclualign.java
 *
 * Created on March 1, 2002, 6:07 PM
 */
import java.io.*;
import java.util.*;
/**
 *
 * @author  tancred
 * @version 
 */
public class hmmclualign {

    /** Creates new hmmclualign */
    public hmmclualign() {
    }

    public String[] malign(String[] inarr, String command,int cpunum,boolean verbose,int verbosenum,int windowsize){
        clustalread myclustalread=new clustalread();
        inarr=removeallallgaps(inarr);
        //this routine should take a String[] consisting of triplets. Name, hmmquery, hmmhit
        //each time the hmmquery is gapped, if there is more than one hitseq with no gaps there, realign
        //that part using clustal (use String command to know what shell you need to open).
        int[][] gapblocks=gethmmblocks(inarr,windowsize);//find the gapped hmm positions
        //gapblocks holds start & length of the blocks to do.
//        try{
//            PrintWriter outfile=new PrintWriter(new BufferedWriter(new FileWriter("blockstest.txt")));
//            for(int i=0;i<java.lang.reflect.Array.getLength(gapblocks);i++){
//                outfile.println("block "+i+" start="+gapblocks[i][0]+" length="+gapblocks[i][1]);
//            }// end for i
//            outfile.close();
//        }catch (IOException e){
//            System.out.println("IOerror in writing gapfile");
//            e.printStackTrace();
//        }
        File alnfile=new File("tmpfile"+cpunum+".aln");
        File tmpfile=new File("tmpfile"+cpunum+".txt");
        String orgname="tmpfile"+cpunum+".txt";
        File dndfile=new File("tmpfile"+cpunum+".dnd");
        int lastpos=0;
        int gapstart=0;
        int gaplength=0;
        int noseqs=java.lang.reflect.Array.getLength(inarr);
        int noblocks=java.lang.reflect.Array.getLength(gapblocks);
        lastpos=0;
        String[][] noaln=new String[noblocks+1][noseqs];//don't realign
        String[][] doaln=new String[noblocks][noseqs];//do realign
        for(int i=0;i<noblocks;i++){
            gapstart=gapblocks[i][0];
            gaplength=gapblocks[i][1];
            //System.out.println("gap"+i+" "+gapstart+" length "+gaplength);
            for(int j=0;j<(noseqs-2);j+=3){
                //System.out.print(".");
                //noaln[j+1][i]=inarr[j+1].substring(lastpos,gapstart);
                //doaln[j+1][i]=inarr[j+1].substring(gapstart,gapstart+gaplength);
                noaln[i][j+2]=inarr[j+2].substring(lastpos,gapstart);
                doaln[i][j+2]=inarr[j+2].substring(gapstart,(gapstart+gaplength));
                //if(j==0){
                    //System.out.println("'"+inarr[j+2].substring(gapstart,gapstart+gaplength)+"'");
                //    System.out.println("'"+doaln[i][j+2]+"'");
                //}
            }// end for j<noseqs-2
            lastpos=(gapstart+gaplength);
        }// end for i gapblocks
        //all sequences should be the same length
        for(int j=0;j<(noseqs-2);j+=3){
            if(lastpos<inarr[j+2].length()){//if I am not at the end of the sequence
                noaln[noblocks][j+2]=inarr[j+2].substring(lastpos);//to end
            }else{
                noaln[noblocks][j+2]="";
            }
        }// end for j
        //just testing to see what is the alignment input
//        try{
//            PrintWriter testfilethis=new PrintWriter(new BufferedWriter(new FileWriter("testfile.txt")));
//            for(int i=0;i<(noseqs-2);i+=3){
//                testfilethis.println(inarr[i]);
//                testfilethis.println(inarr[i+2]);
//                for(int j=0;j<noblocks;j++){
//                    testfilethis.print("'"+noaln[j][i]+"/"+doaln[j][i]+"'");
//                }// end for j
//                testfilethis.println("'"+noaln[noblocks][i]);
//            }
//            testfilethis.close();
//        }catch (IOException e){
//            System.out.println("IOErr1");
//        }
        //now I have split the sequence array into two arrays. noaln containing the block not needing to be aligned
        //and doaln containing the blocks to be aligned. sequence names are not provided, take inarr every third element
        //now align the doaln blocks using clustal
        try{
            int[] addpos=new int[noseqs];
            for(int i=0;i<noblocks;i++){
                //tmpfile=new File(orgname+i);
                PrintWriter outfile=new PrintWriter(new BufferedWriter(new FileWriter(tmpfile)));
                String tmpstr;
                for(int j=0;j<(noseqs-2);j+=3){
                    addpos[j+2]=0;
                    outfile.println(">"+inarr[j]);
                    //if(j==0){
                    //    System.out.println("-"+doaln[i][j+2]+"-");
                    //}
                    String[] tmparr=doaln[i][j+2].split("-+",0);//remove the gaps from the sequence
                    StringBuffer tmpbuf=new StringBuffer();
                    for(int k=0;k<java.lang.reflect.Array.getLength(tmparr);k++){
                        tmpbuf.append(tmparr[k]);
                    }
                    tmpstr=tmpbuf.toString();
                    //check to see that no sequence has length of 1
                    if(tmpstr.length()==1){// if length of 1
                        tmpstr="x"+tmpstr;// prepend a character
                        addpos[j+2]=-1;//remember the addition
                    }// end if length==1
                    outfile.println(tmpstr);
                }//end for j
                outfile.close();
                //now I have transferred the parts to be aligned to a file called tmpfile
                //do clustalwalign on tmpfile
                try{
                    StringBuffer errout=new StringBuffer();
                    StringBuffer inout=new StringBuffer();
                    if(verbose){
                        if(verbosenum>1){
                        System.out.println("running "+command+" -INFILE="+tmpfile.getAbsolutePath());
                        }else{
                            System.out.print(".");
                        }
                    }
                    Process p=Runtime.getRuntime().exec(command+" -INFILE="+tmpfile.getAbsolutePath());
                    BufferedReader perr=new BufferedReader(new InputStreamReader(p.getErrorStream()));
                    BufferedReader pin=new BufferedReader(new InputStreamReader(p.getInputStream()));
                    threadstreamreader errread=new threadstreamreader(perr,errout);
                    threadstreamreader inread=new threadstreamreader(pin,inout);
                    //output should be in tmpfile.aln&dnd
                    try{// wait for clustal to finish
                        errread.start();
                        inread.start();
                        p.waitFor();
                    }catch (InterruptedException e){
                        System.err.println("Interrupted Clustalw run");
                    }
                    System.err.print(errout.toString());
                    if(verbose){
                        if(verbosenum>1){
                        System.out.println("done clualign of block "+i);
                        }
                    //    System.out.println(inout.toString());
                    }// end if verbose
                }catch (IOException e){
                    System.err.println("IOError in running hmmclualign");
                    e.printStackTrace();
                }
                //System.out.println("reading "+alnfile);
                aaseq[] tmparr=myclustalread.clustalintread(alnfile);
                //System.out.println("did cluread");
                doaln[i]=getseqparts(tmparr,inarr);
                //System.out.println("done getseqparts");
                for(int j=0;j<(noseqs-2);j+=3){
                    if(addpos[j+2]==-1){//if I added a serine before..
                        doaln[i][j+2]=removefirstchar(doaln[i][j+2],'x');//remove it now
                    } 
                    //System.out.println("doaln ["+i+"]["+(j+2)+"] '"+doaln[i][j+2]+"'");
                }// end for j
                //might need to lengthen the hmmquery seq here, still unsure!
                // and now delete the clustal files
                //tmpfile.renameTo(new File("tmpfile"+i+"-"+cpunum+".txt"));
                //alnfile.renameTo(new File("tmpfile"+i+"-"+cpunum+".aln"));
                tmpfile.delete();
                alnfile.delete();
                dndfile.delete();
            }// end for i<numberofblocks (clualign)
        }catch (IOException e){
            System.err.println("IOError in hmmclualign");
            e.printStackTrace();
        }
//        try{
//            PrintWriter testfilethis=new PrintWriter(new BufferedWriter(new FileWriter("testfile2.txt")));
//            for(int i=0;i<(noseqs-2);i+=3){
//                testfilethis.println(inarr[i]);
//                testfilethis.println(inarr[i+2]);
//                for(int j=0;j<noblocks;j++){
//                    testfilethis.print("'"+noaln[j][i]+"/"+doaln[j][i]+"'");
//                }// end for j
//                testfilethis.println("'"+noaln[noblocks][i]);
//            }
//            testfilethis.close();
//        }catch (IOException e){
//            System.out.println("IOErr1");
//        }
        
        //and last restore the sequences from the aligned and nonaligned blocks
        //StringBuffer this1=new StringBuffer();
        StringBuffer this2=new StringBuffer();
        for(int i=0;i<(noseqs-2);i+=3){
            for(int j=0;j<noblocks;j++){
                //this1.append(noaln[i+1][j]);
                //this1.append(doaln[i+1][j]);
                this2.append(noaln[j][i+2]);
                this2.append(doaln[j][i+2]);
            }//end for j
            //this1.append(noaln[i+1][noblocks]);
            this2.append(noaln[noblocks][i+2]);
            //inarr[i+1]=this1.toString();
            inarr[i+2]=this2.toString();
            //this1=new StringBuffer();
            this2=new StringBuffer();
        }// end for i<seqs
        //******** NOTE ****** the query hmm is now not aligned to the hit sequence anymore!
        return inarr;
    }// end malign
    
    //----------------------------------------------------------------------------------------------------------------
    
    int[][] gethmmblocks(String[] inarr, int windowsize){
        Vector tmpvec=new Vector();
        //find the blocks that need to be realigned
        //no sequence will be present before the beginning of the hmm, and none after the end
        //all blocks that need to be aligned are those where the query hmm has less than windowsize elements in a row
        int noseqs=java.lang.reflect.Array.getLength(inarr);
        int maxhmmlength=inarr[1].length();//if all hmm are the same length
        //int maxhmmlength=0;
        //for(int i=0;i<(noseqs-2);i+=3){
        //    if(inarr[i+1].length()>maxhmmlength){
        //        maxhmmlength=inarr[i+1].length();
        //    }
        //}// end for i<noseqs
        //now look for the last position of a non gap char in the seqs. 
        //further than that position for each seq, no need to check for gaps.
        int[] seqsend=new int[noseqs];
        int[] seqsstart=new int [noseqs];
        int currlength;
        for(int i=0;i<(noseqs-2);i+=3){
            currlength=inarr[i+2].length();
            int lastchar=0;
            for(int pos=(currlength-1);pos>=0;pos--){
                if(inarr[i+2].charAt(pos)!='-'){//if the seqchar is not a gap
                    lastchar=pos;
                    //System.out.print("'"+inarr[i+2].charAt(pos)+"'");
                    break;
                }// end if ischar
            }// end for pos
            //seqsend[i+1]=lastchar;
            seqsend[i+2]=lastchar;
            //System.out.println("seq"+i+" lastchar @ "+seqsend[i+1]);
        }// end for i
        for(int i=0;i<(noseqs-2);i+=3){
            int firstchar=0;
            for(int pos=0;pos<inarr[i+2].length();pos++){
                if(inarr[i+2].charAt(pos)!='-'){
                    firstchar=pos;
                    break;
                }
            }// end for pos
            seqsstart[i+2]=firstchar;
            //System.out.println(inarr[i]+" start at "+firstchar);
        }// end for i
        //now I know the maximum length of throws hmm profiles present
        //loop through each position and mark where gaps start and end
        gapobj thisgap=new gapobj();
        int currwidth=windowsize+1;
        boolean ingap=false;
        int counter=0;
        int nogapseqs=0;//check if there is more than one seq creating the gap. otherwise no need to align
        for(int pos=0;pos<maxhmmlength;pos++){//loop through the positions of the hmmqueries
            boolean foundgap=false;
            int thisnogapseqs=0;
            for(int i=0;i<(noseqs-2);i+=3){
                if(pos<seqsstart[i+2]){//if the current position is before the actual start of this sequence
                    continue;
                }
                if(pos>=seqsend[i+2]){// if this position is in the added fillup gaps, skip this seq
                    continue;
                }
                if(pos>=inarr[i+2].length()){
                    continue;
                }
                if(inarr[i+2].charAt(pos)=='-'){
                    foundgap=true;
                }else{
                    thisnogapseqs+=1;
                }
            }// end for i
            if(foundgap){
                if(ingap){
                    if(thisnogapseqs>nogapseqs){
                        nogapseqs=thisnogapseqs;
                    }
                }// end if ingap
                currwidth=0;
                if(ingap==false){
                    thisgap=new gapobj();
                    thisgap.begin=pos;
                    ingap=true;
                    nogapseqs=0;
                }
                thisgap.end=pos;
                continue;
            }//end if foundgap
            if(foundgap==false){
                currwidth+=1;
                if((ingap)&&(windowsize<=currwidth)){
                    thisgap.length=(thisgap.end-thisgap.begin)+1;// just testing , the +1
                    if((thisgap.length>1)&&(nogapseqs>1)){
                        tmpvec.addElement(thisgap);
                        //if(counter==2){
                        //    System.out.println("adding counter=2 nogapseqs="+nogapseqs);
                        //}
                        counter+=1;
                    }
                    ingap=false;
                }
                if(ingap){
                    if(thisnogapseqs>nogapseqs){
                        nogapseqs=thisnogapseqs;
                    }
                }// end if ingap
            }// end if foundgap==false
        }// end for i<maxhmmlength
        //if the sequence ends with a gap, add it
        if((ingap)){
            thisgap.length=(thisgap.end-thisgap.begin)+1;// just testing , the +1
            if(thisgap.length>1){
                tmpvec.addElement(thisgap);
            }
            ingap=false;
        }// end if ingap
        int vecsize=tmpvec.size();
        int [][] outarr=new int[vecsize][2];
        for(int i=0;i<vecsize;i++){
            outarr[i][0]=((gapobj)tmpvec.elementAt(i)).begin;
            outarr[i][1]=((gapobj)tmpvec.elementAt(i)).length;
        }// end for i
        return outarr;
    }// end getblocks
    
    //----------------------------------------------------------------------------------------------------------------
    
    String[] getseqparts(aaseq[] seqarr, String[] inarr){
        //this needs to sort the clustal output of aaseq[] in the order specified bu innames
        String[] tmparr=new String[java.lang.reflect.Array.getLength(inarr)];
        //seqarr=rename(seqarr);
        //inarr=rename(inarr);
        //for(int i=0;i<java.lang.reflect.Array.getLength(seqarr);i++){
        //    System.out.println("seqarrnames"+i+"="+seqarr[i].getname());
        //}// end for i
        int noseqs=java.lang.reflect.Array.getLength(seqarr);
        int arrlength=java.lang.reflect.Array.getLength(inarr);
        int maxlength=0;
        for (int i=0;i<(arrlength-2);i+=3){
            tmparr[i]=inarr[i];
            tmparr[i+1]=inarr[i+1];
            tmparr[i+2]="";
            boolean foundname=false;
            int inamelength;
            int snamelength;
            inamelength=inarr[i].length();
            for(int j=0;j<noseqs;j++){
                snamelength=(seqarr[j].getname()).length();
                if(snamelength>inamelength){
                    if(inarr[i].equals((seqarr[j].getname()).substring(0,inamelength))){//check if the names are the same
                        tmparr[i+2]=new String(seqarr[j].getseq());
                        if(maxlength<tmparr[i+2].length()){
                            maxlength=tmparr[i+2].length();
                        }
                        foundname=true;
                        break;
                    }// end if
                }// end if snamelength>inamelength
                if(snamelength==inamelength){
                    if(inarr[i].equals((seqarr[j].getname()))){//check if the names are the same
                        tmparr[i+2]=new String(seqarr[j].getseq());
                        if(maxlength<tmparr[i+2].length()){
                            maxlength=tmparr[i+2].length();
                        }
                        foundname=true;
                        break;
                    }// end if
                }//end if sname==iname
                if(snamelength<inamelength){
                    if((inarr[i].substring(0,snamelength)).equals((seqarr[j].getname()))){//check if the names are the same
                        tmparr[i+2]=new String(seqarr[j].getseq());
                        if(maxlength<tmparr[i+2].length()){
                            maxlength=tmparr[i+2].length();
                        }
                        foundname=true;
                        break;
                    }// end if
                }// end if sname<inam
            }// end for j
            if(foundname==false){//if I don't find the name via an equals search
               System.err.println("no name found for "+inarr[i]);
            }
        }// end for i
        //now make all sequences the same length
        int gaplength=0;
        for(int i=0;i<(arrlength-2);i+=3){
            gaplength=maxlength-tmparr[i+2].length();
            StringBuffer appstr=new StringBuffer();
            while (gaplength>0){
                appstr.append("-");
                gaplength-=1;
            }
            tmparr[i+2]=tmparr[i+2]+appstr.toString();
        }// end for i
        return tmparr;
    }// end getseqparts
    
    //---------------------------------------------------------------------------------------------------------
    /*
    String[] rename(String[] inarr){
        int noelem=java.lang.reflect.Array.getLength(inarr);
        int beginnum=0;
        int endnum=0;
        for(int i=0;i<(noelem-2);i+=3){
            String currname=inarr[i];
            //System.out.print("renaming "+currname);
            if((beginnum=(inarr[i]).indexOf("gi|"))>-1){
                if((endnum=(inarr[i]).indexOf("|",beginnum+3))>-1){
                    inarr[i]=(inarr[i]).substring(beginnum+3,endnum);
                }// end if stop ok
            }// end if gi
            if((beginnum=(inarr[i]).indexOf("gt|"))>-1){
                if((endnum=(inarr[i]).indexOf("|",beginnum+3))>-1){
                    inarr[i]=("t"+((inarr[i]).substring(beginnum+3,endnum)));
                }// end if stop ok
            }// end if gi
            //System.out.println(" to "+inarr[i]);
        }// end for i
        return inarr;
    }//end rename
    //---------------------------------------------------------------------------------------------------------
    
    aaseq[] rename(aaseq[] inarr){
        int noelem=java.lang.reflect.Array.getLength(inarr);
        int beginnum=0;
        int endnum=0;
        for(int i=0;i<noelem;i++){
            String currname=inarr[i].getname();
            //System.out.print("renaming "+currname);
            if((beginnum=(inarr[i].getname()).indexOf("gi|"))>-1){
                if((endnum=(inarr[i].getname()).indexOf("|",beginnum+3))>-1){
                    inarr[i].setname((inarr[i].getname()).substring(beginnum+3,endnum));
                }// end if stop ok
            }// end if gi
            if((beginnum=(inarr[i].getname()).indexOf("gt|"))>-1){
                if((endnum=(inarr[i].getname()).indexOf("|",beginnum+3))>-1){
                    inarr[i].setname("t"+((inarr[i].getname()).substring(beginnum+3,endnum)));
                }// end if stop ok
            }// end if gi
            //System.out.println(" to "+inarr[i].getname());
        }// end for i
        return inarr;
    }//end rename
     */
    //---------------------------------------------------------------------------------------------------------
    
    String removefirstchar(String instr, char inchar){
        int strl=instr.length();
        int rmpos=-1;
        for(int i=0;i<strl;i++){
            if(Character.toUpperCase(instr.charAt(i))==Character.toUpperCase(inchar)){
                rmpos=i;
                break;
            }
        }// end for i
        if(rmpos==0){
            return "-"+instr.substring(1);
        }
        //if(rmpos==instr.length()-1){//I don't need this here
        //    return instr.substring(0,(instr.length()-1));
        //}
        if(rmpos>0){
            instr=instr.substring(0,rmpos)+"-"+instr.substring(rmpos+1);
        }
        return instr;
    }// end removefirstchar
    
    //-------------------------------------------------------------------------------------------------------
    
    String[] removeallallgaps(String[] inarr){
        int noseqs=java.lang.reflect.Array.getLength(inarr);
        StringBuffer[] tmparr=new StringBuffer[noseqs];
        for(int i=0;i<(noseqs-2);i+=3){
            tmparr[i+1]=new StringBuffer();
            tmparr[i+2]=new StringBuffer();
        }// end for i
        //init done;
        int seqlength=inarr[1].length();//all sequences should have the same length!
        //int countgap=0;
        for(int i=0;i<seqlength;i++){
            boolean allgaps=false;
            //if(inarr[1].charAt(i)=='-'){
                //System.out.print("ingap1 "+countgap+ "'-");
                //countgap+=1;
                allgaps=true;
                for(int j=0;j<(noseqs-2);j+=3){
                    //System.out.print("'"+inarr[j+2].charAt(i));
                    if((i<inarr[j+2].length())&&(inarr[j+2].charAt(i)!='-')){
                        allgaps=false;
                    }
                }// end for j
                //System.out.println();
            //}//end if inarr[1].charAt(i)!=-
            if(allgaps==false){
                for(int j=0;j<(noseqs-2);j+=3){
                    tmparr[j+1].append(inarr[1].charAt(i));//all hmmqueries are the same
                    tmparr[j+2].append(inarr[j+2].charAt(i));
                }
                continue;
            }//else{
             //   countgap+=1;
            //}
            //System.out.println("removed allgap at "+i);
        }// end for i
        for(int i=0;i<(noseqs-2);i+=3){
            inarr[i+1]=tmparr[i+1].toString();
            inarr[i+2]=tmparr[i+2].toString();
        }// end for i
        return inarr;
    }// end removeallallgaps
    
    //-------------------------------------------------------------------------------------------------------
    
    class gapobj{
        
        public void gapobj(){
            begin=0;
            end=0;
            length=0;
        }
        int begin;
        int end;
        int length;
        
    }
    
    
}//end class hmmclualign
