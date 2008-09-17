// Node.java
//
// Copyright (C) 1999-2002 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved
//
// Created: 1999
// Author: Christian M. Zmasek
// zmasek@genetics.wustl.edu
// http://www.genetics.wustl.edu/eddy/people/zmasek/


package forester.tree;


import java.util.*;
import java.io.*;


/**

@author Christian M. Zmasek

@version 1.700 -- last modified: 02/16/02

*/
public class Node implements Serializable {

    // See Horstmann and Cornell: Core Java 1.2 Vol I, p.686.
    static final long serialVersionUID = -896584903030L;
                      
   
    /** Value of -99.0 is used as default value. */
    public final static double DISTANCE_DEFAULT = -99.0;
    
    
    /** Value of -99 is used as default value. */
    public final static int BOOTSTRAP_DEFAULT = -99;
    
    /** Value of -99 is used as default value. */
    public final static int TAXO_ID_DEFAULT = -99;    


    /** Value of -100 is used to indicate that the branch does not exist.
        I.e. to simulate nodes with more than two children. */
    public final static double DISTANCE_NULL = -100.0;


    /** Value of getOrthologous == -11 is used to indicate that this Node is 
        sequence X in the context of orthologous relationships. */
    public final static int SEQ_X  = -11;

    public final static int ORTHOLOGOUS_DEFAULT = 0;


    private static int node_count = 0; // Used to assign ids to nodes.


    private int     indicator,
                    id,
                    taxo_id,           // NCBI taxonomy ID.
                    bootstrap,
                    sum_ext_nodes,
                    orthologous,
                    super_orthologous,
                    subtree_neighborings,
                    x,                 // Coordinates for drawing of tree
                    y;        
    private String  seq_name,
                    ec_number,
                    species;
    private double  distance_parent;
    private float   lnL_on_parent_branch;
    private boolean lnL_on_parent_branch_assigned,
                    significantly_worse,
                    duplication_or_spec_assigned,
                    duplication,
                    collapse;
    private Node    next_ext_node, // Used only in ext Nodes.
                    prev_ext_node, // Used only in ext Nodes.
                    child1,
                    child2,
                    parent,
                    link;         // Link to another Node (possibly
                                  // in another Tree).
    private Vector  vector;       // Used in Eulenstein's algorithm.






    // ---------------------------------------------------------
    // Constructors
    // ---------------------------------------------------------


    /**

    Constructor for Node.
    <p>
    (Last modified: 06/12/01)

    @param s String representing one Node in New Hampshire (NH)
             or New Hampshire X (NHX) format.

    */
    public Node( String s ) throws Exception {

        next_ext_node = null;
        prev_ext_node = null;
        child1        = null;
        child2        = null;
        parent        = null;
        id            = 0;
        deleteData();

        if ( s != null && s.length() > 0 ) {

            int             ob = 0,
                            cb = 0;
            String          a  = "",
                            b  = "";
            StringTokenizer t  = null;

            ob = s.indexOf( "[" );
            cb = s.indexOf( "]" );      

            if ( ob > -1 ) {
                a = "";
                b = "";

                if ( cb < 0 ) {
                    throw new Exception( "Node( String ): Error in NHX format: No closing ]" );
                }
                if ( s.indexOf( "&&NHX" ) == ob + 1 ) {
                    a = s.substring( 0, ob );
                    b = s.substring( ob + 6, cb );
                }
                else {
                    a = s.substring( 0, ob );
                }
                s = a + b;
                if ( s.indexOf( "[" ) > -1 || s.indexOf( "]" ) > -1 ) {
                    throw new Exception( "Node( String ): Error in NHX format: More than one ] or [" );
                }
            }

            t = new StringTokenizer( s, ":" );
            if ( t.countTokens() >= 1 ) {
                if ( !s.startsWith( ":" ) ) {
                    setSeqName( t.nextToken() );
                }
                while ( t.hasMoreTokens() ) {
                    s = t.nextToken();
                    if ( s.startsWith( "S=" ) ) {
                        setSpecies( s.substring( 2 ) );
                    }
                    else if ( s.startsWith( "E=" ) ) {
                        setECnumber( s.substring( 2 ) );
                    }
                    else if ( s.startsWith( "L=" ) ) {
                        setLnLonParentBranch( Float.valueOf( s.substring( 2 ) ).floatValue() );
                    }
                    else if ( s.startsWith( "D=" ) ) {
                        if ( s.charAt( 2 ) == 'Y' ) {
                            setDuplication( true );
                        }
                        else if ( s.charAt( 2 ) == 'N' ) {
                            setDuplication( false );
                        }
                        else {
                            throw new Exception( "Node( String ): Error in NHX format: :D=Y or :D=N" );
                        }
                    }
                    else if ( s.startsWith( "Sw=" ) ) {
                        if ( s.charAt( 3 ) == 'Y' ) {
                            setSignificantlyWorse( true );
                        }
                        else if ( s.charAt( 3 ) == 'N' ) {
                            setSignificantlyWorse( false );
                        }
                        else {
                            throw new Exception( "Node( String ): Error in NHX format: :Sw=Y or :Sw=N" );
                        }
                    }
                    else if ( s.startsWith( "Co=" ) ) {
                        if ( s.charAt( 3 ) == 'Y' ) {
                            setCollapse( true );
                        }
                        else if ( s.charAt( 3 ) == 'N' ) {
                            setCollapse( false );
                        }
                        else {
                            throw new Exception( "Node( String ): Error in NHX format: :Co=Y or :Co=N" );
                        }
                    }
                    else if ( s.startsWith( "B=" ) ) {
                        setBootstrap( Integer.parseInt( s.substring( 2 ) ) );
                    }
                    else if ( s.startsWith( "T=" ) ) {
                        setTaxonomyID( Integer.parseInt( s.substring( 2 ) ) );
                    }
                    else if ( s.startsWith( "O=" ) ) {
                        setOrthologous( Integer.parseInt( s.substring( 2 ) ) );
                    }
                    else if ( s.startsWith( "SO=" ) ) {
                        setSuperOrthologous( Integer.parseInt( s.substring( 3 ) ) );
                    }
                    else if ( s.startsWith( "SN=" ) ) {
                        setSubtreeNeighborings( Integer.parseInt( s.substring( 3 ) ) );
                    }
                    else if ( s.startsWith( "Bp=" ) ) {
                        // Bp= tag is not used anymore, this is just here for 
                        // compatibility with old NHX files.
                    }
                    else {
                        if ( distance_parent != DISTANCE_DEFAULT ) {
                            throw new Exception( "Node( String ):"
                            + " Error in NHX format: More than one distance to parent"
                            + " or non existing tag used." );
                        }
                        setDistanceToParent( Double.valueOf( s ).doubleValue() );
                    }
                } // end of while loop
            }
        }

        setID( getNodeCount() );
        increaseNodeCount();

        setSumExtNodes( 1 );  // For ext node, this number is 1 (not 0!!)

    } // Node( String s )



    /**

    Default constructor for Node.
    <p>
    (Last modified: 06/12/01)

    */
    public Node() {
   
        next_ext_node = null;
        prev_ext_node = null;
        child1        = null;
        child2        = null;
        parent        = null;
        id            = 0;
        deleteData();

        setID( getNodeCount() );
        increaseNodeCount();
        setSumExtNodes( 1 );  // For ext node, this number is 1 (not 0!!)

    } // Node()





    // ---------------------------------------------------------
    // Copy and delete Nodes, copy subtress
    // ---------------------------------------------------------

 
    /**
    
    Returns a new Node which has its data copied from this Node.
    Links to the other Nodes in the same Tree are NOT copied (e.g.
    link to parent).
    Field "link" IS copied.
    
    @see #getLink()
    
    */
    public Node copyNodeData() {

        Node node = null;

        node = new Node();

        decreaseNodeCount();

        node.id                            = id;
        node.bootstrap                     = bootstrap;
        node.sum_ext_nodes                 = sum_ext_nodes;
        node.indicator                     = indicator;
        node.x                             = x;
        node.y                             = y;
        node.duplication                   = duplication;
        node.seq_name                      = seq_name;
        node.ec_number                     = ec_number;
        node.species                       = species;
        node.taxo_id                       = taxo_id;
        node.orthologous                   = orthologous;
        node.super_orthologous             = super_orthologous;
        node.subtree_neighborings          = subtree_neighborings;
        node.distance_parent               = distance_parent;
        node.lnL_on_parent_branch          = lnL_on_parent_branch;
        node.lnL_on_parent_branch_assigned = lnL_on_parent_branch_assigned;
        node.significantly_worse           = significantly_worse;
        node.duplication_or_spec_assigned  = duplication_or_spec_assigned;
        node.collapse                      = collapse;
        node.link                          = link;
        node.vector                        = vector;

        return node;
    } // copyNodeData()



    /**
   
    Deletes data of this Node.
    Links to the other Nodes in the Tree, the ID and the sum
    of external nodes are NOT deleted.
    Field "link" (link to Nodes in other Tree) IS deleted.
    
    @see #getLink()
    
    */
    public void deleteData() {
    
        indicator                     = 0;
        taxo_id                       = TAXO_ID_DEFAULT;
        bootstrap                     = BOOTSTRAP_DEFAULT;
        orthologous                   = ORTHOLOGOUS_DEFAULT;
        super_orthologous             = ORTHOLOGOUS_DEFAULT;
        subtree_neighborings          = ORTHOLOGOUS_DEFAULT;
        x                             = 0;
        y                             = 0;                           
        seq_name                      = "";
        ec_number                     = "";
        species                       = "";
        distance_parent               = DISTANCE_DEFAULT;
        lnL_on_parent_branch          = 0.0f;
        lnL_on_parent_branch_assigned = false;
        significantly_worse           = true;
        duplication_or_spec_assigned  = false;
        duplication                   = false;
        collapse                      = false;
        link                          = null;
        vector                        = null;

    } // deleteData()



    /**

    Deep copies the Tree originating from this Node. 

    */
    static Node copyTree( Node source ) {

        if ( source == null ) {
            return null;
        }
        else {

            Node newnode = source.copyNodeData();

            newnode.child1 = copyTree( source.child1 );
            newnode.child2 = copyTree( source.child2 );

            return newnode;
        }
    } // copyTree( Node )








    // ---------------------------------------------------------
    // Static set and get methods for Node class
    // ---------------------------------------------------------


    /**

    Returns the total number of all Nodes created so far.

    @return total number of Nodes (int) 

    */
    public static int getNodeCount() {
        return node_count;
    }



    /**
    
    Sets the total number of all Nodes created so far to i (int). 
    
    */
    public static void setNodeCount( int i ) {
        
        node_count = i;
    }

    
    
    /**
    
    Increases the total number of all Nodes created so far by one. 
    
    */
    public static void increaseNodeCount() {
        ++node_count;
    }
    
    
    
    /**
    
    Decreases the total number of all Nodes created so far by one.
    
    */
    static void decreaseNodeCount() {
        --node_count;
    }
    


   


    
    // ---------------------------------------------------------
    // Set and get methods for Nodes
    // ---------------------------------------------------------


    /**

    Returns the ID (int) of this Node.

    */
    public int getID() {
        return id;
    }
    
    
    
    /**

    Sets the ID of this Node to i (int). In most cases,
    this number should not be set to values lower than getNodeCount().

    */
    public void setID( int i ) {
        id = i;
    }
    
    
    /**

    Returns the bootstrap value (int) of this Node.

    */
    public int getBootstrap() {
        return bootstrap;
    }
    
    
    
    /**

    Sets the bootstrap value of this Node to i (int).

    */
    public void setBootstrap( int i ) {
        if ( i < 0 && i != BOOTSTRAP_DEFAULT ) {
            bootstrap = 0;
            System.err.print( "Node: setBootstrap( int ): WARNING: Negative " );
            System.err.println( "bootstrap has been replaced by bootstrap 0!\n" );
        }
        else {
            bootstrap = i;
        }
    }



    /**

    Sets the NCBI Taxonomy ID of this Node to i (int).

    */
    public void setTaxonomyID( int i ) {
        taxo_id = i;
    }



    /**

    Returns the NCBI Taxonomy ID (int) of this Node.

    */
    public int getTaxonomyID() {
        return taxo_id;
    }



    /**

    Checks whether this Node is a pseudo Node, i.e. used to
    simulate nodes with more than two childrem. A pseudo node has no distance
    to its parent.

    @return true if this Node is a pseudo node, false otherwise

    */
    public boolean isPseudoNode() {
        return ( getDistanceToParent() == DISTANCE_NULL );
    }



    /**

    Checks whether this Node is external (tip).

    @return true if this Node is external, false otherwise

    */
    public boolean isExternal() {
        return ( getChild1() == null );
    }



    /**

    Checks whether this Node is a root.

    @return true if this Node is the root, false otherwise

    */
    public boolean isRoot() {
        return ( getParent() == null );
    }



    /**

    Returns the total number of external Nodes originating from this
    Node (int).

    */
    public int getSumExtNodes() {
        return sum_ext_nodes;
    }
    
    
    
    /**

    Sets the total number of external Nodes originating from this
    Node to i (int).

    */
    public void setSumExtNodes( int i ) {
        sum_ext_nodes = i;
    }
    
    
    
    /**

    Returns the indicator value of this Node (int).

    */
    public int getIndicator() {
        return indicator;
    }
    
    
    
    /**

    Sets the indicator value of this Node to i (int).

    */
    public void setIndicator( int i ) {
        indicator = i;
    }
    
    
    /**

    Used for drawing of Trees.

    */
    public int getXcoord() {
        return x;
    }
    
    
    
    /**

    Used for drawing of Trees.

    */
    public void setXcoord( int i ) {
        x = i;
    }
    
    
    
    /**

    Used for drawing of Trees.

    */
    public int getYcoord() {
        return y;
    }
    
    
    
    /**

    Used for drawing of Trees.

    */
    public void setYcoord( int i ) {
        y = i;
    }
    
    
    
    /**

    Returns true if this Node represents a duplication event,
    false otherwise. 

    */
    public boolean isDuplication() {
        return duplication;
    }
    
    
    
    /**

    Sets whether this Node represents a duplication event or not.

    */
    public void setDuplication( boolean b ) {
        duplication = b;
        setDuplicationOrSpecAssigned( true );
    }
    
    
    
    /**

    Sets the name of the sequence associated with this Node to String s.

    */
    public void setSeqName( String s ) {
        seq_name = s.trim();
    }
    
    
    
    /**

    Returns the name of the sequence associated with this Node (String).

    */
    public String getSeqName() {
        return seq_name;
    }
    
    
    
    /**

    Sets the EC number associated with this Node to String s.

    */
    public void setECnumber( String s ) {
        ec_number = s.trim();
    }
    
    
    
    /**

    Returns the EC number associated with this Node (as String).

    */
    public String getECnumber() {
        return ec_number;
    }
    
    
    
    /**

    Sets the name of the species associated with this Node to String s.

    */
    public void setSpecies( String s ) {
        species = s.trim();
    }
    
    
    
    /**

    Returns the name of the species associated with this Node (String).

    */
    public String getSpecies() {
        return species;
    }
    
    
    /**

    Returns the length of the branch leading to the parent of this Node (double).

    */
    public double getDistanceToParent() {
        return distance_parent;
    }
    
    
    
    /**

    Sets the length of the branch leading to the parent of this Node to double d.

    */
    public void setDistanceToParent( double d ) {
        if ( d < 0.0 && d != DISTANCE_DEFAULT && d != DISTANCE_NULL ) {
            distance_parent = 0.0;
        }
        else {
            distance_parent = d;
        }
    }
    
    
    
    /**

    Returns the log likelihood value associated
    with the branch leading to the parent of this Node (float).

    */
    public float getLnLonParentBranch() {
        return lnL_on_parent_branch;
    }
    
    
    
    /**

    Sets the log likelihood value associated
    with the branch leading to the parent of this Node to float f.

    */
    public void setLnLonParentBranch( float f ) {
        lnL_on_parent_branch = f;
        setLnLonParentBranchAssigned( true );
    }
    
    
    
    /**

    Returns a boolean which could represent whether placement
    of an additional Node on the parent branch of this Node
    makes the likelihood of the resulting tree significantly worse.

    */
    public boolean significantlyWorse() {
        return significantly_worse;
    }
    
    
    
    /**

    Sets a boolean which could represent whether placement
    of an additional Node on the parent branch of this Node
    makes the likelihood of the resulting tree significantly worse.

    */
    public void setSignificantlyWorse( boolean b ) {
        significantly_worse = b;
    }
    
    
    
    /**

    Returns whether a log likelihood value associated
    with the branch leading to the parent of this Node
    has been assigned.

    */
    public boolean isLnLonParentBranchAssigned() {
        return lnL_on_parent_branch_assigned;
    }
    
    
    
    /**

    Sets whether a log likelihood value associated
    with the branch leading to the parent of this Node
    has been assigned.

    */
    public void setLnLonParentBranchAssigned( boolean b ) {
        lnL_on_parent_branch_assigned = b;
    }
    
    
    
    /**

    Returns whether a duplication or speciation event has been assigned
    for this Node.

    */
    public boolean isDuplicationOrSpecAssigned() {
        return duplication_or_spec_assigned;
    }
    
    
    
    /**

    Sets whether a duplication or speciation event has been assigned
    for this Node.

    */
    public void setDuplicationOrSpecAssigned( boolean b ) {
        duplication_or_spec_assigned = b;
    }
    
    
    
    /**

    Sets whether this Node should be drawn as collapsed.

    */
    public void setCollapse( boolean b ) {
        collapse = b;
    }
    
    
    
    /**

    Returns whether this Node should be drawn as collapsed.

    */
    public boolean collapse() {
        return collapse;
    }
    
    
    
    /**

    Returns a refernce to the next external Node of this Node.

    */
    public Node getNextExtNode() {
        return next_ext_node;
    }
    
    
    
    /**

    Sets the next external Node of this Node to n.

    */
    public void setNextExtNode( Node n ) {
        next_ext_node = n;
    }
    
    
    
    /**

    Returns a refernce to the previous external Node of this Node.

    */
    public Node getPrevExtNode() {
        return prev_ext_node;
    }
    
    
    
    /**

    Sets the previous external Node of this Node to n.

    */
    public void setPrevExtNode( Node n ) {
        prev_ext_node = n;
    }
    
    
    
    /**

    Returns a refernce to the first child Node of this Node.

    */
    public Node getChild1() {
        return child1;
    }
    
    
    
    /**

    Sets the first child Node of this Node to n.

    */
    public void setChild1( Node n ) {
        child1 = n;
    }
    
    
    
    /**

    Returns a refernce to the second child Node of this Node.

    */
    public Node getChild2() {
        return child2;
    }
    
    
    
    /**

    Sets the second child Node of this Node to n.

    */
    public void setChild2( Node n ) {
        child2 = n;
    }
    
    
    
    /**

    Returns a refernce to the parent Node of this Node.

    */
    public Node getParent() {
        return parent;
    }
    
    
    
    /**

    Sets the parent Node of this Node to n.

    */
    public void setParent( Node n ) {
        parent = n;
    }


 
    /**

    Sets the linked Node of this Node to n.
    Currently, this method is only used for 
    the speciation-duplication assignment algorithms.

    */
    public void setLink( Node n ) {
        link = n;
    }



    /**

    Returns a refernce to the linked Node of this Node.
    Currently, this method is only used for 
    the speciation-duplication assignment algorithms.

    */
    public Node getLink() {
        return link;
    }



    /**

    Sets the Vector associated with this Node to v.
    Currently, this method is only used for 
    Eulenstein's speciation-duplication assignment algorithm.

    */
    public void setVector( Vector v ) {
        vector = v;
    }



    /**

    Returns a refernce to the Vector associated with this Node.
    Currently, this method is only used for 
    Eulenstein's speciation-duplication assignment algorithm.

    */
    public Vector getVector() {
        return vector;
    }



    /**

    Returns how many times this Node is orthologous to another one.
    (Last modified: 12/05/00 )

    */
    public int getOrthologous() {
        return orthologous;
    }



    /**

    Sets how many times this Node is orthologous to another one.
    (Last modified: 12/05/00 )

    */
    public void setOrthologous( int i ) {
        orthologous = i;
    }



    /**

    Returns how many times this Node is super orthologous to another one.
    (Last modified: 12/05/00 )

    */
    public int getSuperOrthologous() {
        return super_orthologous;
    }



    /**

    Sets how many times this Node is super orthologous to another one.
    (Last modified: 12/05/00 )

    */
    public void setSuperOrthologous( int i ) {
        super_orthologous = i;
    }



    /**

    Returns how many times this Node is a subtree-neighbor to another one.
    (Last modified: 02/16/02 )

    */
    public int getSubtreeNeighborings() {
        return subtree_neighborings;
    }



    /**

    Sets how many times this Node is a subtree-neighbor to another one.
    (Last modified: 02/16/02 )

    */
    public void setSubtreeNeighborings( int i ) {
        subtree_neighborings = i;
    }








    // ---------------------------------------------------------
    // Inquiery of Node properties
    // ---------------------------------------------------------



    /**

    Returns true if this Node is the first child of its parent Node.
    Returns false if this Node is the second child of its parent or
    if this Node has no parent.

    */
    public boolean isChild1() {

        if ( getParent() == null ||
        getParent().getChild2() == this ) {
            return false;
        }
        return true;

    } // isChild1()





    // ---------------------------------------------------------
    // Obtaining of Nodes
    // ---------------------------------------------------------


    /**

    Returns a Vector containing references to all external children of
    this Node. The order is the same as in the Tree.

    @return Vector of references to external Nodes, null
            if this node is external

    */
    public Vector getAllExternalChildren() {

        Vector nodes = new Vector();
        Node   node1 = null,
               node2 = null;

        if ( isExternal() ) {
            nodes.addElement( this );
            nodes.trimToSize();
            return nodes;
        }

        node1 = this;
        while ( !node1.isExternal() ) {
            node1 = node1.getChild1();
        }

        node2 = this;
        while ( !node2.isExternal() ) {
            node2 = node2.getChild2();
        }

        do {
            nodes.addElement( node1 );
            node1 = node1.getNextExtNode();
        } while (  node1 != node2 );
        nodes.addElement( node1 );

        nodes.trimToSize();

        return nodes;

    } // getAllExternalChildren()



    
    
    /**

    Returns a Vector containing references to all (both internal and external) 
    children of this Node.
    Does not return pseudo Nodes (which are used to simulate nodes with more
    than two children).

    @return Vector of references to Nodes, null if this node is external

    */
    public Vector getAllChildren() {
        Vector nodes = new Vector();
        if ( isExternal() ) {
            return null;
        }
        Node node1, node2, node3;

        node1 = this;
        while ( !node1.isExternal() ) {
            node1 = node1.getChild1();
        }

        node3 = this;
        while ( !node3.isExternal() ) {
            node3 = node3.getChild2();
        }

        setIndicatorsToZero();
        do {
            node2 = node1;
            do { 
                if ( node2.getIndicator() == 0  ) {
                    node2.setIndicator( 1 );
                    if ( !node2.isPseudoNode() && node2 != this ) {
                        //                                nec.???
                        nodes.addElement( node2 );
                    }
                }
                node2 = node2.getParent();
            } while ( node2 != this );
            node1 = node1.getNextExtNode();
        } while ( node1 != null && node1.getPrevExtNode() != node3 );

        nodes.trimToSize();

        return nodes;
    } // getAllChildren()



    /**
    
    Returns a array containing copies all external children of this Node.
    
    */
    public Node[] copyAllExtChildren() throws Exception {
        int i = 1;
        Node node, first = this, last = this;
        Node[] nodes;
        if ( isExternal() ) {
            nodes = new Node[ 1 ];
            nodes[ 0 ] = copyNodeData();
        }
        else {
            while ( !first.isExternal() ) {
                first = first.getChild1();
            }
            while ( !last.isExternal() ) {
                last = last.getChild2();
            }
            node = first;
            do {
                node = node.getNextExtNode();
                i++;
            } while ( node != last );
            nodes = new Node[ i ];
            node = first;
            for ( i = 0; i<nodes.length; i++ ) {
                nodes[ i ] = node.copyNodeData();
                node = node.getNextExtNode();
            }
        }
        return nodes;
    } // copyAllExtChildren()







    // ---------------------------------------------------------
    // Writing of Nodes to Strings
    // ---------------------------------------------------------



    /**

    Converts this Node to a New Hampshire X (NHX) String representation.

    */
    String toNewHampshireX() {
        
        StringBuffer s     = new StringBuffer( 200 ),
                     s_nhx = new StringBuffer( 200 );
        
        if ( !getSeqName().equals( "" ) ) {
            s.append( getSeqName() );
        }
        if ( getDistanceToParent() >= 0.0 ) {
            s.append( ":" );
            s.append( getDistanceToParent() );
        }
        if ( !getSpecies().equals( "" ) ) {
            s_nhx.append( ":S=" );
            s_nhx.append( getSpecies() );
        }
        if ( getTaxonomyID() > 0 ) {
            s_nhx.append( ":T=" );
            s_nhx.append( getTaxonomyID() );
        }
        if ( !getECnumber().equals( "" ) ) {
            s_nhx.append( ":E=" );
            s_nhx.append( getECnumber() );
        }
        if ( isLnLonParentBranchAssigned() ) {
            s_nhx.append( ":L=" );
            s_nhx.append( getLnLonParentBranch() );
            if ( significantlyWorse() ) {
                s_nhx.append( ":Sw=Y" );
            }
            else {
                s_nhx.append( ":Sw=N" );
            }
        }
        if ( !isExternal() ) {
            
            if ( isDuplicationOrSpecAssigned() ) {
                if ( isDuplication() ) {
                    s_nhx.append( ":D=Y" );
                }
                else {
                    s_nhx.append( ":D=N" );
                }
            }
            if ( getBootstrap() != BOOTSTRAP_DEFAULT ) {
                s_nhx.append( ":B=" );
                s_nhx.append( getBootstrap() );
            }
            if ( collapse() ) {
                s_nhx.append( ":Co=Y" );
            }
        }
        else {
            if ( getOrthologous() != 0 ) {
                s_nhx.append( ":O=" );
                s_nhx.append( getOrthologous() );
            }
            if ( getSuperOrthologous() != 0 ) {
                s_nhx.append( ":SO=" );
                s_nhx.append( getSuperOrthologous() );
            }  
            if ( getSubtreeNeighborings() != 0 ) {
                s_nhx.append( ":SN=" );
                s_nhx.append( getSubtreeNeighborings() );
            }
            
        }
        
        if ( s_nhx.length() > 0 ) {
            s.append( "[&&NHX" );
            s.append( s_nhx );
            s.append( "]" );
        }

        return s.toString();
      
    } // toNewHampshireX()


    
    /**
  
    Converts this Node to a String, which looks "pretty"
    when printed to the console.

    */
    public String toString() {

        String s = "";

        if ( !isPseudoNode() ) {
            s = "\nSeq name                : " + getSeqName();
        }
        else {
            s = "\nSeq name                :  *pseudo node*";
        }
        s += "\nEC number               : " + getECnumber();
        s += "\nSpecies                 : " + getSpecies();
        if ( getTaxonomyID() > 0 ) {
            s += "\nTaxonomy ID             : " + getTaxonomyID();
        }
        else {
            s += "\nTaxonomy ID             : n/a";
        }
        if ( !isPseudoNode()
        && getDistanceToParent() != DISTANCE_DEFAULT ) {
            s += "\nDistance to parent      : " + getDistanceToParent();
        }
        else {
            s += "\nDistance to parent      : n/a";
        }
        if ( getBootstrap() != BOOTSTRAP_DEFAULT ) {
            s += "\nBootstrap value         : " + getBootstrap();
        }
        else {
            s += "\nBootstrap value         : n/a";
        }
        if ( isLnLonParentBranchAssigned() ) {
            s += "\nlnL on parent branch    : " + getLnLonParentBranch();
        }
        else {
            s += "\nlnL on parent branch    : n/a";
        }
        s += "\nL: Significantly worse  : " + significantlyWorse();
        if ( isDuplicationOrSpecAssigned() ) {
            s += "\nDuplication             : " + isDuplication();
        }
        else {
            s += "\nDuplication             : n/a";
        }
        if ( isExternal() ) {
            if ( getOrthologous() != 0 ) {
                s += "\nOrthologous             : " + getOrthologous();
            }
            if ( getSuperOrthologous() != 0 ) {
                s += "\nSuper orthologous       : " + getSuperOrthologous();
            }   
            if ( getSubtreeNeighborings() != 0 ) {
                s += "\nSubtree-neighborings    : " + getSubtreeNeighborings();
            }
        }
        s += "\nSum of ext nodes	: " + getSumExtNodes();
        s += "\nID                      : " + getID();
        if ( !isRoot() ) {
            s += "\nID of parent            : " + getParent().getID();
        }
        else {
            s += "\nID of parent            : n/a (root or pseudo root)";
        }
        if ( !isExternal() ) {
            s += "\nID of child1            : " + getChild1().getID();
            s += "\nID of child2            : " + getChild2().getID();
        }
        else {
            s += "\nID of child             : n/a (external node)";
        }
        s += "\n";

        return s;
    } // toString()






    // ---------------------------------------------------------
    // Comparison
    // ---------------------------------------------------------


 
    /**
    
    Compares this Node with Node node. Nodes are considered equal if
    their sequence name, species name, taxonomy ID, and EC number
    are exactly the same. Case sensitive.
    
    @return true if equal, false otherwise
    
    */
    public boolean equals( Node node ) {

        return ( node != null
        && getSeqName().equals( node.getSeqName() )
        && getSpecies().equals( node.getSpecies() )
        && getECnumber().equals( node.getECnumber() )
        && getTaxonomyID() == node.getTaxonomyID() );

    } // equals( Node )



    /**
    
    Returns true if Node arrays nodes1 and nodes2 are equal, false otherwise.
    Uses sequence names, species names, taxonomy IDs, 
    and EC numbers for comparison.
    
    */
    public static boolean compareArraysOfNodes( Node[] nodes1, 
                                                Node[] nodes2 )
    throws Exception {

        int     i = 0, 
                j = 0;
        Node[] n2 = null;

        if ( nodes1.length != nodes2.length ) {
            return false;
        }
       
        // copy nodes2 since it will be destroyed:
        n2 = new Node[ nodes2.length ];
        for ( i = 0; i < nodes2.length; i++ ) {
            n2[ i ] = nodes2[ i ].copyNodeData();
        }

        I: for ( i = 0; i < nodes1.length; i++ ) {
            for ( j = 0; j < n2.length; j++ ) {
                if ( nodes1[ i ].equals( nodes2[ j ] ) ) {
                    n2[ j ] = null; 
                    continue I;
                }
            }
            return false;
        }
        return true;
    } // compareArraysOfNodes( Node[], Node[] )






    // ---------------------------------------------------------
    // Basic printing
    // ---------------------------------------------------------


    /**
    
    Prints to the console the subtree originating from this Node in preorder.
    
    */
    public void preorderPrint() {
        System.out.println( this + "\n" );
        if ( getChild1() != null ) {
            getChild1().preorderPrint();
        }
        if ( getChild2() != null ) {
            getChild2().preorderPrint();
        }
    } // preorderPrint()







    // --------------------------------------------------------------------
    // Adjust methods (related to Tree construcation and Tree modification)
    // --------------------------------------------------------------------


    /**
    
    Sets the indicators of all the children of this Node to zero.
    
    */
    void setIndicatorsToZero() {
        
        Stack stack = new Stack();
        Node  n     = this;

        stack.push( n );
        while ( !stack.empty() ) {
            n = ( Node ) stack.pop();
            n.setIndicator( 0 );
            if ( n.getChild1() != null ) {
                stack.push( n.getChild1() );
            }
            if ( n.getChild2() != null ) {
                stack.push( n.getChild2() );
            }
        }

    } // setIndicatorsToZero()



    /**
   
    Resets the parents of all Nodes of the subtree originating from this
    Node, given that child1 and child2 are correctly set.
   
    */
    void setParents() {

        Node    start = this,
                node  = this,
                prev  = null;
        boolean done  = false;


        if ( isExternal() ) {
            return;
        }

        start.setIndicatorsToZero();

        while ( !done ) {

            if ( node == start && start.getIndicator() == 2 ) {
                done = true;
            }
            else if ( node.getIndicator() == 0 && !node.isExternal() ) {
                node.setParent( prev );
                prev = node;
                node.setIndicator( 1 );
                node = node.getChild1();
            }
            else if ( node.getIndicator() == 1 && !node.isExternal() ) {
                prev = node;
                node.setIndicator( 2 );
                node = node.getChild2();
            }
            else if ( node.getIndicator() == 2 && !node.isExternal() ) {
                node = node.getParent();
            }
            else if ( node.isExternal() ) {
                node.setParent( prev );
                node = prev;
            }
        }
    } // setParents()






    // ---------------------------------------------------------
    // Tree creation
    // ---------------------------------------------------------


    /**
    
    For building Trees.
    
    */
    void addExtNode( String s ) throws Exception {

        Node node = getLastExtNode();
        node.setNextExtNode( new Node( s ) );
        node.getNextExtNode().setPrevExtNode( node );

    } // addExtNode( String )
    


    /**
    
    For building Trees.
    
    */
    void connect( String s ) throws Exception {

        Node node1, node2, node3;

        node2 = getLastExtNode();
        node1 = node2.getRoot();   //remember root of last ext node

        do {                //move back to find 1st node with different root
            node2 = node2.getPrevExtNode();
            node3 = node2.getRoot();
        } while ( node1 == node3 );

        node1.setParent( new Node( s ) );
        node3.setParent( node1.getParent() );

        node1.getParent().setChild1( node3 ); // Setting the childern of new node
        node1.getParent().setChild2( node1 );
        // Setting sum of ext nodes of new node:
        node1.getParent().setSumExtNodes( node1.getSumExtNodes() + node3.getSumExtNodes() );

    } // connect( String )

   

    /**
  
    Returns the root Node of the tree of which this Node is member. 

    */
    Node getRoot() {
        Node node = this;
        while ( !node.isRoot() ) {
            node = node.getParent();
        }
        return node;
    } // getRoot()

   
   
    /**

    Returns the last external Node.
    
    */
    Node getLastExtNode() {

        Node node = this;
        while ( !node.isExternal() ) {
            node = node.getChild1();
        }
        while ( node.getNextExtNode() != null ) {
            node = node.getNextExtNode();
        }
        return node;

    } // getLastExtNode()

} // End of class Node.
