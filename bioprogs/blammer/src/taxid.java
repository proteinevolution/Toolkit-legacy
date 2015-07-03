/*
 * taxid.java
 *
 * Created on November 8, 2002, 6:27 PM
 */
import java.io.*;
import java.util.*;
/**
 *
 * @author  tancred
 */
public class taxid {
    
    /** Creates a new instance of taxid */
    public taxid() {
    }
    //this object will hold an array containing the ncbi gi# and their corresponding
    //taxonomic numbers.
    //the input file is of the format: gi#      taxid
    
    HashMap taxhash=new HashMap();
    //now the methods to get the right taxid for a given gi number
    
    int gettaxid(String ginum){
        try{
            int giint=Integer.parseInt(ginum);
            return gettaxid(giint);
        }catch (NumberFormatException e){
            System.err.println("Error: unable to parse int from "+ginum);
        }
        return -1;
    }//end gettaxid
    
    int gettaxid(int ginum){
        //use a binary search to get to the right ginumber and return its associated taxid
        Integer searchint=new Integer(ginum);
        if(taxhash.containsKey(searchint)){
            return ((Integer)taxhash.get(searchint)).intValue();
        }else{
            return -1;
        }
    }// end gettaxid
    
    //--------------------------------------------------------------------------
    //------------------read the taxid file and store it -----------------------
    
    boolean readfile(File infile,int verbose){
        return readfile(infile.getAbsolutePath(),verbose);
    }//end readfile
    
    boolean readfile(String filename,int verbose){
        //this should read the inputfile and save the data in it to the gitax array.
        taxhash=new HashMap();
        int currnum=0;
        try{
            BufferedReader inread=new BufferedReader(new FileReader(filename));
            String instring;
            String[] tmparr;
            Integer tmpgi;
            Integer tmptax;
            if(verbose>0){
                while ((instring=inread.readLine())!=null){
                    currnum++;
                    instring=instring.trim();
                    tmparr=instring.split("\\s+",0);//split on one or more whitespaces
                    //now I should have two elements in this array, the gi number and the taxid
                    if(java.lang.reflect.Array.getLength(tmparr)!=2){
                        System.err.println("Error reading from "+filename+" "+java.lang.reflect.Array.getLength(tmparr)+" elements.");
                    }else{
                        try{
                            tmpgi=Integer.valueOf(tmparr[0]);
                            tmptax=Integer.valueOf(tmparr[1]);
                        }catch (NumberFormatException e){
                            System.err.println("unable to parse number from "+tmparr[0]+" "+tmparr[1]);
                            return false;
                        }
                        taxhash.put(tmpgi,tmptax);
                    }
                    if(currnum==100000){
                        System.out.print(".");
                        currnum=0;
                    }
                }
            }else{
                while ((instring=inread.readLine())!=null){
                    instring=instring.trim();
                    tmparr=instring.split("\\s+",0);//split on one or more whitespaces
                    //now I should have two elements in this array, the gi number and the taxid
                    if(java.lang.reflect.Array.getLength(tmparr)!=2){
                        System.err.println("Error reading from "+filename+" "+java.lang.reflect.Array.getLength(tmparr)+" elements.");
                    }else{
                        try{
                            tmpgi=Integer.valueOf(tmparr[0]);
                            tmptax=Integer.valueOf(tmparr[1]);
                        }catch (NumberFormatException e){
                            System.err.println("unable to parse number from "+tmparr[0]+" "+tmparr[1]);
                            return false;
                        }
                        taxhash.put(tmpgi,tmptax);
                    }
                }
            }
        }catch (IOException e){
            System.err.println("IOError in reading from "+filename);
            e.printStackTrace();
            return false;
        }
        return true;
    }// end readfile
}
