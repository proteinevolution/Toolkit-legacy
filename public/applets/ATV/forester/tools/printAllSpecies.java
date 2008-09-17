// printAllSpecies
//
// Copyright (C) 2001 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved
//
// Created: 02/2601
// Author: Christian M. Zmasek
// zmasek@genetics.wustl.edu
// http://www.genetics.wustl.edu/eddy/people/zmasek/



// Requires forester packages.


import forester.tree.*;

import java.io.*;

public class printAllSpecies {
    
    public static void main( String args[] ) {
	
        Tree        tree    = null;
        Node        node    = null;
        PrintWriter out     = null;
        File        infile  = null, 
		            outfile = null;

		  
        if ( args.length != 2 ) {
            System.err.println( "\nprintAllSpecies: Wrong number of arguments." ); 
            System.err.println( "Usage: \"java printAllSpecies <infile> <outfile>\"\n" ); 
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

        TreeHelper.cleanSpeciesNamesInExtNodes( tree );
        node = tree.getExtNode0();

        try {

            out = new PrintWriter( new FileWriter( outfile ), true );

            while ( node != null ) {
                out.println( node.getSpecies() );            
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


