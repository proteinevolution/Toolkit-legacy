// ATVapplet.java
// Copyright (C) 1999-2001 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved



// AWT version.
// Does not display in some versions of IE 4 and 5 on Win 95.


package forester.atv_awt;

import forester.tree.*;

import java.io.*;
import java.awt.*;
import java.net.URL;
import java.applet.*;


/**
 
    @author Christian M. Zmasek
    
    @version AWT 1.000 -- last modified: 10/31/00


*/
public class ATVapplet extends Applet {

    private ATVappletFrame atvappletframe;
    
    private String url_string = "",
                   message1   = "",
                   message2   = "";
    
    private final static Color background_color = new Color( 0, 0, 150 ),
                               font_color       = new Color( 0, 255, 255 );
 			 
    private final static Font font = new Font( "SansSerif", Font.BOLD, 10 );	 
    
    private boolean exception;
    
    
    /**
    
    Initializes the Applet.
    Loads the Tree from value tagged by "url_of_tree_to_load".
    Opens a Frame (ATVappletFrame) containing the display of the Tree
    and all the controls.
    There is no need to call this method, since it gets called
    automatically whenever a ATVapplet is created.
    This is part of the atv_awt package. It requires at least
    JDK 1.1 (but no Swing -- since it only relies on the AWT).
    
    */
    public void init() {
        
        exception = false;
        this.setName( "ATV Applet" );
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
            System.err.println( "Could not determine Java version" ); 
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
	        message1 = "ATV Applet is now ready!";
	        repaint();
	    }
    }


    
    /**
    
    Will be overwritten by subclasses.
    Added by Peter Ernst.

    */
    protected ATVappletFrame createATVFrame( ATVapplet applet ) {
        return new ATVappletFrame (applet);
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
            System.err.println( e + " URL = " + url );
	    }
	
    }
    
    
    
    /**
    
    Closes the Frame containg the Tree display.
    Called automatically. 
    
    */
    public void destroy() {
        atvappletframe.close();
    }
    // It seems that IE (4 and 5) calls the destroy() method whenever 
    // the web page containing the Applet is not displayed anymore.
    // Therefore, in some settings, it is necessary to remove this
    // destroy() method.
    
    
    
    
} // End of class ATVapplet.




