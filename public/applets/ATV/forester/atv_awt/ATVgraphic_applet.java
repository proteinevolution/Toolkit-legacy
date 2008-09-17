// ATVgraphic_applet.java
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

import java.awt.event.*;
import java.net.URL;


/**

@author Christian Zmasek

@version AWT 1.020 -- last modified: 10/08/01

*/
class ATVgraphic_applet extends ATVgraphic {

    final static String SWISSPROT_URL_DE = "http://www.expasy.ch/cgi-bin/sprot-search-de?",
                        SWISSPROT_URL_AC = "http://www.expasy.ch/cgi-bin/sprot-search-ac?";

    final static int GO_TO_SWISSPROT = 2;

    private ATVpanel_applet atvpanel;


    /**
    
    Constructor.

    */
    ATVgraphic_applet( Tree t, ATVpanel_applet ap ) {

        tree = t;

        if ( tree != null && !tree.isEmpty() ) {
            tree.adjustNodeCount( true );
            tree.recalculateAndReset();
        }

        atvpanel = ap;

        color_scheme = 1;
        setColors1();
        mediumFonts();

        setBackground( background_color );

        addMouseListener( new ATVmouseListener( this ) );
        
        setPropertiesForPainting( tree );
        
        setVisible( true );
    }


    void goToSwissProt( Node node ) {
        String s = node.getSeqName().trim();
        URL u = null;
        int i = s.indexOf( "/" );
        if ( i > 10 || s.length() < 3 || !node.isExternal() ) {
            return;
        }
        if ( i > 0 ) {
            s = s.substring( 0, i );
        }
        s = s.replace( ' ', '_' );

        if ( s.indexOf( "_" ) != -1 ) {
            s = SWISSPROT_URL_DE + s;
        }
        else {
            s = SWISSPROT_URL_AC + s;
        }
        // Compare with "getalignment" in "/nfs/pfam/pfamserver-x.y/cgi-bin".


        try {
            u = new URL( s );
        }
        catch ( Exception e ) {
            System.err.println( "ATVgraphic_applet: goToSwissProt( Node ): Could not create URL from: " 
            + s + ". Exception: " + e );
            e.printStackTrace();
        }
        if ( u != null ) {
            try {
                atvpanel.getATVappletFrame().getATVapplet().go( u );
            }
            catch ( Exception e ) {
                System.err.println( "ATVgraphic_applet: goToSwissProt( Node ): " + e );
                e.printStackTrace();
            }
        }
    }



    void reRoot( Node node ) {
        if ( !(( node.isRoot() || node.getParent().isRoot() )
        && tree.isRooted() ) ) {
            try {
                tree.reRoot( node );
                tree.adjustNodeCount( true );
                tree.recalculateAndReset();
            }
            catch ( Exception e ) {
                System.err.println( "ATVgraphic: reRoot( node ): " + e );
            }
            resetPreferredSize();
            atvpanel.adjustJScrollPane();
            repaint();
            atvpanel.validate();
        }
    }



    void collapse( Node node ) {
        if ( !node.isExternal() ) {
            node.setCollapse( !node.collapse() );
            tree.adjustNodeCount( true );
            tree.recalculateAndReset();
            resetPreferredSize();
            atvpanel.adjustJScrollPane();
            repaint();
        }
    }



    /**

    Mouse clicked.
    (Last modified: 10/08/01)

    */
    public void MouseClicked( MouseEvent e ) {
        int  x    = e.getX(),
             y    = e.getY();
        Node node = findNode( x, y );
        
        if ( node != null ) {
 
            // right (3rd) mouse button.
            if ( e.getModifiers() == 4 ) {
                i = 0;
                while ( atvnodeframes[ i ] != null ) {
                    i++;
                }
                atvnodeframes[ i ] = new ATVnodeFrame( node, this, i );
            }
            // other mouse button.
            else {
                if ( action_when_node_clicked == COLLAPSE ) {
                    collapse( node );
                }
                else if ( action_when_node_clicked == GO_TO_SWISSPROT ) {
                    goToSwissProt( node );
                }
                else if ( action_when_node_clicked == REROOT ) {
                    reRoot( node );
                }
                else if ( action_when_node_clicked == SUBTREE ) {
                    subTree( node );
                }
                else if ( action_when_node_clicked == SWAP ) {
                    swap( node );
                }
                // show info is default:
                else {
                    i = 0;
                    while ( atvnodeframes[ i ] != null ) {
                        i++;
                    }
                    atvnodeframes[ i ] = new ATVnodeFrame( node, this, i );
                }
            }
        }
    }
    
    
    
    void subTree( Node node ) {
        if ( !node.isExternal() && !node.isRoot() && j <= MAX_SUBTREES - 1 ) {
            try {
                trees[ j++ ] = tree;
                tree = tree.subTree( node.getID() );
            }
            catch ( Exception e ) {
                System.err.println( "ATVgraphic: subTree( Node ): " + e );
            }
        }
        else if ( node.isRoot() && j >= 1 ) {
            try {
                trees[ j ] = null;
                tree = trees[ --j ];
            }
            catch ( Exception e ) {
                System.err.println( "ATVgraphic: subTree( Node ): " + e );
            }
        }
        atvpanel.getATVcontrol().setCheckBoxes();
        atvpanel.getATVcontrol().showWhole();
        repaint();
    }

}
