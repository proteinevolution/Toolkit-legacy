/*
 * taxonomy.java
 *
 * Created on November 28, 2001, 1:29 PM
 */
import java.util.HashMap;
import java.util.Vector;
/**
 *
 * @author  noname
 * @version
 */
public class taxonomy {
    
    /** Creates new taxonomy */
    public taxonomy() {
    }
    HashMap namestoids=new HashMap();//220000,(float)0.85);
    HashMap idstonames=new HashMap();//220000,(float)0.85);
    HashMap idstoparents=new HashMap();//220000,(float)0.85);
    HashMap idstorank=new HashMap();
    
    String getnameforid(int id){
        String idstring=String.valueOf(id);
        if(idstonames.containsKey(idstring)){
            return (String)idstonames.get(idstring);
        }else{
            return "unknown taxonomy";
        }
    }// end getnameforid
    
    String[] getallnames(String inname){
        Vector tmpvec=new Vector();
        if((namestoids.containsKey(inname))!=true){
            System.err.println("-ERROR- no key found for: "+inname);
            tmpvec.addElement(inname);
        }
        if(namestoids.containsKey(inname)){
            String id=(String)namestoids.get(inname);
            while ((id.equals("1"))==false){
                // check to see that this is really a new element (trouble with leishmania, adds up to 8000 names)
                String thisname=(String)idstonames.get(id);
                boolean hassame=false;
                for(int i=0;i<tmpvec.size();i++){
                    if(((String)tmpvec.elementAt(i)).equalsIgnoreCase(thisname)){
                        hassame=true;
                    }
                }
                if(hassame==false){
                    tmpvec.addElement(thisname);
                }
                id=(String)idstoparents.get(id);
            }// end while
        }// end if namestoids
        String[] retarr=new String[tmpvec.size()];
        tmpvec.copyInto(retarr);
        return retarr;
    }// end getallnames
    
    String[] getallranks(String inname, boolean verbose){
        Vector tmpvec=new Vector();
        if((namestoids.containsKey(inname))!=true){
            if(verbose){
                System.out.println("no key found");
            }
            tmpvec.addElement(inname);
        }
        if(namestoids.containsKey(inname)){
            String id=(String)namestoids.get(inname);
            while ((id.equals("1"))==false){
                tmpvec.addElement(idstorank.get(id));
                id=(String)idstoparents.get(id);
            }// end while
        }// end if namestoids
        String[] retarr=new String[tmpvec.size()];
        tmpvec.copyInto(retarr);
        return retarr;
    }// end getallranks
    
    String[][] getallinfo(String inname, boolean verbose){
        Vector tmpvec=new Vector();
        if((namestoids.containsKey(inname))!=true){
            if(verbose){
                System.out.println("no key found");
            }
            tmpvec.addElement(inname);
            tmpvec.addElement("no rank found");
        }
        if(namestoids.containsKey(inname)){
            String id=(String)namestoids.get(inname);
            while ((id.equals("1"))==false){
                tmpvec.addElement(idstonames.get(id));
                tmpvec.addElement(idstorank.get(id));
                id=(String)idstoparents.get(id);
            }// end while
            // and now add for id=1
            tmpvec.addElement(idstonames.get(id));
            tmpvec.addElement(idstorank.get(id));
        }// end if namestoids
        String[][] retarr=new String[(int)(tmpvec.size()/2)][2];
        for (int i=0;i<tmpvec.size();i+=2){
            retarr[(int)(i/2)][0]=(String)tmpvec.elementAt(i);
            retarr[(int)(i/2)][1]=(String)tmpvec.elementAt(i+1);
        }// end for i
        return retarr;
    }// end getallinfo*/
    
}// end taxonomy
