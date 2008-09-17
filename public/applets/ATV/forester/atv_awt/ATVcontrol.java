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

// AWT version.


package forester.atv_awt;


import forester.tree.*;

import java.awt.*;
import java.awt.event.*;


/**

@author Christian M. Zmasek

@version AWT 1.210 -- last modified: 02/17/02


*/
class ATVcontrol extends Panel implements ActionListener, ItemListener {

    ATVpanel      atvpanel;

    Checkbox      userealbl, seqnameextnodes, seqnameintnodes, speciesextnodes,
                  speciesintnodes, ecintnodes, ecextnodes, writelnl, writebl,
                  writebootstrap, writed_s, colorbranches, color_orthos,
                  color_super_orthos, color_sn, editable;

    Button        zoom_in_x, zoom_in_y, zoom_out_x, zoom_out_y, show_whole, order,
                  uncollapse_all, collapse_to_deepest_annot;

    Checkbox      display_info, collapse, reroot, swap, subtree;

    CheckboxGroup group;

    Label         click_to;
    
    boolean       order_of_appearance; 

    final static  Font jcb_font   = new Font( "SansSerif", Font.PLAIN, 9 );

    static Color  background_color,
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
        
        order_of_appearance = true;

        setBackground( background_color );

        setLayout( new GridLayout( 0, 1, 2, 2 ) );

        userealbl          = new Checkbox( "real branch lengths" );
        seqnameextnodes    = new Checkbox( "seq name ext nodes" );
        seqnameintnodes    = new Checkbox( "seq name int nodes" );
        speciesextnodes    = new Checkbox( "species ext nodes" );
        speciesintnodes    = new Checkbox( "species int nodes" );
        ecextnodes         = new Checkbox( "EC ext nodes" );
        ecintnodes         = new Checkbox( "EC int nodes" );
        writelnl           = new Checkbox( "log L values" );
        writebl            = new Checkbox( "branch length values" );
        writebootstrap     = new Checkbox( "bootstrap values" );
        writed_s           = new Checkbox( "duplic vs spec" );
        colorbranches      = new Checkbox( "color accord to log L" );
        color_orthos       = new Checkbox( "display orthology" );
        color_sn           = new Checkbox( "display subtr-neighb" );
        color_super_orthos = new Checkbox( "display s-orthology" );
        editable           = new Checkbox( "editable" );

        addCB( userealbl ) ;
        addCB( seqnameextnodes );
        addCB( seqnameintnodes );
        addCB( speciesextnodes );
        addCB( speciesintnodes );
        addCB( ecextnodes );
        addCB( ecintnodes );
        addCB( writebl );
        addCB( writebootstrap );
        addCB( writed_s );
        addCB( color_orthos );
        addCB( color_sn );
        addCB( color_super_orthos );
        addCB( colorbranches );
        addCB( writelnl );
        addCB( editable );

        click_to = new Label( "click on node to:" );
        click_to.setFont( jcb_font );
        click_to.setForeground( jcb_text_color );
        click_to.setBackground( background_color );
        add( click_to );

        group = new CheckboxGroup();

        display_info    = new Checkbox( "display/edit information", group, true );
        collapse        = new Checkbox( "collapse/uncollapse", group, false );
        reroot          = new Checkbox( "root/reroot", group, false );
        swap            = new Checkbox( "swap children", group, false  );
        subtree         = new Checkbox( "subtree/parent tree", group, false );
        

        addRB( display_info );
        addRB( collapse );
        addRB( reroot );
        addRB( subtree );
        addRB( swap );

        zoom_in_x                 = new Button( "zoom in X" );
        zoom_in_y                 = new Button( "zoom in Y" );
        zoom_out_x                = new Button( "zoom out X" );
        zoom_out_y                = new Button( "zoom out Y" );
        show_whole                = new Button( "show whole" );
        order                     = new Button( "order subtrees" );
        uncollapse_all            = new Button( "uncollapse all" );
        collapse_to_deepest_annot = new Button( "collapse to deepest" );

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
            display_info.setState( true );
            userealbl.setState( ag.useRealBranchLenghts() );
            seqnameextnodes.setState( ag.seqNameExtNodes() );
            seqnameintnodes.setState(  ag.seqNameInternalNodes() );
            speciesextnodes.setState( ag.speciesExtNodes() );
            speciesintnodes.setState( ag.speciesInternalNodes() );
            ecextnodes.setState( ag.ECExtNodes() );
            ecintnodes.setState( ag.ECInternalNodes() );
            writelnl.setState( ag.writeLnLValues() );
            writebl.setState( ag.writeBranchLengthValues() );
            writebootstrap.setState( ag.writeBootstrapValues() );
            writed_s.setState( ag.writeDupSpec() );
            colorbranches.setState( ag.colorBranchesAccToLnL() );
            color_orthos.setState( ag.colorOrthologous() );
            color_sn.setState( ag.colorSubtreeNeighbors() );
            color_super_orthos.setState( ag.colorSuperOrthologous() );
            editable.setState( ag.isEditable() );
            
            if ( atvpanel.getATVgraphic().getActionWhenNodeClicked()
            == ATVgraphic.SHOW_INFO ) {
                display_info.setState( true );
            }
            else if ( atvpanel.getATVgraphic().getActionWhenNodeClicked()
            == ATVgraphic.COLLAPSE ) {
                collapse.setState( true );
            }
            else if ( atvpanel.getATVgraphic().getActionWhenNodeClicked()
            == ATVgraphic.REROOT ) {
                reroot.setState( true );
            }
            else if ( atvpanel.getATVgraphic().getActionWhenNodeClicked()
            == ATVgraphic.SUBTREE ) {
                subtree.setState( true );
            }
            else if ( atvpanel.getATVgraphic().getActionWhenNodeClicked()
            == ATVgraphic.SWAP ) {
                swap.setState( true );
            }
        }
    }


    void addCB( Checkbox cb ) {
        cb.setBackground( jcb_background_color );
        cb.setForeground( jcb_text_color );
        cb.setFont( jcb_font );
        add( cb );
        cb.addItemListener( this );
    }

    void addRB( Checkbox rb ) {
        rb.setBackground( jcb_background_color );
        rb.setForeground( jcb_text_color );
        rb.setFont( jcb_font );
        add( rb );
        rb.addItemListener( this );
    }

    void addJB( Button jb ) {
        jb.setBackground( button_background_color );
        jb.setForeground( button_text_color );
        jb.setFont( jcb_font );
        add( jb );
        jb.addActionListener( this );
    }

    void addJB2( Button jb ) {
        jb.setBackground( background_color );
        jb.setForeground( button_text_color );
        jb.setFont( jcb_font );
        add( jb );
        jb.addActionListener( this );
    }

    public void itemStateChanged( ItemEvent e ) {
        ATVgraphic ag = atvpanel.getATVgraphic();
        if ( e.getSource() == color_orthos ) {
            color_super_orthos.setState( false );
            color_sn.setState( false );
        }
        if ( e.getSource() == color_super_orthos ) {
            color_orthos.setState( false );
            color_sn.setState( false );
        }
        if ( e.getSource() == color_sn ) {
            color_orthos.setState( false );
            color_super_orthos.setState( false );
        }
        if ( ag.getTree() != null ) {
            if   ( userealbl.getState() ) {
                ag.setUseRealBranchLenghts( true );
            }
            else { 
                ag.setUseRealBranchLenghts( false );
            }
            if ( e.getSource() == userealbl ) {
                showWhole();   
            }
            
            ag.setSeqNameExtNodes( seqnameextnodes.getState() );
            ag.setSeqNameInternalNodes( seqnameintnodes.getState() );
            ag.setSpeciesExtNodes( speciesextnodes.getState() );
            ag.setSpeciesInternalNodes( speciesintnodes.getState() );
            ag.setECExtNodes( ecextnodes.getState() );
            ag.setECInternalNodes( ecintnodes.getState() );
            ag.setWriteLnLValues( writelnl.getState() );
            ag.setWriteBranchLengthValues( writebl.getState() );
            ag.setWriteBootstrapValues( writebootstrap.getState() );
            ag.setWriteDupSpec( writed_s.getState() );
            ag.setColorBranchesAccToLnL( colorbranches.getState() );
            ag.setColorOrthologous( color_orthos.getState() );
            ag.setColorSuperOrthologous( color_super_orthos.getState() );
            ag.setColorSubtreeNeighbors( color_sn.getState() );
            ag.setEditable( editable.getState() );
           
            if   ( display_info.getState() ) {
                atvpanel.getATVgraphic().setActionWhenNodeClicked(
                ATVgraphic.SHOW_INFO );
            }
            if   ( collapse.getState() ) {
                atvpanel.getATVgraphic().setActionWhenNodeClicked(
                ATVgraphic.COLLAPSE );
            }
            if   ( reroot.getState() ) {
                atvpanel.getATVgraphic().setActionWhenNodeClicked(
                ATVgraphic.REROOT );
            }

            if   ( subtree.getState() ) {
                atvpanel.getATVgraphic().setActionWhenNodeClicked(
                ATVgraphic.SUBTREE );
            }
            if   ( swap.getState() ) {
                atvpanel.getATVgraphic().setActionWhenNodeClicked(
                ATVgraphic.SWAP );
            }
        }        
        atvpanel.adjustJScrollPane();
        atvpanel.getATVgraphic().repaint();
        atvpanel.validate();
    }    



    public void actionPerformed( ActionEvent e ) {
        ATVgraphic ag = atvpanel.getATVgraphic();
        if ( ag.getTree() != null ) {

            if (  e.getSource() == zoom_in_x ) {
                atvpanel.getATVgraphic().setXdistance(
                ( int ) ( atvpanel.getATVgraphic().getXdistance() * 1.10 ) + 1 );

                atvpanel.getATVgraphic().setXcorrectionFactor(
                atvpanel.getATVgraphic().getXcorrectionFactor() * 1.15 );
                atvpanel.getATVgraphic().resetPreferredSize();

            }
            else if ( e.getSource() == zoom_in_y ) {
                atvpanel.getATVgraphic().setYdistance(
                ( int ) ( atvpanel.getATVgraphic().getYdistance() * 1.10 ) + 1 );
                atvpanel.getATVgraphic().resetPreferredSize();

            }
            else if ( e.getSource() == zoom_out_x ) {
                atvpanel.getATVgraphic().setXdistance(
                ( int ) ( atvpanel.getATVgraphic().getXdistance() * 0.90 ) );

                atvpanel.getATVgraphic().setXcorrectionFactor(
                atvpanel.getATVgraphic().getXcorrectionFactor() * 0.85 );
                atvpanel.getATVgraphic().resetPreferredSize();

            }
            else if ( e.getSource() == zoom_out_y ) {
                atvpanel.getATVgraphic().setYdistance(
                ( int ) ( atvpanel.getATVgraphic().getYdistance() * 0.90 ) );
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
            atvpanel.validate();
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


