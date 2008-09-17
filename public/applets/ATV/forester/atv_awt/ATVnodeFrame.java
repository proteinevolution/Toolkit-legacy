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

// AWT version.


package forester.atv_awt;


import forester.tree.*;

import java.awt.*;
import java.awt.event.*;


/**

@author Christian Zmasek

@version AWT 1.00 -- last modified: 06/27/00

*/
class ATVnodeFrame extends Frame  {

    private ATVnodePanel atvnodepanel;
    private ATVgraphic atvgraphic;
    private int i;



    ATVnodeFrame( Node n, ATVgraphic ag, int x ) {
        super();
        atvgraphic = ag;
        i = x;
        atvnodepanel = new ATVnodePanel( n, this );
        setSize( 360, 320 );
        
        add( atvnodepanel, BorderLayout.CENTER );
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

