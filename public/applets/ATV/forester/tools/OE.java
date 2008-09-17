// OE.java
// Speciation versus duplication inference with Oliver Eulenstein's
// algorithm
//
// Copyright (C) 2000-2002 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved
//
// Created: 2000
// Author: Christian M. Zmasek
// zmasek@genetics.wustl.edu
// http://www.genetics.wustl.edu/eddy/people/zmasek/

// Implements Oliver Eulenstein's algorithm for speciation - duplication inference.
// References:
// Oliver Eulenstein (1998) "Vorhersage von Genduplikationen und
// deren Entwicklung in der Evolution"
// GMD Research Series, No 20/1998
// GMD - Forschungszentrum Informationstechnik GmbH. - Sankt Augustin
// (http://www.gmd.de/publications/research/1998/020/)
// Oliver Eulenstein (1996) "A linear time algorithm for tree mapping"
// Arbeitspapiere der GMD No. 1046, St Augustine, Germany


// Requires JDK 1.2 or greater.


package forester.tools;


import forester.tree.*;
import forester.datastructures.BasketDataStructure;

import java.util.HashMap;    // Requires JDK 1.2 or greater.
import java.util.Vector;



/**

Implements Oliver Eulenstein's algorithm for speciation - duplication inference.

<p>
References:
</p>
<ul>
<li>
Oliver Eulenstein (1998) "Vorhersage von Genduplikationen und 
deren Entwicklung in der Evolution" GMD Research Series, No 20/1998, 
GMD - Forschungszentrum Informationstechnik GmbH. - Sankt Augustin. 
http://www.gmd.de/publications/research/1998/020/
<li>
Oliver Eulenstein (1996) "A linear time algorithm for tree mapping" 
Arbeitspapiere der GMD No. 1046, St Augustine, Germany.
</ul>

<p>
The initialization is accomplished by:
</p>
<ul>
<li>
"stripTree(Tree,Tree)" of class SDI: stripping of the species tree
<li>
"preorderReID(int)" of class Tree: numbering of nodes of species and gene tree in preorder
<li>
"hashIDs()" of class Tree: Enables nodes to be retrieved in constant time, given their ID number
<li>
"setIndicatorsToZero()" of class Tree: Initializing indicators
<li>
"linkExtNodesOfS()" of this class: Setting the links for the external nodes of the species tree
</ul>

<p>
The recursion part is accomplished by method "DFS(Node)" of this class

<p>
Duplication and speciations are determined by "determine(Node)" of this class.

<p>
Requires JDK 1.2 or greater.

@see SDI#stripTree(Tree,Tree)
@see Tree#preorderReID(int)
@see Tree#hashIDs()
@see Tree#setIndicatorsToZero()
@see #linkExtNodesOfS()
@see #DFS(Node)
@see #determine(Node)


@author Christian M. Zmasek

@version 1.012 -- last modified: 10/02/01

*/
public class OE extends SDI {


    private BasketDataStructure b;


    /**

    Constructor which sets the gene tree and the species tree to be
    compared. species_tree is the species tree to which the gene
    tree gene_tree will be compared to - with method "infer(boolean)".
    Both Trees must be completely binary and rooted.
    The actual inference is accomplished with method "infer(boolean)".
    The mapping cost L can then be calculated with method "computeMappingCost()".
    <br>
    (Last modified: 01/11/01)
    <br>

    @see #infer(boolean)
    @see #computeMappingCost()

    @param gene_tree    reference to a rooted binary gene Tree to which assign
                        duplication vs speciation, must have species names in 
                        the species name fields for all external nodes 
    @param species_tree reference to a rooted binary species Tree which might
                        get stripped in the process, must have species names in 
                        the species name fields for all external nodes 

    */
    public OE( Tree gene_tree, Tree species_tree ) throws Exception {

        super( gene_tree, species_tree );

    }



    /**

    Infers for each Node of gene_tree (set in constructor) whether it
    represents a speciation or duplication event by calculating 
    and interpreting the mapping function M. The most parsimonious
    sequence of speciation and duplication events is assumed.
    <p>
    The species tree MUST NOT contain species not found in the gene tree.
    If it does, set strip_species_tree to true.
    <p>
    (Last modified: 01/11/01)
    <br>

    @param strip_species_tree set to true if species are present in the
                              species tree which are not in the gene tree
                              (not optional!)

    @return number of duplications which have been assigned in gene_tree

    */
    public int infer( boolean strip_species_tree ) throws Exception {
       
        setDuplicationsToZero();

        if ( strip_species_tree ) {
            stripTree( getGeneTree(), getSpeciesTree() );
        }
        
        int x = getSpeciesTree().preorderReID( 0 );
        
        getGeneTree().preorderReID( x );
        
        // Enables nodes to be retrieved in constant time,
        // given their ID number -- would not be necessary if
        // Tree were based on a array instead of a dynamic
        // datastructure.
        getSpeciesTree().hashIDs();
        
        getGeneTree().setIndicatorsToZero();
        
        linkExtNodesOfS();

        b = new BasketDataStructure( getGeneTree().getNumberOfExtNodes() * 2  
                                     + getSpeciesTree().getNumberOfExtNodes() * 2 - 2 );

        DFS( getSpeciesTree().getRoot() );
 
        determine( getGeneTree().getRoot() );
        
        return getDuplications();

    }


    
    /**

    Computes the cost of mapping the gene tree gene_tree onto the
    species tree species_tree. Before this method can be called,
    the mapping has to be calculated with method "infer(boolean)".
    <p>
    Overrides the method of the base class, since additionaly the
    links for the gene tree have to be calculated first.
    <p>
    Reference. Zhang, L. (1997) On a Mirkin-Muchnik-Smith Conjecture
    for Comparing Molecular Phylogenies. Journal of Computational
    Biology 4 177-187.
    <p>
    (Last modified: 11/07/00)
    <br>

    @return the mapping cost "L"

    */
    public int computeMappingCost() throws Exception {

        linkExtNodesOfG();
        
        return super.computeMappingCost();

    }




    /**

    Traverses the species tree in postorder. Creates Baskets for
    each external node.
    <p>
    (Last modified: 01/11/01)
    <br>

    */
    void DFS( Node s ) {

        Vector nodevector = null;

        if ( !s.isExternal() ) {
            DFS( s.getChild1() );
            b.moveBasket( s.getChild1().getID(), s.getID() );
            DFS( s.getChild2() );
            b.mergeBasket( s.getChild2().getID(), s.getID() );
        }
        else {
            nodevector = s.getVector();
            
            for ( int i = 0; i < nodevector.size(); ++i ) {
                Node n = ( Node ) nodevector.elementAt( i );
                b.createBasket( n.getID(), s.getID() );
                geneTreeWalk( n );
            }
        }
    }



    // Called by DFS(Node).
    private void geneTreeWalk( Node g ) {
     
        int species1,
            species2;

        while ( !g.isRoot() && g.getParent().getIndicator() == 1 ) {
        
            g = g.getParent();
           
            species1 = b.findBasket( g.getChild1().getID() );
            species2 = b.findBasket( g.getChild2().getID() );
            
            if ( species1 < species2 ) {
                g.setLink( getSpeciesTree().getNode( species1 ) );
            }      
            else {
                g.setLink( getSpeciesTree().getNode( species2 ) );
            }
            
            b.insertIntoBasket( g.getID(), g.getLink().getID() );
        }

        if ( !g.isRoot() ) {
            g.getParent().setIndicator( 1 );
        }
    }



    /**

    Links each external Node of the species tree to the all external
    nodes of the gene tree which have the same species name.
    <p>
    The matching Nodes of the gene tree are placed in a Vector associated with
    each external Nodes of the species tree. This is necessary in order to deal
    with redundant species in the gene tree and is not part of the algorithm
    as described in Eulenstein (1998), but it is mentioned in Eulenstein (1996). 
    <p>
    (Last modified: 01/11/01)
    <br>

    */
    void linkExtNodesOfS() throws Exception {

        Node s = getSpeciesTree().getExtNode0(),
             g = getGeneTree().getExtNode0();

        String name       = null;
        Vector nodevector = null;          


        HashMap genetree_ext_nodes = new HashMap();  

        // Put references to all external Nodes of Tree genetree into HashMap.
        // Species name is the key, Vector of Nodes is the value.
        while ( g != null ) {
            name = g.getSpecies();
            if ( !genetree_ext_nodes.containsKey( name ) ) {
                nodevector = new Vector();
                nodevector.addElement( g );
                genetree_ext_nodes.put( name, nodevector );
            }
            else {
                ( ( Vector ) genetree_ext_nodes.get( name ) ).addElement( g );
            }
            g = g.getNextExtNode();
        }

        // Retrieve the reference to the Node with a matching species name.
        while ( s != null ) {

            nodevector = ( Vector ) genetree_ext_nodes.get( s.getSpecies() );

            if ( nodevector == null ) {
                String message  = "SDI: species \"" + s.getSpecies();
                       message += "\" not present in Tree genetree.";
                throw new Exception( message );
            }

            s.setVector( nodevector );
            
            s = s.getNextExtNode();
        }

    }



    /**

    Determines which nodes of the subtree of gene tree node g represent
    duplications and which ones speciations.
    <p>
    Precondition: Mapping function M for all nodes of the gene tree
    must have been calculated.
    <p>
    (Last modified: 01/11/01)
    <br>

    @param g starting node of a gene tree - normally the root

    */
    void determine( Node g ) {

        if ( !g.isExternal() ) {

            determine( g.getChild1() );
            determine( g.getChild2() );

            g.setDuplicationOrSpecAssigned( true );

            if ( g.getChild1().isExternal()
            &&   g.getChild2().isExternal()
            &&   g.getChild1().getSpecies().equals(
                 g.getChild2().getSpecies() ) ) { 
                 g.setDuplication( true );
                increaseDuplications();
            }
            else if ( g.getLink() == g.getChild1().getLink()
            ||        g.getLink() == g.getChild2().getLink() ) {
                g.setDuplication( true );
                increaseDuplications();
            }
            else {
                g.setDuplication( false );
            }
        }
    }


    
} // End of class OE.
