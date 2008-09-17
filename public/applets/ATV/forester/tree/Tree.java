// Tree.java
// 
// Copyright (C) 1999-2002 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved
//
// Created: 1999
// Author: Christian M. Zmasek
// zmasek@genetics.wustl.edu
// http://www.genetics.wustl.edu/eddy/people/zmasek/



// Internally, the trees are -- after they are completely constructed --
// always rooted binary trees.


package forester.tree;


import java.io.*;
import java.util.Stack;
import java.util.Vector;
import java.util.StringTokenizer;
import java.net.*;
import java.util.Hashtable;  // For JDK 1.1.



/**

@author Christian M. Zmasek

@version 1.920 -- last modified: 12/26/01

*/
public class Tree implements Serializable {

    static final int MAX_LENGTH = 10;
    // Max length for seq names, when printing out "clean" NH.
    
    static final long serialVersionUID = -6847390332113L;
    // See Horstmann and Cornell: Core Java 1.2 Vol I, p.686.

    private Node      ext_node0_,
                      root_;
    private double    highest_lnL_,
                      lowest_lnL_,
                      real_height_;
    private int       external_nodes_,
                      number_of_duplications_;
    private boolean   rooted_,
                      more_than_bin_nodes_in_NH_;
    private String    name_;
    private Hashtable idhash_;
    private int       j_;   // Used in recursive method "preorderReID".






    // ---------------------------------------------------------
    // Constructors
    // ---------------------------------------------------------

 
    /**

    Default Tree constructor.
    Constructs an empty Tree.
    
    */
    public Tree() {
        delete();
    } // Tree()



    /**

    Tree constructor which constructs a Tree from String nh_string.
    The tree is considered unrooted if the deepest node has more than
    two children, otherwise it is considered rooted.

    @param nh_string String in New Hampshire (NH) or New Hampshire X (NHX) format

    */
    public Tree( String nh_string ) throws Exception {
        
        delete();
        
        boolean      first              = true;
        int          i                  = 0;
        String       internal_node_info = "", 
                     A                  = "",
                     B                  = "",
                     next               = "";
        StringBuffer sb                 = null;
        Stack        st                 = null;

        // To simulate >binary trees.
        String null_distance = new String( ":" + Node.DISTANCE_NULL ); 

        nh_string = TreeHelper.removeWhiteSpace( nh_string );
       
        nh_string = TreeHelper.removeComments( nh_string );

        // Remove anything before first "(", unless tree is just one node.
        if ( !TreeHelper.isEmpty( nh_string ) && nh_string.charAt( 0 ) != '('
        && nh_string.indexOf( "(" ) != -1 ) {
            int x = nh_string.indexOf( "(" );
            nh_string = nh_string.substring( x );
        }

        // If ';' at end, remove it.
        if ( !TreeHelper.isEmpty( nh_string )
        && nh_string.endsWith( ";" ) ) {
            nh_string = nh_string.substring( 0, nh_string.length() - 1 );
        }

        if ( TreeHelper.countAndCheckParantheses( nh_string ) <= -1 ) {
            String message = "Tree: Tree( String ): Error in NHX format: ";
            message += "open parantheses != close parantheses.";
            throw new Exception( message );
        }
        if ( !TreeHelper.checkCommas( nh_string ) ) {
            String message = "Tree: Tree( String ): Error in NHX format: ";
            message += "Commas not properly set.";
            throw new Exception( message );
        }
  
        // Conversion from nh string to tree object.

        // Empty Tree.
        if ( nh_string.length() < 1 ) {
            setExtNode0( null );
            setRoot( null );
        }

        // Check whether nh string represents a tree with more than
        // one node or just a single node.
        // More than one node.
        else if ( nh_string.indexOf( "(" ) != -1 ) {

            A = B = next = "";

            st = new Stack();

            i = 0;

            while ( i <= nh_string.length() - 1 ) {
                if ( nh_string.charAt( i ) == ',' ) {
                    st.push( "," );
                }
                if ( nh_string.charAt( i ) == '(' ) {
                    st.push( "(" );
                }
                if ( nh_string.charAt( i ) != ','
                && nh_string.charAt( i ) != '('
                && nh_string.charAt( i ) != ')' ) {
                    sb = new StringBuffer( "" );
                    while ( i <= nh_string.length() - 1
                    && nh_string.charAt( i ) != ')'
                    && nh_string.charAt( i ) != ','   ) {
                        sb.append( nh_string.charAt( i ) );
                        i++;
                    }
                    i--;
                    st.push( sb.toString() );
                }

                // A ")" calls for connection of one kind or another.
                if ( nh_string.charAt( i ) == ')' ) {
                    internal_node_info = "";
                    // If present, read information for internal node.
                    if ( i <= nh_string.length() - 2
                    && nh_string.charAt( i + 1 ) != ')'
                    && nh_string.charAt( i + 1 ) != ',' ) {
                        i++;
                        sb = new StringBuffer( "" );
                        while ( i <= nh_string.length() - 1
                        && nh_string.charAt( i ) != ')'
                        && nh_string.charAt( i ) != ',' ) {
                            sb.append( nh_string.charAt( i ) );
                            i++;
                        }
                        i--;
                        internal_node_info = sb.toString();
                    }

                    first = true;

                    // Parsing between two parantheses.
                    do {

                        A = st.pop().toString();

                        if ( st.empty() ) {
                            connectInternal( internal_node_info );
                            break;
                        }

                        B = st.pop().toString();

                        if ( st.empty() ) {
                            if ( A.equals( "(" ) ) {
                                connectInternal( internal_node_info );
                                st.push( "(" );
                            }
                            else if ( A.equals( "," ) ) {
                                connectInternal( internal_node_info );
                                break;
                            }
                            else {
                                addNodeAndConnect( A, internal_node_info );
                                break;
                            }
                        }
                        else {
                            next = st.peek().toString();

                            if ( !next.equals( "(" ) && B.equals( "," )
                            && !A.equals( "," ) ) {
                                if ( first && !next.equals( "," ) ) {
                                    addNode( A );
                                    st.push( "," );
                                }
                                else {
                                    addNodeAndConnect( A, null_distance );
                                }
                                first = false;
                            }

                            else {
                                first = false;

                                if ( next.equals( "," ) && !B.equals( "," )
                                && !B.equals( "(" )
                                && A.equals( "," ) ) {
                                    addNodeAndConnect( B, null_distance );
                                }

                                else if ( !next.equals( "(" )
                                && B.equals( "," ) && A.equals( "," ) ) {
                                    connectInternal( null_distance );
                                    st.push( "," );
                                }

                                else if ( next.equals( "(" ) && B.equals( "," )
                                && !A.equals( "(" ) && !A.equals( "," ) ) {
                                    addNodeAndConnect( A, internal_node_info );
                                    st.pop();
                                    break;
                                }

                                else if ( next.equals( "(" ) && !B.equals( "(" )
                                && !B.equals( "," ) && A.equals( "," ) ) {
                                    addNodeAndConnect( B, internal_node_info );
                                    st.pop();
                                    break;
                                }

                                else if ( next.equals( "(" )
                                && B.equals( "," ) && A.equals( "," ) ) {
                                    connectInternal( null_distance );
                                    connectInternal( internal_node_info );
                                    st.pop();
                                    break;
                                }

                                else if ( next.equals( "," ) && B.equals( "(" )
                                && !A.equals( "(" ) && !A.equals( "," ) ) {
                                    addNodeAndConnect( A, internal_node_info );
                                    break;
                                }

                                else if ( next.equals( "," )
                                && B.equals( "(" ) && A.equals( "," ) ) {
                                    connectInternal( internal_node_info );
                                    break;
                                }

                                else if ( next.equals( "(" )
                                && B.equals( "(" ) && !A.equals( "(" ) ) {
                                    if ( A.equals( "," ) ) {
                                        connectInternal( internal_node_info );
                                    }
                                    else {
                                        addNodeAndConnect( A,internal_node_info) ;
                                    }
                                    break;
                                }

                                else if ( A.equals("(")
                                && ( ( next.equals("(") && B.equals(",") )
                                || ( next.equals(",") && B.equals("(") )
                                || ( next.equals("(") && B.equals("(") ) ) ) {
                                    connectInternal( internal_node_info );
                                    st.push( "(" );
                                    break;
                                }

                            }

                        } // end of else (st is not empty).

                    } while ( true );


                }

                i++;

            } // End of while loop going through nh_string.

            if ( !getExtNode0().getRoot().getChild1().isPseudoNode() 
            && !getExtNode0().getRoot().getChild2().isPseudoNode() ) {
                setRooted( true );  
            }
        }

        // Just one node.
        // Conversion from nh string to tree object with one node.
        else {
            addNode( nh_string );
            setRooted( true );
        }


        if ( !isEmpty() ) {
            setRoot( getExtNode0().getRoot() );
            if ( !isRooted() ) {
                getRoot().deleteData();
            }
            findExtremeLnL();
            calculateRealHeight();

            // Checks whether branch lenghts are actually bootstraps.
            // (In case of trees coming form NH format.)
            if ( areBranchLenghtsBootstraps() ) {
                moveBranchLenghtsToBootstrap();
            }
        }

    } // Tree( String )









    // ---------------------------------------------------------
    // Copy and delete Trees
    // ---------------------------------------------------------
    

    /**

    Returns a deep copy of this Tree.
    <p>
    (The resulting Tree has its references in the
    external nodes corrected, if they are lacking/
    obsolete in this.)
    <p>
    (Last modified: 06/11/01)

    */
    public Tree copyTree() {

        Tree tree                       = new Tree();

        if ( isEmpty() ) {
            tree.delete();
            return tree;
        }

        tree.rooted_                     = rooted_;
        tree.highest_lnL_                = highest_lnL_;
        tree.lowest_lnL_                 = lowest_lnL_;
        tree.real_height_                = real_height_;
        tree.external_nodes_             = external_nodes_;
        tree.number_of_duplications_     = number_of_duplications_;
        tree.more_than_bin_nodes_in_NH_  = more_than_bin_nodes_in_NH_;
        tree.name_                       = new String( name_ );
        tree.idhash_                     = idhash_;

        tree.root_ = Node.copyTree( root_ );

        tree.getRoot().setParents();

        tree.adjustExtNode0();
        tree.adjustReferencesInExtNodes();
        return tree;

    } // copyTree()


     
    /**

    Deletes this Tree.

    */
    public void delete() {
        ext_node0_                 = null;
        root_                      = null;
        rooted_                    = false;
        more_than_bin_nodes_in_NH_ = true;
        highest_lnL_               = 0.0;
        lowest_lnL_                = 0.0;
        real_height_               = 0.0;
        external_nodes_            = 0;
        number_of_duplications_    = -1;
        name_                      = "";
        idhash_                    = null;
        j_                         = 0;
    
    } // delete()



    /**

    Returns the subtree of this Tree which has the Node with ID id
    as its root Node.
    
    @param id ID (int) of Node

    */
    public Tree subTree( int id ) { 

        Tree tree = null;
        Node node = null;

        if ( isEmpty() ) {
            return null;
        }
        tree = copyTree();
        node = tree.getNode( id );
        if ( node == null || node.isExternal() ) {
            return null;
        }
        node.setParent( null );
        node.setDistanceToParent( Node.DISTANCE_DEFAULT );
        tree.setRooted( true );
        tree.setRoot( node );
        tree.adjustExtNode0();
        tree.adjustReferencesInExtNodes();
        tree.adjustNodeCount( true );
        tree.recalculateAndReset();
        tree.setExtNodes( tree.getRoot().getSumExtNodes() );
        return tree;

    } // subTree( int )

   





    // ---------------------------------------------------------
    // Modification of Tree topology and Tree appearance
    // ---------------------------------------------------------


    /**
    
    Removes the root Node of this Tree 
    and makes at least a trifurcation at its basal node.

    */
    public void unRootAndTrifurcate() {

        double sum = 0.0;

        if ( isEmpty() ) {
            return;
        }
        unRoot();
        if ( getNumberOfExtNodes() <= 2 ) {
            return;
        }

        sum = getRoot().getChild2().getDistanceToParent()
        + getRoot().getChild1().getDistanceToParent();
        if ( getRoot().getChild2().isExternal() || getRoot().getChild2().collapse() ) {
            if ( sum >= 0.0 ) {
                getRoot().getChild2().setDistanceToParent( sum );
            }
            else {
                getRoot().getChild2().setDistanceToParent( Node.DISTANCE_DEFAULT );
            }
            getRoot().getChild1().setDistanceToParent( Node.DISTANCE_NULL );
        }
        else {
            if ( sum >= 0.0 ) {
                getRoot().getChild1().setDistanceToParent( sum );
            }
            else {
                getRoot().getChild1().setDistanceToParent( Node.DISTANCE_DEFAULT );
            }
            getRoot().getChild2().setDistanceToParent( Node.DISTANCE_NULL );
        }
        recalculateAndReset();
        return;

    } // unRootAndTrifurcate()

    

    /**
    
    Removes the root Node this Tree.

    */
    public void unRoot() {
        if ( isEmpty() ) {
            return;
        }

        setIndicatorsToZero();
        if ( !isRooted() || getNumberOfExtNodes() <= 1 ) {
            return;
        }
        setRooted( false );
        recalculateAndReset();
        return;

    } // unRoot()




    /**

    Removes external Node n from this Tree.
    If this tree has only one node, a empty tree will be returned.

    @param n Node to remove

    */
    public void removeExtNode( Node n ) {

        Node removed_node = null,
             p            = null,
             pp           = null;

        if ( isEmpty() ) {
            return;
        }
     
        // Returns an empty tree.   
        if ( getNumberOfExtNodes() == 1 && n == getExtNode0() ) {
            delete();
            return;  
        }

        removed_node = n;

        if ( removed_node == getExtNode0() ) {
            setExtNode0( removed_node.getNextExtNode() );
            removed_node.getNextExtNode().setPrevExtNode( null );
        }
        else if ( removed_node.getNextExtNode() == null ) {
            removed_node.getPrevExtNode().setNextExtNode( null );
        }
        else {
            removed_node.getNextExtNode().setPrevExtNode( removed_node.getPrevExtNode() );
            removed_node.getPrevExtNode().setNextExtNode( removed_node.getNextExtNode() );
        }

        p = removed_node.getParent();

        if ( p.isRoot() ) {
            if ( removed_node.isChild1() ) {
                setRoot( getRoot().getChild2() );
                getRoot().setParent( null );
            }
            else {
                setRoot( getRoot().getChild1() );
                getRoot().setParent( null );
            }
        }
        else {
            pp = removed_node.getParent().getParent();
            if ( p.isChild1() ) {
                if ( removed_node.isChild1() ) {
                    p.getChild2().setDistanceToParent( addDist( p.getDistanceToParent(), p.getChild2().getDistanceToParent() ) );
                    pp.setChild1( p.getChild2() );
                    p.getChild2().setParent( pp );
                }
                else {
                    p.getChild1().setDistanceToParent( addDist( p.getDistanceToParent(), p.getChild1().getDistanceToParent() ) );
                    pp.setChild1( p.getChild1() );
                    p.getChild1().setParent( pp );
                }

            }
            else {
                if ( removed_node.isChild1() ) {
                    p.getChild2().setDistanceToParent( addDist( p.getDistanceToParent(), p.getChild2().getDistanceToParent() ) );
                    pp.setChild2( p.getChild2() );
                    p.getChild2().setParent( pp );
                }
                else {
                    p.getChild1().setDistanceToParent( addDist( p.getDistanceToParent(), p.getChild1().getDistanceToParent() ) );
                    pp.setChild2( p.getChild1() );
                    p.getChild1().setParent( pp );
                }
            }

            while ( pp != getRoot() ) {
                pp.setSumExtNodes( pp.getSumExtNodes() - 1 );
                pp = pp.getParent();
            }

            pp.setSumExtNodes( pp.getSumExtNodes() - 1 );




        }
        setExtNodes( getNumberOfExtNodes() - 1 );
        idhash_ = null;
        return;

    } // removeExtNode( Node )



    // Helper method for removeExtNode( Node ).
    private double addDist( double a, double b ) {
        if ( a >= 0.0 && b >= 0.0 ) {
            return a + b;
        }
        else if ( a >= 0.0 ) {
            return a;
        }
        else if ( b >= 0.0 ) {
            return b;
        }
        else if ( a == Node.DISTANCE_NULL && b == Node.DISTANCE_NULL ) {
            return Node.DISTANCE_NULL;
        }
        return Node.DISTANCE_DEFAULT;

    } // addDist( double, double )
    


    /**

    Swaps the the two childern of a Node with ID id of this Tree.
    
    @param id ID (int) of Node
    
    */
    public void swapChildren( int id ) {
        swapChildren( getNode( id ) );
    } // swapChildren( int )



    /**

    Swaps the the two childern of a Node node of this Tree.
    <p>
    (Last modified: 06/13/01)
    
    @param node a Node of this Tree
    
    */
    public void swapChildren( Node node ) {

        Node temp = null;

        if ( isEmpty() ) {
            return;
        }
        if ( node.isExternal() ) {
            return;
        }
        temp = node.getChild1();
        node.setChild1( node.getChild2() );
        node.setChild2( temp );
        adjustExtNode0();
        adjustReferencesInExtNodes();

    } // swapChildren( Node )



    /**

    Arranges the order of childern for each node of this Tree in such
    a way that either the branch with more children is on top (right)
    or on bottom (left), dependent on the value of boolean order.
    <p>
    (Last modified: 06/13/01)

    @param order decides in which direction to order
    
    */
    public void orderAppearance( boolean order ) {

        if ( isEmpty() ) {
            return;
        }
    
        orderAppearanceHelper( getRoot(), order );

        adjustExtNode0();
        adjustReferencesInExtNodes();

    } // void orderAppearance( boolean )



    // Helper method for "orderAppearance(boolean)".
    // Traverses this Tree recusively.
    // (Last modified: 06/13/00)
    private void orderAppearanceHelper( Node n, boolean order ) {

       if ( n.isExternal() ) {
           return;
       }
       else {
           Node temp = null;
           if ( ( n.getChild1().getSumExtNodes() 
               != n.getChild2().getSumExtNodes() ) 
           && ( ( n.getChild1().getSumExtNodes() 
                < n.getChild2().getSumExtNodes() ) == order ) ) {
               temp = n.getChild1();
               n.setChild1( n.getChild2() );
               n.setChild2( temp );
               
           }
           orderAppearanceHelper( n.getChild1(), order );
           orderAppearanceHelper( n.getChild2(), order );
       }

    } // orderAppearanceHelper( Node, boolean )



    /**

    Sets all Nodes of this Tree to not-collapsed.
    <p>
    In most cases methods adjustNodeCount(false) and 
    recalculateAndReset() need to be called
    after this method has been called.
    <p>
    (Last modified: 07/03/01)
    
    */    
    public void setAllNodesToNotCollapse() {
        if ( isEmpty() ) {
            return;
        }
        setAllNodesToNotCollapseHelper( getRoot() );

    } // setAllNodesToNotCollapse()
 
 

    // Helper for setAllNodesToNotCollapse()
    // (Last modified: 07/03/01)
    private void setAllNodesToNotCollapseHelper( Node n ) {
        if ( n.isExternal() ) {
            return;
        }
        else {
            n.setCollapse( false );
            setAllNodesToNotCollapseHelper( n.getChild1() );
            setAllNodesToNotCollapseHelper( n.getChild2() );
        }

    } // setAllNodesToNotCollapseHelper( Node )  



    /**

    Collapses this Tree's deepest Nodes anotated with either a sequence name
    or a species name. All other Nodes are uncollapsed.
    <p>
    (Last modified: 07/03/01)
    
    */    
    public void collapseToDeepestAnotNodes() {
        if ( isEmpty() ) {
            return;
        }
        setAllNodesToNotCollapse();
        collapseToDeepestAnotNodesHelper( getRoot() );
        adjustNodeCount( true );
        recalculateAndReset();

    } // collapseToDeepestAnotNodes()



    // Helper for collapseToDeepestAnotNodes()
    // (Last modified: 07/03/01)
    private void collapseToDeepestAnotNodesHelper( Node n ) {
        if ( n.isExternal() ) {
            return;
        }
        else {
            if ( !n.isPseudoNode()  
            && ( !n.getSpecies().equals( "" ) 
            || !n.getSeqName().equals( "" ) ) ) {
                n.setCollapse( true );
                return;
            }
            else {
                collapseToDeepestAnotNodesHelper( n.getChild1() );
                collapseToDeepestAnotNodesHelper( n.getChild2() );
            }
        }

    } // collapseToDeepestAnotNodesHelper( Node )  







    // ---------------------------------------------------------
    // Rerooting
    // ---------------------------------------------------------



    /**

    Places the root of this Tree on the parent branch of the
    Node with a corresponding ID.
    The new root is always placed on the middle of the branch.
    If the resulting reRooted Tree is to be used any further,
    in most cases the following methods have to be
    called on the resulting Tree:<p>
    <li> adjustNodeCount(boolean)
    <li> recalculateAndReset()
    <p>
    (Last modified: 10/01/01)

    @param id ID (int) of Node of this Tree
    
    */ 
    public void reRoot( int id ) throws Exception {
        reRoot( getNode( id ) );
    } // reRoot( int )



    /**

    Places the root of this Tree on the parent branch Node n.
    The new root is always placed on the middle of the branch.
    <p>
    If the resulting reRooted Tree is to be used any further,
    in most cases the following three methods have to be
    called on the resulting Tree:
    <ul>
    <li> adjustNodeCount(boolean)
    <li> recalculateAndReset()
    </ul>
    <p>
    (Last modified: 10/01/01)

    @param n Node of this Tree 
    
    */ 
    public void reRoot( Node n ) throws Exception {

        Node    nodeA       = n,
                node        = null,
                nodeB       = null,
                nodeC       = null,
                new_root    = null;
        double  distance1   = 0.0,
                distance2   = 0.0;
        float   lnL1        = 0.0f,
                lnL2        = 0.0f;
        boolean sign_worse1 = false,
                sign_worse2 = false,
                lnL_assign1 = false,
                lnL_assign2 = false;
        int     bootstrap1  = 0,
                bootstrap2  = 0; 

        

        if ( isEmpty() || getNumberOfExtNodes() < 2 ) {
            return;
        }

        if ( nodeA.isPseudoNode() ) {
            throw new Exception( "Tree: reRoot(Node): Can not place root on parent branch of pseudo node." );
        }

        setRooted( true );

        if ( nodeA.isRoot() ) {
            moveRootToMiddle();
            return;
        }

        if ( nodeA.getParent().isRoot() ) {
            if ( getRoot().getChild1().isPseudoNode()
            || getRoot().getChild2().isPseudoNode() ) {
                if ( getRoot().getChild1() == nodeA
                &&   getRoot().getChild2().isPseudoNode() ) {
                    node = getRoot().getChild2();
                }
                if ( getRoot().getChild2() == nodeA
                &&   getRoot().getChild1().isPseudoNode() ) {
                    node = getRoot().getChild1();
                }
                if ( nodeA.getDistanceToParent() == Node.DISTANCE_DEFAULT ) {
                    node.setDistanceToParent( Node.DISTANCE_DEFAULT );
                }
                else {
                    double d = nodeA.getDistanceToParent() / 2;
                    node.setDistanceToParent( d );
                    nodeA.setDistanceToParent( d );
                }

                node.setLnLonParentBranch( nodeA.getLnLonParentBranch() );
                node.setSignificantlyWorse( nodeA.significantlyWorse() );
                node.setLnLonParentBranchAssigned( nodeA.isLnLonParentBranchAssigned() );
                node.setBootstrap( nodeA.getBootstrap() ); 
            }
            else {
                 moveRootToMiddle();
            }
            return;
        }

        nodeB = nodeA.getParent();
        nodeC = nodeB.getParent();

        // New Root.
        new_root = new Node();
        if ( nodeB.getChild2() == nodeA ) {
            new_root.setChild1( nodeA );
            new_root.setChild2( nodeB );
        }
        else {
            new_root.setChild1( nodeB );
            new_root.setChild2( nodeA );
        }

        distance1   = nodeC.getDistanceToParent();
        lnL1        = nodeC.getLnLonParentBranch();
        sign_worse1 = nodeC.significantlyWorse();
        lnL_assign1 = nodeC.isLnLonParentBranchAssigned();
        bootstrap1  = nodeC.getBootstrap();

        nodeC.setDistanceToParent( nodeB.getDistanceToParent() );

        nodeC.setLnLonParentBranch( nodeB.getLnLonParentBranch() );
        nodeC.setLnLonParentBranchAssigned( nodeB.isLnLonParentBranchAssigned() );
        nodeC.setSignificantlyWorse( nodeB.significantlyWorse() );
        nodeC.setBootstrap( nodeB.getBootstrap() );      


        nodeB.setLnLonParentBranch( nodeA.getLnLonParentBranch() );
        nodeB.setLnLonParentBranchAssigned( nodeA.isLnLonParentBranchAssigned() );
        nodeB.setSignificantlyWorse( nodeA.significantlyWorse() );
        nodeB.setBootstrap( nodeA.getBootstrap() ); 


        // New root is always placed in the middle of the branch:
        if ( nodeA.getDistanceToParent() == Node.DISTANCE_DEFAULT ) {
            nodeB.setDistanceToParent( Node.DISTANCE_DEFAULT );
        }
        else {
            double d = nodeA.getDistanceToParent() / 2;
            nodeB.setDistanceToParent( d );
            nodeA.setDistanceToParent( d );
        }

        // nodeA:
        nodeA.setParent( new_root );


        // nodeB:
        if ( nodeB.getChild1() == nodeA ) {
            nodeB.setChild1( nodeC );
        }
        else {
            nodeB.setChild2( nodeC );
        }
        nodeB.setParent( new_root );

        // moving to the old root, swapping references:
        while ( !nodeC.isRoot() ) {

            nodeA = nodeB;
            nodeB = nodeC;
            nodeC = nodeC.getParent();

            if ( nodeB.getChild1() == nodeA ) {
                nodeB.setChild1( nodeC );
            }
            else {
                nodeB.setChild2( nodeC );
            }
            nodeB.setParent( nodeA );

            distance2   = nodeC.getDistanceToParent();
            lnL2        = nodeC.getLnLonParentBranch();
            sign_worse2 = nodeC.significantlyWorse();
            lnL_assign2 = nodeC.isLnLonParentBranchAssigned();
            bootstrap2  = nodeC.getBootstrap();

            nodeC.setDistanceToParent( distance1 );
            nodeC.setLnLonParentBranch( lnL1 );
            nodeC.setSignificantlyWorse( sign_worse1 );
            nodeC.setLnLonParentBranchAssigned( lnL_assign1 );
            nodeC.setBootstrap( bootstrap1 );

            distance1   = distance2;
            lnL1        = lnL2;
            sign_worse1 = sign_worse2;
            lnL_assign1 = lnL_assign2;
            bootstrap1  = bootstrap2;
        }


        // removing the old root:
        if ( nodeC.getChild1() == nodeB ) {
            node = nodeC.getChild2();
        }
        else {
            node = nodeC.getChild1();
        }
        node.setParent( nodeB );

        if ( nodeC.getDistanceToParent() == Node.DISTANCE_NULL
        && node.getDistanceToParent() == Node.DISTANCE_NULL ) {
            node.setDistanceToParent( Node.DISTANCE_NULL );
        }
        else if ( ( nodeC.getDistanceToParent() == Node.DISTANCE_DEFAULT
        ||  nodeC.getDistanceToParent() == Node.DISTANCE_NULL )
        && ( node.getDistanceToParent() == Node.DISTANCE_DEFAULT
        ||  node.getDistanceToParent() == Node.DISTANCE_NULL ) ) {
            node.setDistanceToParent( Node.DISTANCE_DEFAULT );
        }
        else {
            node.setDistanceToParent( ( nodeC.getDistanceToParent() >= 0.0 ?
            nodeC.getDistanceToParent() : 0.0 )
            + ( node.getDistanceToParent() >= 0.0 ?
            node.getDistanceToParent() : 0.0 ) );
        }


        if ( nodeC.getDistanceToParent() != Node.DISTANCE_NULL ) {
            node.setLnLonParentBranch( nodeC.getLnLonParentBranch() );
            node.setSignificantlyWorse( nodeC.significantlyWorse() );
            node.setLnLonParentBranchAssigned( nodeC.isLnLonParentBranchAssigned() );
        }

        node.setBootstrap( nodeC.getBootstrap() );

        if ( nodeB.getChild1() != nodeC ) {
            nodeB.setChild2( node );
        }
        else {
            nodeB.setChild1( node );
        }

        setRoot( new_root );

        adjustExtNode0();
        adjustReferencesInExtNodes();
        return;

    } // reRoot( Node )
   


    /**

    Places the root of this Tree on Branch b.
    The new root is always placed on the middle of the branch b.
    <p>
    (Last modified: 10/01/01)

    @param n1 Node of Node of this Tree
           n2 Node of Node of this Tree
    
    */ 
    public void reRoot( Branch b ) throws Exception {
    
        Node n1 = b.getNode1(),
             n2 = b.getNode2();

        if ( n2 == n1.getChild1()
        ||   n2 == n1.getChild2() ) {
            reRoot( n2 );
        }
        else if ( n1 == n2.getChild1()
             ||   n1 == n2.getChild2() ) {
            reRoot( n1 );
        }
        else if ( n1.getParent() != null 
             &&   n1.getParent().isRoot() 
             && ( n1.getParent().getChild1() == n2 || n1.getParent().getChild2() == n2 ) ) {
            reRoot( n1 );
        }
        else {
            throw new Exception( "reRoot( Branch b ): b is not a branch." );
        }

    } // reRoot( Branch )



    /**

    Places the root of this Tree on the parent branch Node n.
    The new root is always placed on the middle of the branch.
    <p>
    This method only considers the "skeleton" of the Tree:
    It ignores everything except the topology and branch lenghts.
    It also does not deal properly with multifurcated tree!
    DO NOT USE.
    <p>
    This is ONLY to be used by methods in class SDIunrooted
    (in forester/tools)! 
    <p>
    (Last modified: 10/01/01)

    @param n Node of this Tree 
    
    */ 
    public void reRootSkeleton( Node n ) throws Exception {

        Node   nodeA     = n,
               node      = null,
               nodeB     = null,
               nodeC     = null,
               new_root  = null;
        double distance1 = 0.0,
               distance2 = 0.0;

        if ( isEmpty() || getNumberOfExtNodes() < 2 ) {
            return;
        }

        setRooted( true );

        if ( nodeA.isRoot() || nodeA.getParent().isRoot() ) { 
            moveRootToMiddle();
            return;
        }

        nodeB = nodeA.getParent();
        nodeC = nodeB.getParent();

        // New Root.
        new_root = new Node();
        if ( nodeB.getChild2() == nodeA ) {
            new_root.setChild1( nodeA );
            new_root.setChild2( nodeB );
        }
        else {
            new_root.setChild1( nodeB );
            new_root.setChild2( nodeA );
        }

        distance1   = nodeC.getDistanceToParent();
        
        nodeC.setDistanceToParent( nodeB.getDistanceToParent() );

        // New root is always placed in the middle of the branch:
        if ( nodeA.getDistanceToParent() == Node.DISTANCE_DEFAULT ) {
            nodeB.setDistanceToParent( Node.DISTANCE_DEFAULT );
        }
        else {
            double d = nodeA.getDistanceToParent() / 2;
            nodeB.setDistanceToParent( d );
            nodeA.setDistanceToParent( d );
        }

        // nodeA:
        nodeA.setParent( new_root );

        // nodeB:
        if ( nodeB.getChild1() == nodeA ) {
            nodeB.setChild1( nodeC );
        }
        else {
            nodeB.setChild2( nodeC );
        }
        nodeB.setParent( new_root );

        // moving to the old root, swapping references:
        while ( !nodeC.isRoot() ) {

            nodeA = nodeB;
            nodeB = nodeC;
            nodeC = nodeC.getParent();

            if ( nodeB.getChild1() == nodeA ) {
                nodeB.setChild1( nodeC );
            }
            else {
                nodeB.setChild2( nodeC );
            }
            nodeB.setParent( nodeA );
            distance2   = nodeC.getDistanceToParent();
            nodeC.setDistanceToParent( distance1 );
            distance1   = distance2;
        }


        // removing the old root:
        if ( nodeC.getChild1() == nodeB ) {
            node = nodeC.getChild2();
        }
        else {
            node = nodeC.getChild1();
        }
        node.setParent( nodeB );

        
        if (  nodeC.getDistanceToParent() == Node.DISTANCE_DEFAULT
        &&  node.getDistanceToParent() == Node.DISTANCE_DEFAULT ) {
            node.setDistanceToParent( Node.DISTANCE_DEFAULT );
        }
        else {
            node.setDistanceToParent( ( nodeC.getDistanceToParent() >= 0.0 ?
            nodeC.getDistanceToParent() : 0.0 )
            + ( node.getDistanceToParent() >= 0.0 ?
            node.getDistanceToParent() : 0.0 ) );
        }

        if ( nodeB.getChild1() != nodeC ) {
            nodeB.setChild2( node );
        }
        else {
            nodeB.setChild1( node );
        }
        setRoot( new_root );

        return;

    } // reRootSkeleton( Node )



    /**

    Places the root of this Tree on Branch b.
    The new root is always placed on the middle of the branch b.
    <p>
    This method only considers the "skeleton" of the Tree:
    It ignores everything except the topology and branch lenghts.
    It also does not deal properly with multifurcated tree!
    DO NOT USE.
    <p>
    This is ONLY to be used by methods in class SDIunrooted
    (in forester/tools)! 
    <p>
    (Last modified: 10/01/01)

    @param n1 Node of Node of this Tree
           n2 Node of Node of this Tree
    
    */ 
    public void reRootSkeleton( Branch b ) throws Exception {
    
        Node n1 = b.getNode1(),
             n2 = b.getNode2();

        if ( n2 == n1.getChild1()
        ||   n2 == n1.getChild2() ) {
            reRootSkeleton( n2 );
        }
        else if ( n1 == n2.getChild1()
             ||   n1 == n2.getChild2() ) {
            reRootSkeleton( n1 );
        }
        else if ( n1.getParent() != null 
             &&   n1.getParent().isRoot() 
             && ( n1.getParent().getChild1() == n2 || n1.getParent().getChild2() == n2 ) ) {
            reRootSkeleton( n1 );
        }
        else {
            throw new Exception( "reRootSkeleton( Branch b ): b is not a branch." );
        }

    } // reRootSkeleton( Branch )



    // (Last modified: 10/01/01)
    private void moveRootToMiddle() {
        if ( getRoot().getChild1() != null 
        && getRoot().getChild2() != null ) {
            double d1 = getRoot().getChild1().getDistanceToParent(),
                   d2 = getRoot().getChild2().getDistanceToParent(),
                   d  = 0.0;
            if ( d1 < 0.0 ) {
                d1 = 0.0;
            }
            if ( d2 < 0.0 ) {
                d2 = 0.0;
            }
            d = ( d1 + d2 ) / 2.0;
            getRoot().getChild1().setDistanceToParent( d );
            getRoot().getChild2().setDistanceToParent( d );
        }
    } // moveRootToMiddle()








    // ----------------------------------------------------------------------------
    // Orthologs, Super Orthologs, Ultra Paralogs, Subtree Neighbors, "X-Orthologs"
    // ----------------------------------------------------------------------------
    

    /**

    Returns all orthologs of the external Node n of this Tree. Orthologs are
    returned as Vector of references to Nodes.
    <p>
    PRECONDITION: This tree must be binary and rooted, and
    speciation - duplication need to be assigned for each of its
    internal Nodes.
    <p>
    Returns null if this Tree is empty or if n is internal.
    <p>
    (Last modified: 11/22/00)

    @param n external Node whose orthologs are to be returned

    @return Vector of references to all orthologous Nodes of Node n of this
            Tree, null if this Tree is empty or if n is internal 

    */
    public Vector getOrthologousNodes( Node n ) {

        Node   node  = n,
               prev  = null;
        Vector v     = new Vector();

        if ( !node.isExternal() || isEmpty() ) {
            return null;
        }

        while ( !node.isRoot() ) {
            prev = node;
            node = node.getParent();
            if ( !node.isDuplication() ) {
                if ( node.getChild1() == prev ) {
                    addIntoVector( node.getChild2().getAllExternalChildren(), v );
                }
                else {
                    addIntoVector( node.getChild1().getAllExternalChildren(), v );
                }            
            }
        }

        v.trimToSize();

        return v;
    } // getOrthologousNodes( Node )
    


    // Adds all element from Vector from into Vector addto.
    // (Last modified: 11/22/00)
    private void addIntoVector( Vector from, Vector addto ) {
        for ( int i = 0; i < from.size(); ++i ) {
            addto.addElement( from.elementAt( i ) );
        }
    } // addIntoVector( Vector, Vector )



    /**

    Returns all Nodes which are connected to external Node n of this Tree by
    a path containing only speciation events. We call these "super orthologs". 
    Nodes are returned as Vector of references to Nodes.
    <p>
    PRECONDITION: This tree must be binary and rooted, and
    speciation - duplication need to be assigned for each of its
    internal Nodes.
    <p>
    Returns null if this Tree is empty or if n is internal.
    <p>
    (Last modified: 11/22/00)

    @param n external Node whose strictly speciation related Nodes are to be 
             returned 

    @return Vector of references to all strictly speciation related Nodes of
            Node n of this Tree, null if this Tree is empty or if n is internal

    */
    public Vector getSuperOrthologousNodes( Node n ) {

        Node   node    = n,
               deepest = null;
        Vector v       = new Vector();

        if ( !node.isExternal() || isEmpty() ) {
            return null;
        }

        while ( !node.isRoot() && !node.getParent().isDuplication() ) {
            node = node.getParent();
        }

        deepest = node;
        deepest.setIndicatorsToZero();

        do {
            if ( !node.isExternal() ) {
                if ( node.getIndicator() == 0 ) {
                    node.setIndicator( 1 );
                    if ( !node.isDuplication() ) {
                        node = node.getChild1();
                    }
                }
                if ( node.getIndicator() == 1 ) {
                    node.setIndicator( 2 );
                    if ( !node.isDuplication() ) {
                        node = node.getChild2();
                    }
                }
                if ( node != deepest && node.getIndicator() == 2 ) {
                    node = node.getParent();
                }
            }
            else {
                if ( node != n ) {
                    v.addElement( node );
                }
                if ( node != deepest ) {
                    node = node.getParent();
                }
                else {
                    node.setIndicator( 2 );
                }
            }
        } while ( node != deepest || deepest.getIndicator() != 2 );

        v.trimToSize();

        return v;

    } // getSuperOrthologousNodes( Node )



    /**

    Returns all Nodes which are connected to external Node n of this Tree by
    a path containing, and leading to, only duplication events.
    We call these "ultra paralogs". 
    Nodes are returned as Vector of references to Nodes.
    <p>
    PRECONDITION: This tree must be binary and rooted, and
    speciation - duplication need to be assigned for each of its
    internal Nodes.
    <p>
    Returns null if this Tree is empty or if n is internal.
    <p>
    (Last modified: 10/06/01)

    @param n external Node whose ultra paralogs are to be returned 

    @return Vector of references to all ultra paralogs of Node n of this
            Tree, null if this Tree is empty or if n is internal

    */
    public Vector getUltraParalogousNodes( Node n ) {

        Node   node    = n;
        Vector v       = new Vector();

        if ( !node.isExternal() || isEmpty() ) {
            return null;
        }

        while ( !node.isRoot() 
        && node.getParent().isDuplication() 
        && areAllChildrenDuplications( node.getParent() ) ) {
            node = node.getParent();
        }

        v = node.getAllExternalChildren();

        v.removeElement( n );

        v.trimToSize();

        return v;

    } // getUltraParalogousNodes( Node )



  
    // Helper for getUltraParalogousNodes( Node ).
    //(Last modified: 11/22/00)
    public boolean areAllChildrenDuplications( Node n ) {
        if ( n.isExternal() ) {
            return true;
        }
        else {
            if ( n.isDuplication() ) {
                return ( areAllChildrenDuplications( n.getChild1() ) 
                &&       areAllChildrenDuplications( n.getChild2() ) ) ; 
            }
            else {
                return false;
            }
        }
    }



    /**

    Returns all external nodes (except n) which are members of the 2nd smallest
    subtree containing Node n.
    In other words, this method returns all external descendants (except n
    itself) of n's parent's parent node (n.getParent().getParent()).
    We call these "subtree neighbors". This concept is not dependent on
    duplications and speciations.
    Nodes are returned as Vector of references to Nodes. 
    <p>
    PRECONDITION: This tree must be binary and rooted.
    <p>
    Returns null if this Tree is empty or if n is internal.
    <p>
    (Last modified: 12/26/01)

    @param n external Node whose "subtree neighbors" are to be returned 

    @return Vector of references to all "subtree neighbors" of Node n of this
            Tree, null if this Tree is empty or if n is internal

    */
    public Vector getSubtreeNeighbors( Node n ) {

        Node   node = n;
        Vector v    = new Vector();

        if ( !node.isExternal() || isEmpty() ) {
            return null;
        }

        if ( !node.isRoot() ) {
            node = node.getParent();
        }
        if ( !node.isRoot() ) {
            node = node.getParent();
        }

        v = node.getAllExternalChildren();

        v.removeElement( n );

        v.trimToSize();

        return v;

    } // getSubtreeNeighbors( Node )

 






    // ---------------------------------------------------------
    // Getting and finding of Nodes and Names
    // ---------------------------------------------------------



    /**

    Returns a Node of this Tree which has a matching sequence name seqname.
    Throws an Exception if seqname is not present in this or not unique.
    <p>   
    (Last modifed: 12/03/00)

    @param seqname Sequence name (String) of Node to find

    @return Node with matchin sequence name 

    */
    public Node getNode( String seqname ) throws Exception {

        Vector nodes = getNodes( seqname );

        if ( isEmpty() ) {
            return null;
        }
        
        if ( nodes == null || nodes.size() < 1 ) {
            throw new Exception( seqname + " not found" );
        }
        if ( nodes.size() > 1 ) {
            throw new Exception( seqname + " not unique" );
        }
        return ( Node ) nodes.elementAt( 0 );

    } // getNode( String )



    /**

    Finds the Node of this Tree which has a matching ID number.
    Takes O(n) time. After method hashIDs() has been called it runs in
    constant time.
    <p>
    (Last modified: 11/20/00)

    @param id ID number (int) of the Node to find

    @return Node with matching ID, null if Node not found

    */
    public Node getNode( int id ) {

        if ( isEmpty() ) {
            return null;
        }

        if ( idhash_ != null ) {
            return ( Node ) idhash_.get( new Integer( id ) );
        }
        else {
            return getNodeHelper( getRoot(), id );
        }

    } // getNode( int id ) 



    // Helper method for "getNode(int)".
    // Searches for id by traversing tree recusively.
    // (Last modified: 11/18/00)
    private Node getNodeHelper( Node n, int id ) {

       if ( n == null || n.getID() == id ) {
           return n;
       }
       else {
           Node n1 = getNodeHelper( n.getChild1(), id ),
                n2 = getNodeHelper( n.getChild2(), id );
           if ( n1 != null ) {
              return n1;
           }
           return n2;
       }

    } // getNodeHelper( Node, int )



    /**

    Returns a Vector of references to Nodes which match in 
    sequence name AND species AND EC number AND taxonomy ID.
    To not use a parameter set it to "", or to
    Node.TAXO_ID_DEFAULT for taxonomy_id.
    Is case insensitive.
    <p>
    (Last modified: 07/30/01)

    @param name        sequence name to match
           species     species name to match
	   ec          EC number to match
	   taxonomy_id taxonomy ID to match

    @return Vecotor of references to matching Nodes

    */
    public Vector find( String name,
                        String species,
			String ec,
			int taxonomy_id ) throws Exception {

        Vector nodes           = new Vector();
        PreorderTreeIterator i = null;
        Node current           = null,
	     n                 = null;
        boolean failed         = false;

        if ( isEmpty() ) {
	    return null;
	}
 
        name    = name.toLowerCase().trim();
	species = species.toLowerCase().trim();
	ec      = ec.toLowerCase().trim();

        i = new PreorderTreeIterator ( this );
	
	while ( !i.isDone() ) {
	    current = i.currentNode();
	    if ( name != null && !name.equals( "" ) ) { 
	        if ( current.getSeqName().toLowerCase().equals( name ) ) {
	            n = current;
		}
		else {
		    failed = true;
		}
	    }
	    if ( !failed && species != null && !species.equals( "" ) ) {
	        if ( current.getSpecies().toLowerCase().equals( species ) ) {
		    n = current;
		}
		else {
		    failed = true; 
		}
	    }
	    if ( !failed && ec != null && !ec.equals( "" ) ) {
	        if ( current.getECnumber().toLowerCase().equals( ec ) ) {
		    n = current;
		}
		else {
		    failed = true;
		}
	    }
	    if ( !failed && taxonomy_id != Node.TAXO_ID_DEFAULT ) {
	        if ( current.getTaxonomyID() == taxonomy_id ) {
	            n = current;
	        }
		else {
		    failed = true;
		}
	    }
	    if ( !failed ) {
	        nodes.addElement( n );
	    }
	    i.next();
	}
	
	nodes.trimToSize();
	return nodes;

    } // find( String, String, String, int )




    /**

    Returns a Vector of references to Nodes which match in 
    sequence name OR species OR EC number OR taxonomy ID.
    Matches are substring matches.
    Is case insensitive.
    <p>
    (Last modified: 07/30/01)

    @param query to String to match

    @return Vecotor of references to matching Nodes
    
    */
    public Vector findInNameSpecECid( String query ) throws Exception {
    
        Vector nodes           = new Vector();
	PreorderTreeIterator i = null;
        Node current           = null;
        
	if ( isEmpty() ) {
	    return null;
	}
       
        query = query.toLowerCase().trim();

        if ( query.equals( "" ) ) {
            return null;
        }
         
        i = new PreorderTreeIterator( this );

        while ( !i.isDone() ) {
	    current = i.currentNode();
	    if ( current.getSeqName().toLowerCase().indexOf( query ) >= 0 ) {
	        nodes.addElement( current );
	    }
	    else if ( current.getSpecies().toLowerCase().indexOf( query ) >= 0 ) {
		nodes.addElement( current );
	    }
	    else if ( current.getECnumber().toLowerCase().indexOf( query ) >= 0 ) {
		nodes.addElement( current );
            }
	    else {
	        String id = ( new Integer( current.getTaxonomyID() ) ).toString();
	        if ( id != null && id.equals( query ) ) {
	            nodes.addElement( current );
	        }
	    }
	    i.next();
	}
	
	nodes.trimToSize();
	return nodes;
    
    } // findInNameSpecECid( String )





    /**

    Returns a Vector with references to all Nodes of this Tree which
    have a matching sequence name.
    <p>
    (Last modified: 07/29/01)
    
    @param seqname Sequence name (String) of Nodes to find

    @return Vector of references to Nodes of this Tree with matching
    sequence names

    @see #getNodesWithMatchingSpecies(String)

    */
    public Vector getNodes( String seqname ) throws Exception {
        
        Vector nodes           = new Vector();
        PreorderTreeIterator i = null;

        if ( isEmpty() ) {
            return null;
        }

        i = new PreorderTreeIterator( this );
      
        while ( !i.isDone() ) {
            if ( i.currentNode().getSeqName().equals( seqname ) ) {
                nodes.addElement( i.currentNode() );
            }
            i.next();
        }

        nodes.trimToSize();
        return nodes;

    } // getNodes( String )



    
    /**

    Returns a Vector with references to all Nodes of this Tree which
    have a matching species name.

    @param specname species name (String) of Nodes to find

    @return Vector of references to Nodes of this Tree with matching
    species names.

    @see #getNodes(String)

    */
    public Vector getNodesWithMatchingSpecies( String specname ) throws Exception {
           
        Vector nodes           = new Vector();
        PreorderTreeIterator i = null;

        if ( isEmpty() ) {
            return null;
        }
         
        i = new PreorderTreeIterator( this );
        
        while ( !i.isDone() ) {
            if ( i.currentNode().getSpecies().equals( specname ) ) {
                nodes.addElement( i.currentNode() );
            }
            i.next();
        }

        nodes.trimToSize();
        return nodes;

    } // getNodesWithMatchingSpecies( String )




    /**

    Returns the sequence names of all external Nodes of this Tree
    as array of Strings.
    <p> 
    (Last modified: 11/13/00)

    @return all external sequence names as String[]

    */
    public String[] getAllExternalSeqNames() {

        int i = 0;

        if ( isEmpty() ) {
            return null;
        }
        
        String[] names = new String[ getNumberOfExtNodes() ];
        Node node = getExtNode0();
        while ( node != null ) {
                names[ i++ ] = new String( node.getSeqName() );
                node = node.getNextExtNode();
        } 
        return names;

    } // getAllExternalSeqNames()







    // ---------------------------------------------------------
    // Calculation of simple numerical values
    // ---------------------------------------------------------


    /**

    Calculates the real height of this (rooted) Tree -- the longest distance
    from root to external node.
    The height of this is stored and can be obtained with "getRealHeight()".
    Returns the difference in heights of the two subtrees originating at the
    root of this (which obviously only makes sense if this is rooted and binary
    at the root).
    Difference = height of subtree at child1 - height of subtree at child2
    (i.e. is positive if subtree 1 is higher, negative otherwise).
    <p>
    Takes into account collapsed Nodes.
    <p>
    (Last modified: 01/18/01)

    @return the difference in heigh of the two subtrees originating at the
            root of this Tree

    */
    public double calculateRealHeight() {

        Node   root   = null;
        Node   child1 = null,
               child2 = null;
        double r      = 0.0, 
               l      = 0.0,
               l1     = 0.0,          
               l2     = 0.0,
               diff   = 0.0;


        if ( isEmpty() ) {
            setRealHeight( 0.0 );
            return 0.0;
        }

        root   = getRoot();
        child1 = root.getChild1();
        child2 = root.getChild2();
        
        if ( isRooted() ) {
            r = root.getDistanceToParent();
            if ( r < 0.0 ) {
               r = 0.0;
            }
        }

        if ( child1 != null && child2 != null ) {
            l1 = calculateRealHeightHelper( child1 );
            l2 = calculateRealHeightHelper( child2 );

            diff = l1 - l2;

            l = ( l1 > l2 ? l1 : l2 );
        }
        
        setRealHeight( l + r );
        return diff;

    } // calculateRealHeight()



    // (Last modified: 07/03/01)
    private double calculateRealHeightHelper( Node n ) {
        if ( n == null ) {
            return 0.0;
        }
        else if ( n.collapse() ) {
           double l = n.getDistanceToParent();
           if ( l < 0.0 ) {
               l = 0.0;
           }
           return l;
        } 
        else {
            double l1 = calculateRealHeightHelper( n.getChild1() ), 
                   l2 = calculateRealHeightHelper( n.getChild2() ),
                   l  = n.getDistanceToParent();

            if ( l < 0.0 ) {
                l = 0.0;
            }
            return l + ( l1 > l2 ? l1 : l2 );
        }
    } // calculateRealHeightHelper( Node )



    /**

    Finds the highest of all log likelihood value associated with
    branches of this Tree.
    The result can be obtained with "getHighestLnL()".
    <p>
    (Last modifed: 11/18/00)    

    @see #getHighestLnL()

    */
    public void findExtremeLnL() {
        if ( isEmpty() ) {
            return;
        }
        lowest_lnL_  = +Double.MAX_VALUE;
        highest_lnL_ = -Double.MAX_VALUE;
        findExtremeLnLHelper( getRoot() );

    } // findExtremeLnL() 



    private void findExtremeLnLHelper( Node n ) {

        if ( n == null ) {
            return;
        }
        else {
            if ( n.isLnLonParentBranchAssigned()
            && !n.isPseudoNode() ) {
                if ( n.getLnLonParentBranch() > highest_lnL_ ) {
                    highest_lnL_ = n.getLnLonParentBranch();
                }
                if ( n.getLnLonParentBranch() < lowest_lnL_ ) {
                    lowest_lnL_ = n.getLnLonParentBranch();
                }
            }
            findExtremeLnLHelper( n.getChild1() );
            findExtremeLnLHelper( n.getChild2() );
        }

    } // findExtremeLnLHelper( Node )









    // ---------------------------------------------------------
    // Various methods to modify Tree (Node) values
    // ---------------------------------------------------------

    

    /**

    Modifies this Tree with the branch lenghts of Tree t.
    Important (but obvious): The topology of both trees
    needs to be the same. (The method is not robust in this point, and will
    produce wrong results if the internal topology differs.)
    Furthermore, the combination of sequence name, species, and EC number
    needs to be unique for each external node.
    <p>
    (Last modified: 05/22/01) 

    @param t the Tree to copy the branch lenghts from

    */
    public void copyBranchLengthValuesFrom( Tree t ) throws Exception {

        Node   node0  = null,
               node2_ = null,
               node1_ = null;
        Node[] nodes1 = null,
               nodes2 = null;
        int    i      = 0;

        if ( isEmpty() || t.isEmpty() ) {
            return;
        }
       
        setIndicatorsToZero();
        t.setIndicatorsToZero();

        // Visit each node of this and set distance to parent to 0.0:
        Node node2, node1 = getExtNode0();
        while ( node1 != null ) {
            node2 = node1;
            while ( node2 != null ) {
                if ( !node2.isExternal() ) {
                    node2.setDistanceToParent( 0.0 );
                }
                node2 = node2.getParent();
            }
            node1 = node1.getNextExtNode();
        }

        // Visit each internal node of t:
        node1 = t.getExtNode0();
        while ( node1 != null ) {
            node2 = node1;
            while ( node2 != null ) {
                if ( node2.getIndicator() == 0
                && !node2.isPseudoNode() ) {
                    node2.setIndicator( 1 );
                    nodes2 = node2.copyAllExtChildren();
                    node0 = nodes2[ 0 ];
                    i++;
                    node1_ = getExtNode0();
                    // Visit each internal node of this:
                    while ( node1_ != null ) {
                        node2_ = node1_;
                        if ( node0.equals( node1_ ) ) {
                            while ( node2_ != null ) {
                                if ( node2_.getIndicator()
                                != i && node2_.getIndicator() != -1 ) {
                                    node2_.setIndicator( i );
                                    if ( nodes2.length
                                    == node2_.getSumExtNodes() ) {
                                        nodes1 = node2_.copyAllExtChildren();
                                        if ( Node.compareArraysOfNodes(
                                         nodes2, nodes1 ) ) {
                                            node2_.setIndicator( -1 );
                                            node2_.setDistanceToParent(
                                             node2.getDistanceToParent() );
                                        }
                                        else {
                                            String message = "Trees were ";
                                            message += "not identical.";
                                            throw new Exception( message );
                                        }
                                    }
                                }
                                node2_ = node2_.getParent();
                            }
                        }
                        node1_ = node1_.getNextExtNode();
                    } //end of visiting each internal node of this.
                }
                node2 = node2.getParent();
            }
            node1 = node1.getNextExtNode();
        }
        if ( !t.isRooted() ) {
            setRooted( false );
        }
        else {
            setRooted( true );
        }
        recalculateAndReset();
        reassignIDs();

        return;

    } // copyBranchLengthValuesFrom( Tree ) 



    /**
    
    Moves the values in the branch length field to the bootstrap field, for
    each Node of this Tree.
    Converts a Tree originating from a phylip treefile after bootstrapping
    and which therefore has its bootstrap values where the branch lenghts
    would be.
    
    */
    public void moveBranchLenghtsToBootstrap() {
        
        Node node1 = null,
             node2 = null;

        if ( isEmpty() ) {
            return;
        }
        setIndicatorsToZero();
        node1 = getExtNode0();
        while ( node1 != null ) {
            node2 = node1;
            while ( node2 != null ) {
                if ( node2.getIndicator() == 0 ) {
                    if ( node2.getDistanceToParent() > 0.0 ) {
                        if ( !node2.isExternal() ) {
                            node2.setBootstrap( ( int ) node2.getDistanceToParent() );
                        }
                        node2.setDistanceToParent( Node.DISTANCE_DEFAULT );
                    }
                    else {
                        node2.setBootstrap( Node.BOOTSTRAP_DEFAULT );
                    }
                    node2.setIndicator( 1 );
                }
                node2 = node2.getParent();
            }
            node1 = node1.getNextExtNode();
        }
        recalculateAndReset();

    } // moveBranchLenghtsToBootstrap()
   






   
    // ---------------------------------------------------------
    // Inquiery of Tree properties
    // ---------------------------------------------------------



    /**

    Checks whether a Tree object is deleted (or empty).

    @return true if the tree is deleted (or empty), false otherwise

    */
    public boolean isEmpty() {
        return ( getExtNode0() == null );
    } // isEmpty()


   

    /**
  
    Returns whether this is a completely binary tree
    (i.e. all internal nodes are bifurcations).
    <p>
    (Last modifed: 05/26/01)
  
    */
    public boolean isCompletelyBinary() {
        if ( isEmpty() ) {
            return false;
        }
        return isCompletelyBinaryHelper( getRoot() );

    } // isCompletelyBinary()
    
    

    // Helper for isCompletelyBinary()
    private boolean isCompletelyBinaryHelper( Node n ) {
        if ( n == null ) {
            return true;
        }
        else if ( n.isPseudoNode() ) {
            return false;
        }
        boolean b1 = isCompletelyBinaryHelper( n.getChild1() ),
                b2 = isCompletelyBinaryHelper( n.getChild2() );
        if ( !b1 || !b2 ) {
            return false;
        }
        else {
            return true;
        }

    } // isCompletelyBinaryHelper( Node )
  
  

    /**

    Checks whether the branch length values actually are bootstrap values
    All external Nodes must have the same, >0, divisible by 10 branch length.
    Boostrap of root must be assigned.
    
    */
    public boolean areBranchLenghtsBootstraps() {

        Node   node = null;
        double d1   = 0.0, 
               d2   = 0.0;


        if ( isEmpty() ) {
            return false;
        }
        if ( getNumberOfExtNodes() <= 1 ) {
            return false;
        }
        // Has bootstrap already been assigned?
        if ( getRoot().getBootstrap() != Node.BOOTSTRAP_DEFAULT ) {
            return false;
        }

        node = getExtNode0();
        
        while ( node != null ) {
            d1 = node.getDistanceToParent();
            if ( d1 <= 0.0 || ( d1 %  10 ) != 0 ) {
                return false;
            }
            node = node.getNextExtNode();
            if ( node != null ) {
                d2 = node.getDistanceToParent();
                if ( d2 <= 0.0 || ( d2 %  10 ) != 0 ) {
                    return false;
                }
                if ( d1 != d2 ) {
                    return false;
                }
            }
        }
        return true;

    } // areBranchLenghtsBootstraps()







    // ---------------------------------------------------------
    // Ordered Tree labeling
    // ---------------------------------------------------------


    /**

    Resets the ID numbers of the Nodes of this Tree in
    level order, starting with i (for the root).
    Warning. After this method has been called, node IDs
    are not longer unique.
    Implemented recursively.
    <p>
    (Last modified: 11/20/00)
    
    @param i the starting value (int)

    */
    public void levelOrderReID( int i ) {

        idhash_ = null;
        levelOrderReIDHelper( getRoot(), i );

    } // levelOrderReID( int )



    // Helper method for levelOrderReID.
    private void levelOrderReIDHelper( Node n, int label ) {
        n.setID( label );
        label++;
        if ( n.getChild1() != null ) {
            levelOrderReIDHelper( n.getChild1(), label );
        }
        if ( n.getChild2() != null ) {
            levelOrderReIDHelper( n.getChild2(), label );
        }

    } // levelOrderReIDHelper( Node, int )



    /**

    Resets the ID numbers of the Nodes of this Tree in
    preorder, starting with i. Implemented using a Stack.
    <p>
    (Last modified: 11/20/00)    

    @param i the starting value (int)

    @return i plus the total number of Nodes of this Tree (int)
    
    */
    public int preorderReID( int i ) {

        Stack stack = null;
        Node  n     = null;

        if ( isEmpty() ) { 
            return i;
        }

        stack = new Stack();
        n = getRoot();
        stack.push( n );
        while ( !stack.empty() ) {
            n = ( Node ) stack.pop();
            n.setID( i++ ); 
            if ( n.getChild2() != null ) {
                stack.push( n.getChild2() );
            }
            if ( n.getChild1() != null ) {
                stack.push( n.getChild1() );
            }
            
        }
        idhash_ = null;
        return i;

    } // preorderReID( int )








    // ---------------------------------------------------------
    // Set and get methods
    // ---------------------------------------------------------


    /**

    Returns the root Node of this Tree.

    */
    public Node getRoot() {
        return root_;
    } // getRoot()
    
    
    
    void setRoot( Node n ) {
        root_ = n;
    } // setRoot( Node )

    
    
    /**

    Returns true is this Tree is rooted.

    */
    public boolean isRooted() {
        return rooted_;
    } // isRooted()
    
    
    
    /**

    Sets whether this Tree is rooted or not.

    */
    public void setRooted( boolean b ) {
        rooted_ = b;
    } // setRooted( boolean )
    
    
    
    private void setHighestLnL( double d ) {
        highest_lnL_ = d;
    } // setHighestLnL( double )
    
    
    
    /**

    Returns the highest log likelihood value associated with branches
    of this Tree (double).
    
    @see #findExtremeLnL()

    */
    public double getHighestLnL() {
        return highest_lnL_;
    } // getHighestLnL() 
    
    
    
    private void setLowestLnL( double d ) {
        lowest_lnL_ = d;
    } // setLowestLnL( double d )
    
    
    
    /**
    
    Returns the lowest log likelihood value associated with branches
    of this Tree (double).

    @see #findExtremeLnL()

    */
    public double getLowestLnL() {
        return lowest_lnL_;
    } // getLowestLnL().
    
    
    
    /**

    Returns the real height of this Tree - the longest distance
    from root to external node. Is either calculated with
    "calculateRealHeight()" or manualy set with
    "setRealHeight(double)".

    @return the real height of this Tree - as calculated
            with "calculateRealHeight()" or set with
            "setRealHeight(double)"

    @see #calculateRealHeight()
    @see #setRealHeight(double)

    */
    public double getRealHeight() {
        return real_height_;
    } // getRealHeight()
    
    

    /**

    Sets the real height of this Tree - the longest distance
    from root to external node. Could either be calculated with
    "calculateRealHeight()" or manualy set with this method.
   
    @param the real height of this Tree

    @see #calculateRealHeight()

    */
    public void setRealHeight ( double d ) {
        real_height_  = d;
    }  // setRealHeight ( double )



    /**

    Returns the number of duplications of this Tree (int).
    A return value of -1 indicates that the number of duplications
    is unknown.

    */
    public int getNumberOfDuplications() {
        return number_of_duplications_;
    } // getNumberOfDuplications()
    
    
    
    /**
    
    Sets the number of duplications of this Tree (int).
    A value of -1 indicates that the number of duplications
    is unknown.
    
    @param clean_nh set to true for clean NH format
    
    */
    public void setNumberOfDuplications( int i ) {
        if ( i < 0 ) {
            number_of_duplications_ = -1;    
        }
        else {
            number_of_duplications_ = i;
        }
    } // setNumberOfDuplications( int )
    
    
    
    /**

    Returns the first external Node.

    */
    public Node getExtNode0() {
        return ext_node0_;
    } // getExtNode0()
    
    
    
    private void setExtNode0( Node n ) {
        ext_node0_ = n;
    } // setExtNode0( Node )
    
    
    
    /**

    Returns the sum of external Nodes of this Tree (int).
  
    */
    public int getNumberOfExtNodes() {
        return external_nodes_;
    } // getNumberOfExtNodes()
    

    
    /**

    Sets the sum of external Nodes of this Tree (int).
  
    */
    public void setExtNodes( int i ) {
        external_nodes_ = i;
    } // setExtNodes( int )
    
    
    
    /**
    
    Returns whether to allow more than binary Nodes in New Hampshire (NH)
    output. The basal node can always appear trifurcated in the NH output.

    */
    private boolean allowMoreThanBinaryNodesInNHoutput() {
        return more_than_bin_nodes_in_NH_;
    } // allowMoreThanBinaryNodesInNHoutput()


    
    
    /**

    Sets whether to allow more than binary Nodes in New Hampshire (NH)
    output. The basal node can always appear trifurcated in the NH output.

    */
    public void allowMoreThanBinaryNodesInNHoutput( boolean b ) {
        more_than_bin_nodes_in_NH_ = b;
    } // allowMoreThanBinaryNodesInNHoutput( boolean )



    /**
    
    Returns the name of this Tree.

    */
    public String getName() {
        return name_;
    } // getName()


    
    
    /**

    Sets the name of this Tree to s.

    */
    public void setName( String s ) {
        name_ = s;
    } // setName( String )









    // ---------------------------------------------------------
    // Writing of Tree to Strings
    // ---------------------------------------------------------


    /**
  
    Converts this Tree to a New Hampshire X (String) representation.
    
    @return New Hampshire X (String) representation of this
    
    @see #toNewHampshireX()
    
    */
    public String toString() {
        if ( isEmpty() ) {
            return "";
        }
        return toNewHampshireX();

    } // toString()



    /**
  
    Converts this Tree to a New Hampshire (String) representation.
    If the boolean clean_nh is true, the length of sequence names
    will be truncated to MAX_LENGTH (usually 10) characters and 
    everything after a "/" will be removed (including the "/"). 
    <br>
    (Last modified: 06/28/01)

    @param clean_nh set to true for clean NH format

    @return New Hampshire (String) representation of this
    
    */
    public String toNewHampshire( boolean clean_nh ) {

        int    i         = 0;
        String s         = "", 
               nh_string = "";
        Stack  A_stack   = null,
               B_stack   = null;
        Node   node      = null;

        if ( isEmpty() ) {
            return "";
        }
      
        A_stack = new Stack();
        B_stack = new Stack();
        node    = getRoot();

        adjustNodeCount( false );
        
        setIndicatorsToZero();

        do {
            if ( !node.isExternal() ) {
                if ( node.getIndicator() == 0 ) {
                    node.setIndicator( 1 );
                    node = node.getChild1();
                }
                if ( node.getIndicator() == 1  ) {
                    node.setIndicator( 2 );
                    node = node.getChild2();
                }
                // Add internal node:
                if ( node.getIndicator() == 2 ) {

                    if ( !node.isPseudoNode()
                    || ( !allowMoreThanBinaryNodesInNHoutput()
                     && !node.getParent().isRoot()
                     && ( !(node.getParent().getChild1().isPseudoNode()  
                      && node.getParent().getChild2().isPseudoNode() )
                     || node.getParent().getChild1() == node ) ) ) {

                        i = 0;
                        while ( i < 2 * node.getSumExtNodes() - 2 ) {
                            B_stack.push( A_stack.pop() );
                            if ( !B_stack.peek().toString().equals( "(" )
                            && !B_stack.peek().toString().equals( ")" ) ) {
                                i++;
                            }
                        }
                        A_stack.push( "(" );
                        while ( !B_stack.empty() ) {
                            A_stack.push( B_stack.pop() );
                        }
                        A_stack.push( ")" );
                    }

                    if ( node.getDistanceToParent() >= 0.0
                    && !node.isPseudoNode() ) {
                        s = ":" + node.getDistanceToParent() + ",";
                    }
                    else if ( node.isPseudoNode()
                    && !allowMoreThanBinaryNodesInNHoutput()
                    && !node.getParent().isRoot()
                    && ( !(node.getParent().getChild1().isPseudoNode()
                     && node.getParent().getChild2().isPseudoNode() )
                     || node.getParent().getChild1() == node ) ) {
                        s = ":0.0,";
                    }
                    else {
                        s = ",";
                    }

                    A_stack.push( s );

                    node = node.getParent();
                }
            }
            // Add external node. Always preceeded by a "," which will need
            // to be removed in cases of "(,X"
            else {
                // If no seq_name is given, use species as name;
                // If no species is given, use EC as name
                // Otherwise, no information will be given.
                
                if ( clean_nh && !node.getSeqName().equals( "" ) ) {

                    String tmp = node.getSeqName();

                    try {
                        if ( tmp.length() > MAX_LENGTH ) {
                            tmp = tmp.substring( 0, MAX_LENGTH + 1 );
                        }
                        if ( tmp.indexOf( '/' ) > 0 ) {
                            tmp = tmp.substring( 0, tmp.indexOf( '/' ) );
                        }
                    }
                    catch ( Exception e ) {
                        System.err.println( "\ntoNewHampshire()" +
                        "Unexpected Exception.\n" );
                    }

                    s = "," + tmp;
                }
                else if ( !clean_nh && !node.getSeqName().equals( "" ) ) {
                    s = "," + node.getSeqName();
                }
                else if ( !clean_nh && !node.getSpecies().equals( "" ) ) {
                    s = "," + node.getSpecies();
                }
                else if ( !clean_nh && !node.getECnumber().equals( "" ) ) {
                    s = "," + node.getECnumber();
                }
                else {
                    s = ",\t";
                    // Introduces a tab to prevent comma from being removed.
                    // Tab is removed later.
                }
                if ( node.getDistanceToParent() >= 0.0 ) {
                    s += ( ":" + node.getDistanceToParent() );
                }
                A_stack.push( s );
                // Need to check whether parent is null in case the tree is only
                // one node:
                if ( !node.isRoot() ) {
                    node = node.getParent();
                }
                else {
                    node.setIndicator( 2 );
                }
            }
        } while ( !node.isRoot() || node.getIndicator() != 2 );

        //inverse:
        while ( !A_stack.empty() ) {
            B_stack.push( A_stack.pop() );
        }

        //make a nh string out of B_stack:
        nh_string = stackToString( B_stack ); 
 
        adjustNodeCount( true );

        //In case tree is just one node -- return empty string:
        if ( nh_string.indexOf( "(" ) == -1 ) {
            return "";
        }

        return nh_string;

    } // toNewHampshire( boolean )



    /**
  
    Converts this Tree to a New Hampshire X (String) representation.
    <br>
    (Last modified: 06/28/01)
    
    @return New Hampshire X (String) representation of this
    
    */
    public String toNewHampshireX() {

        int    i         = 0;
        String s         = "", 
               nh_string = "";
        Stack  A_stack   = null,
               B_stack   = null;
        Node   node      = null;

        if ( isEmpty() ) {
            return "";
        }

        A_stack = new Stack();
        B_stack = new Stack();
        node = getRoot();

        adjustNodeCount( false );

        setIndicatorsToZero();

        do {
            if ( !node.isExternal() ) {
                if ( node.getIndicator() == 0 ) {
                    node.setIndicator( 1 );
                    node = node.getChild1();
                }
                if ( node.getIndicator() == 1 ) {
                    node.setIndicator( 2 );
                    node = node.getChild2();
                }
                // Add internal node:
                if ( node.getIndicator() == 2 ) {

                    if ( !node.isPseudoNode()
                    || ( !allowMoreThanBinaryNodesInNHoutput()
                    && !node.getParent().isRoot() )
                    && ( !(node.getParent().getChild1().isPseudoNode()  &&
                    node.getParent().getChild2().isPseudoNode() ) ||
                    node.getParent().getChild1() == node ) ) {
                        i = 0;
                        while ( i < 2 * node.getSumExtNodes() - 2 ) {

                            B_stack.push( A_stack.pop() );
                            if (    !B_stack.peek().toString().equals( "(" )
                            &&  !B_stack.peek().toString().equals( ")" ) ) {
                                i++;
                            }
                        }
                        A_stack.push( "(" );
                        while ( !B_stack.empty() ) {
                            A_stack.push( B_stack.pop() );
                        }
                        A_stack.push( ")" );
                    }

                    // If there is info about an internal node, a "," needs to be added.
                    // In cases of ",)" the comma will be removed later.

                    s = "";
                    if ( !node.isPseudoNode() ) {

                        s = node.toNewHampshireX();
                        
                    }
                    else if ( node.isPseudoNode()
                    && !allowMoreThanBinaryNodesInNHoutput()
                    && !node.getParent().isRoot()
                    && ( !(node.getParent().getChild1().isPseudoNode()  &&
                    node.getParent().getChild2().isPseudoNode() ) ||
                    node.getParent().getChild1() == node ) ) {
                        s = ":0.0";
                    }
                    // If s contains something, add a comma:
                    if ( s.length() >= 1 ) {
                        s += ",";
                    }
                    A_stack.push( s );
                    node = node.getParent();
                }
            }
            // Add external node. Always preceeded by a "," which will need
            // to be removed in cases of "(,X"
            else {
                s = ",";
                s += node.toNewHampshireX();
               
                A_stack.push( s );

                // Need to check whether parent is null in case the tree is only
                // one node:
                if ( !node.isRoot() ) {
                    node = node.getParent();
                }
                else {
                    node.setIndicator( 2 );
                }
            }


        } while ( !node.isRoot() || node.getIndicator() != 2 );

        //inverse:
        while ( !A_stack.empty() ) {
            B_stack.push( A_stack.pop() );
        }
        //make a nh string out of B_stack:
        nh_string = stackToString( B_stack );

        // If information is present about the root, add it after the last ")":
        if ( getNumberOfExtNodes() >= 2
        && ( !root_.getSeqName().equals( "" ) || root_.getDistanceToParent() != 0.0
        || !root_.getSpecies().equals( "" ) || !root_.getECnumber().equals( "" )
        || root_.isLnLonParentBranchAssigned() || root_.isDuplicationOrSpecAssigned()
        || root_.getBootstrap() != 0 ) ) {

            //remove ; at the end
            nh_string = nh_string.substring( 0, nh_string.length() - 1 );

            nh_string += node.toNewHampshireX();
            
            nh_string += ";";
        }

        adjustNodeCount( true );

        return nh_string;

    } // toNewHampshireX()

 
  
    // Private helper method used by the "toNewHampshire..." methods.
    private String stackToString( Stack stack ) {
       
        int           i       = 0;
        String        s       = ""; 
        StringBuffer  string  = new StringBuffer( 10000 );

        if ( getNumberOfExtNodes() >= 2 ) {
            string.append( "(" );
        }
        else {
            // No need to add a "(" if tree has just one node
            string.append( "" );
        }
        while ( !stack.empty() ) {
            s =  stack.pop().toString();
            //add "," in between ")(":
            if (  s.startsWith( "(" ) && string.charAt( string.length() -1 ) ==  ')' ) {
                string.append( "," );
                string.append( s );
            } 
            //add "," in between "'not(,'(":
            else if ( s.startsWith( "(" ) && string.length() > 0 && string.charAt( string.length() -1 ) !=  '(' 
            && string.charAt( string.length() -1 ) !=  ',' ) {
                string.append( "," );
                string.append( s );
            }
            //get rid of the "," in "(,X":
            else if (  s.startsWith( "," ) && string.length() > 0 && string.charAt( string.length() -1 ) ==  '(' ) {
                string.append( s.substring( 1 ) );
            }
            //get rid of the "," in "X,)":
            else if (  s.startsWith( ")" ) && string.length() > 0 && string.charAt( string.length() -1 ) ==  ',' ) {
                string = new StringBuffer( string.toString().substring( 0, string.length() - 1 ) );
                string.append( s );
            }
            //get rid of one comma in ",,":
            else if (  s.startsWith( "," ) && string.length() > 0 && string.charAt( string.length() -1 ) ==  ',' ) {
                string.append( s.substring( 1 ) );
            }
            else {
                string.append( s );
            }
        }

        // Remove "," at end of nh_string:
        if ( string.charAt( string.length() -1 ) == ','  ) {
            string = new StringBuffer( string.toString().substring( 0, string.length() - 1 ) );
        }
        if ( getNumberOfExtNodes() >=2 ) {
            string.append( ");" );
        }
        else {
            // No need to add a "(" if tree has just one node
            string.append( ";" );
        }
        // Remove "," at begining of nh_string (can only happen
        // if tree contains just one node):
        if ( string.charAt( 0 ) == ',' ) {
            string = new StringBuffer( string.toString().substring( 1 ) );
        }


        // Remove tabs which were introduced to protect commas originating from
        // unnamed ext nodes from being removed:
        //sb = new StringBuffer( string );

        for ( i = 0; i <= string.length() - 1; i++ ) {
            if ( string.charAt( i ) == '\t' ) {
                string = new StringBuffer( string.toString().substring( 0, i ) +
                string.toString().substring( i + 1 ) );
                i--;
            }
       }

       return string.toString();
              
    } // stackToString( Stack )

    







    // ---------------------------------------------------------
    // Basic printing
    // ---------------------------------------------------------


    /**

    Prints descriptions of all external Nodes of this Tree to System.out.

    */
    public void printExtNodes() {

        Node node = getExtNode0();

        if ( isEmpty() ) { 
            return;
        }
        
        while ( node != null ) {
            System.out.println( node + "\n" );
            node = node.getNextExtNode();
        }

    } // printExtNodes()



    /**

    Prints descriptions of all Nodes of this Tree to the console.

    */
    public void printAllNodes() {
        if ( isEmpty() ) { 
            return;
        }
        getRoot().preorderPrint();
    } // printAllNodes()









    // --------------------------------------------------------------------
    // Adjust methods (related to Tree construcation and Tree modification)
    // --------------------------------------------------------------------


    /**

    Sets the indicators of all Nodes of this Tree to 0.

    */
    public void setIndicatorsToZero() {

        if ( isEmpty() ) {
            return;
        }
        getRoot().setIndicatorsToZero();
        
    } // setIndicatorsToZero()




    /**

    Hashes the ID number of each Node of this Tree to its corresonding
    Node, in order to make method getNode( id ) run in constant time.
    Important: The user is responsible for calling this method (again) after
    this Tree has been changed/created/renumbered. 

    */
    public void hashIDs() {
 
        idhash_      = null;
        Stack stack  = null;
        Node  n      = null;

        if ( isEmpty() ) {
            return;
        }
             
        //idhash = new HashMap(); // Requires JDK 1.2 or greater.
        idhash_ = new Hashtable();  // For JDK 1.1.

        stack = new Stack();
        n = getRoot();
        stack.push( n );
        while ( !stack.empty() ) {
            n = ( Node ) stack.pop(); 
            // ID is the key, reference to Node is the value.
            idhash_.put( new Integer( n.getID() ), n );
            if ( n.getChild1() != null ) {
                stack.push( n.getChild1() );
            }
            if ( n.getChild2() != null ) {
                stack.push( n.getChild2() );
            }
        }

    } // hashIDs()




    /**

    Recalculates and resets parameters of this Tree:
    <ul>
    <li> highest and lowest lnL
    <li> real height
    <li> sum of ext Nodes
    </ul> 
    To be used after Tree has been modified.
    <p>
    (Last modified: 11/18/00)

    */
    public void recalculateAndReset() {

        if ( isEmpty() ) {
            return;
        }

        findExtremeLnL();
        calculateRealHeight();
        setExtNodes( getRoot().getSumExtNodes() );

    } // recalculateAndReset()



    /**
  
    (Re)counts the number of children for each Node of this Tree.
    As an example, this method needs to be called after a Tree has
    been reRooted and it is to be diplayed.
    <p>
    (Last modifed 06/28/00)

    @param considerCollapsedNodes set to true to take into account
                                  collapsed nodes (collapsed nodes
                                  have 1 child). 
    

    */
    public void adjustNodeCount( boolean considerCollapsedNodes ) {

        Node node1 = null,
             node2 = null;

        if ( isEmpty() ) {
            return;
        }

        adjustNodeCountHelper( getRoot() );

        //Set all to the new, correct values:
        node2 = getExtNode0();
        O: do {
            node1 = node2;
            do {
                if ( considerCollapsedNodes && node1.collapse() ) {
                    if ( node1.getIndicator() != 1 ) {
                        node1.setIndicator( 1 );  
                    }
                    else {
                        node2 = node2.getNextExtNode();
                        continue O;
                    }  
                }
                node1.setSumExtNodes( node1.getSumExtNodes() + 1 );
                node1 = node1.getParent();
            } while ( node1 != null );
            node2 = node2.getNextExtNode();
        } while( node2 != null );

    } // adjustNodeCount(boolean)


 
    private void adjustNodeCountHelper( Node n ) {
    
        if ( n == null ) {
            return;
        }
        else {
            n.setSumExtNodes( 0 );
            n.setIndicator( 0 );
            adjustNodeCountHelper( n.getChild1() );
            adjustNodeCountHelper( n.getChild2() );
        }
    } // adjustNodeCountHelper(Node)



    // Reassigns the IDs of the Nodes of this Tree.
    private void reassignIDs() {

        PreorderTreeIterator i = null;

        if ( isEmpty() ) {
            return;
        }
        
        try {
            i = new PreorderTreeIterator( this );
        }
        catch ( Exception e ) {
            System.err.println( "Unexpected failure: Could not create Iterator." );
            e.printStackTrace();
            System.exit( -1 );
        }
        while ( !i.isDone() ) {
            Node.setNodeCount( Node.getNodeCount() + 1 );
            i.currentNode().setID( Node.getNodeCount() );
            i.next();
        }
        idhash_ = null;

    } // reassignIDs()




    // Adjusts the references (previous and next) in the
    // external Nodes of this Tree.
    private void adjustReferencesInExtNodes() {

        Node node      = null,
             prev_node = null;

        if ( isEmpty() ) {
            return;
        }

        // getIndicator() must be 0 for all nodes:
        getRoot().setIndicatorsToZero();

        node = getRoot();

        if ( getNumberOfExtNodes() <= 1 ) {
            return;
        }

        do {

            if ( node.getIndicator() == 0 && !node.isExternal() ) {
                node.setIndicator( 1 );
                node = node.getChild1();
            }

            if ( node.getIndicator() == 1 && !node.isExternal() ) {
                node.setIndicator( 2 );
                node = node.getChild2();
            }

            if ( node.isExternal() ) {

                node.setNextExtNode( null );
                node.setPrevExtNode( prev_node );
                if ( prev_node != null ) {
                    prev_node.setNextExtNode( node );
                }

                prev_node = node;
                node.setIndicator( 2 );

            }

            // Moving towards the root:
            if ( node.getIndicator() == 2 ) {
                node = node.getParent();
            }

        } while ( !node.isRoot() || node.getIndicator() != 2 );

    } // adjustReferencesInExtNodes()


   
    // Adjusts the "first" external Node.
    private void adjustExtNode0() {

        Node node = getRoot();

        if ( node == null ) {
           return;
        }
        while ( !node.isExternal() ) {
            node = node.getChild1();
        }
        setExtNode0( node );

    } // adjustExtNode0()








    // ---------------------------------------------------------
    // Tree creation
    // ---------------------------------------------------------


    // Used for building Trees.
    void addNodeAndConnect( String s1, String s2 ) throws Exception {
        if ( getExtNode0() == null ) {
            System.err.println( "addNodeAndConnect( String, String ): Error: Cannot add and connect one node to empty tree." );
            System.exit( -1 );
        }
        getExtNode0().addExtNode( s1 );
        getExtNode0().connect( s2 );
        external_nodes_++;

    } // addNodeAndConnect( String, String )




    // Used for building Trees.
    private void addNode( String s ) throws Exception {
        if ( getExtNode0() == null ) {
            setExtNode0( new Node( s ) );
        }
        else {
            getExtNode0().addExtNode( s );
        }
        external_nodes_++;

    } // addNode( String ) 




    // Used for building Trees.
    private void connectInternal( String s ) throws Exception {

        if ( isEmpty() ) { 
           return;
        }
        getExtNode0().connect( s );

    } // connectInternal( String )




} // End of class Tree.

