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

// AWT version.


package forester.atv_awt;


import forester.tree.*;

import java.io.*;
import java.awt.*;
import java.util.Vector;
import java.awt.event.*;
import java.net.URL;


/**

@author Christian M. Zmasek

@version AWT 1.030 last modified: 10/04/01

*/
class ATVappletFrame extends Frame implements ActionListener {

    private Tree             reload_tree_ = null;
    private MenuBar          menubar;
    private Menu             file_jmenu, edit_jmenu, view_jmenu, options_jmenu, help_jmenu,
                             search_jmenu;
    private MenuItem         close_item, open_url_item, remove_root_item,
                             reload_item, remove_root_tri_item,
                             tiny_fonts_item, small_fonts_item, medium_fonts_item, large_fonts_item,
                             switch_colors_item, view_as_NH_item, view_as_NHX_item,
                             about_item, help_item, find_item, find_reset_item;
    private ATVapplet        atvapplet; 
    public  ATVpanel_applet  atvpanel;      // Must not be private in order for 
                                            // Applet to work in browser.
                                        
    public  Dialog           d;             // Same.
    public  TextField        url_tf,        // Same.
                             search_tf;
    private String url_string = "http://",
                   query      = "";                                    

    private final static Color menu_background_color = new Color( 215, 215, 215 ),
                               menu_text_color       = new Color( 0, 0, 0 );
                         
    private final static Font  menu_font             = new Font( "SansSerif", Font.PLAIN, 10 );

    private final static int FRAME_X_SIZE = 640,
                             FRAME_Y_SIZE = 580;



    ATVappletFrame( ATVapplet atva ) {

        atvapplet    = atva;
        URL url      = null;
        Tree t       = null;

        if ( atvapplet.getURLstring() != null ) {
            try {
                url = new URL( atvapplet.getURLstring() );
            }
            catch ( Exception e ) {
                
                Message message = new Message( this
                                               , "Exception while trying to create URL"
                                               , e + "\nCould not create URL from:\n" 
                                               + url );
                
                close();
            }
        }

        if ( url != null ) {
            try {
                t = TreeHelper.readNHtree( url );
            }
            catch ( Exception e ) {
                
                Message message = new Message( this
                                               , "Exception while trying to read Tree from URL"
                                               , e + "\nCould not read Tree from:\n" 
                                               + url );
                close();
            }
        }

        if ( t != null && !t.isEmpty() ) {
            t.adjustNodeCount( true );
            t.recalculateAndReset();
            reload_tree_ = t.copyTree();
        }

        setTitle( "ATV" );

        atvpanel      = new ATVpanel_applet( t, this );

        menubar       = new MenuBar();
        file_jmenu    = new Menu( "File" );
        edit_jmenu    = new Menu( "Edit" );
        search_jmenu  = new Menu( "Search" );
        view_jmenu    = new Menu( "View" );
        options_jmenu = new Menu( "Options" );
        help_jmenu    = new Menu( "Help" );

        file_jmenu.setFont( menu_font );
        edit_jmenu.setFont( menu_font );
        search_jmenu.setFont( menu_font );
        view_jmenu.setFont( menu_font );
        options_jmenu.setFont( menu_font );
        help_jmenu.setFont( menu_font );


        file_jmenu.add( reload_item = new MenuItem( "Reload") );
        file_jmenu.addSeparator();
        file_jmenu.add( open_url_item
         = new MenuItem( "Open URL to read a NH/NHX tree" ) );
        file_jmenu.addSeparator();
        file_jmenu.add( close_item = new MenuItem( "Close" ) );

        edit_jmenu.add( remove_root_item = new MenuItem( "Remove root" ) );
        edit_jmenu.add( remove_root_tri_item
         = new MenuItem( "Remove root and trifurcate" ) );
    
        search_jmenu.add( find_item = new MenuItem( "Search" ) );
        search_jmenu.addSeparator();
        search_jmenu.add( find_reset_item = new MenuItem( "Reset" ) );

        options_jmenu.add( switch_colors_item  = new MenuItem( "Switch colors" ) );
        options_jmenu.addSeparator();
        options_jmenu.add( tiny_fonts_item     = new MenuItem( "Tiny fonts" ) );
        options_jmenu.add( small_fonts_item    = new MenuItem( "Small fonts" ) );
        options_jmenu.add( medium_fonts_item   = new MenuItem( "Medium fonts" ) );
        options_jmenu.add( large_fonts_item    = new MenuItem( "Large fonts" ) );
        
        
        view_jmenu.add( view_as_NH_item     = new MenuItem( "View as NH" ) );
        view_jmenu.add( view_as_NHX_item    = new MenuItem( "View as NHX" ) );

        help_jmenu.add( help_item        = new MenuItem( "Help" ) );
        help_jmenu.add( about_item       = new MenuItem( "About" ) );


        customizeMenuItem( reload_item );
        customizeMenuItem( open_url_item );
        customizeMenuItem( close_item );
        customizeMenuItem( remove_root_item );
        customizeMenuItem( remove_root_tri_item );
        customizeMenuItem( tiny_fonts_item );
        customizeMenuItem( small_fonts_item );
        customizeMenuItem( medium_fonts_item );
        customizeMenuItem( large_fonts_item );
        customizeMenuItem( switch_colors_item );
        customizeMenuItem( view_as_NH_item );
        customizeMenuItem( view_as_NHX_item );
        customizeMenuItem( about_item );
        customizeMenuItem( help_item );
        customizeMenuItem( find_item );
        customizeMenuItem( find_reset_item );


        menubar.add( file_jmenu );
        menubar.add( edit_jmenu );
        menubar.add( search_jmenu );
        menubar.add( view_jmenu );
        menubar.add( options_jmenu );
        menubar.add( help_jmenu );

        setMenuBar( menubar );

        setLayout( new BorderLayout() );
        add( atvpanel, BorderLayout.CENTER );

        setSize( FRAME_X_SIZE, FRAME_Y_SIZE );

        addWindowListener( new WindowAdapter() {
            public void windowClosing( WindowEvent e ) {
                close();
            }
        } );

        addComponentListener( new ComponentAdapter() {
            public void componentResized( ComponentEvent e ) {
                atvpanel.getATVgraphic().setParametersForPainting(
                atvpanel.getATVgraphic().getSize().width,
                atvpanel.getATVgraphic().getSize().height );
            }
        } );


        setVisible( true );


    } // End of constructor ATVappletFrame( atvapplet ).


    ATVapplet getATVapplet() {
        return atvapplet;
    }


    ATVpanel getATVpanel() {
        return atvpanel;
    }

 
    /**
    
    Added by Peter Ernst.
    
    */
    protected Menu getFileMenu() {
        return file_jmenu;
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
        else if ( o == view_as_NH_item ) {
            viewAsNH();
        }
        else if ( o == view_as_NHX_item ) {
            viewAsNHX();
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


    // (Last modified: 07/30/01)
    private void findReset() {
        if ( atvpanel.getATVgraphic().getTree() == null
        || atvpanel.getATVgraphic().getTree().isEmpty() ) {
            return;
        }
        atvpanel.getATVgraphic().setFoundNodes( null );
        atvpanel.getATVgraphic().repaint();
    } // findReset()



    // (Last modified: 07/30/01)
    private void find() {
        if ( atvpanel.getATVgraphic().getTree() == null
        || atvpanel.getATVgraphic().getTree().isEmpty() ) {
            return;
        }
        String message = "Search seq, spec names, EC numbers, taxonomy IDs for:";

        d = new Dialog( this, "Search", true );
        d.setLayout( new BorderLayout() );
        
        Panel mp = new Panel();
        Panel bp = new Panel();
        
        mp.setLayout( new FlowLayout( FlowLayout.CENTER, 5, 5 ) );
        bp.setLayout( new FlowLayout( FlowLayout.CENTER, 5, 5 ) );
        
        mp.add( new Label( message ) );
        search_tf = new TextField( query, 60 );
        mp.add( search_tf );
        
        Button sbutton = new Button( "Search " );
        Button cancelbutton = new Button( "Cancel" );
        
        bp.add( sbutton );
        bp.add( cancelbutton );
        
        d.add( mp, BorderLayout.CENTER );
        d.add( bp, BorderLayout.SOUTH );
        d.setSize( 500, 130 );
        
        d.addWindowListener( new WindowAdapter() {
            public void windowClosing( WindowEvent e ) {
                d.dispose();
                return;
            }
        } );
        
        sbutton.addActionListener( new ActionListener() {
            public void actionPerformed( ActionEvent e ) {
                query = search_tf.getText();
                if ( query != null ) {
                    query = query.trim();  
                    if ( !query.equals( "" ) ) {
                        Vector nodes = null;
                        try {
                            nodes 
                            = atvpanel.getATVgraphic().getTree().findInNameSpecECid( query );
                        }
                        catch ( Exception ex ) {
                            System.err.println( "Unexpected exception: " + e );
                        }
                        if ( nodes != null && nodes.size() > 0 ) {
                            atvpanel.getATVgraphic().setFoundNodes( nodes );
                        }
                        else {
                            atvpanel.getATVgraphic().setFoundNodes( null );
                        }    
                    }
                }
                d.dispose();
                atvpanel.getATVgraphic().repaint();
                return;
            }
        } );
        
        cancelbutton.addActionListener( new ActionListener() {
            public void actionPerformed( ActionEvent e ) {
                d.dispose();
                return;
            }
        } );

        d.show();
       
    } // find()



    private void reLoad() {
        if ( reload_tree_ != null && !reload_tree_.isEmpty() ) {
            Tree t = reload_tree_.copyTree();
            atvpanel.terminate();
            atvpanel.getATVgraphic().setTree( t );
            atvpanel.getATVgraphic().setPropertiesForPainting( t );
            atvpanel.getATVcontrol().setCheckBoxes();
            atvpanel.getATVcontrol().showWhole();
        }
    }



    private void openURL() {
        String message = "Please enter a complete URL. Must "
         + "refer to same server as provided this Applet.";


        d = new Dialog( this, "Open URL to read a NH/NHX tree", true );
        d.setLayout( new BorderLayout() );
        
        Panel mp = new Panel();
        Panel bp = new Panel();
        
        mp.setLayout( new FlowLayout( FlowLayout.CENTER, 5, 5 ) );
        bp.setLayout( new FlowLayout( FlowLayout.CENTER, 5, 5 ) );
        
        mp.add( new Label( message ) );
        url_tf = new TextField( url_string, 60 );
        mp.add( url_tf );
        
        Button openbutton = new Button( "Open " );
        Button cancelbutton = new Button( "Cancel" );
        
        bp.add( openbutton );
        bp.add( cancelbutton );
        
        d.add( mp, BorderLayout.CENTER );
        d.add( bp, BorderLayout.SOUTH );
        d.setSize( 500, 130 );
        
        d.addWindowListener( new WindowAdapter() {
            public void windowClosing( WindowEvent e ) {
                d.dispose();
                return;
            }
        } );
        
        openbutton.addActionListener( new ActionListener() {
            public void actionPerformed( ActionEvent e ) {
                doOpenURL( url_tf.getText() );
                d.dispose();
                return;
            }
        } );
        
        cancelbutton.addActionListener( new ActionListener() {
            public void actionPerformed( ActionEvent e ) {
                d.dispose();
                return;
            }
        } );

        url_tf.addActionListener( new ActionListener() {
            public void actionPerformed( ActionEvent e ) {
                doOpenURL( url_tf.getText() );
                d.dispose();
                return;
            }
        } );

        d.show();
        
    }

    
    // Must not be private.
    void doOpenURL( String s ) { 
        
        url_string = s;
        
        boolean exception = false;
        
        URL url     = null;
        Tree t      = null;

        if ( url_string != null && url_string.length() > 4 ) {

            try {
                url = new URL( url_string );
            }
            catch ( Exception e ) {
                Message message = new Message( this
                                               , "Exception during File|Open URL"
                                               ,  e + "\nCould not create URL from:\n" + url_string );
            }
            if ( url != null ) {
                try {
                    t = TreeHelper.readNHtree( url );
                }
                catch ( Exception e ) {
                    exception = true;
                    Message message = new Message( this
                                                   , "Exception during File|Open URL"
                                                   , e + "\nCould not read from URL:\n" + url );
                }
               
                if ( !exception && t != null && !t.isEmpty() ) {
                    atvpanel.terminate();
                    setTitle( "ATV: " + url );
                    t.adjustNodeCount( true );
                    t.recalculateAndReset();
                    reload_tree_ = t.copyTree();
                    atvpanel.getATVgraphic().setTree( t );
                    atvpanel.getATVgraphic().setPropertiesForPainting( t );
                    atvpanel.getATVcontrol().setCheckBoxes();
                    atvpanel.getATVcontrol().showWhole();
                }
            }
        }
    }


    void close() {
        atvpanel.terminate();
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
        if ( atvpanel.getATVgraphic().getTree() == null ) {
            return;
        }
        if ( atvpanel.getATVgraphic().getTree().isEmpty() ) {
            return;
        }
        
        String s = atvpanel.getATVgraphic().getTree().toNewHampshire( false );
        
        Message message = new Message( this
                                       , "ATV: Tree as NH"
                                       , s );
    }


    
    private void viewAsNHX() {
        if ( atvpanel.getATVgraphic().getTree() == null ) {
            return;
        }
        if ( atvpanel.getATVgraphic().getTree().isEmpty() ) {
            return;
        }
        String s = atvpanel.getATVgraphic().getTree().toNewHampshireX();
        
        Message message = new Message( this
                                       , "ATV: Tree as NHX"
                                       , s );
    }

    
    
    private void about() {
        
        d = new Dialog( this, "ATV Applet (AWT Version)", true );
        d.setLayout( new BorderLayout() );
        
        Panel mp = new Panel();
        Panel bp = new Panel();
        
        mp.setLayout( new GridLayout( 10, 1 ) );
        bp.setLayout( new FlowLayout( FlowLayout.CENTER ) );
        
        mp.add( new Label( "ATV (A Tree Viewer) Version 1.92 (AWT version)", Label.CENTER ) );
        mp.add( new Label( "Copyright (C) 1999-2002 Washington University School of Medicine", Label.CENTER ) );
        mp.add( new Label( "and Howard Hughes Medical Institute", Label.CENTER ) );
        mp.add( new Label( "All Rights Reserved", Label.CENTER ) );
        mp.add( new Label( "Author: Christian M. Zmasek", Label.CENTER ) );
        mp.add( new Label( "Last modified: 02/17/02", Label.CENTER ) );
        mp.add( new Label( "Reference: Zmasek C.M. and Eddy S.R. Bioinformatics, 17, 383 (2001)", Label.CENTER ) );
        mp.add( new Label( "For more information & download:", Label.CENTER ) );
        mp.add( new Label( "http://www.genetics.wustl.edu/eddy/atv/"
         , Label.CENTER ) );
        mp.add( new Label( "Comments: zmasek@genetics.wustl.edu", Label.CENTER ) );
        
        Button okbutton = new Button( "OK" );
        bp.add( okbutton );
        
        d.add( mp, BorderLayout.CENTER );
        d.add( bp, BorderLayout.SOUTH );
        
        d.setSize( 450, 300 );
        
        d.addWindowListener( new WindowAdapter() {
            public void windowClosing( WindowEvent e ) {
                d.dispose();
                return;
            }
        } );
        
        okbutton.addActionListener( new ActionListener() {
            public void actionPerformed( ActionEvent e ) {
                d.dispose();
                return;
            }
        } );

        d.show();
        
    }

    private void help() {
        String help = "(Left) click on nodes of the tree to:\n";
        help += "o  Display and edit information of a node.\n";
        help += "    To edit information, box \"Editable\" needs to be checked.\n";
        help += "o  Collapse and uncollapse subtrees.\n";
        help += "o  Go to SWISS-PROT and display its entry for the corresponding sequence.\n";
        help += "    Only available in Applet version.\n";
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
        help += "o  The Applet can only connect to network ports on the server.\n";
        help += "    E.g. \"http://www.genetics.wustl.edu/\".\n";
        help += "    The application can connect to any host.\n";
        help += "o  \"Save\", \"SaveAs\", \"Print\", and \"Open\" are only available in the \n";
        help += "    application version.\n";
        help += "o  Changes made to a subtree affect this subtree and its subtrees,\n";
        help += "    but not any of its parent tree(s).\n";
        help += "o  ATV tries to detect whether the numerical values in a NH tree \n";
        help += "    are likely to be bootstrap values instead of branch length values.\n";

        Message message = new Message( this
                                       , "ATV Applet (AWT version)"
                                       , help );

       
    }



    // Sets font, background, and foreground, adds ActionListener
    // to a MenuItem:
    protected void customizeMenuItem( MenuItem jmi ) {
        jmi.setFont( menu_font );
        jmi.addActionListener( this );
    }

    

} // End of class ATVappletFrame.




