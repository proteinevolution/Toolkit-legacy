// ATVmouseListener.java
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

import java.awt.event.*;


/**

@author Christian Zmasek

@version 1.030 -- last modified: 10/04/01


*/
class ATVmouseListener extends MouseAdapter {

    private ATVgraphic atvgraphic;

    /**
    
    Constructor.
    
    */
    ATVmouseListener( ATVgraphic ag ) {
        atvgraphic = ag;
    }


    /**

    Mouse clicked.

    */
    public void mouseClicked( MouseEvent e ) {
        atvgraphic.MouseClicked( e );
    }


}
