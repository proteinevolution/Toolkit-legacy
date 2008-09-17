// ATVprinter.java
//
// Copyright (C) 1999-2001 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved
//
// Created: 1999
// Author: Christian M. Zmasek
// zmasek@genetics.wustl.edu
// http://www.genetics.wustl.edu/eddy/people/zmasek/

package forester.atv;


import forester.tree.*;

import java.io.*;
import java.awt.*;
import java.awt.event.*;
import java.text.NumberFormat;


/**

@author Christian Zmasek

@version 1.500 -- last modified: 02/17/02


*/
class ATVprinter extends Frame {

    private Tree tree;
    private Node node,
                 n;
    private String title;
    private ATVgraphic ag;
 
    private final static boolean DRAW_NODES_AS_BOXES  = false;
    private final static double  FACTOR_TO_FILL_SHEET = 1.0;
    private final static int     BOX_SIZE             = 3,
                                 CIRCLE_SIZE          = 6,  // Circles to represent duplications.
                                 MOVE                 = 30, // tree graphic is moved by this distance in both x and y.
                                 TITLE                = MOVE * 2,
                                 HALF_BOX_SIZE        = ( int ) BOX_SIZE / 2,
                                 HALF_CIRCLE_SIZE     = ( int ) CIRCLE_SIZE / 2;
    
   
    private int longest_ext_node_info          = 0,
                y_current                      = 0,
                x1                             = 0,
                y1                             = 0, 
                x2                             = 0, 
                y2                             = 0, 
                factor                         = 0,
                green                          = 0, 
                red                            = 0,
                x                              = 0, // for offsetting text in x direction
                ext_nodes_x                    = 0;

    private double x_current                   = 0.0,
                   x2double                    = 0.0,
                   x_correction_factor         = 0.0,
                   x_distance                  = 0.0,
                   y_distance                  = 0.0,
                   d                           = 0.0;
 
    private boolean done                       = false,
                    color                      = false;


    private static Color ext_node_seq_name_color,
                         int_node_seq_name_color,
                         species_color,
                         bootstrap_color,
                         ec_color,
                         dub_spec_color,
                         lnL_color,
                         branch_length_color,
                         branch_color,
                         box_color,
                         duplication_box_color,
                         background_color,
                         seq_x_color;

    private final static Font small_font        = new Font( "Helvetica", Font.PLAIN,  5 );
    private final static Font large_font        = new Font( "Helvetica", Font.PLAIN,  6 );
    private final static Font small_italic_font = new Font( "Helvetica", Font.ITALIC, 5 );
    private final static Font large_italic_font = new Font( "Helvetica", Font.ITALIC, 6 );

    private final FontMetrics fm_small        = getFontMetrics( small_font );
    private final FontMetrics fm_large        = getFontMetrics( large_font );
    private final FontMetrics fm_small_italic = getFontMetrics( small_italic_font );
    private final FontMetrics fm_large_italic = getFontMetrics( large_italic_font );

    private final int small_maxDescent = fm_small.getMaxDescent(),
                      small_maxAscent  = fm_small.getMaxAscent() + 2;

    private NumberFormat lnL_nf  = NumberFormat.getNumberInstance(),
                         dist_nf = NumberFormat.getNumberInstance();



    ATVprinter( ATVgraphic a, String s, boolean print_in_color ) {
        
        ag = a;

        tree = ag.getTree();

        title = s;

        color = print_in_color;

        x_distance          = ag.x_distance * FACTOR_TO_FILL_SHEET;
        y_distance          = ag.y_distance;
        x_correction_factor = ag.getXcorrectionFactor() * FACTOR_TO_FILL_SHEET;

        if ( !color ) {
            ext_node_seq_name_color = new Color( 0, 0, 0 );
            int_node_seq_name_color = new Color( 0, 0, 0 );
            species_color           = new Color( 0, 0, 0 );
            bootstrap_color         = new Color( 0, 0, 0 );
            ec_color                = new Color( 0, 0, 0 );
            dub_spec_color          = new Color( 0, 0, 0 );
            lnL_color               = new Color( 0, 0, 0 );
            branch_length_color     = new Color( 0, 0, 0 );
            branch_color            = new Color( 0, 0, 0 );
            box_color               = new Color( 0, 0, 0 );
            duplication_box_color   = new Color( 0, 0, 0 );
            background_color        = new Color( 255, 255, 255 );
            seq_x_color             = new Color( 0, 0, 0 );
        }    
        else {                      
            ext_node_seq_name_color = new Color( 0, 0, 0 );
            int_node_seq_name_color = new Color( 255, 0, 0 );
            species_color           = new Color( 40, 40, 40 );
            bootstrap_color         = new Color( 0, 160, 0 );
            ec_color                = new Color( 255, 100, 0 );
            dub_spec_color          = new Color( 255, 0, 0 );
            lnL_color               = new Color( 40, 40, 40 );
            branch_length_color     = new Color( 70, 70, 0 );
            branch_color            = new Color( 0, 0, 0 );
            box_color               = new Color( 0, 0, 0 );
            duplication_box_color   = new Color( 0, 0, 0 );
            background_color        = new Color( 255, 255, 255 );
            seq_x_color             = new Color( 0, 0, 255 );
        }    

        setBackground( background_color );
        
        setVisible( true );

        printTree();

        ag = null;
        tree = null;

        dispose();

    }

    

    private void printTree() {

        if ( tree == null || tree.isEmpty() ) {
            return;
        }

        Graphics g;
        Toolkit  tk = Toolkit.getDefaultToolkit();

        if ( tk != null ) {

            PrintJob pj = tk.getPrintJob( this, title , null );
            if ( pj != null ) {

                g = pj.getGraphics();

                if ( g != null ) {

                    done = false;


                    lnL_nf.setMaximumFractionDigits( 6 );
                    lnL_nf.setMinimumFractionDigits( 1 );
                    dist_nf.setMaximumFractionDigits( 6 );
                    dist_nf.setMinimumFractionDigits( 1 );

                    node = tree.getRoot();

                    tree.setIndicatorsToZero();

                    if ( !tree.isRooted() ) {
                        x_current = MOVE;
                    }
                    else if ( tree.getRoot().getDistanceToParent() > 0.0
                    && ag.useRealBranchLenghts() ) {
                        x_current = MOVE + tree.getRoot().getDistanceToParent()
                                    * x_correction_factor;
                    }
                    else {
                        x_current = MOVE + x_distance;
                    }
                    g.setFont( large_font );
                    g.drawString( title, MOVE, TITLE - MOVE );

                    y_current = TreeHelper.roundToInt( y_distance * tree.getNumberOfExtNodes()
                                + TITLE + MOVE / 2.0 );

                    ext_nodes_x = MOVE + TreeHelper.roundToInt( x_distance * tree.getNumberOfExtNodes() );
                   

                    do {
                        // Does not write onto ext nodes.
                        if ( !node.isPseudoNode() ) {

                            if ( ag.writeBranchLengthValues() && node.getIndicator() == 0
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
                            if ( ag.writeLnLValues() && node.getIndicator() == 0
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
                            if ( ag.writeBootstrapValues() && node.getIndicator() == 0
                            && node.getBootstrap() > 0 && tree.getNumberOfExtNodes() >= 2
                            && !node.collapse() ) {
                                g.setFont( small_font );
                                g.setColor( bootstrap_color );
                                g.drawString( Integer.toString( node.getBootstrap() ), TreeHelper.roundToInt( x_current ) -
                                fm_small.stringWidth( Integer.toString( node.getBootstrap() ) ) - 1
                                - HALF_BOX_SIZE, y_current + small_maxAscent );
                            }
                        }

                        // Draw a line as root:
                        if ( node.isRoot() && tree.isRooted()
                        && node.getIndicator() == 0 ) {

                            x1 = TreeHelper.roundToInt( x_current );

                            if ( !ag.colorBranchesAccToLnL()
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

                            if ( ag.useRealBranchLenghts() && tree.getRoot().getDistanceToParent() > 0.0 ) {
                                d = x_correction_factor * tree.getRoot().getDistanceToParent();
                                g.drawLine( x1, y_current, x1 - TreeHelper.roundToInt( d ), y_current );
                            }
                            else {
                                g.drawLine( x1, y_current, x1 - TreeHelper.roundToInt( x_distance ), y_current );
                                if ( ag.colorBranchesAccToLnL()
                                && !node.significantlyWorse() ) {
                                    g.drawLine( x1, y_current - 1, x1 - TreeHelper.roundToInt( x_distance ), y_current - 1 );
                                    g.drawLine( x1, y_current + 1, x1 - TreeHelper.roundToInt( x_distance ), y_current + 1 );
                                }
                            }
                            if ( !node.collapse() ) {
                                if ( !ag.writeDupSpec() && node.isDuplicationOrSpecAssigned()
                                && node.isDuplication() ) {
                                     drawDuplicationNode( TreeHelper.roundToInt( x_current ), y_current, g );
                                }
                                else if ( DRAW_NODES_AS_BOXES ) {
                                    g.setColor( box_color );
                                    g.fillRect( TreeHelper.roundToInt( x_current ) - HALF_BOX_SIZE,
                                                y_current - HALF_BOX_SIZE,
                                                BOX_SIZE,
                                                BOX_SIZE );
                                }
                            }
                            else {
                                drawCollapsedNode( TreeHelper.roundToInt( x_current ), y_current, g, node );
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
                                if ( ag.speciesInternalNodes()
                                && !node.collapse() && !node.getSpecies().equals( "" )  ) {
                                    g.setFont( small_italic_font );
                                    g.setColor( species_color );
                                    g.drawString( node.getSpecies(), x1 + 3 + HALF_BOX_SIZE,
                                    y_current + ( int ) fm_small_italic.getAscent() / 2 );
                                }

                                // Sequence name int node:
                                if ( ag.seqNameInternalNodes() && !node.getSeqName().equals( "" )
                                && !node.collapse() ) {
                                    g.setColor( int_node_seq_name_color );
                                    g.setFont( large_font );
                                    g.drawString( node.getSeqName(), x1 -
                                    fm_large.stringWidth( node.getSeqName() ) - 3 - HALF_BOX_SIZE,
                                    y_current - fm_large.getMaxDescent() );
                                }

                                // EC int node:
                                if ( ag.ECInternalNodes() && !node.getECnumber().equals( "" )
                                && !node.collapse() ) {
                                    g.setColor( ec_color );
                                    g.setFont( large_font );
                                    if ( ag.seqNameInternalNodes() && !node.getSeqName().equals( "" ) ) {
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
                                if ( ag.writeDupSpec() && node.isDuplicationOrSpecAssigned()
                                && !node.collapse() ) {
                                    g.setColor( dub_spec_color );
                                    g.setFont( large_font );

                                    if ( ag.speciesInternalNodes() ) {
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
                                if ( ag.useRealBranchLenghts() ) {
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

                                if ( !ag.useRealBranchLenghts() 
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
                                
                                g.drawLine( x1, y1, x1, y2 );
                                

                                if ( !ag.colorBranchesAccToLnL()
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
                                    if ( !node.getChild1().collapse() ) {
                                        if ( !ag.writeDupSpec()
                                        && node.getChild1().isDuplicationOrSpecAssigned()
                                        && node.getChild1().isDuplication() ) {
                                            drawDuplicationNode( x2, y2, g );
                                        }
                                        else if ( DRAW_NODES_AS_BOXES ) {
                                            g.setColor( box_color );
                                            g.fillRect( x2 - HALF_BOX_SIZE,
                                                        y2 - HALF_BOX_SIZE,
                                                        BOX_SIZE,
                                                        BOX_SIZE );
                                        } 
                                    }
                                    else {
                                        drawCollapsedNode( x2, y2, g, node.getChild1() );
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

                                if ( ag.useRealBranchLenghts() ) {
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
                                if ( !ag.useRealBranchLenghts()
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
                              
                                g.drawLine( x1, y1, x1, y2 );

                                if ( !ag.colorBranchesAccToLnL()
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


                                if (  !node.getChild2().isPseudoNode() ) {
                                    if ( !node.getChild2().collapse() ) {
                                        if ( !ag.writeDupSpec() 
                                        && node.getChild2().isDuplicationOrSpecAssigned()
                                        && node.getChild2().isDuplication() ) {
                                            drawDuplicationNode( x2, y2, g );
                                        }
                                        else if ( DRAW_NODES_AS_BOXES ) {
                                            g.setColor( box_color );
                                            g.fillRect( x2 - HALF_BOX_SIZE,
                                                        y2 - HALF_BOX_SIZE,
                                                        BOX_SIZE,
                                                        BOX_SIZE );
                                        }
                                    }
                                    else {
                                        drawCollapsedNode( x2, y2, g, node.getChild2() );
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

                            if ( ag.speciesExtNodes() && !node.getSpecies().equals( "" ) ) {
                                g.setFont( large_italic_font );
                                if ( ag.colorOrthologous()
                                && node.getOrthologous() != Node.ORTHOLOGOUS_DEFAULT ) {
                                    g.setColor( calculateColorForOrthologous( node ) );
                                }
                                else if ( ag.colorSuperOrthologous()
                                && node.getSuperOrthologous() != Node.ORTHOLOGOUS_DEFAULT ) {
                                    g.setColor( calculateColorForSuperOrthologous( node ) );
                                }
                                else if ( ag.colorSubtreeNeighbors()
                                && node.getSubtreeNeighborings() != Node.ORTHOLOGOUS_DEFAULT ) {
                                    g.setColor( calculateColorForSubtreeNeighbors( node ) );
                                }
                                else {
                                    g.setColor( species_color );
                                }
                                g.drawString( node.getSpecies() + " ", x1 + 3 + HALF_BOX_SIZE,
                                y_current + ( int ) fm_large.getAscent() / 2 );
                            }
                            if ( ag.seqNameExtNodes() && !node.getSeqName().equals( "" ) ) {
                                g.setFont( large_font );
                                if ( ag.colorOrthologous()
                                && node.getOrthologous() != Node.ORTHOLOGOUS_DEFAULT ) {
                                    g.setColor( calculateColorForOrthologous( node ) );
                                }
                                else if ( ag.colorSuperOrthologous()
                                && node.getSuperOrthologous() != Node.ORTHOLOGOUS_DEFAULT ) {
                                    g.setColor( calculateColorForSuperOrthologous( node ) );
                                }
                                else if ( ag.colorSubtreeNeighbors()
                                && node.getSubtreeNeighborings() != Node.ORTHOLOGOUS_DEFAULT ) {
                                    g.setColor( calculateColorForSubtreeNeighbors( node ) );
                                }
                                else {
                                    g.setColor( ext_node_seq_name_color );
                                }
                                if ( ag.speciesExtNodes() && !node.getSpecies().equals( "" ) ) {
                                    x = fm_large_italic.stringWidth( node.getSpecies() + " " );
                                }
                                else {
                                    x = 0;
                                }
                                g.drawString( node.getSeqName(), x1 + x + 3 + HALF_BOX_SIZE,
                                y_current + ( int ) fm_large.getAscent() / 2 );
                            }
                            if ( ag.ECExtNodes() && !node.getECnumber().equals( "" ) ) {
                                g.setFont( large_font );
                                g.setColor( ec_color );
                                if ( ag.speciesExtNodes() && !node.getSpecies().equals( "" ) ) {
                                    x = fm_large_italic.stringWidth( node.getSpecies() + " " );
                                }
                                else {
                                    x = 0;
                                }
                                if ( ag.seqNameExtNodes() && !node.getSeqName().equals( "" ) ) {
                                    x += fm_large.stringWidth( node.getSeqName() + " " );
                                }

                                g.drawString( node.getECnumber(), x1 + x + 3  + HALF_BOX_SIZE,
                                y_current + ( int ) fm_large.getAscent() / 2 );
                            }

                            if ( ( ag.colorOrthologous()
                            && node.getOrthologous() != Node.ORTHOLOGOUS_DEFAULT ) 
                            ||  ( ag.colorSuperOrthologous()
                            && node.getSuperOrthologous() != Node.ORTHOLOGOUS_DEFAULT )
                            || ( ag.colorSubtreeNeighbors()
                            && node.getSubtreeNeighborings() != Node.ORTHOLOGOUS_DEFAULT ) ) {
                                g.setColor( calculateColorForOrthologous( node ) );
                                g.setFont( large_font );
                                if ( ag.speciesExtNodes() && !node.getSpecies().equals( "" ) ) {
                                    x = fm_large_italic.stringWidth( node.getSpecies() + " " );
                                }
                                else {
                                    x = 0;
                                }
                                if ( ag.seqNameExtNodes() && !node.getSeqName().equals( "" ) ) {
                                    x += fm_large.stringWidth( node.getSeqName() + " " );
                                }
                                if ( ag.ECExtNodes() && !node.getECnumber().equals( "" ) ) {
                                    x += fm_large.stringWidth( node.getECnumber() + " " );
                                }
                                if ( ag.colorOrthologous() ) {
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
                                else if ( ag.colorSuperOrthologous() ) {
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
                                else if ( ag.colorSubtreeNeighbors() ) {
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

                            if ( ag.writeBranchLengthValues()
                            && !node.isRoot() && node.getDistanceToParent() >= 0.0 ) {
                                g.setFont( small_font );
                                g.setColor( branch_length_color );
                                g.drawString( dist_nf.format( node.getDistanceToParent() ),
                                node.getParent().getXcoord() + 3,
                                y_current - small_maxDescent );
                            }
                            if ( ag.writeLnLValues()
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

                    tree.setIndicatorsToZero();

                    g.dispose();

                }

                pj.end();

            }
        }

    } // end of method printTree.


    

    private void drawDuplicationNode( int x, int y, Graphics g ) {
        g.setColor( duplication_box_color );
        g.fillOval( x - HALF_CIRCLE_SIZE,
                    y - HALF_CIRCLE_SIZE,
                    CIRCLE_SIZE,
                    CIRCLE_SIZE ); 
    }

  
    // (Last modified: 06/13/01)
    private Color calculateColorForOrthologous( Node n ) {
        int o = n.getOrthologous();
        if ( o == Node.SEQ_X ) {
            return seq_x_color;
        }
        else {
            if ( o > ag.getMaxOrtho() ) {
                o = ag.getMaxOrtho();
            }
            else if ( o < 0 ) {
               o = 0;
            }
            int green = ( int ) ( ( o * 240 ) / ag.getMaxOrtho() );
            return new Color( ext_node_seq_name_color.getRed(),
                              green,
                              ext_node_seq_name_color.getBlue() );
        }
    }



    // (Last modified: 06/13/01)
    private Color calculateColorForSuperOrthologous( Node n ) {
        int o = n.getSuperOrthologous();
        if ( o == Node.SEQ_X ) {
            return seq_x_color;
        }
        else {
            if ( o > ag.getMaxOrtho() ) {
                o = ag.getMaxOrtho();
            }
            else if ( o < 0 ) {
               o = 0;
            }
            int red = ( int ) ( ( o * 255 ) / ag.getMaxOrtho() );
            return new Color( red,
                              ext_node_seq_name_color.getGreen(),
                              ext_node_seq_name_color.getBlue() );
        }
    }


     // (Last modified: 02/17/02)
    private Color calculateColorForSubtreeNeighbors( Node n ) {
        int o = n.getSubtreeNeighborings();
        if ( o == Node.SEQ_X ) {
            return seq_x_color;
        }
        else {
            if ( o > ag.getMaxOrtho() ) {
                o = ag.getMaxOrtho();
            }
            else if ( o < 0 ) {
               o = 0;
            }
            int c = ( int ) ( ( o * 255 ) / ag.getMaxOrtho() );
            return new Color( ext_node_seq_name_color.getRed(),
                              c,
                              c );
        }
    }


    
    // (Last modified: 06/28/01)
    void drawCollapsedNode( int x, int y, Graphics g, Node node ) {
        int offset = 0;
        g.setColor( branch_color );
        g.drawRect( x - HALF_BOX_SIZE + 1,
                    y - HALF_BOX_SIZE,
                    BOX_SIZE,
                    BOX_SIZE );
        g.setColor( background_color );
        g.fillRect( x - HALF_BOX_SIZE + 2,
                    y - HALF_BOX_SIZE + 1,
                    BOX_SIZE - 2,
                    BOX_SIZE - 2 );

        if ( ag.speciesExtNodes() && !node.getSpecies().equals( "" ) ) {
            g.setFont( large_italic_font );
            g.setColor( species_color );
            if ( ag.seqNameExtNodes() && !node.getSeqName().equals( "" ) ) {
                g.drawString( node.getSpecies() + ": ", x + 3 + HALF_BOX_SIZE,
                y + ( int ) fm_large_italic.getAscent() / 2 );
                offset = fm_large_italic.stringWidth( node.getSpecies() + ": " );
            }
            else {
                g.drawString( node.getSpecies(), x + 3 + HALF_BOX_SIZE,
                y + ( int ) fm_large_italic.getAscent() / 2 );
            }
        }

        if ( ag.seqNameExtNodes() && !node.getSeqName().equals( "" ) ) {
            g.setFont( large_font );
            g.setColor( int_node_seq_name_color );
            g.drawString( node.getSeqName(), x + 3 + HALF_BOX_SIZE + offset,
            y + ( int ) fm_large.getAscent() / 2 );
        }
    }


} // End of class ATVprinter.
