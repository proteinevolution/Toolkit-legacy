/*
 * hmmcheck.java
 *
 * Created on May 16, 2002, 2:24 PM
 */
import java.util.*;
/**
 *
 * @author  tancred
 * @version 
 */
public class hmmcheck {

    /** Creates new hmmcheck */
    public hmmcheck() {
    }

    static String[] docompcheck(String[] inarr, float maxsim, int maxseqs, int verbose, boolean getdissim,float simstep){
        
        /* what I want this to do is filter out all those sequences that are more than maxsim similar,
         *look if maxseqs is -1, and if not, output maximally maxseqs sequences. the getdissim flag tells me wether these
         *should be the maxsim most dissimilar or similar sequences.
         */
        Random rand=new Random(java.lang.System.currentTimeMillis());
        int arrlength=(int)(java.lang.reflect.Array.getLength(inarr)/3);//should be a multiple of 3
        int numberofsteps=(int)((maxsim/simstep)+2);//I want to check in 10% steps; the less I have to do the better
        if(verbose>2){
            System.out.println("number of steps="+numberofsteps+" maxsim="+maxsim+" simstep="+simstep);
        }
        int[][] simval=new int[arrlength][numberofsteps];
        int[] checkvals=new int[numberofsteps];//holds the similarity values to check aginst.
        int[] seqnums=new int[numberofsteps];//how many sequences does each subset contain
        //init simvals to 1
        for(int i=0;i<arrlength;i++){
            for(int j=0;j<numberofsteps;j++){
                simval[i][j]=1;
            }
        }
        for(int i=0;i<numberofsteps;i++){
            checkvals[i]=(int)((100*(maxsim-(simstep*i)))+0.5);//in percent, hight to low
        }//last checkvals should be either 0 or negative.
        int tmpsim;
        for(int i=0;i<arrlength;i++){
            tmpsim=-1;
            for(int j=0;j<i;j++){
                tmpsim=(int)(getsim(inarr[(i*3)+2],inarr[(j*3)+2])*100);//in percent; rounded downwards
                for(int k=0;k<numberofsteps;k++){
                    if(simval[i][k]==1){//if the element i am comparing against exists in this k
                        if(tmpsim>checkvals[k]){//if similarity is greater than permitted to element prior in the list
                            simval[i][k]=0;//remove it from further analysis for this k
                        }
                    }// end if simval ==1
                }// end for k
            }// end for j
        }// end for i
        //now i should have an array (simval) with information about which sequences would be present in which
        //dataset of permitted maximum similarity. next aim is to see how many sequences I want and to then
        //select accordingly (watch out for getdissim)
        int counter;
        for(int i=0;i<numberofsteps;i++){
            counter=0;
            for(int j=0;j<arrlength;j++){
                if(simval[j][i]>0){
                    counter+=1;
                }
            }// end for j
            seqnums[i]=counter;
        }// end for i
        
        if(verbose>2){
            for(int i=0;i<numberofsteps;i++){
                System.out.println("%ident="+checkvals[i]+" # of seqs="+seqnums[i]);
            }
        }
        //now I know which level of permitted similarity has how many seqs (seqnums)
        //the output I want is a maximum number of sequences. If getdissim is true,
        //select the most dissimilar sequences to return, if false, the most similar.
        //fill up the leftover space with randomly selected sequences.
        int levelselect=numberofsteps;
        if(maxseqs!=-1){//if I want an upper seqnum cutoff
            for(int i=0;i<numberofsteps;i++){
                if(seqnums[i]<=maxseqs){
                    levelselect=i;
                }
            }//end for i
        }//end if maxseqs !=-1
        //now I know at which level I can find the most diverse sequences without going over maxseqs
        Vector retvec=new Vector();//will hold the sequences I return
        if(getdissim){
            for(int i=0;i<arrlength;i++){
                if(simval[i][levelselect]==1){
                    retvec.addElement(inarr[i*3]);
                    retvec.addElement(inarr[(i*3)+1]);
                    retvec.addElement(inarr[(i*3)+2]);
                }
            }// end for i
            if((retvec.size()<maxseqs)&&(levelselect<numberofsteps)){//if I have less sequences than I wanted, and am not using all i have
                Vector tmpvec=new Vector();
                for(int i=0;i<arrlength;i++){
                    if((simval[i][0]==1)&&(simval[i][levelselect]!=1)){//get all sequences below maxhmmsim that I do no yet have in retarr
                        tmpvec.addElement(inarr[i*3]);
                        tmpvec.addElement(inarr[(i*3)+1]);
                        tmpvec.addElement(inarr[(i*3)+2]);
                    }
                }// end for i
                int currpos;
                while(((retvec.size()/3)<maxseqs)&&(tmpvec.size()>2)){
                    currpos=rand.nextInt(tmpvec.size()/3);
                    retvec.addElement(tmpvec.elementAt(currpos*3));
                    retvec.addElement(tmpvec.elementAt((currpos*3)+1));
                    retvec.addElement(tmpvec.elementAt((currpos*3)+2));
                    tmpvec.removeElementAt((currpos*3)+2);
                    tmpvec.removeElementAt((currpos*3)+1);
                    tmpvec.removeElementAt(currpos*3);
                }// end while
            }// end if retvec.size< maxseqs
            
        }else{//end if getdissim and start if getmostsimilar sequences
            
            for(int i=0;i<arrlength;i++){
                if(simval[i][0]==1){//get all sequences below maxhmmsim 
                    retvec.addElement(inarr[i*3]);
                    retvec.addElement(inarr[(i*3)+1]);
                    retvec.addElement(inarr[(i*3)+2]);
                }
            }// end for i
            //and now get rid of the most dissimilar ones
            if(retvec.size()/3>maxseqs){
                boolean rmseqs=true;
                int poscount;
                //look at the most dissimilar sequences and remove them from retvec
                for(int i=numberofsteps-1;i>0;i--){
                    poscount=1;
                    for(int j=1;j<arrlength;j++){//always keep the first seq
                        if(simval[j][0]==1){//if I have this seq in the array
                            if(simval[j][i]==1){//if seq is also in the most dissimilar list
                                if(retvec.size()/3>maxseqs){
                                    retvec.removeElementAt((poscount*3)+2);
                                    retvec.removeElementAt((poscount*3)+1);
                                    retvec.removeElementAt(poscount*3);
                                    poscount-=1;
                                    simval[j][0]=0;//remember that this element is gone
                                }else{//if retvec is the right size or smaller
                                    inarr=new String[retvec.size()];
                                    retvec.copyInto(inarr);
                                    return inarr;
                                }//end else retvec.size too big
                            }// end if simval[j][i]
                            poscount+=1;
                        }
                    }// end for j
                }// end for i
            }// end if retvec.size > maxseqs
            //if this is still not enough, remove sequences at random
            int currpos;
            while((retvec.size()/3)>maxseqs){
                currpos=rand.nextInt(retvec.size()/3);
                retvec.removeElementAt(((currpos*3)+2));
                retvec.removeElementAt(((currpos*3)+1));
                retvec.removeElementAt((currpos*3));
            }// end while
        }// end if getdissim==false*/
        
        inarr=new String[retvec.size()];
        retvec.copyInto(inarr);
        return inarr;
    }//end docompcheck
    
    //--------------------------------------------------------------------------
    //------------------below is simpler version---------------------------------
    
    static String[] docheck(String[] inarr, float maxsim, int verbose){
        //this should check through all sequences and remove those with similarity greater than maxsim
        //when it removes a sequence it should keep the longer one of the two
        //first compute the similarities for all pairwise comparisons
        int seqnum=java.lang.reflect.Array.getLength(inarr)/3;
        float[][] simarr=new float[seqnum][seqnum];
        for(int i=0;i<seqnum;i++){
            simarr[i][i]=1;
            for(int j=i+1;j<seqnum;j++){
                simarr[i][j]=getsim(inarr[(i*3)+2],inarr[(j*3)+2]);
                simarr[j][i]=simarr[i][j];
                //if(i==0){
                //    System.out.println(simarr[i][j]);
                //}
            }// end for j
        }// end for i
        //now I have all pairwise similarities in an array.
        //now start adding sequences and check before adding if they are more similar than permitted to the ones already 
        //in the output vector
        int [] addedarr=new int[seqnum];//hold which sequences I have added
        addedarr[0]=-1;//contains -1 if the sequence was added, else the number of the sequence that kicked it out
        for(int i=1;i<seqnum;i++){
            //loop through the sequences already added and check the similarity
            addedarr[i]=-1;
            for(int j=0;j<i;j++){
                if(addedarr[j]==-1){
                    if(simarr[i][j]>maxsim){
                        if(inarr[(i*3)+2].length()>inarr[(j*3)+2].length()){//if the new sequence is longer than what existed before
                            addedarr[j]=i;
                            //theoreticall I should now take a look at what sequences were removed by the sequence I just removed and re-check those
                        }else{
                            addedarr[i]=0;
                        }
                    }
                }
            }// end for j
        }// end for i
        int counter=0;
        for(int i=0;i<seqnum;i++){
            if(addedarr[i]==-1){
                counter++;
            }
        }
        String[] retarr=new String[(counter*3)];
        counter=0;
        for(int i=0;i<seqnum;i++){
            if(addedarr[i]==-1){
                retarr[counter*3]=inarr[i*3];
                retarr[(counter*3)+1]=inarr[(i*3)+2];
                retarr[(counter*3)+2]=inarr[(i*3)+2];
                counter++;
            }
        }
        return retarr;
    }// end docheck
    
    //--------------------------------------------------------------------------
    
    static float getsim(String in1,String in2){
        int looplength=in1.length();
        int in2l=in2.length();
        if(in2l<looplength){
            looplength=in2l;
        }
        int ident=0;
        int comparelength=0;
        char c1;
        char c2;
        for(int i=0;i<looplength;i++){
            c1=in1.charAt(i);
            c2=in2.charAt(i);
            if(((c1=='.')||(c1=='-')||(c1=='_'))&&((c2=='.')||(c2=='-')||(c2=='_'))){
                //if both chars are gap characters
                continue;// next for
            }else {
                if(c1==c2){
                    ident+=1;
                }
                comparelength+=1;
            }// end else
        }// end for i
        return ((float)(((float)ident)/(float) comparelength));
    }// end getsim
    
    //--------------------------------------------------------------------------
        
}//end hmmcheck
