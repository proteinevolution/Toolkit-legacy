// ATVjapplet.java
// Copyright (C) 1999-2001 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved


package forester.atv;

import forester.tree.*;

import javax.swing.*;
import java.awt.*;
import java.net.URL;
import java.applet.*;


/**
 
@author Christian M. Zmasek
    
@version 1.08 -- last modified: 10/31/00

*/
public class ATVjapplet extends JApplet {

    private ATVappletFrame atvappletframe;
    
    private String url_string = "",
                   message1   = "",
                   message2   = "";
    
    private final static Color background_color = new Color( 100, 100, 100 ),
                               font_color       = new Color( 255, 51, 0 );
 			 
    private final static Font font = new Font( "Helvetica", Font.BOLD, 10 );	 
    
    private boolean exception;
    
    /**
    
    Initializes the JApplet.
    Loads the Tree from value tagged by "url_of_tree_to_load".
    Opens a JFrame (ATVappletFrame) containing the display of the Tree
    and all the controls.
    There is no need to call this method, since it gets called
    automatically whenever a ATVapplet is created.
    Requirement: JDK 1.1 plus Swing/JFC, or JDK 1.2 or greater.
    
    */
    public void init() { 
        
        exception = false;
        this.setName( "ATV JApplet" );
        url_string = getParameter( "url_of_tree_to_load" );
        setBackground( background_color );
	    setForeground( font_color );
	    setFont( font );
	    repaint();
	    String s = null;
	    
        try {
            s = System.getProperty( "java.version" );
        }
        catch ( Exception e ) {
            System.err.println( e.toString() );    
        }
        
        if ( s != null ) {
            message2 = "(Your Java version: " + s + ")";
            repaint();
        }    
        
        try {
            atvappletframe = new ATVappletFrame( this );
            atvappletframe.getATVpanel().getATVcontrol().showWhole();
	    }
	    catch ( Exception e ) {
            exception = true;
            message1 = "Exception: " + e;
            repaint();
        }
        if ( !exception ) {
	        message1 = "ATV JApplet is now ready!";
	        repaint();
	    }
	
    }
    
    
    
    /**
    
    Prints message when initialization is finished. Called automatically.
    
    @param g Graphics
    
    */
    public void paint( Graphics g ) {
        g.drawString( message2, 10, 20 );
        g.drawString( message1, 10, 40 );
    }
    
    
    
    /**
    
    Returns the URL of the loaded Tree as a String.
    
    */
    String getURLstring() {
        return url_string;
    }
    
    
    
    /**
    
    Opens a new browser frame displaying the contents at the URL url.

    @param url URL whose contents are to be displayed
    
    */
    void go( URL url ) throws Exception {
    
        AppletContext context = getAppletContext();
	
	    try {
	        context.showDocument( url, "ATV" );
	        // Opens a new browser frame. All the subsequently opened web
	        // pages will be shown in this frame. Currently (08/31/99), it
	        // seems not possible to use "_self" in IE 4 or 5.
	        // (It would work for the first page, but then null pointers will be thrown.)
	    }
        catch ( Exception e ) {
	        JOptionPane.showMessageDialog( this, e.toString()
	         + "\nURL = "
	         + url, "Exception in ATVapplet", JOptionPane.ERROR_MESSAGE );
	        throw new Exception( e.toString() );
	    }
	
    }
    
    
    
    /**
    
    Closes the JFrame containg the Tree display.
    Called automatically. 
    
    */
    public void destroy() {
        atvappletframe.close();
    }
    // It seems that IE (4 and 5) calls the destroy() method whenever 
    // the web page containing the JApplet is not displayed anymore.
    // Therefore, in some settings, it is necessary to remove this
    // destroy() method.
    
    
    
    
} // End of class ATVapplet.




