// ATVapp.java
// Copyright (C) 1999-2000 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved



import forester.tree.*;
import forester.atv.*;

import java.io.*;


/**

@author Christian Zmasek

@version 1.00 -- last modified: 07/18/00

*/
public class ATVapp {

    public static void main( String args[] ) {

       Tree tree = null;   

       try {
           if ( args.length == 1 ) {
               File f = new File( args[ 0 ] );
               tree = TreeHelper.readNHtree( f );
           }
       }
       catch ( Exception e ) {
           System.out.println( "Could not start ATVpp: " + e );
           System.exit( -1 );
       }
       
       ATVjframe atvframe = new ATVjframe( tree );
       atvframe.showWhole();
    }
}
