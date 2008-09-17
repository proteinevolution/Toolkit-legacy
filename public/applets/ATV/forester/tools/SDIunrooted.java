// SDIunrooted.java
// Speciation versus Duplication Inference for a possibly unrooted tree
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



/**

Allows to infer duplications - speciations on a unrooted gene tree.
It reroots the gene trees on each of its branches and performs SDIse
on each of the resulting trees. Trees which minimize a certain
criterion are returned as the "correctly" rooted ones. The criterions are:
<ul>
<li> Sum of duplications
<li> Mapping cost L
<li> Tree height - which is the largest distance from root to external node
     (minimizing of which is the same as "midpoint rooting")
</ul>

@see SDIse
@see SDI

@author Christian M. Zmasek

@version 1.400 -- last modified: 10/01/01

*/
public class SDIunrooted {

    // How many resulting trees "main" should return/display.
    private final static int     TREES_TO_RETURN = 5;

    private final static double  ZERO_DIFF       = 1.0E-10; // Due to inaccurate
                                                            // calculations on
                                                            // Java's side, not
                                                            // everything that should
                                                            // be 0.0 is 0.0.

    private int    count_,
                   min_dup_,
                   min_cost_;
    private double min_height_,
                   min_diff_;
    private long   time_sdi;



    /**

    Default contructor which creates an "empty" SDIunrooted object.

    */
    public SDIunrooted() {
        count_      = -1;
        min_dup_    = Integer.MAX_VALUE;
        min_cost_   = Integer.MAX_VALUE;
        min_height_ = Double.MAX_VALUE;
        min_diff_   = Double.MAX_VALUE;
        time_sdi    = -1;
    } // SDIunrooted()



    /**

    Returns the number of differently rooted trees which minimize
    the (rooting) "criterion" - as determined by method "infer".

    @see #infer(Tree,Tree,boolean,boolean,boolean,boolean,int,boolean)

    @return number of differently rooted trees which minimized
            the criterion

    */
    public int getCount() {
        return count_;
    }



    /**

    Returns the minimal number of duplications - as determined
    by method "infer".
    <p>
    <B>IMPORTANT</B>: If the tree is not rooted by minimizing
    the sum of duplications or the mapping cost L, then this
    number is NOT NECESSARILY the MINIMAL number of duplications.

    @see #infer(Tree,Tree,boolean,boolean,boolean,boolean,int,boolean)

    @return (minimal) number of duplications

    */
    public int getMinimalDuplications() {
        return min_dup_;
    }



    /**

    Returns the minimal mapping cost L - as determined
    by method "infer" - if minimize_mapping_cost is set to true.
    <p>
    (Last modified: 11/07/00)

    @see #infer(Tree,Tree,boolean,boolean,boolean,boolean,int,boolean)

    @return the minimal mapping cost "L" -- IF calculated by "infer"

    */
    public int getMinimalMappingCost() {
        return min_cost_;
    }



    /**

    Returns the minimal tree height - as determined
    by method "infer" - if minimize_height is set to true.
    <B>IMPORTANT</B>: If minimize_mapping_cost or minimize_sum_of_dup
    are also set to true, then this returns the minimal tree height
    of the trees which minimize the first criterion.
    <p>
    (Last modified: 01/12/00)

    @see #infer(Tree,Tree,boolean,boolean,boolean,boolean,int,boolean)

    @return the minimal tree height -- IF calculated by "infer"

    */
    public double getMinimalTreeHeight() {
        return min_height_;
    }



    /**

    Returns the (absolue value of the) minimal difference in tree heights
    of the two subtrees at the root (of the (re)rooted gene tree)
    - as determined by method "infer" - if minimize_height is set to true.
    <p>
    If a tree is midpoint rooted this number is zero.
    <p>
    <B>IMPORTANT</B>: If minimize_mapping_cost or minimize_sum_of_dup
    are also set to true, then this returns the minimal difference
    in tree heights of the trees which minimize the first criterion, and
    is therefore not necessarily zero.
    <p>
    (Last modified: 01/22/00)

    @see #infer(Tree,Tree,boolean,boolean,boolean,boolean,int,boolean)

    @return the minimal difference in tree heights -- IF calculated by "infer"

    */
    public double getMinimalDiffInSubTreeHeights() {
        return min_diff_;
    }



    /**

    Returns the sum of times (in ms) needed to run method infer of class SDI.
    Final variable TIME needs to be set to true.

    @return sum of times (in ms) needed to run method infer of class SDI

    */
    public long getTimeSumSDI() {
        return time_sdi;
    }



    /**

    Infers gene duplications on a possibly unrooted gene Tree gene_tree.
    The tree is rooted be minimizing either the sum of duplications, the
    mapping cost L, or the tree height (or combinations thereof).
    If return_trees is set to true, it returns an array of possibly
    more than one differently rooted Trees.
    <br>
    The maximal number of returned trees is set with max_trees_to_return.
    <br>
    Tree species_tree is a species Tree to which the gene
    Tree gene_tree is compared to.
    <br>
    If both minimize_sum_of_dup and minimize_mapping_cost are true,
    the tree is rooted by minimizing the mapping cost L.
    <br>
    If minimize_sum_of_dup, minimize_mapping_cost, and minimize_height
    are false tree gene_tree is assumed to be alreadty rooted and no
    attempts at rooting are made, and only one tree is returned.
    <br>
    <p>
    Conditions:
    </p>
    <ul>
    <li> Both Trees must be completely binary (except deepest node of gene tree)
    <li> The species Tree must be rooted
    <li> Both Trees must have species names in the species name fields of their nodes
    <li> Both Trees must not have any collapses nodes
    </ul>
    <p>
    (Last modified: 10/01/01)

    @param gene_tree             a binary (except deepest node)
                                 gene Tree
    @param species_tree          a rooted binary species Tree
    @param minimize_mapping_cost set to true to root by minimizing the
                                 mapping cost L (and also the
                                 sum of duplications)
    @param minimize_sum_of_dup   set to true to root by minimizing
                                 the sum of duplications
    @param minimize_height       set to true to root by minimizing the
                                 tree height - if minimize_mapping_cost is
                                 set to true or minimize_sum_of_dup is set
                                 to true, then out of the resulting trees with
                                 minimal mapping cost or minimal number of
                                 duplications the tree with the minimal height
                                 is chosen
    @param return_trees          set to true to return Array of Trees,
                                 otherwise null is returned
    @param max_trees_to_return   maximal number of Trees to return
                                 (=maximal size of returned Array)
                                 must be no lower than 1

    @return array of rooted Trees with duplication vs. speciation assigned if
            return_trees is set to true, null otherwise

    */
    public Tree[] infer( Tree gene_tree,
                         Tree species_tree,
                         boolean minimize_mapping_cost,
                         boolean minimize_sum_of_dup,
                         boolean minimize_height,
                         boolean return_trees,
                         int max_trees_to_return ) throws Exception {

        SDIse                sdise                 = null;
        Vector               trees                 = new Vector();
        Tree[]               tree_array            = null;
        Branch[]             branches              = null;
        Tree                 g                     = null,
                             species_tree_stripped = null;
        Node                 prev_root             = null,
                             prev_root_c1          = null,
                             prev_root_c2          = null; 
        int                  duplications          = 0,
                             cost                  = 0,
                             counter               = 0,
                             min_duplications      = Integer.MAX_VALUE,
                             min_cost              = Integer.MAX_VALUE,
                             j                     = 0;
        double               height                = 0.0,
                             diff                  = 0.0,
                             min_height            = Double.MAX_VALUE,
                             min_diff              = 0.0;
        double[]             height__diff          = new double[ 2 ];
        boolean              need_to_root          = true,
                             smaller               = false,
                             equal                 = false, 
                             prev_root_was_dup     = false;

     
        if ( max_trees_to_return < 1 ) {
            max_trees_to_return = 1;
        }

        if ( minimize_mapping_cost && minimize_sum_of_dup ) {
            minimize_sum_of_dup = false;
        }

        if ( !minimize_mapping_cost && !minimize_sum_of_dup
        && !minimize_height ) {
            max_trees_to_return = 1;
            need_to_root        = false;
        }

        g = gene_tree.copyTree();

        if ( g.getNumberOfExtNodes() <= 1 ) {
            g.setRooted( true );
            setMinimalDuplications( 0 );
            setMinimalTreeHeight( 0.0 );
            tree_array = new Tree[ 1 ];
            tree_array[ 0 ] = g;
            return tree_array;
        }

        species_tree_stripped = species_tree.copyTree();
        // Removes from species tree all species not found in g.
        SDI.stripTree( g, species_tree_stripped );


        if ( need_to_root ) {
            g.reRoot( g.getExtNode0() );
            branches = getBranchesInOrder( g );
            if ( branches == null ) {
                throw new Exception( "SDIunrooted: Infer: Unexpected error: Failed to create array of branches." );
            }
        }
        else {
            if ( !g.isRooted() ) {
                throw new Exception( "\nSDIunrooted: Infer: Error: Gene tree must be rooted if no rooting is performed.\n" );
            }
            branches = new Branch[ 1 ];
        }

        if ( minimize_mapping_cost 
        || minimize_sum_of_dup
        || !need_to_root ) {
            sdise = new SDIse( g, species_tree_stripped );
            duplications = sdise.infer( false ); // Stripping has already been done.
        }        


        F: for ( j = 0; j < branches.length ; ++j ) {

            if ( need_to_root ) {
                prev_root         = g.getRoot(); 
                prev_root_c1      = prev_root.getChild1();
                prev_root_c2      = prev_root.getChild2();
                prev_root_was_dup = prev_root.isDuplication(); 
                g.reRoot( branches[ j ] );
            }

            if ( minimize_mapping_cost 
            || minimize_sum_of_dup ) {
                duplications = sdise.updateM( prev_root_was_dup,  
                                              prev_root_c1,
                                              prev_root_c2 );        
            }

            if ( minimize_mapping_cost ) {

                cost = sdise.computeMappingCost();

                if ( minimize_height
                && ( cost == min_cost || cost < min_cost ) ) {
                    height__diff = moveRootOnBranchToMinHeight( g );
                    height = height__diff[ 0 ];
                    diff   = height__diff[ 1 ];
                }

                if ( cost == min_cost ) {
                    if ( minimize_height ) {
                        smaller = equal = false;
                        if ( height < min_height ) {
                            min_height = height;
                            counter = 1;
                            smaller = true;
                        }
                        else if ( height == min_height ) {
                            counter++;
                            equal = true;
                        }
                        if ( Math.abs( diff ) < min_diff ) {
                            min_diff = Math.abs( diff );
                        }
                    }
                    if ( return_trees ) {
                        if ( minimize_height ) {
                            if ( smaller ) {
                                trees.removeAllElements();
                                trees.addElement( g.copyTree() );
                            }
                            else if ( equal && trees.size() < max_trees_to_return ) {
                                trees.addElement( g.copyTree() );
                            }
                        }
                        else {
                            counter++;
                            if ( trees.size() < max_trees_to_return ) {
                                trees.addElement( g.copyTree() );
                            }
                        }
                    }
                    else if ( !minimize_height ) {
                        counter++;
                    }
                }
                else if ( cost < min_cost ) {
                    if ( minimize_height ) {
                        min_height = height;
                        min_diff   = Math.abs( diff );
                    }
                    if ( return_trees ) {
                        trees.removeAllElements();
                        trees.addElement( g.copyTree() );
                    }
                    counter = 1;
                    min_cost = cost;
                }
                if ( duplications < min_duplications ) {
                    min_duplications = duplications;
                }
            }

            else if ( minimize_sum_of_dup ) {

                if ( minimize_height
                && ( duplications == min_duplications
                || duplications < min_duplications ) ) {
                    height__diff = moveRootOnBranchToMinHeight( g );
                    height = height__diff[ 0 ];
                    diff   = height__diff[ 1 ];
                }

                if ( duplications == min_duplications ) {
                    if ( minimize_height ) {
                        smaller = equal = false;
                        if ( height < min_height ) {
                            min_height = height;
                            counter = 1;
                            smaller = true;
                        }
                        else if ( height == min_height ) {
                            counter++;
                            equal = true;
                        }
                        if ( Math.abs( diff ) < min_diff ) {
                            min_diff = Math.abs( diff );
                        }
                    }
                    if ( return_trees ) {
                        if ( minimize_height ) {
                            if ( smaller ) {
                                trees.removeAllElements();
                                trees.addElement( g.copyTree() );
                            }
                            else if ( equal && trees.size() < max_trees_to_return ) {
                                trees.addElement( g.copyTree() );
                            }
                        }
                        else {
                            counter++;
                            if ( trees.size() < max_trees_to_return ) {
                                trees.addElement( g.copyTree() );
                            }
                        }
                    }
                    else if ( !minimize_height ) {
                        counter++;
                    }
                }
                else if ( duplications < min_duplications ) {
                    if ( minimize_height ) {
                        min_height = height;
                        min_diff   = Math.abs( diff );
                    }
                    if ( return_trees ) {
                        trees.removeAllElements();
                        trees.addElement( g.copyTree() );
                    }
                    counter = 1;
                    min_duplications = duplications;
                }
            }

            else if ( minimize_height ) {
                height__diff = moveRootOnBranchToMinHeight( g );
                height = height__diff[ 0 ];
                diff   = height__diff[ 1 ];
                if ( Math.abs( diff ) < ZERO_DIFF ) {
                    sdise = new SDIse( g, species_tree_stripped );
                    min_duplications = sdise.infer( false ); // Here they are obv. not _min_ dups !!!!

                    min_height = height;
                    min_diff   = Math.abs( diff );
                    counter    = 1;
                    if ( return_trees ) {
                       trees.addElement( g.copyTree() );
                    }
                    break F;
                }
            }

            else { // No rooting has been performed
                min_duplications = duplications;
                if ( return_trees ) {
                    trees.addElement( g.copyTree() );
                }
            }

           
        } // End of huge for loop "F".


        if ( return_trees ) {
            trees.trimToSize();
            tree_array = new Tree[ trees.size() ];
            for ( int i = 0; i < trees.size(); ++i ) {
                tree_array[ i ] = ( Tree ) trees.elementAt( i );
                tree_array[ i ].adjustNodeCount( false );
                tree_array[ i ].recalculateAndReset();
            }
        }

        setCount( counter );
        setMinimalDuplications( min_duplications );
        setMinimalMappingCost( min_cost );
        setMinimalTreeHeight( min_height );
        setMinimalDiffInSubTreeHeights( Math.abs( min_diff ) );

        return tree_array;

    } // infer



    /**

    This method is mainly to be used by the RIO classes as the returned tree
    is quite incomplete -- for improved time efficiency (number of external
    nodes of each Node are off, will have lost most annotations).
    The gene Tree gene_tree is modified by this method.
    <p>
    It makes use of the fact that after each rerooting most of the mapping
    function does not need to be recalculated. 
    If the root is only moved one branch at a time, the mapping function
    needs to be recalculated only for the new root and one of its children.
    <p>
    This method always roots by minimizing the sum of duplication, followed
    by selection of the tree with minimal height. It always uses SDIse.
    <p>
    (In order to be able to write the returned Tree to a file,
    method Tree.adjustNodeCount() must be called on it.)
    <p>
    Conditions:
    <ul>
    <li> Both Trees must be completely binary (except deepest node of gene tree)
    <li> The species Tree must be rooted
    <li> Both Trees must have species names in the species name fields of their nodes
    <li> Both Trees must not have any collapses nodes
    </ul>
    <p>
    (Last modified: 06/12/01)

    @param gene_tree    a binary (except deepest node)
                        gene Tree
    @param species_tree a rooted binary species Tree

    @return a rooted Tree with duplication vs. speciation assigned

    */
    Tree fastInfer( Tree gene_tree, Tree species_tree ) throws Exception {

        SDIse    sdise                 = null;
        Tree     tree_to_return        = null,
                 species_tree_stripped = null;
        Node     prev_root             = null,
                 prev_root_c1          = null,
                 prev_root_c2          = null;
        Branch[] branches              = null;
        boolean  prev_root_was_dup     = false;
        double   height                = 0.0,
                 min_height            = Double.MAX_VALUE;
        int      j                     = 0,
                 duplications          = 0,
                 min_duplications      = Integer.MAX_VALUE;
        
        
        if ( gene_tree.getNumberOfExtNodes() <= 1 ) {
            gene_tree.setRooted( true );
            setMinimalDuplications( 0 );
            setMinimalTreeHeight( 0.0 );
            return gene_tree.copyTree();
        }

        species_tree_stripped = species_tree.copyTree();

        // Removes from species tree all species not found in gene Tree.
        SDI.stripTree( gene_tree, species_tree_stripped );

        gene_tree.reRootSkeleton( gene_tree.getExtNode0() );

        branches = getBranchesInOrder( gene_tree );
        if ( branches == null ) {
             throw new Exception( "fastInfer: Unexpected error: Failed to create array of branches." );
        }
       
        sdise = new SDIse( gene_tree, species_tree_stripped );

        sdise.infer( false ); // Stripping has already been done.

        for ( j = 0; j < branches.length ; ++j ) {
        
            prev_root         = gene_tree.getRoot(); 
            prev_root_c1      = prev_root.getChild1();
            prev_root_c2      = prev_root.getChild2();
            prev_root_was_dup = prev_root.isDuplication(); 

            gene_tree.reRootSkeleton( branches[ j ] );

            duplications = sdise.updateM( prev_root_was_dup,  
                                          prev_root_c1,
                                          prev_root_c2 );
            
            if ( duplications <= min_duplications ) {               
                height = moveRootOnBranchToMinHeight( gene_tree )[ 0 ];
                if ( duplications == min_duplications ) {
                    if ( height < min_height ) {
                        min_height     = height;
                        tree_to_return = gene_tree.copyTree();
                    }
                }
                else {
                    min_height       = height;
                    min_duplications = duplications;
                    tree_to_return   = gene_tree.copyTree();
                }
            }
        }

        setMinimalDuplications( min_duplications );
        setMinimalTreeHeight( min_height );
       
        return tree_to_return;

    } // fastInfer( Tree, Tree )
    


    // Places references to all Branches of Tree t into an array.
    // The order is similar to preorder. But branches are put into the
    // array twice: once on the way "forward" and once on the way
    // "back" (except branches connected to external nodes, which are
    // only put once).
    // Trees are treated as if they were unrooted (i.e. child 1 and
    // child 2 of the root are treated as if they were connected 
    // directly).
    // The resulting array allows to visit all branches without ever 
    // traversing more than one node at a time.
    // (Last modified: 09/29/01)  
    private Branch[] getBranchesInOrder( Tree t ) throws Exception {

        Node     node     = t.getRoot();
        Branch[] branches = null;
        int      i        = 0;

        if ( t == null || t.isEmpty() || t.getNumberOfExtNodes() <= 1 ) {
            return null;
        }
 
        if ( node.getChild1().isExternal() || node.getChild2().isExternal() ) {
            branches = new Branch[ 3 * t.getNumberOfExtNodes() - 5 ];
        }
        else {
            branches = new Branch[ 3 * t.getNumberOfExtNodes() - 6 ];
        }

        if ( t.getNumberOfExtNodes() == 2 ) {
            branches[ 0 ] = new Branch( t.getRoot().getChild1(), t.getRoot().getChild2() );
            return branches;
        }

        t.setIndicatorsToZero();

        while ( !node.isRoot() || node.getIndicator() != 2 ) {

            if ( !node.isExternal() && node.getIndicator() != 2 ) {

                if ( node.getIndicator() == 0 ) {
                    node.setIndicator( 1 );
                    node = node.getChild1();
                }
                else {
                    node.setIndicator( 2 );
                    node = node.getChild2();
                }

                if ( !node.getParent().isRoot() ) {
                    branches[ i++ ] = new Branch( node, node.getParent() );
                }
                else {
                    branches[ i++ ] = new Branch( t.getRoot().getChild1(), t.getRoot().getChild2() );
                }

            }
            else {
                if ( !node.getParent().isRoot() && !node.isExternal() ) {
                    branches[ i++ ] = new Branch( node, node.getParent() );
                }
                node = node.getParent();
            }
        } 

        return branches;

    } // getBranchesInOrder( Tree )



    // This places the root (of t) on its branch in such a way that it
    // minimizes the tree height as good as possible.
    // PRECONDITION: the root is placed at the midpoint of its branch.
    // Returns the height and the difference in heights of the resulting
    // modified Tree t.
    // (Last modified: 09/29/01) 
    private double[] moveRootOnBranchToMinHeight( Tree t ) throws Exception {
        Node     root        = t.getRoot(); 
        Node     child1      = root.getChild1(),
                 child2      = root.getChild2();
        double   d           = 0.0,
                 diff        = 0.0,
                 height      = 0.0;
        double[] height_diff = new double[ 2 ];

        if ( t == null || t.isEmpty() || t.getNumberOfExtNodes() <= 1 ) {
            return null;
        }

        d = child1.getDistanceToParent();

        if (  Math.abs( d - child2.getDistanceToParent() ) > ZERO_DIFF ) {
            throw new Exception( "Unexpected error: Root is not in the mid point of its branch." );
        }

        diff   = t.calculateRealHeight();
        height = t.getRealHeight();

        if ( d > 0.0 ) {

            if ( ( 2 * d ) > Math.abs( diff ) ) {
                child1.setDistanceToParent( d - ( diff / 2.0 ) );
                child2.setDistanceToParent( d + ( diff / 2.0 ) );
                height_diff[ 0 ] = height - Math.abs( diff / 2 );
                height_diff[ 1 ] = 0.0;
            }
            else {
                if ( diff > 0 ) {
                    child1.setDistanceToParent( 0.0 );
                    child2.setDistanceToParent( 2 * d );
                    height_diff[ 1 ] = diff - ( 2 * d );
                }
                else {
                    child1.setDistanceToParent( 2 * d );
                    child2.setDistanceToParent( 0.0 );
                    height_diff[ 1 ] = diff +  ( 2 * d );
                }
                height_diff[ 0 ] = height - d;
            }
        }
        else {
            height_diff[ 0 ] = height;
            height_diff[ 1 ] = diff;
        }
        return height_diff;

    } // moveRootOnBranchToMinHeight( Tree )



    private void setCount( int i ) {
        count_ = i;
    }



    private void setMinimalDuplications( int i ) {
        min_dup_ = i;
    }



    private void setMinimalMappingCost( int i ) {
        min_cost_ = i;
    }



    private void setMinimalTreeHeight( double d ) {
        min_height_ = d;
    }



    private void setMinimalDiffInSubTreeHeights( double d ) {
        min_diff_ = d;
    }



    /**

    Main method for this class.
    <p>
    (Last modified: 01/11/01)
    
    @param [args[0] -l to root by minimizing mapping cost L]
    @param [args[0] -d to root by minimizing sum of duplications]
    @param [args[0] -h to root by minimizing tree height]
    @param [args[0] -x use fast infer, always minimizes sum of duplications|height]
    @param [args[0] -n input trees are in New Hampshire format instead
                       of NHX; or gene tree is in NHX, but species
                       information in gene tree is only  present in the
                       form of SWISS-PROT sequence names]
    @param args[0or1]  species tree file name (in NHX format with
                       species names in species name fields;
                       unless -n option is used)
    @param args[1or2]  gene tree file name (in NHX format with
                       species names in species name fields and sequence names
                       in sequence name fields; unless -n option is used)

    */
    public static void main( String args[] ) {



        boolean minimize_cost       = false,
                minimize_sum_of_dup = false,
                minimize_height     = false,
                nh                  = false,
                fast_infer          = false;

        int     r                   = 0;

        File    species_tree_file   = null,
                gene_tree_file      = null;

        Tree    gene_tree           = null,
                species_tree        = null;

        Tree[]  trees               = null;

        SDIunrooted sdiunrooted     = new SDIunrooted();

        java.text.DecimalFormat df = new java.text.DecimalFormat( "0.0#####" );
        df.setDecimalSeparatorAlwaysShown( true );


        if ( args.length < 2 || args.length > 3 ) {
            errorInCommandLine();
        }
        if ( args[ 0 ].startsWith( "-" ) ) {
            if ( args.length < 3 ) {
                errorInCommandLine();
            }
            if ( args[ 0 ].toLowerCase().indexOf( "l" ) != -1 ) {
                minimize_cost       = true;
            }
            if ( args[ 0 ].toLowerCase().indexOf( "d" ) != -1 ) {
                minimize_sum_of_dup = true;
            }
            if ( args[ 0 ].toLowerCase().indexOf( "h" ) != -1 ) {
                minimize_height     = true;
            }
            if ( args[ 0 ].toLowerCase().indexOf( "x" ) != -1 ) {
                fast_infer          = true;
            }
            if ( args[ 0 ].toLowerCase().indexOf( "n" ) != -1 ) {
                nh                  = true;
            }
            species_tree_file = new File( args[ 1 ] );
            gene_tree_file    = new File( args[ 2 ] );
        }
        else {
            if ( args.length > 2 ) {
                errorInCommandLine();
            }
            species_tree_file = new File( args[ 0 ] );
            gene_tree_file    = new File( args[ 1 ] );
        }

        if ( minimize_cost && minimize_sum_of_dup ) {
            minimize_sum_of_dup = false;
        }
        if ( fast_infer ) {
            minimize_sum_of_dup = true;
            minimize_height     = true;
            minimize_cost       = false;
        }

        try {
            gene_tree = TreeHelper.readNHtree( gene_tree_file );
        }
        catch ( Exception e ) {
	        System.err.println( "\nFailed to read " + gene_tree_file + ". Terminating.\n" );
	        System.exit( -1 );
	    }

        try {
            species_tree = TreeHelper.readNHtree( species_tree_file );
        }
        catch ( Exception e ) {
	        System.err.println( "\nFailed to read " + species_tree_file + ". Terminating.\n" );
	        System.exit( -1 );
	    }

        if ( nh ) {
            TreeHelper.extractSpeciesNameFromSeqName( species_tree );
            TreeHelper.extractSpeciesNameFromSeqName( gene_tree );
        }

        TreeHelper.cleanSpeciesNamesInExtNodes( species_tree );

        if ( !minimize_cost && !minimize_sum_of_dup && !minimize_height ) {
            // In this case.... the gene tree must be rooted.
            gene_tree.setRooted( true );
        }

        // Removes from gene_tree all species not found in species_tree.
        r = SDI.stripTree( species_tree, gene_tree );
        System.out.println( "\nRemoved " + r + " external nodes from gene tree.\n" );

        try {
            if ( fast_infer ) {
                trees = new Tree[ 1 ];
                trees[ 0 ] = sdiunrooted.fastInfer( gene_tree.copyTree(),
                                                    species_tree );
                trees[ 0 ].adjustNodeCount( false );
            }
            else {
                trees = sdiunrooted.infer( gene_tree,
                                           species_tree,
                                           minimize_cost,
                                           minimize_sum_of_dup,
                                           minimize_height,
                                           true,
                                           TREES_TO_RETURN );
            }
        }
        catch ( Exception e ) {
	        System.err.println( "Unexpected error during calculation of duplications." );
            System.err.println( "Stack trace: " );
            e.printStackTrace();
	        System.exit( -1 );
	    }

        System.out.println( "" );
        if ( fast_infer ) {
            System.out.println( "Used fast infer." );
        }
        if ( minimize_cost ) {
            System.out.println( "Rooted by minimizing mapping cost L." );
            if ( minimize_height ) {
                System.out.println( "Selected tree(s) with minimal height out of resulting trees." );
            }
            System.out.println( "Number differently rooted trees minimizing criterion  : "
            + sdiunrooted.getCount() );
            System.out.println( "Minimal cost                                          : "
            + sdiunrooted.getMinimalMappingCost() );
            System.out.println( "Minimal duplications                                  : "
            + sdiunrooted.getMinimalDuplications() );
            if ( minimize_height ) {
                System.out.println( "Tree height                                           : "
                + df.format( sdiunrooted.getMinimalTreeHeight() ) );
                System.out.println( "Difference in subtree heights                         : "
                + df.format( sdiunrooted.getMinimalDiffInSubTreeHeights() ) );
            }

            System.out.println( "" );
        }
        else if ( minimize_sum_of_dup ) {
            System.out.println( "Rooted by minimizing sum of duplications." );
            if ( minimize_height ) {
                System.out.println( "Selected tree(s) with minimal height out of resulting trees." );
            }
            if ( !fast_infer ) {
                System.out.println( "Number differently rooted trees minimizing criterion        : "
                + sdiunrooted.getCount() );
            }
            System.out.println( "Minimal duplications                                        : "
            + sdiunrooted.getMinimalDuplications() );
            if ( minimize_height ) {
                System.out.println( "Tree height                                                 : "
                + df.format( sdiunrooted.getMinimalTreeHeight() ) );
                if ( !fast_infer ) {
                    System.out.println( "Difference in subtree heights                               : "
                    + df.format( sdiunrooted.getMinimalDiffInSubTreeHeights() ) );
                }
            }
            System.out.println( "" );
        }
        else if ( minimize_height ) {
            System.out.println( "Rooted by minimizing tree height (midpoint rooting)." );
            System.out.println( "Minimal tree height                  : "
            + df.format( sdiunrooted.getMinimalTreeHeight() ) );
            System.out.println( "Minimal difference in subtree heights: "
            + df.format( sdiunrooted.getMinimalDiffInSubTreeHeights() ) );
            System.out.println( "Duplications in midpoint rooted tree : "
            + sdiunrooted.getMinimalDuplications() );
            System.out.println( "" );
        }
        else {
            System.out.println( "No (re) rooting was performed." );
            System.out.println( "Duplications in tree: "
            + sdiunrooted.getMinimalDuplications() );
            System.out.println( "" );
        }

        ATVjframe[] atvframes = new ATVjframe[ trees.length ];

        for ( int i = 0; i < trees.length; ++i ) {
            atvframes[ i ] = new ATVjframe( trees[ i ] );
            atvframes[ i ].setTitle( "gene tree " + i );
            atvframes[ i ].showWhole();
        }

        ATVjframe atvframe_og = new ATVjframe( gene_tree );
        atvframe_og.setTitle( "original gene tree" );
        atvframe_og.showWhole();

    } // main ( String )



    private static void errorInCommandLine() {
        System.out.println( "\nSDIunrooted: Error in command line.\n" );
        System.out.println( "Usage: \"SDIunrooted  [-options] <species tree file name> <gene tree file name>\"" );
        System.out.println( "\nOptions:" );
        System.out.println( " -n input trees are in New Hampshire format instead of NHX -- or" );
        System.out.println( "    the gene tree is in NHX, but species information is" );
        System.out.println( "    only present in the form of SWISS-PROT sequence names" );
        System.out.println( " -l to root by minimizing the mapping cost L (and also the sum of duplications)" );
        System.out.println( " -d to root by minimizing the sum of duplications" );
        System.out.println( " -h to root by minimizing tree height (can be used together with -l or -d)" );
        System.out.println( " -x use fast infer, always minimizes sum of duplications|height" );

        System.out.println( "\nSpecies tree file" );
        System.out.println( " In NHX format, with species names in species name fields; unless -n option" );
        System.out.println( " is used." );
        System.out.println( "\nGene tree file" );
        System.out.println( " In NHX format, with species names in species name fields and sequence names" );
        System.out.println( " in sequence name fields; unless -n option is used." );
        System.out.println( "" );
        System.exit( -1 );
    } // errorInCommandLine()

} // End of class SDIunrooted.



