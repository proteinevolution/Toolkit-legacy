// ATVapp_awt.java
// Copyright (C) 1999-2000 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved



// AWT version.


import forester.tree.*;
import forester.atv_awt.*;

import java.io.*;



/**

@author Christian Zmasek

@version AWT 1.00 -- last modified: 07/18/00

*/
public class ATVapp_awt {

    public static void main( String args[] ) {

       Tree tree = null;   

       try {
	       if ( args.length == 1 ) {
	           File f = new File( args[ 0 ] );
	           tree = TreeHelper.readNHtree( f );
           }
       }
       catch ( Exception e ) {
	       e.printStackTrace();
	       System.err.println( "" + e );
	       System.exit( -1 );
       }
       
       ATVframe atvframe = new ATVframe( tree );
       //atvframe.setMaxOrtho( 30 );
       atvframe.showWhole();
    }
}
