// DistanceCalculator.java
// Can be used to calculate mean and standard deviation
// of distances from internal nodes to external nodes, as well as the distance
// of individual external nodes to internal nodes.
//
// Copyright (C) 2000-2001 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved
//
// Created: 11/30/00
// Author: Christian M. Zmasek
// zmasek@genetics.wustl.edu
// http://www.genetics.wustl.edu/eddy/people/zmasek/



// Requires JDK 1.2 or greater.


package forester.tools;


import forester.tree.*;

import java.io.*;
import java.util.Vector;
import java.util.ArrayList;
import java.util.ListIterator;



/**

@author Christian M. Zmasek

@version 1.001 -- last modified: 12/04/00

*/
public class DistanceCalculator {

    public final static double DEFAULT = -1.0;
   
    private Tree      tree_;
    private ArrayList nodes_;
    private int       n_;
    private double    mean_,
                      variance_,
                      stand_dev_;
    private Node      lca_; // The LCA of the Nodes in nodes_ 

   

    /**
    
    Default constructor.
    (Last modified: 11/30/00)

    */
    public DistanceCalculator() {

        tree_       = null;
        nodes_      = null;
        n_          = 0;
        mean_       = DEFAULT;
        variance_   = DEFAULT;
        stand_dev_  = DEFAULT;
        lca_        = null;

    }


 
    /**
        
    Constructor. Sets the rooted Tree t for which
    the mean distance to the root and its variance
    and standard deviation are calculated.
    (Last modified: 12/01/00)

    @param t the rooted Tree for which the mean distance
             to the root and its variance and standard
             deviation are calculated
 
    */
    public DistanceCalculator( Tree t ) {

       setTree( t ); 
        
    }



    /**
    
    Constructor. Sets the rooted Tree t and the external Nodes ext_nodes for
    which the mean distance to their lowest common ancestor and its variance
    and standard deviation are calculated.
    (Last modified: 12/01/00)

    @param t the rooted Tree containing Nodes in Vector ext_nodes
    @param ext_nodes a Vector of Nodes of t, the mean distance
                     to their lowest common ancestor and its variance
                     and standard deviation are calculated      
   

    */
    public DistanceCalculator( Tree t, Vector ext_nodes ) {

        setTreeAndExtNodes( t, ext_nodes );
        
    }



    /**

    Sets the rooted Tree t for which
    the mean distance to the root and its variance
    and standard deviation are calculated.
    (Last modified: 12/01/00)

    @param t the rooted Tree for which the mean distance
             to the root and its variance and standard
             deviation are calculated

    */
    public void setTree( Tree t ) {
        tree_       = t;
        nodes_      = null;
        n_          = 0;
        mean_       = DEFAULT;
        variance_   = DEFAULT;
        stand_dev_  = DEFAULT;
        lca_        = null;
        calculateMeanDistToRoot();
        calculateVarianceDistToRoot();
        calculateStandardDeviation();
    }



    /**
    
    Sets the rooted Tree t and the external Nodes ext_nodes for which
    the mean distance to their lowest common ancestor and its variance
    and standard deviation are calculated.
    (Last modified: 12/03/00)

    @param t the rooted Tree containing Nodes in Vector ext_nodes
    @param ext_nodes a Vector of Nodes of t, the mean distance
                     to their lowest common ancestor and its variance
                     and standard deviation are calculated    

    */
    public void setTreeAndExtNodes( Tree t, Vector ext_nodes ) {
        setTreeAndExtNodes( t, new ArrayList( ext_nodes ) );
    }



    /**
    
    Sets the rooted Tree t and the external Nodes ext_nodes for which
    the mean distance to their lowest common ancestor and its variance
    and standard deviation are calculated.
    (Last modified: 12/03/00)

    @param t the rooted Tree containing Nodes in Vector ext_nodes
    @param ext_nodes a ArrayList of Nodes of t, the mean distance
                     to their lowest common ancestor and its variance
                     and standard deviation are calculated    

    */
    public void setTreeAndExtNodes( Tree t, ArrayList ext_nodes ) {
        tree_      = t;
        nodes_     = ext_nodes;
        n_         = 0;
        mean_      = DEFAULT;
        variance_  = DEFAULT;
        stand_dev_ = DEFAULT;
        lca_       = calculateLCA( nodes_ );
        calculateMean();
        calculateVariance();
        calculateStandardDeviation();
    }



    /**
   
    Calculates the distance of Node n to the root of Tree t which
    has been set either with a constructor, setTree(Tree), or 
    setTreeAndExtNodes(Tree,Vector).
    (Last modified: 12/01/00)
    
    @param n the Node for which the distance to the root is to be
             calculated 

    @return distance of Node n to the root

    @see #DistanceCalculator(Tree)
    @see #DistanceCalculator(Tree,Vector)
    @see #setTree(Tree)
    @see #setTreeAndExtNodes(Tree,Vector) 

    */
    public double getDistanceToRoot( Node n ) {

        if ( tree_ == null || tree_.isEmpty() ) {
            return 0.0;
        }
        double d = 0.0;
        try {
            d = getDistanceToNode( n, tree_.getRoot() );
        }
        catch ( Exception e ) {
            System.err.println( "getDistanceToRoot(Node): Unexpected "
                                + "exception: " + e );
            System.exit( -1 );
        }

        return d;
    }



    /**
   
    Calculates the distance of Node outer to Node inner. Node inner
    must be closer to the root than Node outer and on the same "path".
    (Last modified: 12/01/00)

    @param outer a Node
    @param inner a Node closer to the root than outer

    @return distance of Node outer to Node inner

    */
    public double getDistanceToNode( Node outer,
                                     Node inner )
    throws Exception {

        double d    = 0.0,
               dist = 0.0;

        while ( inner != outer && !outer.isRoot() ) {
            if ( !outer.isPseudoNode() ) {
                d = outer.getDistanceToParent();
                if ( d > 0.0 ) {
                    dist += d;
                }
            }
            outer = outer.getParent();
        }

        if ( !inner.isRoot() && outer.isRoot() ) {
            throw new Exception( "getDistanceToNode(Node outer,Node inner): " +
            "Node inner is not closer to the root than Node outer " +
            "or is not on the same \"subtree\"" );
        } 

        return dist;

    }



    /**
   
    Calculates the distance of the Node with seq name seq_name 
    to the root of Tree t, which has been set either with a
    constructor, setTree(Tree), or setTreeAndExtNodes(Tree,Vector).
    Throws an exception if no Node with seq name_seq name is found or if
    seq_name is not unique.
    (Last modified: 12/01/00)
    
    @param seq_name the seq name for the Node for which the distance
                    to the root is to be calculated 
    
    @return distance of Node with seq name seq_name to the root

    @see #DistanceCalculator(Tree)
    @see #DistanceCalculator(Tree,Vector)
    @see #setTree(Tree)
    @see #setTreeAndExtNodes(Tree,Vector)
    @see #setTreeAndExtNodes(Tree,ArrayList)

    */
    public double getDistanceToRoot( String seq_name )
    throws Exception {
        
        if ( tree_ == null || tree_.isEmpty() ) {
            return 0.0;
        }

        return getDistanceToNode( seq_name, tree_.getRoot() );
    }



    /**
   
    Calculates the distance of the Node with seq name seq_name 
    to the LCA of ext_nodes, which has been set either with
    constructor DistanceCalculator(Tree,Vector) or method 
    setTreeAndExtNodes(Tree,Vector).
    Throws an exception if no Node with seq name_seq name is found or if
    seq_name is not unique.
    (Last modified: 12/03/00)
    
    @param seq_name the seq name for the Node for which the distance
                    to the LCA is to be calculated 
    
    @return distance of Node with seq name seq_name to the LCA of
            Nodes in ext_nodes    
   
    @see #DistanceCalculator(Tree,Vector)
    @see #setTreeAndExtNodes(Tree,Vector)
    @see #setTreeAndExtNodes(Tree,ArrayList)

    */
    public double getDistanceToLCA( String seq_name )
    throws Exception {
        
        if ( tree_ == null || tree_.isEmpty() || lca_ == null ) {
            return 0.0;
        }

        return getDistanceToNode( seq_name, lca_ );
    }



    /**

    Calculates the distance of the Node with seq name seq_name to Node inner.
    Node inner must be closer to the root than the Node with seq name seq_name
    and on the same "path".
    Throws an exception if no Node with seq name_seq name is found or if
    seq_name is not unique.
    (Last modified: 12/01/00)

    @param seq_name the seq name of a Node further from the root than
                    Node inner
    @param inner    a Node

    @return distance of Node with seq name seq_nam to Node inner

    */
    public double getDistanceToNode( String seq_name, Node inner )
    throws Exception {

        if ( tree_ == null || tree_.isEmpty() ) {
            return 0.0;
        }

        return getDistanceToNode( tree_.getNode( seq_name ), inner );

    }



    /**

    Returns the mean distance.
    If constructor DistanceCalculator(Tree) or method setTree(Tree)
    have been used, it is the mean of the distances from the root
    to all external Nodes.
    If constructor DistanceCalculator(Tree,Vector) or method
    setTreeAndExtNodes(Tree,Vector) have been used, it is the mean
    of the distances from the external nodes ext_nodes to their lowest
    common ancestor.
    (Last modified: 11/30/00)

    @return mean distance

    @see #DistanceCalculator(Tree)
    @see #DistanceCalculator(Tree,Vector)
    @see #setTree(Tree)
    @see #setTreeAndExtNodes(Tree,Vector)
    @see #setTreeAndExtNodes(Tree,ArrayList)

    */
    public double getMean() {
        return mean_;
    }



    /**

    Returns the variance.
    ( 1/(N - 1) * Sum((x-mean)^2) )
    If constructor DistanceCalculator(Tree) or method setTree(Tree)
    have been used, it is the variance of the distances from the root
    to all external Nodes.
    If constructor DistanceCalculator(Tree,Vector) or method
    setTreeAndExtNodes(Tree,Vector) have been used, it is the variance
    of the distances from the external nodes ext_nodes to their lowest
    common ancestor.
    (Last modified: 11/30/00)

    @return variance

    @see #DistanceCalculator(Tree)
    @see #DistanceCalculator(Tree,Vector)
    @see #setTree(Tree)
    @see #setTreeAndExtNodes(Tree,Vector)
    @see #setTreeAndExtNodes(Tree,ArrayList)

    */
    public double getVariance() {
        return variance_;
    }



    /**

    Returns the standard deviation.
    If constructor DistanceCalculator(Tree) or method setTree(Tree)
    have been used, it is the standard deviation of the distances from
    the root to all external Nodes.
    If constructor DistanceCalculator(Tree,Vector) or method
    setTreeAndExtNodes(Tree,Vector) have been used, it is the
    standard deviation of the distances from the external nodes
    ext_nodes to their lowest common ancestor.
    (Last modified: 11/30/00)

    @return standard deviation

    @see #DistanceCalculator(Tree)
    @see #DistanceCalculator(Tree,Vector)
    @see #setTree(Tree)
    @see #setTreeAndExtNodes(Tree,Vector)
    @see #setTreeAndExtNodes(Tree,ArrayList)

    */
    public double getStandardDeviation() {
        return stand_dev_;
    }



    /**
 
    Returns the sum of all Nodes used to calculate the mean.
    (Last modified: 12/01/00)

    @return n

    */
    public int getN() {
        return n_;
    }



    // (Last modified: 11/30/00)
    private void calculateMeanDistToRoot() {

        if ( tree_ == null || tree_.isEmpty() ) {
            return;
        }

        double sum  = 0.0;
        Node   node = tree_.getExtNode0();
            
        n_   = 0;
   
        while ( node != null ) {
            n_++;
            sum += getDistanceToRoot( node );
            node = node.getNextExtNode();
        }

        setMean( sum / n_ );

    }



    // (Last modified: 11/31/00)
    private void calculateMean() {

        if ( nodes_ == null || nodes_.isEmpty()
        || tree_ == null || tree_.isEmpty() ) {
            return;
        }

        double       sum  = 0.0;
        ListIterator li   = nodes_.listIterator();

        n_ = 0;

        try {
            while ( li.hasNext() ) {
                n_++;
                sum += getDistanceToNode( ( Node ) li.next(), lca_ );
            }
        }
        catch ( Exception e ) {
            System.err.println( "calculateMean(): "
                                + "Exception: " + e );
            System.exit( -1 );
        }

        setMean( sum / n_ );

    }



    // (Last modified: 11/31/00)
    private void calculateVarianceDistToRoot() {

        if ( getMean() == DEFAULT
        || tree_ == null || tree_.isEmpty() || n_ <= 1.0 ) {
            return;
        }

        double x    = 0.0,
               sum  = 0.0; 
        Node   node = tree_.getExtNode0();
        
        while ( node != null ) {
            x = getDistanceToRoot( node ) - getMean();
            sum += ( x * x );
            node = node.getNextExtNode();
        }    
        
        setVariance( sum / ( n_ - 1 ) );

    }



    // (Last modified: 11/31/00)
    private void calculateVariance() {
         
        if ( getMean() == DEFAULT
        || nodes_ == null || nodes_.isEmpty()
        || tree_ == null || tree_.isEmpty() || n_ <= 1.0 ) {
            return;
        }
        
        double x    = 0.0,
               sum  = 0.0; 
        
        ListIterator li = nodes_.listIterator();
        
        try {
            while ( li.hasNext() ) {
                x = getDistanceToNode( ( Node ) li.next(), lca_ ) 
                    - getMean();
                sum += ( x * x );
            }
        }
        catch ( Exception e ) {
            System.err.println( "calculateVariance(): "
                                + "Exception: " + e );
            System.exit( -1 );
        }
       
        setVariance( sum / ( n_ - 1 ) );

    }



    // (Last modified: 11/31/00)
    private void calculateStandardDeviation() {
         
        if ( getVariance() == DEFAULT 
        || getVariance() < 0.0 ) {
            return;
        }
        
        setStandardDeviation( java.lang.Math.sqrt( getVariance() ) );

    }



    // (Last modified: 12/01/00)
    private Node calculateLCA( ArrayList nodes ) {

        if ( nodes == null || nodes.isEmpty() ) {
            return null;
        }

	    Node node = ( Node ) nodes.get( 0 );
 
        int c = node.getSumExtNodes(),
	        v = nodes.size();

        while ( !node.isRoot() && c < v ) {
            node = node.getParent();
            c = node.getSumExtNodes();
        }

        ArrayList current_nodes 
        = new ArrayList( node.getAllExternalChildren() );

        while ( !node.isRoot()
        && !current_nodes.containsAll( nodes ) ) {
            node = node.getParent();
            current_nodes 
            = new ArrayList( node.getAllExternalChildren() );
        }  
       
        return node;
       
    } 
 

    
    // (Last modified: 11/30/00)
    private void setMean( double d ) {
        mean_ = d;
    }

    
    
    // (Last modified: 11/30/00)
    private void setVariance( double d ) {
        variance_ = d;
    }



    // (Last modified: 11/30/00)
    private void setStandardDeviation( double d ) {
        stand_dev_ = d;
    }



    // Main for testing.
    public static void main( String args[] ) {
        File tree_file        = null;
        Tree tree             = null;
        DistanceCalculator dc = null;
        tree_file = new File( args[ 0 ] );

        try {
            tree = TreeHelper.readNHtree( tree_file );
        }
        catch ( Exception e ) {
	        System.out.println( e.toString() );
	        System.exit( -1 );
	    }

        double time = System.currentTimeMillis();

        dc = new DistanceCalculator( tree );

        double m   = dc.getMean(),
               var = dc.getVariance(),
               sd  = dc.getStandardDeviation();

        time = ( System.currentTimeMillis() - time );

        System.out.println( "\nn   = " + dc.getN() );
        System.out.println( "mea = " + m );
        System.out.println( "var = " + var );
        System.out.println( "sd  = " + sd + "\n" );
        System.out.println( "t=" + time + "\n" );

    }

}



