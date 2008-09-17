// ATVappletWjsFrame.java

// ATV applet with JavaScript
// Peter Ernst <P.Ernst@dkfz-heidelberg.de>; August 2000

// AWT version.

// This is an extension class of the "ATVappletFrame" class.
// It contains "communication" functions for JavaScript.

// Implements a "Save On Server" functionality.


package forester.atv_awt;

import forester.tree.*;

import java.io.*;
import java.awt.*;
import java.awt.event.*;
import java.net.URL;

// for communication with JavaScript in the browser
import netscape.javascript.*;

/**

   @author Peter Ernst

   last modified: 31 Aug 2000

*/
class ATVappletWjsFrame extends ATVappletFrame {

    protected MenuItem         save_on_server_item = null;
    private ATVappletWjs       atv_applet_wjs;
    private JSObject           win = null;

    protected static String save_on_server_label = "Save on server in NH/Phylip format";

    // simple constructor
    ATVappletWjsFrame( ATVapplet atva ) {

	super (atva);
    }

    // standard constructor
    ATVappletWjsFrame( ATVappletWjs atva ) {

	// create the "standard" ATVappletFrame ...
	super (atva);

	// ... and add an entry to it's File menu
	atv_applet_wjs = atva;

	Menu      file_jmenu = getFileMenu();

	// search for JavaScript (browser) window object
	try {
	    win = JSObject.getWindow( (java.applet.Applet)atv_applet_wjs );
	    if (win != null) {
		String js_printHook_func   = atv_applet_wjs.get_js_printHook();
		String js_getFileName_func = atv_applet_wjs.get_js_getFileName();
		String js_setFileName_func = atv_applet_wjs.get_js_setFileName();
		String js_saveFile_func    = atv_applet_wjs.get_js_saveFile();

		if ( js_printHook_func == null ) {
		    throw (new AWTException("missing applet parameter 'js_print_hook'\n") );
		}
		if ( js_getFileName_func == null ) {
		    throw (new AWTException("missing applet parameter 'js_get_file_name'\n") );
		}
		if ( js_setFileName_func == null ) {
		    throw (new AWTException("missing applet parameter 'js_set_file_name'\n") );
		}
		if ( js_saveFile_func == null ) {
		    throw (new AWTException("missing applet parameter 'js_save_file'\n") );
		}

		// tell JavaScript via js_printHook the name of the
		// applet's Java function that returns the contents of the editor
		win.eval( js_printHook_func + "('get_newHampshire')" );

		// add 'Save on server' to the applet's File menu
		file_jmenu.addSeparator();
		file_jmenu.add(save_on_server_item
			       = new MenuItem( save_on_server_label ) );
	    }
	} catch (Exception e) {
	  save_on_server_item = null;

	  System.out.println("Don't add '" + save_on_server_label + "' to File menu");
	  System.out.println(e);
	}

	if (save_on_server_item != null) {
	  customizeMenuItem( save_on_server_item );
	}


    } // End of constructor ATVappletWjsFrame( atvapplet ).


    protected ATVappletWjs getATVappletWjs() {
        return atv_applet_wjs;
    }


    /**

    Action performed.

    */
    public void actionPerformed( ActionEvent e ) {

        Object o = e.getSource();

        if ( ( save_on_server_item != null ) && ( o == save_on_server_item ) ) {
            saveOnServer();
        } else {
            super.actionPerformed (e);
        }
    }

    protected void saveOnServer() {

      ATVappletWjs atv_applet = getATVappletWjs();

      String js_getFileName_func = atv_applet.get_js_getFileName();
      String js_setFileName_func = atv_applet.get_js_setFileName();
      String js_saveFile_func    = atv_applet.get_js_saveFile();

       try {
	   if ( js_getFileName_func != null && win != null) {
	       String filename = (String)win.eval(js_getFileName_func + "()");

	       OutputFileRemotePopup ofrp =
	           new OutputFileRemotePopup(this, save_on_server_label, filename, win,
					     js_setFileName_func,
					     js_saveFile_func);
	   } else {
	       throw (new AWTException("missing applet parameter " +
				       "'js_get_file_name' or browser window") );
	   }

       } catch (Exception e) {
	   System.out.println("Can't use JavaScript to save on server\n");
	   System.out.println(e);
       }
    }
    

} // End of class ATVappletWjsFrame.
