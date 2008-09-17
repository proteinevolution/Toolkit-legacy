// ATVgraphic.java
//
// Copyright (C) 1999-2002 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved
//
// Created: 1999
// Author: Christian M. Zmasek
// zmasek@genetics.wustl.edu
// http://www.genetics.wustl.edu/eddy/people/zmasek/

package forester.atv;


import forester.tree.*;

import java.util.Vector;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.text.*;
import java.text.NumberFormat;
import java.net.*;


/**

@author Christian M. Zmasek

@version 1.420 -- last modified: 02/16/02

*/
class ATVgraphic extends JPanel {

    final static private int MAX_ORTHO_DEFAULT = 100;
    final static int         BOX_SIZE          = 6,
                             HALF_BOX_SIZE     = ( int ) BOX_SIZE / 2,
                             MAX_SUBTREES      = 50,
                             MAX_NODEJFRAMES   = 50,
                             MOVE              = 30, // Tree graphic is moved by this distance in both x and y.
                             SHOW_INFO         = 0,
                             COLLAPSE          = 1,
                             REROOT            = 3,
                             SUBTREE           = 4,
                             SWAP              = 5;

    Node           node                = null,
                   n                   = null;
    Tree           tree                = null;
    Tree[]         trees               = new Tree[ MAX_SUBTREES ]; // to store trees in "subTree"
    ATVpanel       atvpanel            = null;
    ATVnodeFrame[] atvnodeframes       = new ATVnodeFrame[ MAX_NODEJFRAMES ];
    
    Vector  found_nodes                = null;

    boolean editable                   = false,
            use_real_br_lenghts        = true,
            seq_name_internal_nodes    = true,
            species_internal_nodes     = false,
            ec_internal_nodes          = false,
            seq_name_ext_nodes         = true,
            species_ext_nodes          = true,
            ec_ext_nodes               = false,
            write_lnL_values           = false,
            write_br_length_values     = false,
            write_bootstrap_values     = false,
            write_dup_spec             = false,
            color_branches_acc_to_lnL  = false,
            color_orthologous          = false,
            color_super_orthologous    = false,
            color_subtree_neighbors    = false,
            done                       = false;

    
    
    int longest_ext_node_info          = 0,
        y_current                      = 0,
        x1                             = 0,
        y1                             = 0, 
        x2                             = 0, 
        y2                             = 0, 
        factor                         = 0,
        green                          = 0, 
        red                            = 0,
        max_ortho                      = MAX_ORTHO_DEFAULT,
        j                              = 0, // index for trees[]
        x                              = 0, // for offsetting text in x direction
        action_when_node_clicked       = 0,
        i                              = 0,
        color_scheme                   = 0,
        small_maxDescent               = 0,
        small_maxAscent                = 0,
        ext_nodes_x                    = 0;
        
    double x_current                   = 0.0,
           x2double                    = 0.0,
           x_correction_factor         = 0.0,
           x_distance                  = 0.0,
           y_distance                  = 0.0,
           d                           = 0.0;

    Color ext_node_seq_name_color,
          int_node_seq_name_color,
          species_color,
          bootstrap_color,
          ec_color,
          dub_spec_color,
          lnL_color,
          branch_length_color,
          branch_color,
          box_color,
          background_color,
          duplication_box_color,
          seq_x_color,
          collapesed_fill_color,
          found_color;

    Font small_font,
         large_font,
         small_italic_font,
         large_italic_font;

    FontMetrics fm_small,
                fm_large,
                fm_small_italic,
                fm_large_italic;

    NumberFormat lnL_nf  = NumberFormat.getNumberInstance(),
                 dist_nf = NumberFormat.getNumberInstance();


    /**

    Constructor.

    */
    ATVgraphic( Tree t, ATVpanel tjp ) {
        
        tree = t;

        if ( tree != null && !tree.isEmpty() ) {
            tree.adjustNodeCount( true );
            tree.recalculateAndReset();
        }

        atvpanel = tjp;
     
        max_ortho = MAX_ORTHO_DEFAULT;
        
        color_scheme = 1;
        setColors1();
        mediumFonts();
        
        setBackground( background_color );

        calculateLongestExtNodeInfo();

        addMouseListener( new ATVmouseListener( this ) );
        
        lnL_nf.setMaximumFractionDigits( 6 );
        lnL_nf.setMinimumFractionDigits( 1 );
        dist_nf.setMaximumFractionDigits( 6 );
        dist_nf.setMinimumFractionDigits( 1 );
        
        if ( tree != null && !tree.isEmpty() ) {
            if ( tree.getHighestLnL() != -Double.MAX_VALUE
            &&   tree.getLowestLnL()  != +Double.MAX_VALUE
            &&   tree.getLowestLnL()  != tree.getHighestLnL() ) {
                setColorBranchesAccToLnL( true );
            }

            // Checks whether bootstrap, branch lenghts,
            // have been assigned.
            if ( tree.getExtNode0() != null ) {
                if ( tree.getExtNode0().getDistanceToParent()
                == Node.DISTANCE_DEFAULT ) {
                    setUseRealBranchLenghts( false );
                }
                else {
                    setUseRealBranchLenghts( true );
                }
                if ( tree.getExtNode0().getParent() != null ) {
                    if ( tree.getExtNode0().getParent().getBootstrap()
                    == Node.BOOTSTRAP_DEFAULT ) {
                        setWriteBootstrapValues( false );
                    }
                    else {
                        setWriteBootstrapValues( true );
                    }
                }
            }
        }
	}

   
    /**

    Default constructor.

    */
    ATVgraphic() {}


    /**
    
    Sets the maximal number a sequence is expected to be
    orthologous towards another, i.e. the number of resampling steps.
    (Last modified: 12/05/00)
    
    */
    void setMaxOrtho( int m ) {
        max_ortho = m;
    }    


    /**
    
    Gets the maximal number a sequence is expected to be
    orthologous towards another, i.e. the number of resampling steps.
    (Last modified: 12/05/00)
    
    */
    int getMaxOrtho() {
        return max_ortho;
    }   



    void setParametersForPainting( int x, int y ) {
        if ( tree != null && !tree.isEmpty() ) {
            
            double xdist = ( double ) ( x - getLongestExtNodeInfo() - MOVE
                           - getLengthOfRootSpecies() )
                           / ( tree.getNumberOfExtNodes() + 2.0 );
           
            double ydist = ( double ) ( y - MOVE ) 
                           / ( tree.getNumberOfExtNodes() * 2.0 );
           
            
            if ( xdist < 0.0 ) {
                xdist = 0.0;   
            }    
            if ( ydist < 0.0 ) {
                ydist = 0.0;   
            }
            
            setXdistance( xdist );
            setYdistance( ydist );
            
            if ( tree.getRealHeight() > 0.0 ) {
                double corr = (  x - getLongestExtNodeInfo() - MOVE
                              - getXdistance() - getLengthOfRootSpecies() )
                              / tree.getRealHeight();
                if ( corr < 0.0 ) {
                    corr = 0.0;
                } 
                setXcorrectionFactor( corr );
            }
            else {     
                setXcorrectionFactor( 0.0 );
            }
        }
    }



    void resetPreferredSize() {
        if ( tree == null || tree.isEmpty() ) {
            return;
        }
        int x = 0,
            y = 0;
        
        y  = MOVE + ( int ) ( 0.5 + getYdistance() * tree.getNumberOfExtNodes() * 2 );

        if ( useRealBranchLenghts() ) {
            x = MOVE + getLongestExtNodeInfo() + getLengthOfRootSpecies() 
              + TreeHelper.roundToInt( getXcorrectionFactor() * tree.getRealHeight() + getXdistance() );
        }
        else {
            x = MOVE + getLongestExtNodeInfo() + getLengthOfRootSpecies()
              + TreeHelper.roundToInt( getXdistance() * ( tree.getNumberOfExtNodes() + 2 ) );
        }    
        setPreferredSize( new Dimension( x, y ) );
    }

    Tree getTree() {
        return tree;
    }

    void setTree( Tree t ) {
        tree = t;
    }  

    ATVpanel getATVpanel() {
        return atvpanel;
    }

    int getLongestExtNodeInfo() {
        return longest_ext_node_info;
    }
    void setLongestExtNodeInfo( int i ) {
        longest_ext_node_info = i;
    }

    void setFoundNodes( Vector v ) {
        found_nodes = v;
    }

    int getLengthOfRootSpecies() {
        if ( tree == null || tree.isEmpty() ) {
            return 0;
        }
        
        return (int) fm_small_italic.stringWidth( tree.getRoot().getSpecies() );
    }

    void calculateLongestExtNodeInfo() {
        if ( tree == null || tree.isEmpty() ) {
            return;
        }
        
        int longest = 0;
        int sum = 0;
        Node node = tree.getExtNode0();
        while ( node != null ) {
            sum = fm_large_italic.stringWidth( node.getSpecies() + " " )
             + fm_large.stringWidth( node.getSeqName() + " " )
             + fm_large.stringWidth( node.getECnumber() );
            node = node.getNextExtNode();
            if ( sum > longest ) {
                longest = sum;
            }
            sum = 0;
        }
        setLongestExtNodeInfo( longest );
    }


    
    Node findNode( int x, int y ) {
        if ( tree == null || tree.isEmpty() ) {
            return null;
        }
        
        Node node2, node1 = tree.getExtNode0();
        while ( node1 != null ) {
            node2 = node1;
            while ( node2 != null ) {
                if ( !node2.isPseudoNode()
                && ( tree.isRooted() || !node2.isRoot() )
                && node2.getXcoord() - HALF_BOX_SIZE <= x
                && node2.getXcoord() + HALF_BOX_SIZE >= x
                && node2.getYcoord() - HALF_BOX_SIZE <= y
                && node2.getYcoord() + HALF_BOX_SIZE >= y ) {
                    return node2;
                }
                node2 = node2.getParent();
            }
            node1 = node1.getNextExtNode();
        }
        return null; // not found
    }

    void setActionWhenNodeClicked( int i ) {
        action_when_node_clicked = i;
    }
    int getActionWhenNodeClicked() {
        return action_when_node_clicked;
    }


    void collapse( Node node ) {
        if ( !node.isExternal() ) {
            node.setCollapse( !node.collapse() );
            tree.adjustNodeCount( true );
            tree.recalculateAndReset();
            resetPreferredSize();
            atvpanel.adjustJScrollPane();
            repaint();
        }
    }


    void reRoot( Node node ) {
        if ( !(( node.isRoot() || node.getParent().isRoot() )
        && tree.isRooted() ) ) {
            try {
                tree.reRoot( node );
                tree.adjustNodeCount( true );
                tree.recalculateAndReset();
            }
            catch ( Exception e ) {
                System.err.println( "ATVgraphic: reRoot( node ): " + e );
            }
            resetPreferredSize();
            atvpanel.adjustJScrollPane();
            repaint();
        }
    }


    void subTree( Node node ) {
        if ( !node.isExternal() && !node.isRoot() && j <= MAX_SUBTREES - 1 ) {
            try {
                trees[ j++ ] = tree;
                tree = tree.subTree( node.getID() );
            }
            catch ( Exception e ) {
                System.err.println( "ATVgraphic: subTree( Node ): " + e );
            }
        }
        else if ( node.isRoot() && j >= 1 ) {
            try {
                trees[ j ] = null;
                tree = trees[ --j ];
            }
            catch ( Exception e ) {
                System.err.println( "ATVgraphic: subTree( Node ): " + e );
            }
        }
        atvpanel.getATVcontrol().setCheckBoxes();
        atvpanel.getATVcontrol().showWhole();
        repaint();
    }


    void swap( Node node ) {
        if ( !node.isExternal() ) {
            tree.swapChildren( node );
        }
        repaint();
    }


    void removeRoot() {
        if ( tree == null ) {
            return;
        }
        if ( tree.isEmpty() ) {
            return;
        }
        tree.unRoot();
        repaint();
    }


    void removeRootTri() {
        if ( tree == null ) {
            return;
        }
        if ( tree.isEmpty() ) {
            return;
        }
        tree.unRootAndTrifurcate();
        repaint();
    }



    /**

    Mouse clicked.
    (Last modified: 10/08/01)

    */
    public void MouseClicked( MouseEvent e ) {
        int  x    = e.getX(),
             y    = e.getY();
        Node node = findNode( x, y );
        
        if ( node != null ) {
 
            // right (3rd) mouse button.
            if ( e.getModifiers() == 4 ) {
                i = 0;
                while ( atvnodeframes[ i ] != null ) {
                    i++;
                }
                atvnodeframes[ i ] = new ATVnodeFrame( node, this, i );
            }
            // other mouse button.
            else {
                if ( action_when_node_clicked == COLLAPSE ) {
                    collapse( node );
                }

                else if ( action_when_node_clicked == REROOT ) {
                    reRoot( node );
                }
                else if ( action_when_node_clicked == SUBTREE ) {
                    subTree( node );
                }
                else if ( action_when_node_clicked == SWAP ) {
                    swap( node );
                }
                // show info is default:
                else {
                    i = 0;
                    while ( atvnodeframes[ i ] != null ) {
                        i++;
                    }
                    atvnodeframes[ i ] = new ATVnodeFrame( node, this, i );
                }
            }
        }
    }

    void removeNodeJFrame( int i ) {
        atvnodeframes[ i ] = null;
    }

    void removeAllNodeJFrames() {
        for ( i = 0; i <= MAX_NODEJFRAMES - 1; i++ ) {
            if ( atvnodeframes[ i ] != null ) {
                atvnodeframes[ i ].dispose();
                atvnodeframes[ i ] = null;
            }
        }
        i = 0;
    }

    double getXdistance() {
        return x_distance;
    }
    
    double getYdistance() {
        return y_distance;
    }
    void setXdistance( double i ) {
        x_distance = i;
    }
    
    void setYdistance( double i ) {
        y_distance = i;
    }

    void setXcorrectionFactor( double i ) {
        x_correction_factor = i;
    }
    double getXcorrectionFactor() {
        return x_correction_factor;
    }

    boolean isEditable() {
        return editable;
    }
    
    void setEditable( boolean b ) {
        editable = b;
    }
    
    void setUseRealBranchLenghts( boolean b ) {
        use_real_br_lenghts = b;
    }
    
    boolean useRealBranchLenghts() {
        return use_real_br_lenghts;
    }
    
    void setSeqNameInternalNodes( boolean b ) {
        seq_name_internal_nodes = b;
    }
   
    boolean seqNameInternalNodes() {
        return seq_name_internal_nodes;
    }
    
    void setSpeciesInternalNodes( boolean b ) {
        species_internal_nodes = b;
    }
    
    boolean speciesInternalNodes() {
        return species_internal_nodes;
    }
    
    void setECInternalNodes( boolean b ) {
        ec_internal_nodes = b;
    }
    
    boolean ECInternalNodes() {
        return ec_internal_nodes;
    }
    
    void setSeqNameExtNodes( boolean b ) {
        seq_name_ext_nodes = b;
    }
    
    boolean seqNameExtNodes() {
        return seq_name_ext_nodes;
    }
    
    void setSpeciesExtNodes( boolean b ) {
        species_ext_nodes = b;
    }
    
    boolean speciesExtNodes() {
        return species_ext_nodes;
    }
    
    void setECExtNodes( boolean b ) {
        ec_ext_nodes = b;
    }
    
    boolean ECExtNodes() {
        return ec_ext_nodes;
    }
    
    void setWriteLnLValues( boolean b ) {
        write_lnL_values = b;
    }
    
    boolean writeLnLValues() {
        return write_lnL_values;
    }
    
    void setWriteBranchLengthValues( boolean b ) {
        write_br_length_values = b;
    }
    
    boolean writeBranchLengthValues() {
        return write_br_length_values;
    }
    
    void setWriteBootstrapValues( boolean b ) {
        write_bootstrap_values = b;
    }
    
    boolean writeBootstrapValues() {
        return write_bootstrap_values;
    }
    
    void setWriteDupSpec( boolean b ) {
        write_dup_spec = b;
    }
    
    boolean writeDupSpec() {
        return write_dup_spec;
    }
    
    void setColorBranchesAccToLnL( boolean b ) {
        color_branches_acc_to_lnL = b;
    }
    
    boolean colorBranchesAccToLnL() {
        return color_branches_acc_to_lnL;
    }
    
    boolean colorOrthologous() {
        return color_orthologous;
    }
    
    void setColorOrthologous( boolean b ) {
        color_orthologous = b;
    }
    
    boolean colorSuperOrthologous() {
        return color_super_orthologous;
    }
    
    void setColorSuperOrthologous( boolean b ) {
        color_super_orthologous = b;
    }
    
    boolean colorSubtreeNeighbors() {
        return color_subtree_neighbors;
    }
    
    void setColorSubtreeNeighbors( boolean b ) {
        color_subtree_neighbors = b;
    }
    
    
    /**
    
    Paints the Tree. 
    
    */
    public void paintComponent( Graphics g ) {

        super.paintComponent( g );

        if ( tree == null || tree.isEmpty() ) {
            return;
        }
        
        done = false;

        node = tree.getRoot();

        tree.setIndicatorsToZero();

        if ( !tree.isRooted() ) {
            x_current = MOVE;
        }
        else if ( tree.getRoot().getDistanceToParent() > 0.0
        && useRealBranchLenghts() ) {
            x_current = MOVE + tree.getRoot().getDistanceToParent()
                        * x_correction_factor;
        }
        else {
            x_current = MOVE + getXdistance();
        }

        y_current = TreeHelper.roundToInt( getYdistance() * tree.getNumberOfExtNodes()
                    + MOVE / 2.0 );

        ext_nodes_x = MOVE + TreeHelper.roundToInt( x_distance * tree.getNumberOfExtNodes() );

        setBackground( background_color );

        do {
            // Does not write onto ext nodes.
            if ( !node.isPseudoNode() ) {

                if ( writeBranchLengthValues() && node.getIndicator() == 0
                && node.getDistanceToParent() >= 0.0 ) {
                    g.setFont( small_font );
                    g.setColor( branch_length_color );

                    if ( !node.isRoot() ) {
                        g.drawString( dist_nf.format( node.getDistanceToParent() ),
                        node.getParent().getXcoord() + 3,
                        y_current - small_maxDescent );
                    }
                    else {
                        // Deepest node (=root):
                        g.drawString( dist_nf.format( node.getDistanceToParent() ),
                        3, y_current - small_maxDescent );
                    }
                }
                if ( writeLnLValues() && node.getIndicator() == 0
                && node.isLnLonParentBranchAssigned() ) {
                    g.setFont( small_font );
                    g.setColor( lnL_color );

                    if ( !node.isRoot() ) {
                        g.drawString( lnL_nf.format( tree.getHighestLnL() -
                        node.getLnLonParentBranch() ) +
                        " (" + lnL_nf.format( node.getLnLonParentBranch() ) + ")",
                        node.getParent().getXcoord() + 3,
                        y_current + small_maxAscent );
                    }
                    else if ( tree.getNumberOfExtNodes() >= 2 ) {
                        // Deepest node (=root):
                        g.drawString( lnL_nf.format( tree.getHighestLnL()
                        - node.getLnLonParentBranch() ) +
                        " (" + lnL_nf.format( node.getLnLonParentBranch() ) + ")",
                        3, y_current + small_maxAscent );
                    }
                    else {
                        // Tree is just one node:
                        g.drawString( " (" + lnL_nf.format( node.getLnLonParentBranch() ) + ")",
                        3, y_current + small_maxAscent );
                    }
                }
                
                // Write Bootstrap values:
                if ( writeBootstrapValues()&& node.getIndicator() == 0
                && node.getBootstrap() > 0 && tree.getNumberOfExtNodes() >= 2
                && !node.collapse() ) {
                    g.setFont( small_font );
                    g.setColor( bootstrap_color );
                    g.drawString( Integer.toString( node.getBootstrap() ), TreeHelper.roundToInt( x_current ) -
                    fm_small.stringWidth( Integer.toString( node.getBootstrap() ) ) - 2
                    - HALF_BOX_SIZE, y_current + small_maxAscent - 1 );
                }
            }

            // Draw a line as root:
            if ( node.isRoot() && tree.isRooted()
            && node.getIndicator() == 0 ) {

                x1 = TreeHelper.roundToInt( x_current );

                if ( !colorBranchesAccToLnL()
                || !node.isLnLonParentBranchAssigned() ) {
                    g.setColor( branch_color );
                }
                else {
                    green = ( int ) ( ( node.getLnLonParentBranch()
                    - tree.getLowestLnL()  ) * 254.0 / Math.abs(
                    tree.getHighestLnL()
                    - tree.getLowestLnL() ) );
                    red = 255 - green;
                    g.setColor( new Color( red, green, 0 ) );
                }

                if ( useRealBranchLenghts() && tree.getRoot().getDistanceToParent() > 0.0 ) {
                    d = x_correction_factor * tree.getRoot().getDistanceToParent();
                    g.drawLine( x1, y_current, x1 - TreeHelper.roundToInt( d ), y_current );
                }
                else {
                    g.drawLine( x1, y_current, x1 - TreeHelper.roundToInt( x_distance ), y_current );
                    if ( colorBranchesAccToLnL()
                    && !node.significantlyWorse() ) {
                        g.drawLine( x1, y_current - 1, x1 - TreeHelper.roundToInt( x_distance ), y_current - 1 );
                        g.drawLine( x1, y_current + 1, x1 - TreeHelper.roundToInt( x_distance ), y_current + 1 );
                    }
                }
                if ( node.collapse() ) {
                    drawCollapsedNode( x1, y_current, g, node, 
                                       ( found_nodes != null && found_nodes.contains( node ) ) );
                }
                else if ( found_nodes != null && found_nodes.contains( node ) ) {
                    if ( !writeDupSpec()
                    && node.isDuplicationOrSpecAssigned()
                    && node.isDuplication() ) {
                         drawFoundNode( x1, y_current, g, true );
                    }
                    else {
                         drawFoundNode( x1, y_current, g, false );
                    }
                }
                else {
                    if ( !writeDupSpec()
                    && node.isDuplicationOrSpecAssigned()
                    && node.isDuplication() ) {
                        g.setColor( duplication_box_color );
                    }
                    else {
                        g.setColor( box_color );
                    }
                    g.fillRect( x1 - HALF_BOX_SIZE, y_current - HALF_BOX_SIZE, BOX_SIZE, BOX_SIZE );
                }
            }


            //                _
            // Paint child1: |
            if ( node.getIndicator() == 0 && !node.isExternal() ) {

                node.setIndicator( 1 );

                factor = node.getSumExtNodes() - node.getChild1().getSumExtNodes();
                x1 = TreeHelper.roundToInt( x_current );
                node.setXcoord( x1 );
                y1 = y_current;
                node.setYcoord( y1 );
                y2 = y_current - TreeHelper.roundToInt( y_distance * factor );
                if ( !node.isPseudoNode() ) {
                    // Species internal node:
                    if ( speciesInternalNodes()
                    && !node.collapse() && !node.getSpecies().equals( "" )  ) {
                        g.setFont( small_italic_font );
                        if ( found_nodes != null && found_nodes.contains( node ) ) {
                            g.setColor( found_color );
                        }
                        else {
                            g.setColor( species_color );
                        }
                        g.drawString( node.getSpecies(), x1 + 3 + HALF_BOX_SIZE,
                        y_current + ( int ) fm_small_italic.getAscent() / 2 );
                    }

                    // Sequence name int node:
                    if ( seqNameInternalNodes() && !node.getSeqName().equals( "" )
                    && !node.collapse() ) {
                        if ( found_nodes != null && found_nodes.contains( node ) ) {
                            g.setColor( found_color );
                        }
                        else {
                            g.setColor( int_node_seq_name_color );
                        }
                        g.setFont( large_font );
                        g.drawString( node.getSeqName(), x1 -
                        fm_large.stringWidth( node.getSeqName() ) - 3 - HALF_BOX_SIZE,
                        y_current - fm_large.getMaxDescent() );
                    }

                    // EC int node:
                    if ( ECInternalNodes() && !node.getECnumber().equals( "" )
                    && !node.collapse() ) {
                        if ( found_nodes != null && found_nodes.contains( node ) ) {
                            g.setColor( found_color );
                        }
                        else {
                            g.setColor( ec_color );
                        }
                        g.setFont( large_font );
                        if ( seqNameInternalNodes() && !node.getSeqName().equals( "" ) ) {
                            x = fm_large.stringWidth( node.getSeqName() + " " );
                        }
                        else {
                            x = 0;
                        }
                        
                        g.drawString( node.getECnumber(), x1 - x
                        - fm_large.stringWidth( node.getECnumber() ) - 4 - HALF_BOX_SIZE,
                        y_current - fm_large.getMaxDescent() );
                        
                    }

                    // Indicate whether D or S if assigned:
                    if ( writeDupSpec() && node.isDuplicationOrSpecAssigned()
                    && !node.collapse() ) {
                        g.setColor( dub_spec_color );
                        g.setFont( large_font );
                        
                        if ( speciesInternalNodes() ) {
                            x = fm_large.getMaxAscent();
                        }
                        else {
                            x = 0;    
                        }
                        
                        if ( node.isDuplication() ) {
                            g.drawString( "D", x1 + 3 + HALF_BOX_SIZE,
                            y_current + ( int ) fm_large.getAscent() / 2 + x );
                        }
                        else {
                            g.drawString( "S", x1 + 3 + HALF_BOX_SIZE,
                            y_current + ( int ) fm_large.getAscent() / 2 + x );
                        }
                    }
                }

                if ( !node.collapse() ) {
                    if ( useRealBranchLenghts() ) {
                        d = node.getChild1().getDistanceToParent();
                        if ( d < 0.0 ) {
                            d = 0.0; 
                        }
                        x2double = x_current + x_correction_factor * d;
                    }
                    else if ( node.getChild1().isExternal() || node.getChild1().collapse() ) {
                        x2double = ext_nodes_x;
                    }
                    else if ( node.getChild1().isPseudoNode() ) {
                        x2double = x_current;
                    }
                    else {
                        x2double = x_current + x_distance * factor;
                    }
 
                    if ( !useRealBranchLenghts() 
                    && node.isPseudoNode() 
                    && !node.getChild1().isPseudoNode()
                    && !node.getChild1().isExternal()
                    && !node.getChild1().collapse() ) {
                        n = node.getParent();
                        while ( n.isPseudoNode() ) {
                            n = n.getParent();
                        }
                        x2double += ( n.getSumExtNodes() - node.getSumExtNodes() ) * x_distance;
                    }

                    x2 = TreeHelper.roundToInt( x2double );
                    
                    g.setColor( branch_color );
                    if ( !node.isPseudoNode()
                    && !( node.isRoot() && !tree.isRooted() ) ) {
                        if ( ( y1 - y2 ) > HALF_BOX_SIZE ) {
                            g.drawLine( x1, y1 - HALF_BOX_SIZE, x1, y2 );
                        }
                        else {
                            x1 += HALF_BOX_SIZE;
                        }
                    }
                    else {
                        g.drawLine( x1, y1, x1, y2 );
                    }

                    if ( !colorBranchesAccToLnL()
                    || !node.getChild1().isLnLonParentBranchAssigned()
                    || tree.getHighestLnL() == tree.getLowestLnL() ) {
                        g.setColor( branch_color );
                        g.drawLine( x1, y2, x2, y2 );
                    }
                    else {
                        green = ( int ) ( ( node.getChild1().getLnLonParentBranch()
                        - tree.getLowestLnL() ) * 254.0 / Math.abs( tree.getHighestLnL()
                        - tree.getLowestLnL() ) );
                        red = 255 - green;
                        g.setColor( new Color( red, green, 0 ) );
                        g.drawLine( x1, y2, x2, y2 );

                        if ( !node.getChild1().significantlyWorse() ) {
                            g.drawLine( x1, y2 - 1, x2, y2 - 1 );
                            g.drawLine( x1, y2 + 1, x2, y2 + 1 );
                        }
                    }

                    if ( !node.getChild1().isPseudoNode() ) {
                        if ( node.getChild1().collapse() ) {
                            drawCollapsedNode( x2, y2, g, node.getChild1(), 
                                               ( found_nodes != null && found_nodes.contains( node.getChild1() ) ) );
                        }
                        else if ( found_nodes != null && found_nodes.contains( node.getChild1() ) ) {
                            if ( !writeDupSpec()
                            && node.getChild1().isDuplicationOrSpecAssigned()
                            && node.getChild1().isDuplication() ) {
                                drawFoundNode( x2, y2, g, true );
                            }
                            else {
                                drawFoundNode( x2, y2, g, false );
                            }
                        }
                        else {
                            if ( !writeDupSpec()
                            && node.getChild1().isDuplicationOrSpecAssigned()
                            && node.getChild1().isDuplication() ) {
                                g.setColor( duplication_box_color );
                            }
                            else {
                                g.setColor( box_color );
                            }
                            g.fillRect( x2 - HALF_BOX_SIZE, y2 - HALF_BOX_SIZE, BOX_SIZE, BOX_SIZE );
                        }
                    }
                    x_current = x2double;
                    y_current = y2;

                    node = node.getChild1();

                }

            }

            // Paint child2: |_
            if ( node.getIndicator() == 1 && !node.isExternal() ) {

                node.setIndicator( 2 );

                if ( !node.collapse() ) {
                    factor = node.getSumExtNodes() - node.getChild2().getSumExtNodes();

                    x1 = TreeHelper.roundToInt( x_current );
                    y1 = y_current;
                    y2 = y_current + TreeHelper.roundToInt( y_distance * factor );

                    if ( useRealBranchLenghts() ) {
                        d = node.getChild2().getDistanceToParent();
                        if ( d < 0.0 ) {
                            d = 0.0; 
                        }
                        x2double= x_current + x_correction_factor * d;
                    }
                    else if ( node.getChild2().isExternal() || node.getChild2().collapse() ) {
                        x2double = ext_nodes_x;
                    }
                    else if ( node.getChild2().isPseudoNode() ) {
                        x2double = x_current; 
                    }
                    else {
                        x2double = x_current + x_distance * factor;
                    }
                    if ( !useRealBranchLenghts()
                    && node.isPseudoNode() 
                    && !node.getChild2().isPseudoNode()
                    && !node.getChild2().isExternal() 
                    && !node.getChild2().collapse() ) {
                        n = node.getParent();
                        while ( n.isPseudoNode() ) {
                            n = n.getParent();
                        }
                        x2double += ( n.getSumExtNodes() - node.getSumExtNodes() ) * x_distance;
                    } 

                    x2 = TreeHelper.roundToInt( x2double );

                    g.setColor( branch_color );
                    if ( !node.isPseudoNode()
                    && !( node.isRoot() && !tree.isRooted() ) ) {
                        if ( ( y2 - y1 ) > HALF_BOX_SIZE ) {
                            g.drawLine( x1, y1 + HALF_BOX_SIZE, x1, y2 );
                        }
                        else {
                            x1 += HALF_BOX_SIZE;
                        }
                    }
                    else {
                        g.drawLine( x1, y1, x1, y2 );
                    }


                    if ( !colorBranchesAccToLnL()
                    || !node.getChild2().isLnLonParentBranchAssigned()
                    || tree.getHighestLnL() == tree.getLowestLnL() ) {
                        g.setColor( branch_color );
                        g.drawLine( x1, y2, x2, y2 );
                    }
                    else {
                        green = ( int ) ( ( node.getChild2().getLnLonParentBranch()
                        - tree.getLowestLnL()  ) * 254.0 / Math.abs( tree.getHighestLnL()
                        - tree.getLowestLnL() ) );
                        red = 255 - green;
                        g.setColor( new Color( red, green, 0 ) );
                        g.drawLine( x1, y2, x2, y2 );
                        if ( !node.getChild2().significantlyWorse() ) {
                            g.drawLine( x1, y2 - 1, x2, y2 - 1 );
                            g.drawLine( x1, y2 + 1, x2, y2 + 1 );
                        }
                    }
                    

                    if ( !node.getChild2().isPseudoNode() ) {
           
                        if ( node.getChild2().collapse() ) {
                            drawCollapsedNode( x2, y2, g, node.getChild2(), 
                                               ( found_nodes != null && found_nodes.contains( node.getChild2() ) ) );
                        }
                        else if ( found_nodes != null && found_nodes.contains( node.getChild2() ) ) {
                            if ( !writeDupSpec()
                            && node.getChild2().isDuplicationOrSpecAssigned()
                            && node.getChild2().isDuplication() ) {
                                drawFoundNode( x2, y2, g, true );
                            }
                            else {
                                drawFoundNode( x2, y2, g, false );
                            }
                        }
                        else {
                            if ( !writeDupSpec()
                            && node.getChild2().isDuplicationOrSpecAssigned()
                            && node.getChild2().isDuplication() ) {
                                g.setColor( duplication_box_color );
                            }
                            else {
                                g.setColor( box_color );
                            }
                            g.fillRect( x2 - HALF_BOX_SIZE, y2 - HALF_BOX_SIZE, BOX_SIZE, BOX_SIZE );
                        }

                    }
                    x_current = x2double;
                    y_current = y2;
                    node = node.getChild2();
                }

            }

            // In case of collapsed root or collapsed root.child2:
            if ( node.isRoot() ) {
                done = true;
            }

            // Moving towards the root:
            else if ( node.getIndicator() == 2 && !node.isExternal() ) {
                node = node.getParent();
                x_current = node.getXcoord();
                y_current = node.getYcoord();
            }



            // Labelling ext node:
            if ( node.isExternal() ) {

                x1 = TreeHelper.roundToInt( x_current );

                if ( speciesExtNodes() && !node.getSpecies().equals( "" ) ) {
                    g.setFont( large_italic_font );
           
                    if ( found_nodes != null && found_nodes.contains( node ) ) {
                         g.setColor( found_color );
                    }
                    else if ( colorOrthologous()
                    && node.getOrthologous() != Node.ORTHOLOGOUS_DEFAULT ) {
                        g.setColor( calculateColorForOrthologous( node ) );
                    }
                    else if ( colorSuperOrthologous()
                    && node.getSuperOrthologous() != Node.ORTHOLOGOUS_DEFAULT ) {
                        g.setColor( calculateColorForSuperOrthologous( node ) );
                    }
                    else if ( colorSubtreeNeighbors()
                    && node.getSubtreeNeighborings() != Node.ORTHOLOGOUS_DEFAULT ) {
                        g.setColor( calculateColorForSubtreeNeighbors( node ) );
                    }
                    else {
                        g.setColor( species_color );
                    }
                    g.drawString( node.getSpecies() + " ", x1 + 3 + HALF_BOX_SIZE,
                    y_current + ( int ) fm_large.getAscent() / 2 );
                }
                if ( seqNameExtNodes() && !node.getSeqName().equals( "" ) ) {
                    g.setFont( large_font );

                    if ( found_nodes != null && found_nodes.contains( node ) ) {
                         g.setColor( found_color );
                    }
                    else if ( colorOrthologous()
                    && node.getOrthologous() != Node.ORTHOLOGOUS_DEFAULT ) {
                        g.setColor( calculateColorForOrthologous( node ) );
                    }
                    else if ( colorSuperOrthologous()
                    && node.getSuperOrthologous() != Node.ORTHOLOGOUS_DEFAULT ) {
                        g.setColor( calculateColorForSuperOrthologous( node ) );
                    }
                    else if ( colorSubtreeNeighbors()
                    && node.getSubtreeNeighborings() != Node.ORTHOLOGOUS_DEFAULT ) {
                        g.setColor( calculateColorForSubtreeNeighbors( node ) );
                    }
                    else {
                        g.setColor( ext_node_seq_name_color );
                    }
                    if ( speciesExtNodes() && !node.getSpecies().equals( "" ) ) {
                        x = fm_large_italic.stringWidth( node.getSpecies() + " " );
                    }
                    else {
                        x = 0;
                    }
                    g.drawString( node.getSeqName(), x1 + x + 3 + HALF_BOX_SIZE,
                    y_current + ( int ) fm_large.getAscent() / 2 );
                }
                if ( ECExtNodes() && !node.getECnumber().equals( "" ) ) {
                    g.setFont( large_font ); 
                    if ( found_nodes != null && found_nodes.contains( node ) ) {
                        g.setColor( found_color );
                    }
                    else { 
                        g.setColor( ec_color );
                    }
                    if ( speciesExtNodes() && !node.getSpecies().equals( "" ) ) {
                        x = fm_large_italic.stringWidth( node.getSpecies() + " " );
                    }
                    else {
                        x = 0;
                    }
                    if ( seqNameExtNodes() && !node.getSeqName().equals( "" ) ) {
                        x += fm_large.stringWidth( node.getSeqName() + " " );
                    }

                    g.drawString( node.getECnumber(), x1 + x + 3  + HALF_BOX_SIZE,
                    y_current + ( int ) fm_large.getAscent() / 2 );
                }
                
                if ( ( colorOrthologous()
                && node.getOrthologous() != Node.ORTHOLOGOUS_DEFAULT ) 
                ||  ( colorSuperOrthologous()
                && node.getSuperOrthologous() != Node.ORTHOLOGOUS_DEFAULT )
                || ( colorSubtreeNeighbors()
                && node.getSubtreeNeighborings() != Node.ORTHOLOGOUS_DEFAULT ) ) {
                    g.setColor( calculateColorForOrthologous( node ) );
                    g.setFont( large_font );
                    if ( speciesExtNodes() && !node.getSpecies().equals( "" ) ) {
                        x = fm_large_italic.stringWidth( node.getSpecies() + " " );
                    }
                    else {
                        x = 0;
                    }
                    if ( seqNameExtNodes() && !node.getSeqName().equals( "" ) ) {
                        x += fm_large.stringWidth( node.getSeqName() + " " );
                    }
                    if ( ECExtNodes() && !node.getECnumber().equals( "" ) ) {
                        x += fm_large.stringWidth( node.getECnumber() + " " );
                    }
                    if ( colorOrthologous() ) {
                        g.setColor( calculateColorForOrthologous( node ) );
                        if ( node.getOrthologous() == Node.SEQ_X ) {
                            g.drawString( " [ Q ]",
                                    x1 + x + 3 + HALF_BOX_SIZE,
                                    y_current + ( int ) fm_large.getAscent() / 2 );    
                            
                        }
                        else {    
                            g.drawString( " [ " + node.getOrthologous() + " ]",
                                    x1 + x + 3 + HALF_BOX_SIZE,
                                    y_current + ( int ) fm_large.getAscent() / 2 );
                        }
                    }
                    else if ( colorSuperOrthologous() ) {
                        g.setColor( calculateColorForSuperOrthologous( node ) );
                        if ( node.getSuperOrthologous() == Node.SEQ_X ) {
                            g.drawString( " [ Q ]",
                                    x1 + x + 3 + HALF_BOX_SIZE,
                                    y_current + ( int ) fm_large.getAscent() / 2 );    
                            
                        }
                        else {    
                            g.drawString( " [ " + node.getSuperOrthologous() + " ]",
                                    x1 + x + 3 + HALF_BOX_SIZE,
                                    y_current + ( int ) fm_large.getAscent() / 2 );
                        }
                    }
                    else if ( colorSubtreeNeighbors() ) {
                        g.setColor( calculateColorForSubtreeNeighbors( node ) );
                        if ( node.getSubtreeNeighborings() == Node.SEQ_X ) {
                            g.drawString( " [ Q ]",
                                    x1 + x + 3 + HALF_BOX_SIZE,
                                    y_current + ( int ) fm_large.getAscent() / 2 );    
                            
                        }
                        else {    
                            g.drawString( " [ " + node.getSubtreeNeighborings() + " ]",
                                    x1 + x + 3 + HALF_BOX_SIZE,
                                    y_current + ( int ) fm_large.getAscent() / 2 );
                        }
                    }
                }

                if ( writeBranchLengthValues()
                && !node.isRoot() && node.getDistanceToParent() >= 0.0 ) {
                    g.setFont( small_font );
                    g.setColor( branch_length_color );
                    g.drawString( dist_nf.format( node.getDistanceToParent() ),
                    node.getParent().getXcoord() + 3,
                    y_current - small_maxDescent );
                }
                if ( writeLnLValues()
                && !node.isRoot() && node.isLnLonParentBranchAssigned() ) {
                    g.setFont( small_font );
                    g.setColor( lnL_color );

                    g.drawString( lnL_nf.format( tree.getHighestLnL()
                    - node.getLnLonParentBranch() ) +
                    " (" + lnL_nf.format( node.getLnLonParentBranch() ) + ")",
                    node.getParent().getXcoord() + 3,
                    y_current + small_maxAscent );
                }

                node.setXcoord( x1 );
                node.setYcoord( y_current );

                if ( node.getNextExtNode() == null ) {
                    done = true;
                }

                // Need to check whether parent is null in case the tree is only
                // one node:
                if ( !node.isRoot() ) {
                    node = node.getParent();
                    x_current = node.getXcoord();
                    y_current = node.getYcoord();
                }
 
                

            } // if ( node.isExternal() )

        } while ( !done );

    } // end of paint()
    


    // (Last modified: 08/13/01)
    void drawFoundNode( int x,
                        int y,
                        Graphics g,
                        boolean duplication ) {

        if ( duplication ) {
            g.setColor( duplication_box_color );
        }
        else {
            g.setColor( box_color );
        }

        g.drawRect( x - HALF_BOX_SIZE,
                    y - HALF_BOX_SIZE,
                    BOX_SIZE,
                    BOX_SIZE );

        g.setColor( background_color );

        g.fillRect( x - HALF_BOX_SIZE + 1,
                    y - HALF_BOX_SIZE + 1,
                    BOX_SIZE - 1,
                    BOX_SIZE - 1 );

    } // drawFoundNode( int, int, Graphics, boolean )



    // (Last modified: 10/04/01)
    void drawCollapsedNode( int x, int y, Graphics g, Node node, boolean found ) {
        int offset = 0;
        g.setColor( branch_color );
        g.drawRect( x - HALF_BOX_SIZE,
                    y - HALF_BOX_SIZE,
                    BOX_SIZE,
                    BOX_SIZE );
        if ( found ) {
            g.setColor( background_color );
        }
        else {
            g.setColor( collapesed_fill_color );
        }
        g.fillRect( x - HALF_BOX_SIZE + 1,
                    y - HALF_BOX_SIZE + 1,
                    BOX_SIZE - 1,
                    BOX_SIZE - 1 );

        if ( speciesExtNodes() && !node.getSpecies().equals( "" ) ) {
            g.setFont( large_italic_font );
            if ( found_nodes != null && found_nodes.contains( node ) ) {
                g.setColor( found_color );
            }
            else {
                g.setColor( species_color );
            }
            if ( seqNameExtNodes() && !node.getSeqName().equals( "" ) ) {
                g.drawString( node.getSpecies() + ": ", x + 3 + HALF_BOX_SIZE,
                y + ( int ) fm_large_italic.getAscent() / 2 );
                offset = fm_large_italic.stringWidth( node.getSpecies() + ": " );
            }
            else {
                g.drawString( node.getSpecies(), x + 3 + HALF_BOX_SIZE,
                y + ( int ) fm_large_italic.getAscent() / 2 );
            }
        }

        if ( seqNameExtNodes() && !node.getSeqName().equals( "" ) ) {
            g.setFont( large_font );
            if ( found_nodes != null && found_nodes.contains( node ) ) {
                g.setColor( found_color );
            }
            else {
                g.setColor( int_node_seq_name_color );
            }    
            g.drawString( node.getSeqName(), x + 3 + HALF_BOX_SIZE + offset,
            y + ( int ) fm_large.getAscent() / 2 );
        }
    }



    // (Last modified: 06/13/01)
    private Color calculateColorForOrthologous( Node n ) {
        int o = n.getOrthologous();
        if ( o == Node.SEQ_X ) {
            return seq_x_color;
        }
       
        else {
            if ( o > getMaxOrtho() ) {
                o = getMaxOrtho();
            }
            else if ( o < 0 ) {
               o = 0;
            }
            int green = ( int ) ( ( o * 200 ) / getMaxOrtho() );
            if ( color_scheme == 4 ) {
                return new Color( 255 - green,
                                  255 - green,
                                  ext_node_seq_name_color.getBlue() );   
            } 
            else {    
                return new Color( ext_node_seq_name_color.getRed(),
                                  green,
                                  ext_node_seq_name_color.getBlue() );
            }
        }
    }



    // (Last modified: 06/13/01)
    private Color calculateColorForSuperOrthologous( Node n ) {
        int o = n.getSuperOrthologous();
        if ( o == Node.SEQ_X ) {
            return seq_x_color;
        }
        else {
            if ( o > getMaxOrtho() ) {
                o = getMaxOrtho();
            }
            else if ( o < 0 ) {
               o = 0;
            }
            int red = ( int ) ( ( o * 255 ) / getMaxOrtho() );
            if ( color_scheme == 4 ) {
                return new Color( ext_node_seq_name_color.getRed(),
                                  255 - red,
                                  255 - red  );
            }
            else { 
                return new Color( red,
                                  ext_node_seq_name_color.getGreen(),
                                  ext_node_seq_name_color.getBlue() );
            }
        }
        
    }
    

    // (Last modified: 02/16/02)
    private Color calculateColorForSubtreeNeighbors( Node n ) {
        int o = n.getSubtreeNeighborings();
        if ( o == Node.SEQ_X ) {
            return seq_x_color;
        }
        else {
            if ( o > getMaxOrtho() ) {
                o = getMaxOrtho();
            }
            else if ( o < 0 ) {
               o = 0;
            }
            int c = ( int ) ( ( o * 255 ) / getMaxOrtho() );
            if ( color_scheme == 4 ) {
                return new Color( 255 - c,
                                  ext_node_seq_name_color.getGreen(),
                                  255 - c );
            }
            else { 
                return new Color( ext_node_seq_name_color.getRed(),
                                  c,
                                  c );
            }
        }
    }


    /**

    Switches colors between different schemes.

    */
    void switchColors() {

        switch ( color_scheme ) {
            case 1:
                color_scheme = 2;
                setColors2();
                break;
            case 2:
                color_scheme = 3;
                setColors3();
                break;
            case 3:
                color_scheme = 4;
                setColors4();
                break;
            case 4:
               color_scheme = 1;
               setColors1();
               break;
            
        }
        setBackground( background_color );
        repaint();
    }


    /**

    Sets the colors to the "original" scheme.

    */
    void setColors1() {
        ext_node_seq_name_color = new Color( 0, 0, 0 );
        int_node_seq_name_color = new Color( 255, 0, 0 );
        species_color           = new Color( 40, 40, 40 );
        bootstrap_color         = new Color( 0, 125, 0 );
        ec_color                = new Color( 255, 100, 0 );
        dub_spec_color          = new Color( 255, 0, 0 );
        lnL_color               = new Color( 40, 40, 40 );
        branch_length_color     = new Color( 70, 70, 0 );
        branch_color            = new Color( 0, 20, 200 );
        box_color               = new Color( 0, 20, 200 );
        background_color        = new Color( 250, 250, 250 );
        duplication_box_color   = new Color( 255, 0, 0 );
        seq_x_color             = new Color( 0, 0, 255 );
        collapesed_fill_color   = new Color( 255, 255, 0 );
        found_color             = new Color( 255, 0, 0 );

    }

    /**

    Sets the colors to "grey".

    */
    void setColors2() {
        ext_node_seq_name_color = new Color( 0, 0, 0 );
        int_node_seq_name_color = new Color( 0, 0, 0 );
        species_color           = new Color( 0, 0, 150 );
        bootstrap_color         = new Color( 0, 0, 0 );
        ec_color                = new Color( 150, 0, 0 );
        dub_spec_color          = new Color( 150, 0, 150 );
        lnL_color               = new Color( 255, 255, 255 );
        branch_length_color     = new Color( 150, 0, 0 );
        branch_color            = new Color( 255, 255, 0 );
        box_color               = new Color( 255, 255, 0 );
        background_color        = new Color( 180, 180, 180 );
        duplication_box_color   = new Color( 255, 0, 0 );
        seq_x_color             = new Color( 0, 0, 255 );
        collapesed_fill_color   = new Color( 0, 90, 0 );
        found_color             = new Color( 0, 180, 0 );

    }

    /**

    Sets the colors to "b/w".

    */
    void setColors3() {
        ext_node_seq_name_color = new Color( 0, 0, 0 );
        int_node_seq_name_color = new Color( 0, 0, 0 );
        species_color           = new Color( 50, 50, 50 );
        bootstrap_color         = new Color( 100, 100, 100 );
        ec_color                = new Color( 0, 0, 0 );
        dub_spec_color          = new Color( 0, 0, 0 );
        lnL_color               = new Color( 100, 100, 100 );
        branch_length_color     = new Color( 50, 50, 50 );
        branch_color            = new Color( 0, 0, 0 );
        box_color               = new Color( 0, 0, 0 );
        background_color        = new Color( 255, 255, 255 );
        duplication_box_color   = new Color( 255, 0, 0 );
        seq_x_color             = new Color( 0, 0, 255 );
        collapesed_fill_color   = new Color( 255, 255, 0 );
        found_color             = new Color( 255, 0, 0 );
    }
 
 
 
    /**

    Sets the colors to "blue".

    */
    void setColors4() {
        ext_node_seq_name_color = new Color( 255, 255, 255 );
        int_node_seq_name_color = new Color( 255, 255, 255 );
        species_color           = new Color( 200, 200, 200 );
        bootstrap_color         = new Color( 255, 255, 255 );
        ec_color                = new Color( 200, 200, 200 );
        dub_spec_color          = new Color( 255, 255, 255 );
        lnL_color               = new Color( 200, 200, 200 );
        branch_length_color     = new Color( 200, 200, 200 );
        branch_color            = new Color( 0, 255, 255 );
        box_color               = new Color( 0, 255, 255 );
        background_color        = new Color( 0, 0, 70 );
        duplication_box_color   = new Color( 255, 0, 0 );
        seq_x_color             = new Color( 255, 255, 0 );
        collapesed_fill_color   = new Color( 255, 255, 0 );
        found_color             = new Color( 255, 0, 0 );

    }

    
    /**

    Medium size.

    */
    void mediumFonts() {
        small_font        = new Font( "Helvetica", Font.PLAIN,  10 );
        large_font        = new Font( "Helvetica", Font.PLAIN,  11 );
        small_italic_font = new Font( "Helvetica", Font.ITALIC, 10 );
        large_italic_font = new Font( "Helvetica", Font.ITALIC, 11 );

        fm_small        = getFontMetrics( small_font );
        fm_large        = getFontMetrics( large_font );
        fm_small_italic = getFontMetrics( small_italic_font );
        fm_large_italic = getFontMetrics( large_italic_font );

        small_maxDescent = fm_small.getMaxDescent();
        small_maxAscent  = fm_small.getMaxAscent() + 2;
    }


    /**

    Large size.

    */
    void largeFonts() {
        small_font        = new Font( "Helvetica", Font.PLAIN,  13 );
        large_font        = new Font( "Helvetica", Font.PLAIN,  13 );
        small_italic_font = new Font( "Helvetica", Font.ITALIC, 13 );
        large_italic_font = new Font( "Helvetica", Font.ITALIC, 13 );

        fm_small        = getFontMetrics( small_font );
        fm_large        = getFontMetrics( large_font );
        fm_small_italic = getFontMetrics( small_italic_font );
        fm_large_italic = getFontMetrics( large_italic_font );

        small_maxDescent = fm_small.getMaxDescent();
        small_maxAscent  = fm_small.getMaxAscent() + 2;
    }


    /**

    Small size.

    */
    void smallFonts() {
        small_font        = new Font( "Helvetica", Font.PLAIN,  9 );
        large_font        = new Font( "Helvetica", Font.PLAIN,  10 );
        small_italic_font = new Font( "Helvetica", Font.ITALIC, 9 );
        large_italic_font = new Font( "Helvetica", Font.ITALIC, 10 );

        fm_small        = getFontMetrics( small_font );
        fm_large        = getFontMetrics( large_font );
        fm_small_italic = getFontMetrics( small_italic_font );
        fm_large_italic = getFontMetrics( large_italic_font );

        small_maxDescent = fm_small.getMaxDescent();
        small_maxAscent  = fm_small.getMaxAscent() + 1;
    }


    /**

    Tiny size.

    */
    void tinyFonts() {
        small_font        = new Font( "Helvetica", Font.PLAIN,  8 );
        large_font        = new Font( "Helvetica", Font.PLAIN,  8 );
        small_italic_font = new Font( "Helvetica", Font.ITALIC, 8 );
        large_italic_font = new Font( "Helvetica", Font.ITALIC, 8 );

        fm_small        = getFontMetrics( small_font );
        fm_large        = getFontMetrics( large_font );
        fm_small_italic = getFontMetrics( small_italic_font );
        fm_large_italic = getFontMetrics( large_italic_font );

        small_maxDescent = fm_small.getMaxDescent();
        small_maxAscent  = fm_small.getMaxAscent() + 1;
    } 

	
} // End of ATVgraphic.
