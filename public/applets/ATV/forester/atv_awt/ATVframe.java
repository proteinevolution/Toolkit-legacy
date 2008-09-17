// ATVframe.java
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

import java.io.*;
import java.awt.*;
import java.awt.event.*;
import java.net.URL;


/**

@author Christian M. Zmasek

@version AWT 1.050 -- last modified: 07/03/01

*/
public class ATVframe extends Frame implements ActionListener {

    private Tree       reload_tree_ = null;
    private File       treefile = null; // used for "save".
    private MenuBar    menubar;
    private Menu       file_jmenu, edit_jmenu, view_jmenu, options_jmenu, help_jmenu;
    private MenuItem   open_item, open_url_item, save_item, saveas_item, close_item,
                       exit_item, reload_item, remove_root_item, remove_root_tri_item,
                       tiny_fonts_item, small_fonts_item, medium_fonts_item, large_fonts_item,
                       switch_colors_item, view_as_NH_item, view_as_NHX_item,
                       about_item, help_item;
            ATVpanel   atvpanel;
    private Container  contentpane;
    
            Dialog     d;
            TextField url_tf;
    private String url_string = "http://";
    
    private final static Color menu_background_color = new Color( 215, 215, 215 ),
                               menu_text_color       = new Color( 0, 0, 0 );
    
    private final static Font  menu_font = new Font( "SansSerif", Font.PLAIN, 10 );

    private final static int FRAME_X_SIZE = 640,
                             FRAME_Y_SIZE = 580;
                            

    /**

    This constructor creates and displays a Frame containing
    the image of a Tree t plus all the necessary controls.
    It is recommended that method "showWhole()" is called after
    a ATVframe has been constructed to ensure the whole Tree
    is displayed.
    This is part of the atv_awt package. It requires at least
    JDK 1.1 (but no Swing -- since it only relies on the AWT).
    
    @param t the Tree to display
    
    @see #showWhole()

    */
    public ATVframe( Tree t ) {
        
        setVisible( false );
        
        if ( t != null && !t.isEmpty() ) {
            t.adjustNodeCount( true );
            t.recalculateAndReset();
            reload_tree_ = t.copyTree();
        }
        
        setTitle( "ATV" );

        atvpanel = new ATVpanel( t );

        menubar       = new MenuBar();
        file_jmenu    = new Menu( "File" );
        edit_jmenu    = new Menu( "Edit" );
        view_jmenu    = new Menu( "View" );
        options_jmenu = new Menu( "Options" );
        help_jmenu    = new Menu( "Help" );

        file_jmenu.setFont( menu_font );
        edit_jmenu.setFont( menu_font );
        view_jmenu.setFont( menu_font );
        options_jmenu.setFont( menu_font );
        help_jmenu.setFont( menu_font );

        file_jmenu.add( reload_item     = new MenuItem( "Reload") );
        file_jmenu.addSeparator();
        file_jmenu.add( open_item       = new MenuItem( "Open") );
        file_jmenu.add( open_url_item
         = new MenuItem( "Open URL to read a NH/NHX tree" ) );
        file_jmenu.add( saveas_item     = new MenuItem( "Save As" ) );
        file_jmenu.add( save_item       = new MenuItem( "Save" ) );
        file_jmenu.addSeparator();
        file_jmenu.add( close_item      = new MenuItem( "Close" ) );
        file_jmenu.addSeparator();
        file_jmenu.add( exit_item       = new MenuItem( "Exit" ) );

        edit_jmenu.add( remove_root_item = new MenuItem( "Remove root" ) );
        edit_jmenu.add( remove_root_tri_item
         = new MenuItem( "Remove root and trifurcate" ) );
        
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
        customizeMenuItem( open_item );
        customizeMenuItem( open_url_item );
        customizeMenuItem( save_item );
        customizeMenuItem( saveas_item );
        customizeMenuItem( close_item );
        customizeMenuItem( exit_item );
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


        menubar.add( file_jmenu );
        menubar.add( edit_jmenu );
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

    } // End of constructor.

   

    /**

    Resizes the Tree, so that it is displayed in its entirety.
    It is recommended to call this method after the constructor
    ATVframe(Tree t) has been called.
    
    @see #ATVframe(Tree)

    */
    public void showWhole() {
        atvpanel.getATVcontrol().showWhole();
    }    

  
    /**
    
    Sets the maximal number a sequence is expected to be
    orthologous towards another, i.e. the number of resampling steps.
    (Last modified: 12/05/00)
    
    */
    public void setMaxOrtho( int m ) {
        atvpanel.getATVgraphic().setMaxOrtho( m );
    }    
 
 

    /**

    Called automatically.

    */
    public void actionPerformed( ActionEvent e ) {

        Object o = e.getSource();
 
        if ( o == reload_item ) {
            reLoad();
        }
        else if ( o == open_item ) {
            openFile();
        }
        else if ( o == open_url_item ) {
            openURL();
        }
        else if ( o == save_item ) {
            save( atvpanel.getATVgraphic().getTree() );
            // (Always saves the complete tree.) = not true anymore!
            // If subtree currently displayed, save it, instead of complete tree.
        }
        else if ( o == saveas_item ) {
            saveAs( atvpanel.getATVgraphic().getTree() );
            // If subtree currently displayed, save it, instead of complete tree.
        }
        else if ( o == close_item ) {
            close();
        }
        else if ( o == exit_item ) {
            exit();
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
    }



    private void openFile() {
        boolean exception = false;
        Tree t            = null;
        
        // Show the file dialog.
        FileDialog fd = new FileDialog( this, "Open File", FileDialog.LOAD );
        fd.setDirectory( "" );
        fd.show();
        
        // Get file name and directory.
	    // Remove ".*.*" from file name, if necessary.
        String dir = fd.getDirectory();
     	String file = stripStars( fd.getFile() );
     	
     	
     	if ( dir != null && file != null ) {
	
		    File f = new File( dir, file );
		    if ( f != null  ) {
                try {
                    t = TreeHelper.readNHtree( f );
                }
                catch ( Exception e ) {
                    exception = true;
                    Message message = new Message( this
                                                  , "Exception during File|Open"
                                                  , e.toString() );
                }
               
                if ( !exception && t != null && !t.isEmpty() ) {
                    treefile = f;
                    atvpanel.terminate();
                    setTitle( "ATV: " + f );
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

        String message = "Please enter a complete URL";

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



    void save( Tree t ) {

        if ( treefile == null || t == null ) {
            return;
        }
        
        try {
            TreeHelper.writeNHtree( t, treefile, true, true, true );
        }
        catch ( Exception e ) {
            Message message = new Message( this
                                           , "Exception during File|Save"
                                           , e.toString() );
        }
        
    }



    void saveAs( Tree t ) {
        
        if ( t == null ) {
            return;    
        }  
        
        boolean exception = false;  
        
        // Show the file dialog

	    FileDialog fd = new FileDialog( this, " Safe File (\".nh\" to safe in NH format)"
	                                    , FileDialog.SAVE );
	    fd.setFile( "" );
	    fd.show();

	    // Get file name and directory.
	    // Remove ".*.*" from file name, if necessary.

	    String dir = fd.getDirectory();
	    String file = stripStars( fd.getFile() );

	    if ( dir != null && file != null ) {
	
	        File f = new File( dir, file );
	
            if ( f.getName().trim().toLowerCase().endsWith( ".nh" ) ) {
                try {
                    TreeHelper.writeNHtree( t, f, false, true, true );
                }
                catch ( Exception e ) {
                    exception = true;
                    Message message = new Message( this
                                                   , "Exception during File|SaveAs"
                                                   , e.toString() );
                }
            }
            // NHX is default:
            else {
                try {
                    TreeHelper.writeNHtree( t, f, true, true, true );
                }
                catch ( Exception e ) {
                    exception = true;
                    Message message = new Message( this
                                                   , "Exception during File|SaveAs"
                                                   , e.toString() );
                }
            }
           
            if ( !exception ) {
                treefile = f;
                setTitle( "ATV: " + treefile );
            }
		}
    }

    
    
    private void close() {
        atvpanel.terminate();
        setVisible( false );
        dispose();
    }



    private void exit() {
        System.exit( 0 );
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
        
        d = new Dialog( this, "ATV application (AWT Version)", true );
        d.setLayout( new BorderLayout() );
        
        Panel mp = new Panel();
        Panel bp = new Panel();
        
        mp.setLayout( new GridLayout( 14, 1 ) );
        bp.setLayout( new FlowLayout( FlowLayout.CENTER ) );
        
        mp.add( new Label( "ATV (A Tree Viewer) Version AWT 1.6", Label.CENTER ) );
        mp.add( new Label( "Copyright (C) 1999-2001 Washington University School of Medicine", Label.CENTER ) );
        mp.add( new Label( "and Howard Hughes Medical Institute", Label.CENTER ) );
        mp.add( new Label( "All Rights Reserved", Label.CENTER ) );
        mp.add( new Label( "Author: Christian M. Zmasek", Label.CENTER ) );
        mp.add( new Label( "Last modified: 07/03/01", Label.CENTER ) );
        mp.add( new Label( "Reference: Zmasek C.M. and Eddy S.R. Bioinformatics, 17, 383 (2001)", Label.CENTER ) );
        mp.add( new Label( "THIS AWT VERSION OF THE APPLICATION (\"ATVapp_awt\")", Label.CENTER ) );
        mp.add( new Label( "IS NOT BEING SUPPORTED ANYMORE.", Label.CENTER ) );
        mp.add( new Label( "PLEASE USE THE \"SWING\" (Java 1.2) VERSION (\"ATVapp\").", Label.CENTER ) );
        mp.add( new Label( "For more information & download:", Label.CENTER ) );
        mp.add( new Label( "http://www.genetics.wustl.edu/eddy/atv/"
         , Label.CENTER ) );
        mp.add( new Label( "Comments: zmasek@genetics.wustl.edu", Label.CENTER ) );
        
        Button okbutton = new Button( "OK" );
        bp.add( okbutton );
        
        d.add( mp, BorderLayout.CENTER );
        d.add( bp, BorderLayout.SOUTH );
        
        d.setSize( 430, 300 );
        
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
        String help = "THIS AWT VERSION OF THE APPLICATION (\"ATVapp_awt\")\n";
        help += "IS NOT BEING SUPPORTED ANYMORE.\n";
        help += "PLEASE USE THE \"SWING\" (Java 1.2) VERSION (\"ATVapp\").\n\n";
        help += "Click on nodes of the tree to:\n";
        help += "- Display and edit information of a node.\n";
        help += "   To edit information, box \"Editable\" needs to be checked.\n";
        help += "- Collapse and uncollapse subtrees.\n";
        help += "- Go to SWISS-PROT and display its entry for the corresponding sequence.\n";
        help += "   Only available in Applet version.\n";
        help += "   Seq names need to be proper SWISS-PROT names for this to work.\n";
        help += "- Place a root in the middle of the parent branch.\n";
        help += "- Display a subtree.\n";
        help += "   To go back to the parent tree, click on the root node of the subtree.\n";
        help += "- Swap the children of a node (a pure cosmetic operation).\n\n";
        help += "\"SaveAs\" \"Save\" save the (sub)tree which is currently shown in the frame.\n";
        help += "For more information: http://www.genetics.wustl.edu/eddy/atv/\n";
        help += "Email: zmasek@genetics.wustl.edu\n\n";
        help += "Remarks:\n";
        help += "- This software can deal with trees with an arbitrary number of \n";
        help += "   children per parent.\n";
        help += "- The Applet can only connect to network ports on the server.\n";
        help += "   E.g. \"http://www.genetics.wustl.edu/\".\n";
        help += "   The application can connect to any host.\n";
        help += "- \"Save\", \"SaveAs\", and \"Open\" are only available in the \n";
        help += "   application version.\n";
        help += "- Changes made to a subtree affect this subtree and its subtrees,\n";
        help += "   but not any of its parent tree(s).\n";
        help += "- This software is able to detect whether the numerical values in a NH tree \n";
        help += "   are likely to be bootstrap values instead of branch length values.\n";

        Message message = new Message( this
                                       , "ATV application (AWT Version)"
                                       , help );

       
    }


    // Sets font, background, and foreground, adds ActionListener
    // to a MenuItem:
    private void customizeMenuItem( MenuItem jmi ) {
        jmi.setFont( menu_font );
        jmi.addActionListener( this );
    }



    /**
    
    Strip trailing ".*.*" from string, if any
    
    */
    private String stripStars( String s ) {
        if ( s == null ) {
            return s;
        }    
        if ( s.endsWith( ".*.*" ) ) {
            s = s.substring( 0, s.lastIndexOf( ".*.*" ) );
        }    
        return s;
    }




} // End of class ATVframe.


