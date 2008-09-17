// printSameOrder
//
// Copyright (C) 2000-2001 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved
//
// Created: 2000
// Author: Christian M. Zmasek
// zmasek@genetics.wustl.edu
// http://www.genetics.wustl.edu/eddy/people/zmasek/



// Requires forester packages.


import forester.tree.*;

import java.io.*;

public class printSameOrder {
    
    public static void main( String args[] ) {
	
        Tree        tree    = null;
        Node        node    = null;
        PrintWriter out     = null;
        File        infile  = null, 
		            outfile = null;

		  
        if ( args.length != 2 ) {
            System.err.println( "\nprintSameOrder: Wrong number of arguments." ); 
            System.err.println( "Usage: \"java printSameOrder <infile> <outfile>\"\n" ); 
            System.exit( -1 );
        }	  
		  
        infile  = new File( args[ 0 ] );
		outfile = new File( args[ 1 ] );
    	
    	
        try {
	        tree = TreeHelper.readNHtree( infile );
        }
        catch ( Exception e ) {
            System.err.println( e + "\nCould not read " + infile + "\n" );
            System.exit( -1 );
        }

        node = tree.getExtNode0();

        try {

            out = new PrintWriter( new FileWriter( outfile ), true );

            while ( node != null ) {
                out.println( node.getSeqName() );            
                node = node.getNextExtNode();
            }

        }
        catch ( Exception e ) {
            System.err.println( e + "\nException during writing.\n" );
            System.exit( -1 );
        }
        finally {
            out.close();
        }
    }	    
           
}


