// ATVappletWjs.java

// ATV applet with JavaScript
// Peter Ernst <P.Ernst@dkfz-heidelberg.de>; August 2000

// AWT version.

// This is an extension class of the "ATVapplet" class.
// It contains "communication" functions for JavaScript.

// Implements a "Save On Server" functionality.


package forester.atv_awt;

import forester.tree.*;

import java.io.*;
import java.awt.*;
import java.net.URL;
import java.applet.*;


/**
 
    @author Peter Ernst
    
    last modified: 31 Aug 2000


*/
public class ATVappletWjs extends ATVapplet {

    private ATVappletWjsFrame atvappletWjsframe;
    
    // names of JavaScript functions, overwritten by parameters
    private String js_getFileName   = null,
                   js_setFileName   = null,
                   js_printHook     = null,
                   js_saveFile      = null;
    
    public void init() {
	js_getFileName = getParameter( "js_get_file_name" );
	js_setFileName = getParameter( "js_set_file_name" );
	js_printHook   = getParameter( "js_print_hook" );
	js_saveFile    = getParameter( "js_save_file" );

	super.init();
    }


    // overrides the method in the super class
    protected ATVappletFrame createATVFrame( ATVapplet applet) {
	if (applet instanceof ATVappletWjs) {
	    atvappletWjsframe = new ATVappletWjsFrame ( (ATVappletWjs)applet );
	    return atvappletWjsframe;
	} else {
	    atvappletWjsframe = null;
	    return super.createATVFrame (applet);
	}
    }

    /**
    
    Returns the names of JavaScript functions
    
    */
    String get_js_getFileName() {
        return js_getFileName;
    }
    
    String get_js_setFileName() {
        return js_setFileName;
    }
    
    String get_js_printHook() {
        return js_printHook;
    }
    
    String get_js_saveFile() {
        return js_saveFile;
    }

    // will be called by JavaScript from the browser
    public String get_newHampshire() {
	return ( atvappletWjsframe.getATVpanel().getATVgraphic().
		 getTree().toNewHampshire( false ) );
    }

    
} // End of class ATVappletWjs.
