// ATVpanel.java
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
import javax.swing.*;


/**

@author Christian Zmasek

@version 1.06 -- last modified: 06/23/00

*/
class ATVpanel extends JPanel {

    ATVgraphic atvgraphic;
    ATVcontrol atvcontrol;
    JScrollPane treegraphic_jsp;

    final static Color background_color = new Color( 0, 0, 0 );


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
        
        setBackground( background_color );

        treegraphic_jsp = new JScrollPane( atvgraphic );
        treegraphic_jsp.getHorizontalScrollBar().setUnitIncrement( 20 );
        treegraphic_jsp.getHorizontalScrollBar().setBlockIncrement( 50 );
        treegraphic_jsp.getVerticalScrollBar().setUnitIncrement( 20 );
        treegraphic_jsp.getVerticalScrollBar().setBlockIncrement( 50 );
        
        setLayout( new BorderLayout() );

        add( treegraphic_jsp, BorderLayout.CENTER );
        add( atvcontrol, BorderLayout.EAST );

    }


    Dimension getSizeOfViewport() {
        return treegraphic_jsp.getViewport().getExtentSize();
    }



    void adjustJScrollPane() {
        remove( treegraphic_jsp );
        add( treegraphic_jsp, BorderLayout.CENTER );
        treegraphic_jsp.revalidate();
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
