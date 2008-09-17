// SDIdirectory.java
// Speciation versus Duplication Inference on all trees in a directory
//
// Copyright (C) 1999-2001 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved
//
// Created: 2000
// Author: Christian M. Zmasek
// zmasek@genetics.wustl.edu
// http://www.genetics.wustl.edu/eddy/people/zmasek/

// Example:
// java forester.tools.SDIdirectory -ndh /nfs/wol2/people/zmasek/pfam_trees/trees101100full1x_sizelim1000 .nhx /nfs/wol2/people/zmasek/archive/trees/tree_of_life_bin_1-3.nhx outtrees OUTFILE




// Requires JDK 1.2 or greater.


package forester.tools;


import forester.tree.*;
import forester.atv.*;

import java.io.*;
import java.util.Arrays;



/**

Allows to infer duplications - speciations on all (rooted or unrooted) gene trees in
a directory by using method "infer" of class SDIunrooted.
<p>
The output of this is a (re)rooted tree with speciation - duplication assigned
(in NHX format) for each tree (in "gene tree directory" with suffix
"suffix for gene trees"), as well as a summary list ("outputfile name").
<p>
The summary list contains the following. The number in brackets indicates
how many external nodes of the gene tree had to be removed since the
associated species was not found in the species tree. "en" indicates
the number of external nodes in the resulting (analyzed and returned)
gene tree. "d" are the number of duplications, "L=" the mapping cost,
"h=" the height, "d=" the minimal difference in tree heights (of the two
subtrees at the root; this number is 0.0 for a midpoint rooted tree)
of the resulting, analyzed and rooted gene tree(s).
<p>
The output file ending with "_Sdist" is a file which lists the distribution
of trees sizes, "_Ddist" lists the distribution of the sums of duplications
(up to a certain maximal size, set with final variables MAX_EXT_NODE_DIST
and MAX_DUP_DIST).


@see SDIunrooted

@author Christian M. Zmasek

@version 1.400 -- last modified: 10/01/01

*/
public class SDIdirectory {


    /**

    Runs method "infer" of class SDIunrooted on all gene trees in
    directory indir.
    <p>
    Trees are rooted by minimizing either the sum of duplications, the
    mapping cost L, or the tree height (or combinations thereof).
    One resulting tree for each (out of possibly many) is stored in
    outdir and a summary outfile is created. The distributions of the tree
    sizes (name of outfile + _Ddist) and the distributions of the sum
    of duplications per tree (name of outfile + _Sdist) are written out as
    well.
    <p>
    If both minimize_sum_of_dup and minimize_mapping_cost are true,
    trees are rooted by minimizing by minimizing the mapping cost L.
    <p>
    If minimize_sum_of_dup, minimize_mapping_cost, and minimize_height
    are false trees are assumed to be alreadty rooted.
    <p>
    (Last modified: 02/02/01)

    @see SDIunrooted#infer(Tree,Tree,boolean,boolean,boolean,boolean,int,boolean)

    @param indir                 a directory containing gene trees in NHX format
    @param species_tree_file     a species tree file in NHX format
    @param outdir                a directory where to write trees
    @param outfile               a file name for the summary file
    @param suffix                a suffix for the trees to read (e.g. nhx), is
                                 case sensitive
    @param write_trees           set to true to write out one tree with minmal
                                 duplications or L each
    @param minimize_mapping_cost set to true to root by minimizing the
                                 mapping cost L
    @param minimize_sum_of_dup   set to true to root by minimizing
                                 the sum of duplications
    @param minimize_height       set to true to root by minimizing the
                                 tree height -- if minimize_mapping_cost is
                                 set to true or minimize_sum_of_dup is set
                                 to true, then out of the resulting trees with
                                 minimal mapping cost or minimal number of
                                 duplications the tree with the minimal height
                                 is chosen
    @param input_trees_in_nh     set to true if
                                 input trees are in New Hampshire format instead
                                 of NHX;
                                 or
                                 gene trees are in NHX, but species
                                 information in gene trees is only  present in the
                                 form of SWISS-PROT sequence names

    */
    public static void infer( File indir,
                              File species_tree_file,
                              File outdir,
                              File outfile,
                              String suffix,
                              boolean write_trees,
                              boolean minimize_mapping_cost,
                              boolean minimize_sum_of_dup,
                              boolean minimize_height,
                              boolean input_trees_in_nh ) throws Exception {



        final boolean TIME               = true,
                      FAST_INFER         = false;

        final int     MIN_EXT_NODES      = 4;    // Minimal size of trees [in ext nodes]
                                                 // to be analyzed.
        final int     MAX_EXT_NODES      = 5000; // Maximal size of trees [in ext nodes]
                                                 // to be analyzed.
        final int     MAX_DUP_DIST       = 50;   // Max number of dups to output in dup
                                                 // distribution ("_Ddist").
        final int     MAX_EXT_NODE_DIST  = 1000; // Max number of ext nodes to output in size
                                                 // distribution ("_Sdist").

        int         successful                = 0,
                    number_of_too_small_trees = 0,
                    number_of_too_large_trees = 0,
                    dups                      = 0,
                    c                         = 0,
                    ext_nodes                 = 0,
                    removed                   = 0,
                    nodecount0                = 0,
                    j                         = 0;
        long        total_number_of_d         = 0,
                    total_number_of_ext_nodes = 0,
                    sum_costs                 = 0,
                    time0                     = 0,
                    time_for_sdi              = 0;
        double      sum_tree_heights          = 0.0,
                    sum_subtree_diff          = 0.0;
        Tree        species_tree              = null;
        String      filename                  = null;
        String[]    filenames                 = null;
        Tree[]      trees                     = null;
        int[]       duplications              = new int[ MAX_EXT_NODES - 1 ], // For dup distribution.
                    sizes                     = new int[ MAX_EXT_NODES - 1 ]; // For ext nodes dist.of
                                                                             // successfully assigned trees.

        File        outtree                   = null;
        PrintWriter out                       = null,
                    out_ddist                 = null,
                    out_sdist                 = null;
        File        ddist_outfile             = new File( outfile + "_Ddist" ),
                    sdist_outfile             = new File( outfile + "_Sdist" );
        SDIunrooted sdiunrooted               = null;

        java.text.DecimalFormat df = new java.text.DecimalFormat( "0.0#####" );
        df.setDecimalSeparatorAlwaysShown( true );


        if ( !indir.exists() || !indir.isDirectory() ) {
            throw new Exception( indir
            + " does not exist or is not a directory." );
        }
        if ( !outdir.exists() || !outdir.isDirectory() ) {
            throw new Exception( outdir
            + " does not exist or is not a directory." );
        }
        if ( outfile.exists() ) {
            throw new Exception( outfile
            + " does already exist." );
        }
        if ( ddist_outfile.exists() ) {
            throw new Exception( ddist_outfile
            + " does already exist." );
        }
        if ( sdist_outfile.exists() ) {
            throw new Exception( sdist_outfile
            + " does already exist." );
        }
        if ( !species_tree_file.exists() || !species_tree_file.isFile() ) {
            throw new Exception( species_tree_file
            + " does not exist or is not a file." );
        }

        if ( minimize_mapping_cost && minimize_sum_of_dup ) {
            minimize_sum_of_dup = false;
        }

        if ( FAST_INFER ) { 
            minimize_mapping_cost = false;
            minimize_sum_of_dup   = true;
            minimize_height       = true;
        }

        species_tree = TreeHelper.readNHtree( species_tree_file );
       
        if ( input_trees_in_nh ) {
            TreeHelper.extractSpeciesNameFromSeqName( species_tree );
        }
        TreeHelper.cleanSpeciesNamesInExtNodes( species_tree );

        filenames = indir.list();

        Arrays.sort( filenames );

        suffix = suffix.trim();

        out = new PrintWriter( new FileWriter( outfile ), true );

        nodecount0 = Node.getNodeCount();

        time0 = System.currentTimeMillis();

        for ( int i = 0; i < filenames.length; ++i ) {
            filename = filenames[ i ];
            if ( suffix.length() < 1 || filename.endsWith( suffix ) ) {

                File gene_tree_file = new File( indir.getPath(), filename );
                if ( gene_tree_file.exists() && gene_tree_file.isFile() ) {

                    out.print( j + "\t" +  filename );
                    System.out.println( j + ": " +  filename );

                    j++;

                    Tree gene_tree = null;
                    
                    gene_tree = TreeHelper.readNHtree( gene_tree_file );
                    
                    if ( input_trees_in_nh ) {
                        TreeHelper.extractSpeciesNameFromSeqName( gene_tree );
                    }
                    //Removes from gene_tree all species not found in species_tree.
                    removed = SDI.stripTree( species_tree, gene_tree );
                    if ( filename.length() < 8 ) {
                        out.print( "\t\t\t[-" + removed + "]" );
                    }
                    else if ( filename.length() < 16 ) {
                        out.print( "\t\t[-" + removed + "]" );
                    }
                    else {
                        out.print( "\t[-" + removed + "]" );
                    }
                    if ( gene_tree.getNumberOfExtNodes() < MIN_EXT_NODES ) {
                        out.print( "\t<" + MIN_EXT_NODES + "en\n" );
                        number_of_too_small_trees++;
                    }
                    else if ( gene_tree.getNumberOfExtNodes() > MAX_EXT_NODES ) {
                        out.print( "\t>" + MAX_EXT_NODES + "en\n" );
                        number_of_too_large_trees++;
                    }
                    else {
                        Node.setNodeCount( nodecount0 );
                        sdiunrooted = new SDIunrooted();
                        
                        if ( FAST_INFER ) {
                            trees = new Tree[ 1 ];
                            trees[ 0 ] = sdiunrooted.fastInfer( gene_tree,
                                                                species_tree );
                            if ( write_trees ) {
                                trees[ 0 ].adjustNodeCount( false );
                            }
                        }
                        else {
                            trees = sdiunrooted.infer( gene_tree,
                                                       species_tree,
                                                       minimize_mapping_cost,
                                                       minimize_sum_of_dup,
                                                       minimize_height,
                                                       write_trees,
                                                       1 );
                        } 



                        successful++;


                        ext_nodes = gene_tree.getNumberOfExtNodes();
                        total_number_of_ext_nodes += ext_nodes;
                        sizes[ ext_nodes ]++;
                        out.print( "\t " + ext_nodes + "en" );

                        dups = sdiunrooted.getMinimalDuplications();
                        total_number_of_d += dups;
                        duplications[ dups ]++;
                        out.print( "\t " + dups + "d" );


                        if ( minimize_mapping_cost ) {
                            c = sdiunrooted.getMinimalMappingCost();
                            sum_costs += c;
                            out.print( "\t L=" + c );
                        }

                        if ( minimize_height ) {
                            out.print( "\t h=" + df.format( sdiunrooted.getMinimalTreeHeight() ) );
                            if ( !FAST_INFER ) {
                                out.print( "\t d=" + df.format( sdiunrooted.getMinimalDiffInSubTreeHeights() ) );
                            }
                            sum_tree_heights += sdiunrooted.getMinimalTreeHeight();
                            if ( !FAST_INFER ) {
                                sum_subtree_diff += sdiunrooted.getMinimalDiffInSubTreeHeights();
                            }
                        }

                        out.println();

                        if ( TIME && !FAST_INFER ) {
                            time_for_sdi += sdiunrooted.getTimeSumSDI();
                        }

                        if ( write_trees ) {

                            outtree = new File( outdir, new File( filenames[ i ] ).getName() );
                            TreeHelper.writeNHtree( trees[ 0 ], outtree, true, false, false );

                        }
                    }
                }
            }
        }

        Node.setNodeCount( nodecount0 );
        if ( FAST_INFER ) {
            out.println( "\nUsed fast infer." );
            System.out.println( "\nUsed fast infer." );
        }
        if ( input_trees_in_nh ) {
            out.println( "\nInput trees were in NH format or had species names extracted from seq names." );
            System.out.println( "\nInput trees were in NH format or had species names extracted from seq names." );
        }
        else {
            out.println( "\nInput trees were in NHX format." );
            System.out.println( "\nInput trees were in NHX format." );
        }
        if ( minimize_mapping_cost ) {
            out.println( "\nRooted by minimizing mapping cost L." );
            System.out.println( "\nRooted by minimizing mapping cost L." );
            if ( minimize_height ) {
                out.println( "Selected tree(s) with minimal height out of resulting trees." );
                System.out.println( "Selected tree(s) with minimal height out of resulting trees." );
            }
        }
        else if ( minimize_sum_of_dup ) {
            out.println( "\nRooted by minimizing sum of duplications." );
            System.out.println( "\nRooted by minimizing sum of duplications." );
            if ( minimize_height ) {
                out.println( "Selected tree(s) with minimal height out of resulting trees." );
                System.out.println( "Selected tree(s) with minimal height out of resulting trees." );
            }
        }
        else if ( minimize_height ) {
            out.println( "\nRooted by minimizing tree height." );
            System.out.println( "\nRooted by minimizing tree height." );
        }
        else {
            out.println( "\nNo (re) rooting was performed." );
            System.out.println( "\nNo (re) rooting was performed." );
        }

        time0 = ( System.currentTimeMillis() - time0 ) / 1000;

        out.println( "\nTrees directory  : " + indir );
        out.println( "Suffix for trees : " + suffix );
        out.println( "Species tree     : " + species_tree_file );
        out.println( "Output directory : " + outdir );
        out.println( "Output file      : " + outfile );

        out.println( "\nTotal number of attempts (tree files read)       : " + j );
        out.println( "Total number of successfully assigned trees      : " + successful );
        out.println( "Number of too small trees                        : " + number_of_too_small_trees );
        out.println( "Number of too large trees                        : " + number_of_too_large_trees );
        out.println( "\nSum of duplications                                   : "
        + total_number_of_d );
        if ( minimize_mapping_cost ) {
            out.println( "Sum of mapping costs L                                : "
            + sum_costs );
        }
        if ( minimize_height ) {
            out.println( "Sum of tree heights                                   : "
            + sum_tree_heights );
            if ( !FAST_INFER ) {
                out.println( "Sum of differences in subtree heights                 : "
                + sum_subtree_diff );
            }
        }
        out.println( "Sum of external nodes (in successfully assigned trees): "
        + total_number_of_ext_nodes );

        if ( TIME && !FAST_INFER ) {
            out.println( "\nTime sum for actual SDI: " + time_for_sdi + "ms" );
        }
        out.println( "\nTotal time             : " + time0  + "s" );

        out.close();

        System.out.println( "\nTotal number of attempts (tree files read)       : " + j );
        System.out.println( "Total number of successfully assigned trees      : " + successful );
        System.out.println( "Number of too small trees                        : " + number_of_too_small_trees );
        System.out.println( "Number of too large trees                        : " + number_of_too_large_trees );
        System.out.println( "\nSum of duplications                                   : "
        + total_number_of_d );
        if ( minimize_mapping_cost ) {
            System.out.println( "Sum of mapping costs L                                : "
            + sum_costs );
        }
        if ( minimize_height ) {
            System.out.println( "Sum of tree heights                                   : "
            + sum_tree_heights );
            if ( !FAST_INFER ) {
                System.out.println( "Sum of differences in subtree heights                 : "
                + sum_subtree_diff );
            }
        }
        System.out.println( "Sum of external nodes (in successfully assigned trees): "
        + total_number_of_ext_nodes );
        if ( TIME && !FAST_INFER ) {
            System.out.println( "\nTime sum for actual SDI: " + time_for_sdi + "ms" );
        }
        System.out.println( "\nTotal time             : " + time0  + "s" );



        out_ddist = new PrintWriter( new FileWriter( ddist_outfile ), true );
        for ( int i = 0; i < duplications.length && i <= MAX_DUP_DIST; ++i ) {
            out_ddist.println( i + " " + duplications[ i ] );
        }
        out_ddist.close();


        out_sdist = new PrintWriter( new FileWriter( sdist_outfile ), true );
        for ( int i = 0; i < sizes.length && i <= MAX_EXT_NODE_DIST; ++i ) {
            out_sdist.println( i + " " + sizes[ i ] );
        }
        out_sdist.close();

        System.out.println( "\nDone." );


    } // infer


    /**

    Main method for this class.
    <p>
    (Last modified: 01/13/01)
    
    @param [args[0] -l to root by minimizing mapping cost L]
    @param [args[0] -d to root by minimizing sum of duplications]
    @param [args[0] -w to write out trees into outdir]
    @param [args[0] -h to root by minimizing tree height]
    @param [args[0] -n input trees are in New Hampshire format instead
                       of NHX -- or gene tree is in NHX, but species
                       information in gene tree is only  present in the
                       form of SWISS-PROT sequence names]
    @param args[0or1]  trees directory name
    @param args[1or2]  suffix for gene trees
    @param args[2or3]  speciestree file name
    @param args[3or4]  output directory name
    @param args[4or5]  output file name

    */
    public static void main( String args[] ) {

        // These are the default values.
        boolean minimize_mapping_cost = false,
                minimize_sum_of_dup   = true,
                minimize_height       = true,
                write_trees           = false,
                nh                    = true;

        File indir            = null,
             speciestree_file = null,
             outdir           = null,
             outfile          = null;
        String suffix = null;

        if ( args.length == 5 ) {
            indir            = new File( args[ 0 ] );
            suffix           = args[ 1 ];
            speciestree_file = new File( args[ 2 ] );
            outdir           = new File( args[ 3 ] );
            outfile          = new File( args[ 4 ] );
        }

        else if ( args.length == 6 ) {
            if ( args[ 0 ].startsWith( "-" ) ) {
                minimize_mapping_cost = false;
                minimize_sum_of_dup   = false;
                minimize_height       = false;
                write_trees           = false;
                nh                    = false;
               
                if ( args[ 0 ].toLowerCase().indexOf( "w" ) != -1 ) {
                    write_trees           = true;
                }
                if ( args[ 0 ].toLowerCase().indexOf( "l" ) != -1 ) {
                    minimize_mapping_cost = true;
                }
                if ( args[ 0 ].toLowerCase().indexOf( "d" ) != -1 ) {
                    minimize_sum_of_dup   = true;
                }
                if ( args[ 0 ].toLowerCase().indexOf( "h" ) != -1 ) {
                    minimize_height       = true;
                }
                if ( args[ 0 ].toLowerCase().indexOf( "n" ) != -1 ) {
                    nh                    = true;
                }
            }
            else {
                errorInCommandLine();
            }
            indir            = new File( args[ 1 ] );
            suffix           = args[ 2 ];
            speciestree_file = new File( args[ 3 ] );
            outdir           = new File( args[ 4 ] );
            outfile          = new File( args[ 5 ] );
        }

        else {
            errorInCommandLine();
        }

        if ( minimize_mapping_cost && minimize_sum_of_dup ) {
            minimize_sum_of_dup = false;
        }

        try {
            infer( indir,
                   speciestree_file,
                   outdir,
                   outfile,
                   suffix,
                   write_trees,
                   minimize_mapping_cost,
                   minimize_sum_of_dup,
                   minimize_height,
                   nh );
        }
        catch ( Exception e ) {
	        System.err.println( "\nSDIdirectory: Error: " + e + "\n" );
	        System.exit( -1 );
	    }

    } // main




    private static void errorInCommandLine() {
        System.out.println( "\nSDIdirectory: Error in command line.\n" );
        System.out.println( "Usage: \"SDIdirectory  [-options] <gene tree directory> <suffix for gene trees>" );
        System.out.println( "        <species tree file name> <output directory> <outputfile name>\"" );
        System.out.println( "\nOptions:" );
        System.out.println( " -n input trees are in New Hampshire format instead of NHX -- or" );
        System.out.println( "    gene trees are in NHX, but species information is" );
        System.out.println( "    only present in the form of SWISS-PROT sequence names" );
        System.out.println( " -l to root by minimizing the mapping cost L (and also the sum of duplications)" );
        System.out.println( " -d to root by minimizing the sum of duplications" );
        System.out.println( " -h to root by minimizing tree height (can be used together with -l or -d)" );
        System.out.println( " -w to write assigned gene trees into output directory" );
        System.out.println( "\nGene tree directory" );
        System.out.println( " The directory from which to read gene trees. The gene trees " );
        System.out.println( " can either be rooted, in which case no rooting with -l, -d, or -h " );
        System.out.println( " is necessary, or they can be unrooted, in which case rooting " );
        System.out.println( " is mandatory." );
        System.out.println( "\nSuffix for gene trees" );
        System.out.println( " Suffix of the gene trees to analyze (e.g. \"NHX\")." );
        System.out.println( "\nSpecies tree file" );
        System.out.println( " In NHX format, with species names in species name fields; unless -n option" );
        System.out.println( " is used." );
        System.out.println( "\nOutput directory" );
        System.out.println( " The directory into which the assigned gene trees will be written." );
        System.out.println( "\nOutputfile name" );
        System.out.println( " File name for summary output files." );
        System.out.println( "" );
        System.exit( -1 );
    } // errorInCommandLine()

} // End of class SDIdirectory.



