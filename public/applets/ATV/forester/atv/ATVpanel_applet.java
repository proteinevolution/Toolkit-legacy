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

package forester.atv;


import forester.tree.*;

import java.awt.*;
import javax.swing.*;


/**

@author Christian Zmasek

@version 1.03 last modified: 06/23/00


*/


class ATVpanel_applet extends ATVpanel {



    private ATVappletFrame atvappletframe;



    ATVpanel_applet( Tree t, ATVappletFrame aaf ) {
        //super( t );
        atvappletframe = aaf;
        
        atvgraphic = new ATVgraphic_applet( t, this );
        atvcontrol = new ATVcontrol_applet( this );
        
        initialize();

        getATVcontrol().showWhole();
        
    }



    //ATVpanel_applet() {
    //    super();
    //}



    ATVappletFrame getATVappletFrame() {
        return atvappletframe;
    }


}
