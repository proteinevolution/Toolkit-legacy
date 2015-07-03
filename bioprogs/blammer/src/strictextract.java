/*
 * strictextract.java
 *
 * Created on May 28, 2002, 10:16 AM
 */
import java.io.*;
/**
 *
 * @author  tancred
 * @version 
 */
public class strictextract {

    /** Creates new strictextract */
    public strictextract() {
    }

    static boolean reextract(String[] namesseqs, String extfname, String strictextfname){
        //String[] checknames=new String[java.lang.reflect.Array.getLength(namesseqs)/3];
        java.util.HashMap checknames=new java.util.HashMap();
        int checknum=java.lang.reflect.Array.getLength(namesseqs)/3;
        String[] namearr=new String[checknum];
        int underscorepos;
        int pipepos;
        String checknamestr;
        for(int i=0;i<checknum;i++){
            checknamestr=namesseqs[i*3];
            pipepos=checknamestr.indexOf("|");
            underscorepos=checknamestr.indexOf("_");
            if((underscorepos>0)&&((pipepos<0)||(pipepos>underscorepos))){//if I have a _ before a pipe or alone
                checknamestr=checknamestr.substring(underscorepos+1);// get rid of everything before
            }
            checknames.put(checknamestr,new Integer(0));
            namearr[i]=checknamestr;
        }//end for i
        //now I have unique parts of the seqnames and need to get rid of all others in the 
        //extfname file.
        File extfile=new File(extfname);
        if(extfile.exists()==false){//if the extractfile isn't there
            System.err.println("ERROR: unable to find "+extfname+" to read from");
            return false;
        }else{//if the extractfile is there, read from it and get all sequences in namesseqs
            try{
                if(new File(strictextfname).exists()){//in this case I need to remove this file 
                    new File(strictextfname).delete();
                }
                BufferedReader extread=new BufferedReader(new FileReader(extfile));
                PrintWriter strictout=new PrintWriter(new BufferedWriter(new FileWriter(strictextfname)));
                boolean putseq=false;
                String inline;
                while ((inline=extread.readLine())!=null){//while i can read from this file
                    if(inline.startsWith(">")){
                        putseq=checkname(inline,checknames);
                    }
                    if(putseq){
                        strictout.println(inline);
                    }
                }// end while readline
                strictout.close();
                extread.close();
            }catch(IOException e){
                System.err.println("IOError in strictextract for "+extfname);
                e.printStackTrace();
                return false;
            }
            //now output the names not found
            System.out.println("names not found (in strictextract):");
            for(int i=0;i<checknum;i++){
                if(((Integer)checknames.get(namearr[i])).intValue()<1){
                    System.err.println("-----name not found:'"+namearr[i]+"'");
                }
            }//end for i
        }// end else
        return true;
    }// end reextract
    
    //--------------------------------------------------------------------------
    
    static boolean checkname(String inline, java.util.HashMap checknames){
        //checknames are the names I am looking for. see if inline contains any of the checknames
        if(inline.startsWith(">")){
            inline=inline.substring(1).trim();
        }
        String[] tmparr=inline.split("\u0001");//split on the ncbi gi spacer
        //now check each of the array elements
        String testline;
        int j;
        //int namesnum=java.lang.reflect.Array.getLength(checknames.keySet().toArray());
        for(int i=0;i<java.lang.reflect.Array.getLength(tmparr);i++){
            testline=tmparr[i].trim();
            testline=testline.substring(0,testline.indexOf(" "));
            //now see if this name exists in checknames
            //for(j=0;j<namesnum;j++){
                if(checknames.containsKey(testline)){// if this name is wanted
                    if(((Integer)checknames.get(testline)).intValue()>0){
                        //System.out.println("Name already found for "+testline);
                        return true;
                    }else{
                        checknames.put(testline,new Integer(1));
                        return true;
                    }
                }
            //}
        }// end for i
        return false;
    }// end checkname
    
}//end strictextract
