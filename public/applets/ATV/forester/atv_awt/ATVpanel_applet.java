// ATVpanel_applet.java
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


/**

@author Christian Zmasek

@version AWT 0.90 last modified: 06/22/00

*/
class ATVpanel_applet extends ATVpanel {



    private ATVappletFrame atvappletframe;



    ATVpanel_applet( Tree t, ATVappletFrame aaf ) {
        
        atvappletframe = aaf;
        
        atvgraphic = new ATVgraphic_applet( t, this );
        atvcontrol = new ATVcontrol_applet( this );
        
        initialize();

        getATVcontrol().showWhole();

    }



    ATVappletFrame getATVappletFrame() {
        return atvappletframe;
    }


}
