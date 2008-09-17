// ATVnodeFrame.java
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

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;


/**

@author Christian Zmasek

@version 1.01 -- last modified: 11/04/00

*/
class ATVnodeFrame extends javax.swing.JFrame  {

    private ATVnodePanel atvnodepanel;
    private ATVgraphic atvgraphic;
    private int i;



    ATVnodeFrame( Node n, ATVgraphic ag, int x ) {
        super( "ATV" );
        atvgraphic = ag;
        i = x;
        Container contentPane = getContentPane();
        atvnodepanel = new ATVnodePanel( n, this );
        setSize( 372, 330 );
        contentPane.add( atvnodepanel, BorderLayout.CENTER );

        addWindowListener( new WindowAdapter() {
            public void windowClosing( WindowEvent e ) {
                remove();  // to release slot in array
                dispose();
            }
        } );

        setVisible( true );
    }



    ATVgraphic getATVgraphic() {
        return atvgraphic;
    }



    void remove() {
        atvgraphic.removeNodeJFrame( i ); // to release slot in array
    }

} // End of class ATVnodeFrame.

