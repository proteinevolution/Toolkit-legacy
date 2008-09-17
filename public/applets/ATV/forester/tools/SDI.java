// SDI.java
// Speciation versus Duplication Inference
//
// Copyright (C) 2000-2002 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved
//
// Created: 2000
// Author: Christian M. Zmasek
// zmasek@genetics.wustl.edu
// http://www.genetics.wustl.edu/eddy/people/zmasek/



// Requires JDK 1.2 or greater.


package forester.tools;


import forester.tree.*;
import forester.atv.*;

import java.io.*;
import java.util.Vector;
import java.util.HashMap;      // Requires JDK 1.2 or greater.



/**

Abstract class from with classes SDIse and OE inherit.
SDIse implements our SDI algorithm. OE implements Eulenstein's
algorithm for gene duplication inference.
<ul>
<li>
Contains a "main" method to run SDIse or OE on single trees from the
command line.
<li>
Contains a method to compute the mapping cost L: "computeMappingCost()"
<li>
Contains a method to strip trees of nodes with species not found
in another tree: "stripTree(Tree,Tree)"
<li>
Contains a method to calculate the mapping function for the
external nodes of the gene tree: "linkExtNodesOfG()"
</ul>
<p>
Requires JDK 1.2 or greater.

@see SDIse
@see OE
 
@author Christian M. Zmasek

@version 1.012 -- last modified: 10/02/01

*/
public abstract class SDI {


    private Tree genetree_,
                 speciestree_;

    private int  duplications_, // Number of duplications.
                 c_;            // Mapping cost "L".



    /**

    Constructor which sets the gene tree and the species tree to be
    compared. species_tree is the species tree to which the gene
    tree gene_tree will be compared to - with method "infer(boolean)".
    The actual inference is accomplished with method "infer(boolean)".
    The mapping cost L can then be calculated with method "computeMappingCost()".
    <p>
    Conditions:
    </p>
    <ul>
    <li> Both Trees must be completely binary
    <li> Both Trees must be rooted
    <li> Both Trees must have species names in the species name fields of
    all their external nodes
    </ul>    
    <p>
    (Last modified: 01/11/01)

    @see #infer(boolean)
    @see #computeMappingCost()

    @param gene_tree    reference to a rooted binary gene Tree to which assign
                        duplication vs speciation, must have species names in 
                        the species name fields for all external nodes 
    @param species_tree reference to a rooted binary species Tree which might
                        get stripped in the process, must have species names in 
                        the species name fields for all external nodes 

    */
    public SDI( Tree gene_tree, Tree species_tree ) throws Exception {

        if ( !gene_tree.isRooted() ) {
            String message = "SDI: gene tree must be rooted.";
            throw new Exception( message );
        }
        if ( !species_tree.isRooted() ) {
            String message = "SDI: species tree must be rooted.";
            throw new Exception( message );
        }

        genetree_     = gene_tree;
        speciestree_  = species_tree;
        duplications_ = 0;
        c_            = 0;

    }



    /**
    
    Infers for each Node of gene_tree (set in constructor) whether it
    represents a speciation or duplication event by calculating 
    and interpreting the mapping function M. The most parsimonious
    sequence of speciation and duplication events is assumed.
    <p>
    (Last modified: 01/11/01)

    @see #SDI(Tree,Tree)

    @param strip_species_tree set to true to remove from the species tree 
                              species not found in the gene tree prior
                              to analysis

    @return number of duplications which have been assigned in gene_tree

    */
    abstract public int infer( boolean strip_species_tree ) throws Exception;



    /**

    Computes the cost of mapping the gene tree gene_tree onto the
    species tree species_tree. Before this method can be called,
    the mapping has to be calculated with method "infer(boolean)".
    <p> 
    Reference. Zhang, L. (1997) On a Mirkin-Muchnik-Smith Conjecture
    for Comparing Molecular Phylogenies. Journal of Computational
    Biology 4 177-187.
    <p>
    (Last modified: 11/07/00)

    @return the mapping cost "L"

    */
    public int computeMappingCost() throws Exception {

        speciestree_.levelOrderReID( 0 );

        c_ = 0;

        computeMappingCostHelper( genetree_.getRoot() );

        return c_;

    }



    /**

    Removes from Tree to_be_stripped all external Nodes which
    are associated with a species NOT found in Tree reference.
    <p>
    (Last modified: 01/11/01)

    @param reference a reference Tree
    @param to_be_stripped Tree to be stripped

    @return number of external nodes removed from to_be_stripped

    */
    public static int stripTree( Tree reference, Tree to_be_stripped ) {

        Node r    = reference.getExtNode0(),
             s    = to_be_stripped.getExtNode0(),
             temp = null;
        int  i    = 0;

        HashMap r_ext_nodes = new HashMap();

        // Put references to all external Nodes of reference Tree into HashMap.
        // Species name is the key, Node is the value.
        while ( r != null ) {
            r_ext_nodes.put( r.getSpecies(), r );
            r = r.getNextExtNode();
        }


        while ( s != null ) {
            temp = s.getNextExtNode();
            if ( !r_ext_nodes.containsKey( s.getSpecies() ) ) {
                to_be_stripped.removeExtNode( s );
                i++;
                s = null;
            }
            s = temp;
        }

        return i;
    }



    /**

    Returns the gene tree.
    <p>
    (Last modified: 10/02/01)

    @return gene tree

    */
    public Tree getGeneTree() {
        return genetree_;
    }



    /**

    Returns the species tree.
    <p>
    (Last modified: 10/02/01)

    @return species tree

    */
    public Tree getSpeciesTree() {
        return speciestree_;
    }



    /**

    Returns the mapping cost L.
    <p>
    (Last modified: 10/02/01)

    @return the mapping cost L

    */
    public int getMappingCost() {
        return c_;
    }



    /**

    Returns the number of duplications.
    <p>
    (Last modified: 10/02/01)

    @return number of duplications

    */
    public int getDuplications() {
        return duplications_;
    }


    
    /**

    Sets the number of duplications to 0.
    <p>
    (Last modified: 10/02/01)

    */
    void setDuplicationsToZero() {
        duplications_ = 0;
    }


    
    /**

    Increases the number of duplications by one.
    <p>
    (Last modified: 10/02/01)

    */
    void increaseDuplications() {
        duplications_++;
    }



    /**

    Decreases the number of duplications by one.
    <p>
    (Last modified: 10/02/01)

    */
    void decreaseDuplications() {
        duplications_--;
    }



    /**

    Calculates the mapping function for the external nodes of the gene 
    tree: links (sets the field "link" of Node) each external Node of gene_tree
    to the external Node of species_tree which has the same species name.
    <p>
    (Last modified: 01/11/01)

    */
    void linkExtNodesOfG() throws Exception {

        Node g = genetree_.getExtNode0(),
             s = speciestree_.getExtNode0();

        HashMap speciestree_ext_nodes = new HashMap();
      
        // Put references to all external Nodes of Tree t2 into HashMap.
        // Species name is the key, Node is the value.

        while ( s != null ) {
            speciestree_ext_nodes.put( s.getSpecies(), s );
            s = s.getNextExtNode();
        }

        // Retrieve the reference to the Node with a matching species name.

        while ( g != null ) {

            s = ( Node ) speciestree_ext_nodes.get( g.getSpecies() );

            if ( s == null ) {
                String message = "SDI: species \"" + g.getSpecies();
                message += "\" not present in species tree.";
                throw new Exception( message );
            }

            g.setLink( s );
            
            g = g.getNextExtNode();
        }

    }


    
    // Helper method for "computeMappingCost()".
    // Last modified: 11/07/00
    private void computeMappingCostHelper( Node g ) {

        if ( !g.isExternal() ) {

            computeMappingCostHelper( g.getChild1() );
            computeMappingCostHelper( g.getChild2() );

            if ( g.getLink() != g.getChild1().getLink()
            &&   g.getLink() != g.getChild2().getLink() ) {

                c_ += ( g.getChild1().getLink().getID()
                      + g.getChild2().getLink().getID()
                      - ( 2 * g.getLink().getID() )
                      - 2 );

            }
            else if ( g.getLink() != g.getChild1().getLink()
                 &&   g.getLink() == g.getChild2().getLink()  ) {
                      
                c_ += ( g.getChild1().getLink().getID()
                      - g.getLink().getID()
                      + 1 );

            }
            else if ( g.getLink() == g.getChild1().getLink()
                 &&   g.getLink() != g.getChild2().getLink()  ) {
                      
                c_ += ( g.getChild2().getLink().getID()
                      - g.getLink().getID()
                      + 1 ); 

            }
            else {
                c_++;
            }
        }
    }



    /**
    
    A "main method" for SDI (Speciation versus Duplication Inference).
    <p>
    (Last modified: 01/11/01)

    @param [args[0] "-e" to use Eulenstein's algorithm instead of SDIse]
    @param [args[0] "-n" input trees are in New Hampshire format instead
                         of NHX -- or gene tree is in NHX, but species
                         information in gene tree is only  present in the
                         form of SWISS-PROT sequence names] 
    @param args[0or1]    species tree file name (in NHX format with
                         species names in species name fields
                         unless -n option is used) 
    @param args[1or2]    gene tree file name (in NHX format with
                         species names in species name fields and sequence names
                         in sequence name fields unless -n option is used)
    @param [args[2or3]   output file name; default is "sdi_out.nhx"]

    */
    public static void main( String args[] ) {

        final boolean STRIP_SPECIES_TREE = true;
        SDI           sdi                = null;
        Tree          species_tree       = null,
                      gene_tree          = null;
        boolean       use_eulenstein     = false,
                      nh                 = false;
        File          species_tree_file  = null,
                      gene_tree_file     = null,
                      out_file           = new File( "sdi_out.nhx" );
        int           d                  = 0;
    
        
            
        if ( args.length < 2 || args.length > 4 ) {
            errorInCommandLine();
        }
        if ( args[ 0 ].startsWith( "-" ) ) {
            if ( args.length < 3 ) {
                errorInCommandLine();
            }
            if ( args[ 0 ].toLowerCase().indexOf( "e" ) != -1 ) {
                use_eulenstein = true;
            }
            if ( args[ 0 ].toLowerCase().indexOf( "n" ) != -1 ) {
                nh             = true;
            }

            species_tree_file = new File( args[ 1 ] );
            gene_tree_file    = new File( args[ 2 ] );

            if ( args.length == 4 ) {
                out_file = new File( args[ 3 ] );
            }
        }
        else {
            species_tree_file = new File( args[ 0 ] );
            gene_tree_file    = new File( args[ 1 ] );
            if ( args.length == 3 ) {
                out_file = new File( args[ 2 ] );
            }
        }

        try {
            species_tree = TreeHelper.readNHtree( species_tree_file );
        }
        catch ( Exception e ) {
	        System.err.println( "Could not read " + species_tree_file + ". Terminating." );
	        System.exit( -1 );
	    }
        try {
            gene_tree = TreeHelper.readNHtree( gene_tree_file );
        }
        catch ( Exception e ) {
	        System.err.println( "Could not read " +  gene_tree_file + ". Terminating." );
	        System.exit( -1 );
	    }
            
        if ( nh ) {
            TreeHelper.extractSpeciesNameFromSeqName( species_tree );
            TreeHelper.extractSpeciesNameFromSeqName( gene_tree );
        }
            
        TreeHelper.cleanSpeciesNamesInExtNodes( species_tree );
        

        // For timing.
        //gene_tree = TreeHelper.createBalancedTree( 10 );
        //species_tree = TreeHelper.createBalancedTree( 13 );
        //species_tree = TreeHelper.createUnbalancedTree( 1024 );
        //gene_tree = TreeHelper.createUnbalancedTree( 8192 );
        //species_tree = gene_tree.copyTree();
        //gene_tree = species_tree.copyTree();
        //TreeHelper.numberSpeciesInOrder( species_tree );
        //TreeHelper.numberSpeciesInOrder( gene_tree );
        //TreeHelper.randomizeSpecies( 1, 8192, gene_tree );
        //TreeHelper.intervalNumberSpecies( gene_tree, 4096 );
        //TreeHelper.numberSpeciesInDescOrder( gene_tree );


        try {
            if ( use_eulenstein ) {
                sdi = new OE( gene_tree, species_tree );
                System.out.println( "\nUsing Eulenstein's algorithm." );
            }
            else {
                sdi = new SDIse( gene_tree, species_tree );
            }
        }
        catch ( Exception e ) {
	        System.err.println( "Unexpected error during creation of SDI object: " + e );
	        System.exit( -1 );
	    }
         

        try {
            d = sdi.infer( STRIP_SPECIES_TREE );
        }
        catch ( Exception e ) {
	        System.err.println( "Unexpected error during calculation of duplications." );
            System.err.println( "Stack trace: " );
            e.printStackTrace();
	        System.exit( -1 );
	    }


        try {    
            TreeHelper.writeNHtree( gene_tree, out_file, true, true, true );
        }
        catch ( Exception e ) {
	        System.err.println( "Could not write " +  out_file + ". Terminating." );
	        System.exit( -1 );
	    }


        System.out.println( "\nNumber of duplications: " + d );
        System.out.flush();
        ATVjframe atvframe_s = new ATVjframe( species_tree );
        atvframe_s.setTitle( "species tree" );
        atvframe_s.showWhole();
        ATVjframe atvframe_g = new ATVjframe( gene_tree );
        atvframe_g.setTitle( "gene tree" );
        atvframe_g.showWhole();
        
    }



    private static void errorInCommandLine() {
        System.out.println( "\nSDI: Error in command line.\n" );
        System.out.println( "Usage: \"SDI  [-options] <species tree file name> <gene tree file name> [outfile name]\"" );
        System.out.println( "\nOptions:" );
        System.out.println( " -e to use Eulenstein's algorithm instead of SDIse" );
        System.out.println( " -n input trees are in New Hampshire format instead of NHX -- or" );
        System.out.println( "    the gene tree is in NHX, but species information is" );
        System.out.println( "    only present in the form of SWISS-PROT sequence names" );
        System.out.println( "\nSpecies tree file" );
        System.out.println( " In NHX format, with species names in species name fields unless -n option" ); 
        System.out.println( " is used." );
        System.out.println( "\nGene tree file" );
        System.out.println( " In NHX format, with species names in species name fields and sequence names" );
        System.out.println( " in sequence name fields unless -n option is used." );
        System.out.println( "" );
        System.exit( -1 );
    }

   
} // End of abstract class SDI.
