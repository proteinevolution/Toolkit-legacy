// ATVappletFrame.java
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

import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.util.Vector;
import java.net.URL;


/**

@author Christian M. Zmasek

@version 1.150 last modified: 10/04/01


*/

class ATVappletFrame extends JFrame implements ActionListener {

    private Tree              reload_tree_ = null;
    private JMenuBar          jmenubar;
    private JMenu             file_jmenu, edit_jmenu, view_jmenu, options_jmenu, help_jmenu,
                              search_jmenu;
    private JMenuItem         close_item, open_url_item, reload_item,
                              remove_root_item, remove_root_tri_item,
                              tiny_fonts_item, small_fonts_item, medium_fonts_item, large_fonts_item,
                              switch_colors_item, view_as_NH_item, view_as_NHX_item,
                              about_item, help_item, find_item, find_reset_item;
    private ATVjapplet        atvapplet; // "parent" japplet
            ATVpanel_applet   atvpanel;  // Must not be private in order for 
                                         // Applet to work in browser. 
    private Container         contentpane;

    private ATVtextframe      atvtextframe;

    private final static Color menu_background_color = new Color( 215, 215, 215 ),
                               menu_text_color       = new Color( 0, 0, 0 );
                         
    private final static Font  menu_font             = new Font( "Helvetica", Font.PLAIN, 10 );

    private final static int FRAME_X_SIZE = 640,
                             FRAME_Y_SIZE = 580;

    ATVappletFrame( ATVjapplet atva ) {

        atvapplet    = atva;
        atvtextframe = null;
        URL url      = null;
        Tree t       = null;

        if ( atvapplet.getURLstring() != null ) {
            try {
                url = new URL( atvapplet.getURLstring() );
            }
            catch ( Exception e ) {
                JOptionPane.showMessageDialog( this
                , "ATVapplet: Could not create URL from: "
                + atvapplet.getURLstring() + "\nException: " + e
                , "Could not create URL"
                , JOptionPane.ERROR_MESSAGE );
                close();
            }
        }

        if ( url != null ) {
            try {
                t = TreeHelper.readNHtree( url );
            }
            catch ( Exception e ) {
                JOptionPane.showMessageDialog( this
                , "ATVapplet: Could not read Tree: "
                + "\nException: " + e
                , "Could not read Tree"
                , JOptionPane.ERROR_MESSAGE );
                close();
            }
        }
        
        if ( t != null && !t.isEmpty() ) {
            reload_tree_ = t.copyTree();
        }


        setTitle( "ATV" );

        atvpanel   = new ATVpanel_applet( t, this );

        jmenubar      = new JMenuBar();
        jmenubar.setBackground( menu_background_color );
        file_jmenu    = new JMenu( "File" );
        edit_jmenu    = new JMenu( "Edit" );
        search_jmenu  = new JMenu( "Search" );
        view_jmenu    = new JMenu( "View" );
        options_jmenu = new JMenu( "Options" );
        help_jmenu    = new JMenu( "Help" );

        file_jmenu.setFont( menu_font );
        file_jmenu.setBackground( menu_background_color );
        file_jmenu.setForeground( menu_text_color );
        edit_jmenu.setFont( menu_font );
        edit_jmenu.setBackground( menu_background_color );
        edit_jmenu.setForeground( menu_text_color );
        search_jmenu.setFont( menu_font );
        search_jmenu.setBackground( menu_background_color );
        search_jmenu.setForeground( menu_text_color );
        view_jmenu.setFont( menu_font );
        view_jmenu.setBackground( menu_background_color );
        view_jmenu.setForeground( menu_text_color );
        options_jmenu.setFont( menu_font );
        options_jmenu.setBackground( menu_background_color );
        options_jmenu.setForeground( menu_text_color );
        help_jmenu.setFont( menu_font );
        help_jmenu.setBackground( menu_background_color );
        help_jmenu.setForeground( menu_text_color );


        file_jmenu.add( reload_item = new JMenuItem( "Reload") );
        file_jmenu.addSeparator();
        file_jmenu.add( open_url_item
         = new JMenuItem( "Open URL to read a NH/NHX tree" ) );
        file_jmenu.addSeparator();
        file_jmenu.add( close_item = new JMenuItem( "Close" ) );
        edit_jmenu.add( remove_root_item = new JMenuItem( "Remove root" ) );
        edit_jmenu.add( remove_root_tri_item
         = new JMenuItem( "Remove root and trifurcate" ) );
        
        search_jmenu.add( find_item = new JMenuItem( "Search" ) );
        search_jmenu.addSeparator();
        search_jmenu.add( find_reset_item = new JMenuItem( "Reset" ) );
          
        view_jmenu.add( view_as_NH_item     = new JMenuItem( "View as NH" ) );
        view_jmenu.add( view_as_NHX_item    = new JMenuItem( "View as NHX" ) );

        options_jmenu.add( switch_colors_item  = new JMenuItem( "Switch colors" ) );
        options_jmenu.addSeparator();
        options_jmenu.add( tiny_fonts_item     = new JMenuItem( "Tiny fonts" ) );
        options_jmenu.add( small_fonts_item    = new JMenuItem( "Small fonts" ) );
        options_jmenu.add( medium_fonts_item   = new JMenuItem( "Medium fonts" ) );
        options_jmenu.add( large_fonts_item    = new JMenuItem( "Large fonts" ) );

        help_jmenu.add( help_item        = new JMenuItem( "Help" ) );
        help_jmenu.add( about_item       = new JMenuItem( "About" ) );


        customizeJMenuItem( reload_item );
        customizeJMenuItem( open_url_item );
        customizeJMenuItem( close_item );
        customizeJMenuItem( remove_root_item );
        customizeJMenuItem( remove_root_tri_item );
        customizeJMenuItem( tiny_fonts_item );
        customizeJMenuItem( small_fonts_item );
        customizeJMenuItem( medium_fonts_item );
        customizeJMenuItem( large_fonts_item );
        customizeJMenuItem( switch_colors_item );
        customizeJMenuItem( view_as_NH_item );
        customizeJMenuItem( view_as_NHX_item );
        customizeJMenuItem( about_item );
        customizeJMenuItem( help_item );
        customizeJMenuItem( find_item );
        customizeJMenuItem( find_reset_item );

        jmenubar.add( file_jmenu );
        jmenubar.add( edit_jmenu );
        jmenubar.add( search_jmenu );
        jmenubar.add( view_jmenu );
        jmenubar.add( options_jmenu );
        jmenubar.add( help_jmenu );

        setJMenuBar( jmenubar );

        contentpane = getContentPane();

        contentpane.setLayout( new BorderLayout() );

        contentpane.add( atvpanel, BorderLayout.CENTER );

        setSize( FRAME_X_SIZE, FRAME_Y_SIZE );

        addWindowListener( new WindowAdapter() {
            public void windowClosing( WindowEvent e ) {
                close();
            }
        } );

        addComponentListener( new ComponentAdapter() {
            public void componentResized( ComponentEvent e ) {

                atvpanel.getATVgraphic().setParametersForPainting(
                atvpanel.getATVgraphic().getWidth(),
                atvpanel.getATVgraphic().getHeight() );

            }
        } );


        setVisible( true );


    } // End of constructor ATVappletFrame( atvapplet ).


    ATVjapplet getATVapplet() {
        return atvapplet;
    }


    ATVpanel getATVpanel() {
        return atvpanel;
    }


    /**

    Action performed.

    */
    public void actionPerformed( ActionEvent e ) {

        Object o = e.getSource();
        
        if ( o == reload_item ) {
            reLoad();
        }
        else if ( o == open_url_item ) {
            openURL();
        }
        else if ( o == close_item ) {
            close();
        }
        else if ( o == remove_root_item ) {
            removeRoot();
        }
        else if ( o == remove_root_tri_item ) {
            removeRootTri();
        }
        else if ( o == switch_colors_item ) {
            switchColors();
        }
        else if ( o == view_as_NH_item ) {
            viewAsNH();
        }
        else if ( o == view_as_NHX_item ) {
            viewAsNHX();
        }
        else if ( o == tiny_fonts_item ) {
            atvpanel.getATVgraphic().tinyFonts();
            atvpanel.getATVgraphic().repaint();
        }
        else if ( o == small_fonts_item ) {
            atvpanel.getATVgraphic().smallFonts();
            atvpanel.getATVgraphic().repaint();
        }
        else if ( o == medium_fonts_item ) {
            atvpanel.getATVgraphic().mediumFonts();
            atvpanel.getATVgraphic().repaint();
        }
        else if ( o == large_fonts_item ) {
            atvpanel.getATVgraphic().largeFonts();
            atvpanel.getATVgraphic().repaint();
        }
        else if ( o == about_item ) {
            about();
        }
        else if ( o == help_item ) {
            help();
        }
        else if ( o == find_item ) {
            find();
        }
        else if ( o == find_reset_item ) {
            findReset();
        }
    }

    private void openURL() {
        URL url     = null;
        Tree t      = null;
        String message = "Please enter a complete URL. Must "
        + "refer to same server as provided this Applet.";

        String url_string
        = JOptionPane.showInputDialog( this
        , message
        , "Open URL to read a NH/NHX tree"
        , JOptionPane.QUESTION_MESSAGE );

        if ( url_string != null && url_string.length() > 4 ) {

            try {
                url = new URL( url_string );
            }
            catch ( Exception e ) {
                JOptionPane.showMessageDialog( this
                , "ATVapplet: openURL(): "
                + "Exception: " + e
                , "Malformed URL"
                , JOptionPane.ERROR_MESSAGE );
            }
            if ( url != null ) {
                try {
                    t = TreeHelper.readNHtree( url );
                }
                catch ( Exception e ) {
                    JOptionPane.showMessageDialog( this
                    , "ATVapplet: openURL(): "
                    + "\nException: " + e
                    , "Could not read Tree"
                    , JOptionPane.ERROR_MESSAGE );
                }
                if ( t != null ) {
                    reload_tree_ = t.copyTree();
                    removeTextJFrame();
                    atvpanel.terminate();
                    contentpane.removeAll();
                    atvpanel = new ATVpanel_applet( t, this );
                    contentpane.add( atvpanel, BorderLayout.CENTER );
                    setVisible( true );
                    contentpane.repaint();
                    setTitle( "ATV: " + url );
                    atvpanel.getATVcontrol().showWhole();
                }
            }
        }
    }


    private void reLoad() {
        if ( reload_tree_ != null && !reload_tree_.isEmpty() ) {           
            Tree t = reload_tree_.copyTree();
            removeTextJFrame();
            atvpanel.terminate();
            contentpane.removeAll();
            atvpanel = new ATVpanel_applet( t, this );
            contentpane.add( atvpanel, BorderLayout.CENTER );
            setVisible( true );
            contentpane.repaint();
            atvpanel.getATVcontrol().showWhole();
        }
    }

    // (Last modified: 07/30/01)
    private void findReset() {
        if ( atvpanel.getATVgraphic().getTree() == null
        || atvpanel.getATVgraphic().getTree().isEmpty() ) {
            return;
        }
        atvpanel.getATVgraphic().setFoundNodes( null );
        contentpane.repaint();
    } // findReset()



    // (Last modified: 07/30/01)
    private void find() {
        if ( atvpanel.getATVgraphic().getTree() == null
        || atvpanel.getATVgraphic().getTree().isEmpty() ) {
            return;
        }

        String message = "String to search for in sequence and species names,\nEC numbers; or integer for taxonomy IDs:";

        String query = JOptionPane.showInputDialog( this,
                                                    message,
                                                    "Search",
                                                    JOptionPane.QUESTION_MESSAGE );

        if ( query != null ) {
 
            query = query.trim();    

            if ( !query.equals( "" ) ) {
                Vector nodes = null;
                try {
                    nodes 
                    = atvpanel.getATVgraphic().getTree().findInNameSpecECid( query );
                }
                catch ( Exception e ) {
                    System.err.println( "Unexpected exception: " + e );
                }
                if ( nodes != null && nodes.size() > 0 ) {
                    atvpanel.getATVgraphic().setFoundNodes( nodes );
                }
                else {
                    JOptionPane.showMessageDialog( this
                    , "Could not find \"" + query + "\""
                    , "Search"
                    , JOptionPane.ERROR_MESSAGE );
                }
            }
        }
        contentpane.repaint();
       
    } // find()
    
    
    
    void close() {
        removeTextJFrame();
        atvpanel.terminate();
        contentpane.removeAll();
        setVisible( false );
        dispose();
    }

    private void removeRoot() {
        atvpanel.getATVgraphic().removeRoot();
    }

    private void removeRootTri() {
        atvpanel.getATVgraphic().removeRootTri();
    }
    
    private void switchColors() {
        atvpanel.getATVgraphic().switchColors();
    }
    
    private void viewAsNH() {
        removeTextJFrame();
        if ( atvpanel.getATVgraphic().getTree() == null ) {
            return;
        }
        if ( atvpanel.getATVgraphic().getTree().isEmpty() ) {
            return;
        }
        atvtextframe = new ATVtextframe( atvpanel.getATVgraphic(
        ).getTree().toNewHampshire( false ) );
    }

    private void viewAsNHX() {
        removeTextJFrame();
        if ( atvpanel.getATVgraphic().getTree() == null ) {
            return;
        }
        if ( atvpanel.getATVgraphic().getTree().isEmpty() ) {
            return;
        }
        atvtextframe = new ATVtextframe( atvpanel.getATVgraphic(
        ).getTree().toNewHampshireX() );
    }

    private void about() {
        String about = "ATV (A Tree Viewer)\nVersion 1.92\n";
        about += "Copyright (C) 1999-2002 Washington University School of Medicine\n";
        about += "and Howard Hughes Medical Institute\n";
        about += "All Rights Reserved\n";
        about += "Author: Christian M. Zmasek\n";
        about += "Last modified: 02/17/02\n";
        about += "Reference: Zmasek C.M. and Eddy S.R. Bioinformatics, 17, 383 (2001)\n";
        about += "For more information & download:\n";
        about += "http://www.genetics.wustl.edu/eddy/atv/\n";
        about += "Comments: zmasek@genetics.wustl.edu";

        JOptionPane.showMessageDialog( this
        , about
        , "ATV JApplet (Java 1.2 or greater)"
        , JOptionPane.PLAIN_MESSAGE );
    }

    private void help() {
        String help = "(Left) click on nodes of the tree to:\n";
        help += "o  Display and edit information of a node.\n";
        help += "    To edit information, box \"Editable\" needs to be checked.\n";
        help += "o  Collapse and uncollapse subtrees.\n";
        help += "o  Go to SWISS-PROT and display its entry for the corresponding sequence.\n";
        help += "    Only available in JApplet version.\n";
        help += "    Seq names need to be proper SWISS-PROT names for this to work.\n";
        help += "o  Place a root in the middle of the parent branch.\n";
        help += "o  Display a subtree.\n";
        help += "    To go back to the parent tree, click on the root node of the subtree.\n";
        help += "o  Swap the children of a node (a pure cosmetic operation).\n\n";
        help += "Right clicking always displays the information of a node.\n\n";
        help += "\"SaveAs\" \"Save\" save the (sub)tree which is currently shown in the frame.\n";
        help += "\"Print\" prints the (sub)tree which is currently shown in the frame.\n\n";
        help += "For more information: http://www.genetics.wustl.edu/eddy/atv/\n";
        help += "Email: zmasek@genetics.wustl.edu\n\n";
        help += "Remarks:\n";
        help += "o  ATV can deal with trees with an arbitrary number of \n";
        help += "    children per parent.\n";
        help += "o  The application version allows to copy to the clipboard \n";
        help += "    in the \"View\"|\"View as ...\" frame.\n";
        help += "    For security reasons, the JApplet is not allowed to do so.\n";
        help += "o  The JApplet can only connect to network ports on the server.\n";
        help += "    E.g. \"http://www.genetics.wustl.edu/\".\n";
        help += "    The application can connect to any host.\n";
        help += "o  \"Save\", \"SaveAs\", \"Print\", and \"Open\" are only available in the \n";
        help += "    application version.\n";
        help += "o  Changes made to a subtree affect this subtree and its subtrees,\n";
        help += "    but not any of its parent tree(s).\n";
        help += "o  ATV tries to detect whether the numerical values in a NH tree \n";
        help += "    are likely to be bootstrap values instead of branch length values.\n";

        JOptionPane.showMessageDialog( this
        , help
        , "Help"
        , JOptionPane.PLAIN_MESSAGE );
    }



    // Sets font, background, and foreground, adds ActionListener
    // to a JMenuItem:
    private void customizeJMenuItem( JMenuItem jmi ) {
        jmi.setFont( menu_font );
        jmi.setBackground( menu_background_color );
        jmi.setForeground( menu_text_color );
        jmi.addActionListener( this );
    }

    private void removeTextJFrame() {
        if ( atvtextframe != null ) {
            atvtextframe.close();
            atvtextframe = null;
        }
    }

} // End of class ATVappletFrame.




