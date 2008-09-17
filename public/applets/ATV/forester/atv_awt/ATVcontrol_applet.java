// ATVcontrol_applet.java
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

@author Christian Zmasek

@version AWT 1.101 -- last modified: 02/17/02

*/
class ATVcontrol_applet extends ATVcontrol {


    Checkbox go_to_swissprot;


    /**
 
    Constructor.

    */
    ATVcontrol_applet( ATVpanel ap ) {

        atvpanel = ap;
        
        setColors1();

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
        go_to_swissprot = new Checkbox( "go to swiss-prot", group, false );
        swap            = new Checkbox( "swap children", group, false );
        subtree         = new Checkbox( "subtree/parent tree", group, false );

       
        addRB( display_info );
        addRB( collapse );
        addRB( go_to_swissprot );
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
            
            if      ( atvpanel.getATVgraphic().getActionWhenNodeClicked()
            == ATVgraphic.SHOW_INFO ) {
                display_info.setState( true );
            }
            else if ( atvpanel.getATVgraphic().getActionWhenNodeClicked()
            == ATVgraphic.COLLAPSE ) {
                collapse.setState( true );
            }
            else if ( atvpanel.getATVgraphic().getActionWhenNodeClicked()
            == ATVgraphic_applet.GO_TO_SWISSPROT ) {
                go_to_swissprot.setState( true );
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
            ag.setColorSubtreeNeighbors( color_sn.getState() );
            ag.setColorSuperOrthologous( color_super_orthos.getState() );
            ag.setEditable( editable.getState() );
            
            if ( display_info.getState() ) {
                atvpanel.getATVgraphic().setActionWhenNodeClicked(
                ATVgraphic.SHOW_INFO );
            }
            else if ( collapse.getState() ) {
                atvpanel.getATVgraphic().setActionWhenNodeClicked(
                ATVgraphic.COLLAPSE );
            }
            else if ( reroot.getState() ) {
                atvpanel.getATVgraphic().setActionWhenNodeClicked(
                ATVgraphic.REROOT );
            }
            else if   ( go_to_swissprot.getState() ) {
                atvpanel.getATVgraphic().setActionWhenNodeClicked(
                ATVgraphic_applet.GO_TO_SWISSPROT );
            }
            else if ( subtree.getState() ) {
                atvpanel.getATVgraphic().setActionWhenNodeClicked(
                ATVgraphic.SUBTREE );
            }
            else if ( swap.getState() ) {
                atvpanel.getATVgraphic().setActionWhenNodeClicked(
                ATVgraphic.SWAP );
            }
        }        
        atvpanel.adjustJScrollPane();
        atvpanel.getATVgraphic().repaint();
        atvpanel.validate();
    }    

}


