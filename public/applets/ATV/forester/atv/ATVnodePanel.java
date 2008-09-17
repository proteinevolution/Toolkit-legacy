// ATVnodePanel.java
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
import javax.swing.border.*;
import javax.swing.text.*;


/**

@author Christian Zmasek

@version 1.100 -- last modified: 02/17/02


*/
class ATVnodePanel extends JPanel implements ActionListener {

    private Node node;
    private ATVnodeFrame atvnodeframe;

    private boolean editable = false;

    private JLabel       title,
                         seq_name_label, Species_label, EC_label, Distance_parent_label,
                         Bootstrap_label, LnL_label, Sum_ext_nodes_label, taxo_id_label,
                         orthologous_label, super_orthologous_label, sn_label,
                         message_label;
    private JTextField   Seq_name_tf, Species_tf, EC_tf, Distance_parent_tf, taxo_id_tf,
                         Bootstrap_tf, LnL_tf, Sum_ext_nodes_tf, 
                         orthologous_tf, super_orthologous_tf, sn_tf;
    private JRadioButton Duplication_rb, Speciation_rb, NA_rb;
    private JSeparator   sep;
    private JPanel       buttonjpanel, radiobuttonjpanel;
    private ButtonGroup  radiobuttongroup;
    private JButton      close_button, reset_button, write_button;

    private TitledBorder border;

    private final static Font label_font   = new Font( "Helvetica", Font.PLAIN, 9 ),
                              tf_font      = new Font( "Helvetica", Font.PLAIN, 9 ),
                              button_font  = new Font( "Helvetica", Font.PLAIN, 9 ),
                              message_font = new Font( "Helvetica", Font.BOLD, 10 );

    private final static Color background_color        = new Color( 215, 215, 215 ),
                               label_text_color        = new Color( 0, 0, 0 ),
                               tf_text_color           = new Color( 0, 0, 0 ),
                               tf_background_color     = new Color( 250, 250, 250 ),
                               button_background_color = new Color( 165, 165, 165 ),
                               button_text_color       = new Color( 0, 0, 0 ),
                               message_color           = new Color( 0, 0, 255 );

    private GridBagLayout gbl;
    private GridBagConstraints gbc;

    private String message = " ";



    ATVnodePanel( Node n, ATVnodeFrame anf ) {

        node = n;
        atvnodeframe = anf;

        String title = "";

        editable = atvnodeframe.getATVgraphic().isEditable();

        gbl = new GridBagLayout();
        gbc = new GridBagConstraints();
        gbc.insets   = new Insets( 0, 0, 0, 0 );
        gbc.anchor   = GridBagConstraints.WEST;
        setBackground( background_color );
        setLayout( gbl );


        // Adding the TitledBorder:
        // ------------------------

        if ( node.isExternal() ) {
            title = "External Node " + node.getID();
        }
        else {
            title = "Internal Node " + node.getID();
        }
        border = new TitledBorder( title );
        border.setTitleColor( label_text_color );
        border.setTitleFont( label_font );
        border.setTitleJustification( TitledBorder.CENTER );
        setBorder( border );


        // Adding the Seq name:
        // --------------------

        seq_name_label = new JLabel( "seq name" );
        addJLabel( seq_name_label );

        Seq_name_tf         = new JTextField( 25 );
        addJTF( Seq_name_tf );


        // Adding the Species:
        // -------------------

        Species_label  = new JLabel( "species" );
        addJLabel( Species_label );

        Species_tf     = new JTextField( 25 );
        addJTF( Species_tf );


        // Adding the Taxonomy ID:
        // -----------------------

        taxo_id_label  = new JLabel( "taxonomy ID" );
        addJLabel( taxo_id_label );

        taxo_id_tf     = new JTextField( 25 );
        taxo_id_tf.setDocument( new IntegerDocument() );
        addJTF( taxo_id_tf );


        // Adding the EC number:
        // ---------------------

        EC_label       = new JLabel( "EC number" );
        addJLabel( EC_label );

        EC_tf          = new JTextField( 25 );
        addJTF( EC_tf );


        // Adding the Distance to Parent:
        // ------------------------------

        Distance_parent_label       = new JLabel( "distance to parent" );
        addJLabel( Distance_parent_label );

        Distance_parent_tf          = new JTextField( 25 );
        Distance_parent_tf.setDocument( new DoubleDocument() );
        addJTF( Distance_parent_tf );



        if ( !node.isExternal() ) {

            // Adding the Bootstrap:
            // ---------------------

            Bootstrap_label       = new JLabel( "bootstrap value" );
            addJLabel( Bootstrap_label );

            Bootstrap_tf          = new JTextField( 25 );
            Bootstrap_tf.setDocument( new IntegerDocument() );
            addJTF( Bootstrap_tf );
        }

        if ( node.isExternal() ) {
            
            // Adding the Orthologous:
            // -----------------------

            orthologous_label      = new JLabel( "orthologous to query" );
            addJLabel( orthologous_label );

            orthologous_tf = new JTextField( 25 );
            orthologous_tf.setDocument( new IntegerDocument() );
            addJTF( orthologous_tf );
            
            
            // Adding the Subtree-Neighborings:
            // --------------------------------

            sn_label = new JLabel( "subtr-neighb to query" );
            addJLabel( sn_label );

            sn_tf = new JTextField( 25 );
            sn_tf.setDocument( new IntegerDocument() );
            addJTF( sn_tf );
            
            
            
            // Adding the Super Orthologous:
            // -----------------------------

            super_orthologous_label  = new JLabel( "s-orthologous to query" );
            addJLabel( super_orthologous_label );

            super_orthologous_tf = new JTextField( 25 );
            super_orthologous_tf.setDocument( new IntegerDocument() );
            addJTF( super_orthologous_tf );
            
            
 
        }


        // Adding the lnL:
        // ---------------

        LnL_label       = new JLabel( "log L on parent branch" );
        addJLabel( LnL_label );

        LnL_tf          = new JTextField( 25 );
        LnL_tf.setDocument( new DoubleDocument() );
        addJTF( LnL_tf );


        if ( !node.isExternal() ) {

            // Adding the Sum ext nodes:
            // -------------------------

            Sum_ext_nodes_label       = new JLabel( "sum of ext nodes" );
            addJLabel( Sum_ext_nodes_label );

            Sum_ext_nodes_tf          = new JTextField( 25 );
            addJTF( Sum_ext_nodes_tf );
            Sum_ext_nodes_tf.setEditable( false );

        }


        if ( !node.isExternal() ) {

            // Adding the Duplication, Speciation, NA radiobuttons:
            // ----------------------------------------------------

            radiobuttonjpanel = new JPanel();
            radiobuttongroup = new ButtonGroup();
            radiobuttonjpanel.setLayout( new GridLayout( 1, 3, 0, 0 ) );
            radiobuttonjpanel.setBackground( background_color );
            Duplication_rb = new JRadioButton( "duplication" );
            Speciation_rb  = new JRadioButton( "speciation" );
            NA_rb          = new JRadioButton( "not assigned" );
            radiobuttongroup.add( Duplication_rb );
            radiobuttongroup.add( Speciation_rb );
            radiobuttongroup.add( NA_rb );

            // Does not look nice AT ALL, but there seems to be no other easy way
            // to make radiobuttons uneditable......
            Duplication_rb.setEnabled( editable );

            Duplication_rb.setFont( label_font );
            Duplication_rb.setForeground( label_text_color );
            Duplication_rb.setBackground( background_color );

            radiobuttonjpanel.add( Duplication_rb );

            Speciation_rb.setEnabled( editable );
            Speciation_rb.setFont( label_font );
            Speciation_rb.setForeground( label_text_color );
            Speciation_rb.setBackground( background_color );
            radiobuttonjpanel.add( Speciation_rb );


            NA_rb.setEnabled( editable );
            NA_rb.setFont( label_font );
            NA_rb.setForeground( label_text_color );
            NA_rb.setBackground( background_color );
            radiobuttonjpanel.add( NA_rb );



            gbc.gridwidth = GridBagConstraints.REMAINDER;
            gbc.fill   = GridBagConstraints.HORIZONTAL;
            add( radiobuttonjpanel, gbc );

            gbc.fill   = GridBagConstraints.NONE;

        }


        // Adding the separator:
        // ---------------------

        sep = new JSeparator();

        gbc.fill   = GridBagConstraints.HORIZONTAL;
        gbc.insets = new Insets( 10, 0, 10, 0 );
        add( sep, gbc);

        gbc.insets = new Insets( 0, 0, 0, 0 );
        gbc.fill   = GridBagConstraints.NONE;


        // Adding the close, write, and reset buttons:
        // -------------------------------------------

        buttonjpanel= new JPanel();

        buttonjpanel.setLayout( new GridLayout( 1, 0, 20, 40 ) );

        buttonjpanel.setBackground( background_color );


        close_button = new JButton( "Close" );
        close_button.setFont( button_font );
        close_button.setForeground( button_text_color );
        close_button.setBackground( button_background_color );
        close_button.addActionListener( this );
        buttonjpanel.add( close_button );


        if ( editable ) {
            reset_button = new JButton( "Reset" );
            reset_button.setFont( button_font );
            reset_button.setForeground( button_text_color );
            reset_button.setBackground( button_background_color );
            reset_button.setToolTipText( "Read values for this node from tree" );
            reset_button.addActionListener( this );
            buttonjpanel.add( reset_button );

            write_button = new JButton( "Write to tree" );
            write_button.setFont( button_font );
            write_button.setForeground( button_text_color );
            write_button.setBackground( button_background_color );
            write_button.setToolTipText( "Write the values for this node to the tree" );
            write_button.addActionListener( this );
            gbc.gridwidth = GridBagConstraints.REMAINDER;
            buttonjpanel.add( write_button );
        }

        gbc.anchor   = GridBagConstraints.CENTER;
        add( buttonjpanel, gbc );


        // Adding the (normally invisible) message label:
        // ----------------------------------------------

        message_label = new JLabel( " " );
        message_label.setFont( message_font );
        message_label.setForeground( message_color );

        gbc.insets   = new Insets( 14, 0, 0, 0 );
        gbc.anchor   = GridBagConstraints.CENTER;
        add( message_label, gbc );
        gbc.insets   = new Insets( 0, 0, 0, 0 );



        // Setting the text of all the text fields and status of radio buttons:
        reset();



    }

    public void actionPerformed( ActionEvent e ) {

        if ( e.getSource() == close_button ) {
            close();
        }

        else {

            if ( editable && e.getSource() == reset_button ) {
                reset();
            }

            if ( editable && e.getSource() == write_button ) {
                writeToTree();
            }
            atvnodeframe.getATVgraphic().getTree().recalculateAndReset();
            atvnodeframe.getATVgraphic().repaint();
        }

    }


    private void addJLabel( JLabel jl ) {
        gbc.weightx = 0.3;
        jl.setFont( label_font );
        jl.setForeground( label_text_color );
        gbc.gridwidth = 1;
        add( jl, gbc );
    }

    private void addJTF( JTextField jtf ) {
        gbc.weightx = 0.7;
        jtf.setMinimumSize( jtf.getPreferredSize() );
        jtf.setFont( tf_font );
        jtf.setForeground( tf_text_color );
        jtf.setBackground( tf_background_color );
        jtf.setEditable( editable );
        gbc.gridwidth = GridBagConstraints.REMAINDER;
        add( jtf, gbc );
    }





    // Setting the text of all the text fields and status of radio buttons:
    void reset() {

        message_label.setText( " " );
        message = " ";

        // Seq name:
        if ( !node.isPseudoNode() ) {
            Seq_name_tf.setText( node.getSeqName() );
        }
        else {
            Seq_name_tf.setText( "*pseudo node*" );
        }

        // Species:
        Species_tf.setText( node.getSpecies() );

        // Taxonomy ID:
        if ( node.getTaxonomyID() != Node.TAXO_ID_DEFAULT ) {
            taxo_id_tf.setText( "" + node.getTaxonomyID() );
        }    

        // EC:
        EC_tf.setText( node.getECnumber() );

        // Distance to parent:
        if ( !node.isPseudoNode()
        && node.getDistanceToParent() != Node.DISTANCE_DEFAULT ) {
            Distance_parent_tf.setText( "" + node.getDistanceToParent() );
        }
        else {
            Distance_parent_tf.setText( "" );
        }

        // LnL:
        if ( node.isLnLonParentBranchAssigned() ) {
            LnL_tf.setText( "" + node.getLnLonParentBranch() );
        }
        else {
            LnL_tf.setText( "" );
        }



        if ( !node.isExternal() ) {

            // Bootstrap:
            if ( node.getBootstrap() != Node.BOOTSTRAP_DEFAULT ) {
                Bootstrap_tf.setText( "" + node.getBootstrap() );
            }
            else {
                Bootstrap_tf.setText( "" );
            }

            // Sum ext nodes:
            Sum_ext_nodes_tf.setText( "" + node.getSumExtNodes() );

            // Duplication, speciation, NA:
            if ( !node.isDuplicationOrSpecAssigned() ) {
                NA_rb.setSelected( true );
            }
            else {
                if ( node.isDuplication() ) {
                    Duplication_rb.setSelected( true );
                }
                else {
                    Speciation_rb.setSelected( true );
                }
            }
        }
        
        if ( node.isExternal() ) {
            // Orthologous:
            if ( node.getOrthologous() != Node.ORTHOLOGOUS_DEFAULT  
            && node.getOrthologous() != Node.SEQ_X ) {
                orthologous_tf.setText( "" + node.getOrthologous() );
            }
            else {
                orthologous_tf.setText( "" );
            }
            // Super Orthologous:
            if ( node.getSuperOrthologous() != Node.ORTHOLOGOUS_DEFAULT 
            && node.getSuperOrthologous() != Node.SEQ_X ) {
                super_orthologous_tf.setText( "" + node.getSuperOrthologous() );
            }
            else {
                super_orthologous_tf.setText( "" );
            }
            // Subtree-neighborings:
            if ( node.getSubtreeNeighborings() != Node.ORTHOLOGOUS_DEFAULT 
            && node.getSubtreeNeighborings() != Node.SEQ_X ) {
                sn_tf.setText( "" + node.getSubtreeNeighborings() );
            }
            else {
                sn_tf.setText( "" );
            }
        }
        
    }

    


    void writeToTree() {

        boolean exception = false;
        double d = 0.0;
        float  f = 0.0F;
        int i = 0;

        message = " ";
        message_label.setText( " " );

        node.setSeqName( replaceInappropriateChars( Seq_name_tf.getText().trim() ) );
        node.setSpecies( replaceInappropriateChars( Species_tf.getText().trim() ) );
        node.setECnumber( replaceInappropriateChars( EC_tf.getText().trim() ) );
 
        if ( taxo_id_tf.getText().trim().length() > 0 ) {
            exception = false;
            try {
                i = Integer.parseInt( taxo_id_tf.getText().trim() );
            }
            catch ( NumberFormatException e ) {
                exception = true;
                message = "NumberFormatException. ";
            }
            if ( !exception ) {
                node.setTaxonomyID( i );
            }
        }


        if ( Distance_parent_tf.getText().trim().length() > 0 ) {
            exception = false;
            try {
                d = Double.valueOf( Distance_parent_tf.getText().trim() ).doubleValue();
                //d = Double.parseDouble(g.trim()); // JDK 1.2 only
                if ( d < 0.0 ) {
                    d = 0.0;
                }
            }
            catch ( NumberFormatException e ) {
                exception = true;
                message  = "NumberFormatException. ";
            }
            if ( !exception ) {
                node.setDistanceToParent( d );
            }
        }
        else {
            node.setDistanceToParent( Node.DISTANCE_DEFAULT );
        }


        if ( LnL_tf.getText().trim().length() > 0 ) {
            exception = false;
            try {
                f = Float.valueOf( LnL_tf.getText().trim() ).floatValue();
            }
            catch ( NumberFormatException e ) {
                exception = true;
                message = "NumberFormatException. ";
            }
            if ( !exception ) {
                node.setLnLonParentBranch( f );
            }
        }
        else {
            node.setLnLonParentBranch( 0.0F );
            node.setLnLonParentBranchAssigned( false );
        }
        


        if ( !node.isExternal() ) {
            if ( Bootstrap_tf.getText().trim().length() > 0 ) {
                exception = false;
                try {
                    i = Integer.parseInt( Bootstrap_tf.getText().trim() );
                }
                catch ( NumberFormatException e ) {
                    exception = true;
                    message = "NumberFormatException. ";
                }
                if ( !exception ) {
                    node.setBootstrap( i );
                }
            }
            else {
                node.setBootstrap( Node.BOOTSTRAP_DEFAULT );
            }

            if ( Duplication_rb.isSelected() ) {
                node.setDuplication( true );
            }
            else if ( Speciation_rb.isSelected() ) {
                node.setDuplication( false );
            }
            else {
                node.setDuplicationOrSpecAssigned( false );
            }
        }

        if ( node.isExternal() ) {
            if ( orthologous_tf.getText().trim().length() > 0 ) {
                exception = false;
                try {
                    i = Integer.parseInt( orthologous_tf.getText().trim() );
                }
                catch ( NumberFormatException e ) {
                    exception = true;
                    message = "NumberFormatException. ";
                }
                if ( !exception ) {
                    if ( i > 0 ) {
                        node.setOrthologous( i );
                    }
                    else {
                        node.setOrthologous( Node.ORTHOLOGOUS_DEFAULT );
                    }    
                }
            }
            else {
                node.setOrthologous( Node.ORTHOLOGOUS_DEFAULT );
            }
            
            if ( super_orthologous_tf.getText().trim().length() > 0 ) {
                exception = false;
                try {
                    i = Integer.parseInt( super_orthologous_tf.getText().trim() );
                }
                catch ( NumberFormatException e ) {
                    exception = true;
                    message = "NumberFormatException. ";
                }
                if ( !exception ) {
                    if ( i > 0 ) {
                        node.setSuperOrthologous( i );
                    }
                    else {
                        node.setSuperOrthologous( Node.ORTHOLOGOUS_DEFAULT );
                    }    
                }
            }
            else {
                node.setSuperOrthologous( Node.ORTHOLOGOUS_DEFAULT );
            }
            
            if ( sn_tf.getText().trim().length() > 0 ) {
                exception = false;
                try {
                    i = Integer.parseInt( sn_tf.getText().trim() );
                }
                catch ( NumberFormatException e ) {
                    exception = true;
                    message = "NumberFormatException. ";
                }
                if ( !exception ) {
                    if ( i > 0 ) {
                        node.setSubtreeNeighborings( i );
                    }
                    else {
                        node.setSubtreeNeighborings( Node.ORTHOLOGOUS_DEFAULT );
                    }    
                }
            }
            else {
                node.setSubtreeNeighborings( Node.ORTHOLOGOUS_DEFAULT );
            }
            
            
        }



        if ( message.length() > 1 ) {
            Toolkit.getDefaultToolkit().beep();
            message_label.setText( message );
            message = " ";
        }
        else {
            reset();
        }
    }

    void close() {
        atvnodeframe.remove(); // to release slot in array
        atvnodeframe.dispose();
        atvnodeframe = null;
    }

    // [] -> {}  () -> {}    : -> |   , -> |  ' ' -> _ 
    private String replaceInappropriateChars( String s ) {
        s = s.replace( '[', '{' );
        s = s.replace( ']', '}' );
        s = s.replace( '(', '{' );
        s = s.replace( ')', '}' );
        s = s.replace( ':', '|' );
        s = s.replace( ',', '|' );
        s = s.replace( ' ', '_' );
        return s;
    }

} // End of class ATVnodePanel.


