/*
 * clualign.java
 *
 * Created on February 5, 2002, 9:43 AM
 */
import java.lang.*;
import java.util.*;
import java.io.*;
/**
 *
 * @author  noname
 * @version 
 */
public class clualign_old {

    /** Creates new clualign */
    public clualign_old() {
    }

    public String[] align(String command,String[] inarr,int borderwidth,boolean verbose,int verbosenum,int cpunum) {
        // inarr has name,queryseq,hitseq
        //System.out.println("--------------------INSEQS---------------------");
        //for(int i=0;i<java.lang.reflect.Array.getLength(inarr);i++){
        //    System.out.println(inarr[i]);
        //}// end for i
        //try{
        //    String tmptest=(new BufferedReader(new InputStreamReader(System.in))).readLine();
        //}catch (IOException e){}
        if(verbose){
            if(verbosenum>1){
                System.out.println("clualign: command="+command+" cluwidth="+borderwidth);
            }
        }
        String cpustr=String.valueOf(cpunum);
        File alnfile=new File("tmpfile"+cpustr+".aln");
        File tmpfile=new File("tmpfile"+cpustr+".txt");
        File dndfile=new File("tmpfile"+cpustr+".dnd");
        //make all sequences the same length
        int[][] blockinfo=getblockinfo(inarr,borderwidth);//find the blocks flanked by ungapped hits of borderwidth width
        //for(int i=0;i<java.lang.reflect.Array.getLength(blockinfo);i++){
        //    System.out.println(i+"block "+blockinfo[i][0]+","+blockinfo[i][1]);
        //}// end for i
        //split the seqs into blocks to be aligned and  ones, keep names
        int numberofseq=(java.lang.reflect.Array.getLength(inarr)/3);
        int numberofblocks=java.lang.reflect.Array.getLength(blockinfo);
        String[] seqnames=new String[numberofseq];
        String[][] seqaln=new String[numberofseq][numberofblocks];//holds the sequence parts to be aligned by clustal
        String[][] seqnoaln=new String[numberofseq][numberofblocks+1];//holds the  sequence parts (+1 if the end needs no alignment--> one element more)
        int [][] didaddpos=new int[numberofseq][numberofblocks];//remember at which sequence part I added a character
        for(int i=0;i<numberofseq;i++){
            int lastpos=0;
            seqnames[i]=inarr[i*3];
            //System.out.println(seqnames[i]);
            boolean tolastpos=false;
            int currseqlength=inarr[(i*3)+2].length();
            for(int j=0;j<numberofblocks;j++){
                boolean didtolast=false;
                // need to check if blockinfo[1]==-1,or the next block longer than this seq in which case I read to end of line
                if((blockinfo[j][1]==-1)&&(blockinfo[j][1]<currseqlength)){
                    tolastpos=true;
                    seqnoaln[i][j]=inarr[(i*3)+2].substring(lastpos,blockinfo[j][0]);
                    seqaln[i][j]=inarr[(i*3)+2].substring(blockinfo[j][0]);
                }// end if -1
                if((blockinfo[j][1]>currseqlength)){
                    didtolast=true;
                    //System.out.println("subst "+lastpos+","+blockinfo[j][0]);
                    //System.out.println("strl="+inarr[(i*3)+2].length());
                    seqnoaln[i][j]=inarr[(i*3)+2].substring(lastpos,blockinfo[j][0]);
                    seqaln[i][j]=inarr[(i*3)+2].substring(blockinfo[j][0]);    
                }
                if((blockinfo[j][1]>-1)&&(didtolast==false)){
                    seqnoaln[i][j]=inarr[(i*3)+2].substring(lastpos,blockinfo[j][0]);
                    seqaln[i][j]=inarr[(i*3)+2].substring(blockinfo[j][0],blockinfo[j][1]);
                }
                //remove all "-" from the sequences to be aligned
                String[] tmparr=seqaln[i][j].split("-+",0);//split the seqs at - chars
                seqaln[i][j]="";
                for(int k=0;k<java.lang.reflect.Array.getLength(tmparr);k++){//recombine the pieces
                    seqaln[i][j]+=tmparr[k];
                }// end for k
                //if this seq only has one letter, problems with clustal--> give it one more, works fine but is inelegant
                //if I added a char, set didaddpos=1 or -1 (i.e remove first or last char); later on chack for didaddpos and remove first letter.
                if(seqaln[i][j].length()==1){
                    if(seqnoaln[i][j].length()>0){
                        char addc;
                        if((addc=(seqnoaln[i][j].charAt(seqnoaln[i][j].length()-1)))!='-'){
                            seqaln[i][j]=addc+seqaln[i][j];
                            didaddpos[i][j]=1;
                        }
                        if((addc=(seqnoaln[i][j].charAt(seqnoaln[i][j].length()-1)))=='-'){
                            //check to see if there is a next element
                            if(j<numberofblocks-1){
                                if((addc=(seqnoaln[i][j].charAt(seqnoaln[i][j].length()-1)))!='-'){
                                    seqaln[i][j]=addc+seqaln[i][j];
                                    didaddpos[i][j]=-1;
                                }// end if addchar!=-
                                if(addc=='-'){//if before and after no seq, remove single char
                                    seqaln[i][j]="";
                                    didaddpos[i][j]=0;
                                }// end if addchar==-
                            }// end if j<numberofblocks-1
                        }// end if addchar==-
                    }//end if seqnoaln.length>0
                    // add another part here where the case that seqnoaln[i][j]==0
                }// end if length==1
                lastpos=blockinfo[j][1];
            }// end for j
            if(numberofblocks==0){
                //align everything
                System.out.println("0 blocks to align; probably an error");
            }
            if(tolastpos){//if the last seqaln went to the end 
                seqnoaln[i][numberofblocks]="";
            }
            if(tolastpos==false){
                if(verbose){
                    if(verbosenum>1){
                        System.out.println("aligning the leftovers from "+lastpos+" to "+inarr[(i*3)+2].length());
                    }
                }
                if(lastpos<inarr[(i*3)+2].length()){
                seqnoaln[i][numberofblocks]=inarr[(i*3)+2].substring(lastpos);//to end of string
                }
                if(lastpos>=inarr[(i*3)+2].length()){
                seqnoaln[i][numberofblocks]="";
                }
            }
        }// end for i numberofseq
        //now I have seqaln to align
        try{//do some IO; write data to file, run clustal on file, read clustal outfile
            if(verbose){
                if(verbosenum>1){
                System.out.println(numberofblocks+" blocks");
                }
            }
            for(int i=0;i<numberofblocks;i++){
                if(verbose){
                    System.out.print(".");
                    if(verbosenum>1){
                    System.out.println("doing block "+i);
                    }
                }
                //write data to file
                PrintWriter outfile=new PrintWriter(new BufferedWriter(new FileWriter(tmpfile)));
                int elemwrite=0;
                for(int j=0;j<numberofseq;j++){
                    //System.out.println(seqaln[j][i]);
                    //System.out.println(java.lang.reflect.Array.getLength(seqaln[j][i].split("-+")));
                    //was if(java.lang.reflect.Array.getLength(seqaln[j][i].split("-+"))>0){
                    //if(seqaln[j][i].equals("")==false){
                        elemwrite+=1;
                        outfile.println(">"+seqnames[j]);
                        outfile.println(seqaln[j][i]);
                    //}// end if
                }
                outfile.close();
                //System.out.print(",");
                if(elemwrite<2){
                    //System.out.println("only "+elemwrite+" elements output to "+tmpfile.getName());
                    continue;
                }
                //run clustal on file
                if(verbose){
                    if(verbosenum>1){
                    System.out.println("running "+command+" -INFILE="+tmpfile.getAbsolutePath());
                    }
                }
                StringBuffer errout=new StringBuffer();
                StringBuffer inout=new StringBuffer();
                threadstreamreader errread;
                threadstreamreader inread;
                //System.out.print("<");
                Process p=Runtime.getRuntime().exec(command+" -INFILE="+tmpfile.getAbsolutePath());
                errread=new threadstreamreader(new BufferedReader(new InputStreamReader(p.getErrorStream())),errout);
                inread=new threadstreamreader(new BufferedReader(new InputStreamReader(p.getInputStream())),inout);
                //output should be in tmpfile.aln&dnd
                try{// wait for clustal to finish
                    errread.start();
                    inread.start();
                    p.waitFor();
                }catch (InterruptedException e){
                    System.err.println("Interrupted Clustalw run");
                }
                //String currstr;
                System.err.print(errout.toString());
                //read clustal output
                //System.out.print(",");
                //String tmptest=(new BufferedReader(new InputStreamReader(System.in))).readLine();
                aaseq[] tmpseqarr=clustalread.clustalintread(alnfile);
                //System.out.print("-");
                //convert aaseq to String[]
                String[] tmparr=convertaaseq(tmpseqarr,seqnames);
                //System.out.print(">");
                //System.out.print("+");
                for(int j=0;j<numberofseq;j++){
                    seqaln[j][i]=tmparr[j];
                    if(didaddpos[j][i]==1){//if I added a position to the sequence to align it with clustal
                        //remove first letter or this seq
                        boolean didremove=false;
                        for(int k=0;((k<seqaln[j][i].length())&&(didremove==false));k++){
                            if(seqaln[j][i].charAt(k)!='-'){
                                seqaln[j][i]=seqaln[j][i].substring(0,k)+"-"+seqaln[j][i].substring(k+1);
                                didremove=true;
                            }
                        }// end for k
                    }// end for i didaddpos
                    if(didaddpos[j][i]==-1){//if I added a position to the sequence to align it with clustal
                        //remove first letter or this seq
                        boolean didremove=false;
                        for(int k=0;((k<seqaln[j][i].length())&&(didremove==false));k++){
                            if(seqaln[j][i].charAt(seqaln[j][i].length()-(k+1))!='-'){
                                seqaln[j][i]=seqaln[j][i].substring(0,(seqaln[j][i].length()-(k+1)))+"-"+seqaln[j][i].substring((seqaln[j][i].length()-(k+1))+1);
                                didremove=true;
                            }
                        }// end for k
                    }// end for i didaddpos
                }// end for j
                //System.out.print("-");
                //now the sequences should be ordered by seqnames order.
                // remove clustalw output & input
                tmpfile.delete();
                alnfile.delete();
                dndfile.delete();
            }// end for i aligning
            //System.out.println("no errors");
        }catch (IOException e){
            System.err.println("IOError in clualign");
            e.printStackTrace();
        }
        for(int i=0;i<numberofseq;i++){
            inarr[(i*3)]=seqnames[i];
            String newseq="";
            for(int j=0;j<numberofblocks;j++){
                newseq=newseq+seqnoaln[i][j]+seqaln[i][j];
            }// end for j combining
            newseq+=seqnoaln[i][numberofblocks];
            inarr[(i*3)+2]=newseq;
        }// end for i
        inarr=removeendgaps(inarr);
        inarr=makesamelength(inarr);
        //System.out.println(">");
        return inarr;
    }

    //----------------------------------------------------------------------------------------------------------
    
     String[] convertaaseq(aaseq[] inarr, String[] innames){
        int numberofseq=java.lang.reflect.Array.getLength(innames);
        int numberofaaseqs=java.lang.reflect.Array.getLength(inarr);
        if(numberofseq!=numberofaaseqs){
            System.err.println("ERROR clu="+numberofaaseqs+" org="+numberofseq);
        }
        String[] outarr=new String[numberofseq];
        //try{
        //    PrintWriter tmparrfile=new PrintWriter(new BufferedWriter(new FileWriter("tmparrfile.txt")));
                
        for(int i=0;i<numberofseq;i++){
            boolean foundseq=false;
            String[] nameparts=innames[i].split("\\s",0);//get the gi (gt) number in first pos
            for(int j=0;j<numberofaaseqs;j++){
                if(nameparts[0].equals(inarr[j].getname())){// if this is the same name
                    foundseq=true;
                    outarr[i]=new String(inarr[j].getseq());
                    //tmparrfile.println(innames[i]+" -> "+inarr[j].getname());
                    //tmparrfile.println(outarr[i]);
                }
            }// end for j
            if(foundseq==false){
                System.err.println("found no sequence matching "+innames[i]);
                // fill those sequences with gaps
                outarr[i]="";
                for(int j=0;j<(new String(inarr[j].getseq()).length());j++){
                    outarr[i]+="-";
                }
            }
        }// end for i
        
        //    tmparrfile.close();
        //}catch (IOException e){}
                
        return outarr;
    }// end convertseqarr
    
    //--------------------------------------------------------------------------------------------------------------
    
     int[][] getblockinfo(String[] inarr,int borderwidth){
        int beginb=0;
        boolean begin=false;
        Vector blockvec=new Vector();
        int maxseqlength=0;
        //get the maximum length of a sequence, check ALL,get where each seq begins (gaps before that you can skip)
        int numberofseq=(java.lang.reflect.Array.getLength(inarr)/3);
        int[] beginseq=new int[numberofseq];//where does the sequence begin
        int[] endgaps=new int[numberofseq];//how many gaps are at the end of the sequence
        for(int i=0;i<numberofseq;i++){
            if(maxseqlength<(inarr[(i*3)+2].length())){
                maxseqlength=inarr[(i*3)+2].length();
            }
            String[] tmparr=inarr[(i*3)+2].split("\\w+",-1);//to know how many gaps are at the beginning and end
            beginseq[i]=tmparr[0].length();
            endgaps[i]=tmparr[(java.lang.reflect.Array.getLength(tmparr))-1].length();
        }// end for i
        //remove position in the sequence where there are only gaps (theoretically possible)
        for(int pos=0;pos<maxseqlength;pos++){
            boolean allgaps=true;
            for(int i=0;((i<numberofseq)&&(allgaps));i++){
                if(pos<inarr[(i*3)+2].length()){
                    if(inarr[(i*3)+2].charAt(pos)!='-'){
                        allgaps=false;
                    }
                }
            }
            if(allgaps){
                for(int i=0;i<numberofseq;i++){//for each seq remove chat at pos
                    if(pos<inarr[(i*3)+2].length()){
                        String str1=inarr[(i*3)+2].substring(0,pos);
                        String str2=inarr[(i*3)+2].substring(pos+1);
                        inarr[(i*3)+2]=str1+str2;
                    }
                }
                pos-=1;
                maxseqlength-=1;
            }// end if allgaps
        }// end for i
        //loop through the sequence positions and see where the gapped blocks are and add to blockvec
        int colwidth=0;
        for(int pos=0;pos<maxseqlength;pos++){
            //loop through the sequences
            boolean nogap=true;
            for(int i=0;((i<numberofseq)&&(nogap));i++){
                if((pos>beginseq[i])&&(pos<(inarr[(i*3)+2].length())-endgaps[i])){
                    // if this sequence has started and is longer than pos
                    if(inarr[(i*3)+2].charAt(pos)=='-'){
                        nogap=false;
                    }
                }// end if seqlength>pos>beginseq
            }// end for i
            if(nogap){
                colwidth+=1;
                if((colwidth>=borderwidth)&&(begin==true)){
                    begin=false;
                    int[] tmparr=new int[2];
                    tmparr[0]=beginb;
                    tmparr[1]=(pos-(colwidth-1));
                    if(tmparr[1]-tmparr[0]>1){
                        blockvec.addElement(tmparr);
                    }
                }
                continue;
            }// end if nogap
            if(nogap==false){//actually no need to check for that because of continue above
                if((colwidth>=borderwidth)&&(begin==false)){//id this is the first gap after a conservec collumn
                    beginb=pos;
                    begin=true;
                }
                colwidth=0;
            }
        }// end for pos
        //if I didn't find an end to the last gapped partalign
        if(begin==true){
            int[] tmparr=new int[2];
            tmparr[0]=beginb;
            tmparr[1]=-1;//means read to end of string! check for that later! otherwise StringIndexOutOfBoundsException
            blockvec.addElement(tmparr);
        }
        //now I have a Vector with start and end of each gapped part of the alignment
        if(blockvec.size()==0){//if I have nothing to align
            //I want to align everything in the array
            int[] tmparr =new int[2];
            tmparr[0]=0;
            tmparr[1]=maxseqlength;
            blockvec.addElement(tmparr);
        }
        int[][] outarr=new int[blockvec.size()][2];
        blockvec.copyInto(outarr);
        return outarr;
    }// end getblockinfo
    
    //------------------------------------------------------------------------------------------------------------------
    
    String[] makesamelength(String[] inarr){
        int maxlength=-1;
        for(int i=0;i<(java.lang.reflect.Array.getLength(inarr)-2);i+=3){
            //if((inarr[i+1].length())>maxlength){
            //    maxlength=inarr[i+1].length();
            //}
            if((inarr[i+2].length())>maxlength){
                maxlength=inarr[i+2].length();
            }
        }// end for i
        //System.out.println("maxlength="+maxlength);
        for(int i=0;i<(java.lang.reflect.Array.getLength(inarr)-2);i+=3){
            //int ldiff=maxlength-inarr[i+1].length();
            //StringBuffer add=new StringBuffer();
            //while(ldiff>0){
            //    ldiff-=1;
            //    add.append("-");
            //}
            //inarr[i+1]+=add.toString();
            int ldiff=maxlength-inarr[i+2].length();
            StringBuffer add=new StringBuffer();
            while(ldiff>0){ 
                ldiff-=1;
                add.append("-");
            }
            inarr[i+2]+=add.toString();
        }// end for i
        return inarr;
    }// end makesamelength
    
    //-----------------------------------------------------------------------------------------------------------
    
    String[] removeendgaps(String[] inarr){
        int arrlength=java.lang.reflect.Array.getLength(inarr);
        for(int i=0;i<(arrlength-2);i+=3){
            int seqlength=inarr[i+1].length();
            int cutpos=0;
            for(int j=(seqlength-1);j>=0;j--){//loop through the sequence
                if(inarr[i+1].charAt(j)!='-'){
                    break;//stop loop on first non '-' char
                }
                cutpos+=1;
            }// end for j
            inarr[i+1]=inarr[i+1].substring(0,inarr[i+1].length()-cutpos);
            // and now the whole thing for i+2
            seqlength=inarr[i+2].length();
            cutpos=0;
            for(int j=(seqlength-1);j>=0;j--){//loop through the sequence
                if(inarr[i+2].charAt(j)!='-'){
                    break;//stop loop on first non '-' char
                }
                cutpos+=1;
            }// end for j
            inarr[i+2]=inarr[i+2].substring(0,inarr[i+2].length()-cutpos);
        }// end for i
        return inarr;
    }// end removeendgaps
    
}
