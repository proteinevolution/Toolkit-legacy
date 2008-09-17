// transfersBranchLenghts.java
// Copyright (C) 1999-2000 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved


package forester.tools;


import forester.tree.*;

import java.io.*;


/**

@author Christian M. Zmasek

@version 1.100 -- last modified: 07/03/01

*/
public class transfersBranchLenghts {


    /**

    Transfers branch length values from one Tree to another. It is mainly
    a "main method" for method "copyBranchLengthValuesFrom( Tree )" of
    forester.tree.Tree, to be used in other (Perl) programs.

    @param args[0] Filename (String) for Tree which has correct branch length values
    
    @param args[1] String Filename (String) for Tree to which the branch lengths of the first
                   Tree are to be copied, both Trees must only differ in
                   their branch length values, i.e. topology and sequence names,
                   etc. must be the same

    @param args[2] String Filename (String) for outputfile
    @param args[3] R to reroot both trees in the same manner

    @see forester.tree.Tree#copyBranchLengthValuesFrom( Tree )

    */
    public static void main( String args[] ) {
        
	    Tree tree1 = null, // Has correct branch lengths (:...).
	         tree2 = null; // Has bootsrap in the b.l. field (will be transferred
	                       // to the bootstrap field by the Tree constructor) or
                           // has regular boostraps (NHX, :B=...).  
    	
        File f1 = null,
             f2 = null,
	         f3 = null;

        boolean reroot = false;

    	
	    if ( args.length != 3 && args.length != 4 ) {
	        System.err.println( "transfersBranchLenghts: Wrong number"
	        + " of arguments. Usage: \"java transfersBranchLenghts"
	        + " <treefile with correct b.l.> <treefile with bootstraps>"
	        + "<outputfile> [R to reroot both trees in the same manner]\"" );
	        System.exit( -1 );
	    }
    	
        if ( args.length == 4 && args[ 3 ].equals( "R" ) ) {
             reroot = true;
        }

	    try {
    	    f1 = new File( args[ 0 ] );
	        f2 = new File( args[ 1 ] );
	        f3 = new File( args[ 2 ] );
    	    
	        if ( f3.exists() ) {
	            System.err.println( "transfersBranchLenghts: " + f3.getAbsolutePath() + " does already exist." );
	            System.exit( -1 );
	        }
    	    
	        tree1 = TreeHelper.readNHtree( f1 );
	        tree2 = TreeHelper.readNHtree( f2 );
                
	    }
	    catch ( Exception e ) {
	        System.err.println( "treeCombine: Could not read tree(s): " + e );
	        System.exit( -1 );
	    }
    	

        // Ensure that both trees are rooted in the same manner.
        // This is important if the branch length calculation is done by
        // PHILIP FITCH -- which changes the rooting of its input tree.
        if ( reroot ) {
            try {
                Node tree2extnode0 = tree2.getExtNode0();
                tree2.reRoot( tree2extnode0 );
                tree2.adjustNodeCount( false );
                tree2.recalculateAndReset();
                tree2.setExtNodes( tree2.getRoot().getSumExtNodes() );
                tree1.reRoot( tree1.getNode( tree2extnode0.getSeqName() ) );
                tree1.adjustNodeCount( false );
                tree1.recalculateAndReset();
                tree1.setExtNodes( tree1.getRoot().getSumExtNodes() );
            }
            catch ( Exception e ) {
	            System.err.println( "Exception during rerooting" + e );
	            System.exit( -1 );
	        }
        }    	

	    try {
	        tree2.copyBranchLengthValuesFrom( tree1 );
	    }
	    catch ( Exception e ) {
	        System.err.println( "Exception during copying of branch length values:" + e );
	        System.exit( -1 );
	    }
    	
	    try {
	        TreeHelper.writeNHtree( tree2, f3, true, false, false );
	    }
	    catch ( Exception e ) {
	        System.err.println( "Could not write tree: " + e );
	        System.exit( -1 );
	    }
    }
}
