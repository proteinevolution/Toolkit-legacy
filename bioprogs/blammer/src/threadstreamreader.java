/*
 * threadstreamreader.java
 *
 * Created on February 20, 2002, 11:04 AM
 */
import java.io.*;

/**
 *
 * @author  tancred
 * @version 
 */
public class threadstreamreader extends Thread{

    BufferedReader inread;
    StringBuffer outread;
    /** Creates new threadstreamreader */
    public threadstreamreader(BufferedReader inbuf, StringBuffer outbuf) {
        this.inread=inbuf;
        this.outread=outbuf;
    }
    
    public void run(){
        //String currline;
        int readchar;
        try{
            //while((currline=inread.readLine())!=null){
            synchronized(outread){//synchr to be sure that all data is written to before trying to read from
                while((readchar=inread.read())!=-1){
                    outread.append((char)readchar);
                }
            }// end synchronized
            inread.close();
       }catch (Exception e){
            System.err.println("read error");
            e.printStackTrace();
        }// end catch
    }// end run

}// end threadstreamreader
