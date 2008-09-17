// SDIse.java
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

import java.util.HashMap;      // Requires JDK 1.2 or greater.



/**

Implements our algorithm for speciation - duplication inference (SDI).

<p>
Reference:
</p>
<ul>
<li>
Zmasek, C.M. and Eddy, S.R. (2001) "A simple algorithm to infer gene duplication 
and speciation events on a gene tree". Bioinformatics, in press.
</ul>

<p>
The initialization is accomplished by:
</p>
<ul>
<li>
method "linkExtNodesOfG()" of class SDI: setting the links for
the external nodes of the gene tree
<li>
"preorderReID(int)" from class Tree: numbering of nodes of the species tree
in preorder
<li>
the optional stripping of the species tree is accomplished by
method "stripTree(Tree,Tree)" of class Tree
</ul>

<p>
The recursion part is accomplished by this class' method
"geneTreePostOrderTraversal(Node)".

<p>
Requires JDK 1.2 or greater.

@see SDI#linkExtNodesOfG()
@see Tree#preorderReID(int)
@see SDI#stripTree(Tree,Tree)
@see #geneTreePostOrderTraversal(Node)

@author Christian M. Zmasek

@version 1.102 -- last modified: 10/02/01

*/
public class SDIse extends SDI {
    


    /**

    Constructor which sets the gene tree and the species tree to be
    compared. species_tree is the species tree to which the gene
    tree gene_tree will be compared to - with method "infer(boolean)".
    Both Trees must be completely binary and rooted.
    The actual inference is accomplished with method "infer(boolean)".
    The mapping cost L can then be calculated with method "computeMappingCost()".
    <p>
    (Last modified: 01/11/01)

    @see #infer(boolean)
    @see SDI#computeMappingCost()

    @param gene_tree    reference to a rooted binary gene Tree to which assign
                        duplication vs speciation, must have species names in 
                        the species name fields for all external nodes 
    @param species_tree reference to a rooted binary species Tree which might
                        get stripped in the process, must have species names in 
                        the species name fields for all external nodes 

    */
    public SDIse( Tree gene_tree, Tree species_tree ) throws Exception {

        super( gene_tree, species_tree );

    } // SDIse( Tree, Tree ) 


    
    /**
    
    Infers for each Node of gene_tree (set in constructor) whether it
    represents a speciation or duplication event by calculating 
    and interpreting the mapping function M. The most parsimonious
    sequence of speciation and duplication events is assumed.
    <p>
    (Last modified: 01/11/01)

    @see #SDIse(Tree,Tree)

    @param strip_species_tree set to true to remove from the species tree 
                              species not found in the gene tree prior
                              to analysis (optional)

    @return number of duplications which have been assigned in gene_tree

    */
    public int infer( boolean strip_species_tree ) throws Exception {
        
        setDuplicationsToZero();
        
        if ( strip_species_tree ) {
            stripTree( getGeneTree(), getSpeciesTree() );
        }
      
        getSpeciesTree().preorderReID( 0 );
        
        linkExtNodesOfG();
       
        geneTreePostOrderTraversal( getGeneTree().getRoot() );
       
        return getDuplications();

    } // infer( boolean )

    

    /**

    Traverses the subtree of Node g in postorder, calculating the
    mapping function M, and determines which nodes
    represent speciation events and which ones duplication
    events.
    <p>
    Preconditions: Mapping M for external nodes must have been calculated
    and the species tree must be labelled in preorder.
    <p>
    (Last modified: 01/11/01)

    @param g starting node of a gene tree - normally the root

    */
    void geneTreePostOrderTraversal( Node g ) {

        Node a, b;

        if ( !g.isExternal() ) {

            geneTreePostOrderTraversal( g.getChild1() );
            geneTreePostOrderTraversal( g.getChild2() );

            a = g.getChild1().getLink();
            b = g.getChild2().getLink();

            while ( a != b ) {
                if ( a.getID() > b.getID() ) {
                    a = a.getParent();
                }
                else {
                    b = b.getParent();
                }
            }
            g.setLink( a );
            
            // Determines whether dup. or spec.
            g.setDuplicationOrSpecAssigned( true );

            if ( a == g.getChild1().getLink()
            ||   a == g.getChild2().getLink() ) {
                g.setDuplication( true );
                increaseDuplications();
            }
            else {
                g.setDuplication( false );
            }
        }

    } // geneTreePostOrderTraversal( Node )



    /**

    Updates the mapping function M after the root of the gene tree has
    been moved by one branch.
    It calculates M for the root of the gene tree and one of its two children.
    <p>
    To be used ONLY by method "SDIunrooted.fastInfer(Tree,Tree)".
    <p>
    (Last modfied: 10/02/01)

    @param prev_root_was_dup true if the previous root was a duplication,
                             false otherwise
    @param prev_root_c1 child 1 of the previous root
    @param prev_root_c2 child 2 of the previous root


    @return number of duplications which have been assigned in gene tree

    */
    int updateM( boolean prev_root_was_dup, 
                 Node    prev_root_c1, 
                 Node    prev_root_c2 ) {
       
        Node root = getGeneTree().getRoot();

        if ( root.getChild1() == prev_root_c1 
        ||   root.getChild2() == prev_root_c1 ) {
            calculateMforNode( prev_root_c1 );
        }
        else {
            calculateMforNode( prev_root_c2 );
        }

        root.setDuplication( prev_root_was_dup );

        calculateMforNode( root );

        return getDuplications();

    } // updateM( boolean, Node, Node )



    // Helper method for updateM( boolean, Node, Node )
    // Calculates M for Node n, given that M for the two children
    // of n has been calculated.
    // (Last modified: 10/02/01)
    private void calculateMforNode( Node n ) { 
       
        if ( !n.isExternal() ) {

            boolean was_duplication = n.isDuplication();
            Node    a               = n.getChild1().getLink(),
                    b               = n.getChild2().getLink();

            while ( a != b ) {
                if ( a.getID() > b.getID() ) {
                    a = a.getParent();
                }
                else {
                    b = b.getParent();
                }
            }

            n.setLink( a );

            if ( a == n.getChild1().getLink()
            ||   a == n.getChild2().getLink() ) {
                n.setDuplication( true );
                if ( !was_duplication ) {
                    increaseDuplications();
                }
            }
            else {
                n.setDuplication( false );
                if ( was_duplication ) {
                    decreaseDuplications();
                }
            }
        }

    } // calculateMforNode( Node )


    
} // End of class SDIse.
