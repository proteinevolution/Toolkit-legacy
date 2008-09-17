// ATVcontrol.java
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

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;


/**

@author Christian M. Zmasek

@version 1.201 -- last modified: 02/17/02


*/
class ATVcontrol extends JPanel implements ActionListener {

    ATVpanel     atvpanel;

    JCheckBox    userealbl, seqnameextnodes, seqnameintnodes, speciesextnodes,
                 speciesintnodes, ecintnodes, ecextnodes, writelnl, writebl,
                 writebootstrap, writed_s, colorbranches, color_orthos,
                 color_super_orthos, color_sn, editable;

    JButton      zoom_in_x, zoom_in_y, zoom_out_x, zoom_out_y, show_whole, order,
                 uncollapse_all, collapse_to_deepest_annot;

    JRadioButton display_info, collapse, reroot, swap, subtree;

    ButtonGroup  group;

    JLabel       click_to;

    boolean      order_of_appearance; 

    final static Font jcb_font = new Font( "Helvetica", Font.PLAIN, 9 );

    static Color background_color,
                 jcb_text_color,
                 jcb_background_color,
                 button_text_color,
                 button_background_color;



    /**

    Default constructor.

    */
    ATVcontrol() {}



    /**

    Constructor.

    */
    ATVcontrol( ATVpanel ap ) {

        atvpanel = ap;

        setColors1();

        setBackground( background_color );

        setLayout( new GridLayout( 0, 1, 2, 2 ) );

        order_of_appearance = true;

        userealbl          = new JCheckBox( "real branch lengths" );
        seqnameextnodes    = new JCheckBox( "seq name ext nodes" );
        seqnameintnodes    = new JCheckBox( "seq name int nodes" );
        speciesextnodes    = new JCheckBox( "species ext nodes" );
        speciesintnodes    = new JCheckBox( "species int nodes" );
        ecextnodes         = new JCheckBox( "EC ext nodes" );
        ecintnodes         = new JCheckBox( "EC int nodes" );
        writelnl           = new JCheckBox( "log L values" );
        writebl            = new JCheckBox( "branch length values" );
        writebootstrap     = new JCheckBox( "bootstrap values" );
        writed_s           = new JCheckBox( "duplic vs spec" );
        colorbranches      = new JCheckBox( "color accord to log L" );
        color_orthos       = new JCheckBox( "display orthology" );
        color_sn           = new JCheckBox( "display subtr-neighb" );
        color_super_orthos = new JCheckBox( "display s-orthology" );
        editable           = new JCheckBox( "editable" );

        addJCB( userealbl ) ;
        addJCB( seqnameextnodes );
        addJCB( seqnameintnodes );
        addJCB( speciesextnodes );
        addJCB( speciesintnodes );
        addJCB( ecextnodes );
        addJCB( ecintnodes );
        addJCB( writebl );
        addJCB( writebootstrap );
        addJCB( writed_s );
        addJCB( color_orthos );
        addJCB( color_sn );
        addJCB( color_super_orthos );
        addJCB( colorbranches );
        addJCB( writelnl );
        addJCB( editable );

        click_to = new JLabel( "click on node to:" );
        click_to.setFont( jcb_font );
        click_to.setForeground( jcb_text_color );
        click_to.setBackground( background_color );
        add( click_to );

        display_info    = new JRadioButton( "display/edit information" );
        collapse        = new JRadioButton( "collapse/uncollapse" );
        reroot          = new JRadioButton( "root/reroot" );
        swap            = new JRadioButton( "swap children" );
        subtree         = new JRadioButton( "subtree/parent tree" );

        group = new ButtonGroup();

        addJRB( display_info );
        addJRB( collapse );
        addJRB( reroot );
        addJRB( subtree );
        addJRB( swap );

        zoom_in_x                 = new JButton( "zoom in X" );
        zoom_in_y                 = new JButton( "zoom in Y" );
        zoom_out_x                = new JButton( "zoom out X" );
        zoom_out_y                = new JButton( "zoom out Y" );
        show_whole                = new JButton( "show whole" );
        order                     = new JButton( "order subtrees" ); 
        uncollapse_all            = new JButton( "uncollapse all" );
        collapse_to_deepest_annot = new JButton( "collapse to deepest" );
    
        collapse_to_deepest_annot.setToolTipText(
        "Collapses to the deepest nodes annotated with either a species or a sequence name." );
        
        uncollapse_all.setToolTipText(
        "Uncollapses all nodes." );
        
        order.setToolTipText(
        "Orders (swaps children of) each subtree according to its sum of external nodes." );

        addJB( zoom_in_x );
        addJB( zoom_out_x );
        addJB( zoom_in_y );
        addJB( zoom_out_y );
        addJB( show_whole );
        addJB2( order );
        addJB2( uncollapse_all );
        addJB2( collapse_to_deepest_annot );

        setCheckBoxes();

    }

    void setCheckBoxes() {
        ATVgraphic ag = atvpanel.getATVgraphic();
        if ( ag.getTree() != null ) {
            display_info.setSelected( true );
            userealbl.setSelected( ag.useRealBranchLenghts() ); 
            seqnameextnodes.setSelected( ag.seqNameExtNodes() );
            seqnameintnodes.setSelected( ag.seqNameInternalNodes() );
            speciesextnodes.setSelected( ag.speciesExtNodes() );
            speciesintnodes.setSelected( ag.speciesInternalNodes() );
            ecextnodes.setSelected( ag.ECExtNodes()  );
            ecintnodes.setSelected( ag.ECInternalNodes() );
            writelnl.setSelected( ag.writeLnLValues()  );
            writebl.setSelected( ag.writeBranchLengthValues() );
            writebootstrap.setSelected( ag.writeBootstrapValues() );
            colorbranches.setSelected( ag.colorBranchesAccToLnL() );
            color_orthos.setSelected( ag.colorOrthologous() );
            color_sn.setSelected( ag.colorSubtreeNeighbors() );
            color_super_orthos.setSelected( ag.colorSuperOrthologous() );
            editable.setSelected( ag.isEditable() );
            
            if      ( atvpanel.getATVgraphic().getActionWhenNodeClicked()
            == ATVgraphic.SHOW_INFO ) {
                display_info.setSelected( true );
            }
            else if ( atvpanel.getATVgraphic().getActionWhenNodeClicked()
            == ATVgraphic.COLLAPSE ) {
                collapse.setSelected( true );
            }
            else if ( atvpanel.getATVgraphic().getActionWhenNodeClicked()
            == ATVgraphic.REROOT ) {
                reroot.setSelected( true );
            }
            else if ( atvpanel.getATVgraphic().getActionWhenNodeClicked()
            == ATVgraphic.SUBTREE ) {
                subtree.setSelected( true );
            }
            else if ( atvpanel.getATVgraphic().getActionWhenNodeClicked()
            == ATVgraphic.SWAP ) {
                swap.setSelected( true );
            }
        }
    }


    void addJCB( JCheckBox jcb ) {
        jcb.setBackground( jcb_background_color );
        jcb.setForeground( jcb_text_color );
        jcb.setFont( jcb_font );
        add( jcb );
        jcb.addActionListener( this );
    }

    void addJRB( JRadioButton jrb ) {
        jrb.setBackground( jcb_background_color );
        jrb.setForeground( jcb_text_color );
        jrb.setFont( jcb_font );
        add( jrb );
        group.add( jrb );
        jrb.addActionListener( this );
    }

    void addJB( JButton jb ) {
        jb.setBackground( button_background_color );
        jb.setForeground( button_text_color );
        jb.setFont( jcb_font );
        add( jb );
        jb.addActionListener( this );
    }

    void addJB2( JButton jb ) {
        jb.setBackground( background_color );
        jb.setForeground( button_text_color );
        jb.setFont( jcb_font );
        add( jb );
        jb.addActionListener( this );
    }

    

    public void actionPerformed( ActionEvent e ) {
            
        ATVgraphic ag = atvpanel.getATVgraphic();
        if ( e.getSource() == color_orthos ) {
            color_super_orthos.setSelected( false );
            color_sn.setSelected( false );
        }
        if ( e.getSource() == color_super_orthos ) {
            color_orthos.setSelected( false );
            color_sn.setSelected( false );
        }
        if ( e.getSource() == color_sn ) {
            color_orthos.setSelected( false );
            color_super_orthos.setSelected( false );
        }
        if ( ag.getTree() != null ) {
            if   ( userealbl.isSelected() ) {
                ag.setUseRealBranchLenghts( true );
            }
            else {
                ag.setUseRealBranchLenghts( false );
            }
            if ( e.getSource() == userealbl ) {
                showWhole();   
            } 
            
            ag.setSeqNameExtNodes( seqnameextnodes.isSelected() );
            ag.setSeqNameInternalNodes( seqnameintnodes.isSelected() );
            ag.setSpeciesExtNodes( speciesextnodes.isSelected() );
            ag.setSpeciesInternalNodes( speciesintnodes.isSelected() );
            ag.setECExtNodes( ecextnodes.isSelected() );
            ag.setECInternalNodes( ecintnodes.isSelected() );
            ag.setWriteLnLValues( writelnl.isSelected() );
            ag.setWriteBranchLengthValues( writebl.isSelected() );
            ag.setWriteBootstrapValues( writebootstrap.isSelected() );
            ag.setWriteDupSpec( writed_s.isSelected() );
            ag.setColorBranchesAccToLnL( colorbranches.isSelected() );
            ag.setColorOrthologous( color_orthos.isSelected() );
            ag.setColorSuperOrthologous( color_super_orthos.isSelected() );
            ag.setColorSubtreeNeighbors( color_sn.isSelected() );
            ag.setEditable( editable.isSelected() ); 
            
            if ( display_info.isSelected() ) {
                atvpanel.getATVgraphic().setActionWhenNodeClicked(
                ATVgraphic.SHOW_INFO );
            }
            else if ( collapse.isSelected() ) {
                atvpanel.getATVgraphic().setActionWhenNodeClicked(
                ATVgraphic.COLLAPSE );
            }
            else if ( reroot.isSelected() ) {
                atvpanel.getATVgraphic().setActionWhenNodeClicked(
                ATVgraphic.REROOT );
            }
            else if ( subtree.isSelected() ) {
                atvpanel.getATVgraphic().setActionWhenNodeClicked(
                ATVgraphic.SUBTREE );
            }
            else if ( swap.isSelected() ) {
                atvpanel.getATVgraphic().setActionWhenNodeClicked(
                ATVgraphic.SWAP );
            }


            if ( e.getSource() == zoom_in_x ) {
                atvpanel.getATVgraphic().setXdistance(
                ( int ) ( atvpanel.getATVgraphic().getXdistance() * 1.05 ) + 1 );

                atvpanel.getATVgraphic().setXcorrectionFactor(
                atvpanel.getATVgraphic().getXcorrectionFactor() * 1.10 );
                atvpanel.getATVgraphic().resetPreferredSize();
            }
            else if ( e.getSource() == zoom_in_y ) {
                atvpanel.getATVgraphic().setYdistance(
                ( int ) ( atvpanel.getATVgraphic().getYdistance() * 1.05 ) + 1 );
                atvpanel.getATVgraphic().resetPreferredSize();
            }
            else if ( e.getSource() == zoom_out_x ) {
                atvpanel.getATVgraphic().setXdistance(
                ( int ) ( atvpanel.getATVgraphic().getXdistance() * 0.95 ) );

                atvpanel.getATVgraphic().setXcorrectionFactor(
                atvpanel.getATVgraphic().getXcorrectionFactor() * 0.90 );
                atvpanel.getATVgraphic().resetPreferredSize();
            }
            else if ( e.getSource() == zoom_out_y ) {
                atvpanel.getATVgraphic().setYdistance(
                ( int ) ( atvpanel.getATVgraphic().getYdistance() * 0.95 ) );
                atvpanel.getATVgraphic().resetPreferredSize();
            }
            else if ( e.getSource() == show_whole ) {
                showWhole();
            }
            else if ( e.getSource() == order ) {
                ag.getTree().orderAppearance( order_of_appearance );
                order_of_appearance = !order_of_appearance;
            }
            else if ( e.getSource() == uncollapse_all ) {
                uncollapseAll( ag );
            }
            else if ( e.getSource() == collapse_to_deepest_annot ) {
                collapseToDeepestAnnot( ag );
            }
            
            atvpanel.adjustJScrollPane();
            atvpanel.getATVgraphic().repaint();

        }
    }



    void uncollapseAll( ATVgraphic ag ) {
        Tree t = ag.getTree();
        if ( t != null && !t.isEmpty() ) {
            t.setAllNodesToNotCollapse();
            t.adjustNodeCount( false );
            t.recalculateAndReset();
            showWhole();
        }
    }



    void collapseToDeepestAnnot( ATVgraphic ag ) {
        Tree t = ag.getTree();
        if ( t != null && !t.isEmpty() ) {
            t.collapseToDeepestAnotNodes();
            showWhole();
        }
    }


    // (Last modified: 10/04/01)
    void showWhole() {
        atvpanel.getATVgraphic().setParametersForPainting(
         atvpanel.getSizeOfViewport().width,
         atvpanel.getSizeOfViewport().height );
        atvpanel.getATVgraphic().resetPreferredSize();
        atvpanel.adjustJScrollPane();
    }

    
    
    /**

    Sets the colors to MS Windows scheme.

    */
    void setColors1() {
        background_color        = new Color( 215, 215, 215 );
        jcb_text_color          = new Color( 0, 0, 0 );
        jcb_background_color    = background_color;
        button_text_color       = new Color( 0, 0, 0 );
        button_background_color = new Color( 165, 165, 165 );
    }
   
    

} // End of class ATVcontrol.


