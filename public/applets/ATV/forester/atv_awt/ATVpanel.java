// ATVpanel.java
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


/**

@author Christian Zmasek

@version AWT 1.00 -- last modified: 06/27/00

*/
class ATVpanel extends Panel {

    ATVgraphic atvgraphic;
    ATVcontrol atvcontrol;
    ScrollPane treegraphic_jsp;

   
    ATVpanel( Tree t ) {
        
        atvgraphic = new ATVgraphic( t, this );
        atvcontrol = new ATVcontrol( this );
               
        initialize();

        getATVcontrol().showWhole();
    }



    ATVpanel() {}
    

    /**

    Helper method for constructor.

    */
    void initialize() {
        treegraphic_jsp = new ScrollPane( ScrollPane.SCROLLBARS_ALWAYS );
        treegraphic_jsp.getHAdjustable().setUnitIncrement( 20 );
        treegraphic_jsp.getHAdjustable().setBlockIncrement( 50 );
        treegraphic_jsp.getVAdjustable().setUnitIncrement( 20 );
        treegraphic_jsp.getVAdjustable().setBlockIncrement( 50 );
        treegraphic_jsp.add( atvgraphic );
        setLayout( new BorderLayout() );
        add( treegraphic_jsp, BorderLayout.CENTER );
        add( atvcontrol, BorderLayout.EAST );
        setBackground( atvgraphic.getBackground() );
        treegraphic_jsp.setBackground( atvgraphic.getBackground() );
        treegraphic_jsp.setVisible( true );
    }    
    
    

    Dimension getSizeOfViewport() {
        return treegraphic_jsp.getViewportSize();
    }



    void adjustJScrollPane() {
        remove( treegraphic_jsp );
        add( treegraphic_jsp, BorderLayout.CENTER );
        treegraphic_jsp.repaint();
    }



    ATVgraphic getATVgraphic() {
        return atvgraphic;
    }



    ATVcontrol getATVcontrol() {
        return atvcontrol;
    }



    void terminate() {
        atvgraphic.removeAllNodeJFrames();
    }

} // End of class ATVpanel.
