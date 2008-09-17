/*
 * taken and slightly modified from
 *
 * Jalview - a java multiple alignment editor
 *   (author: Michele Clamp <michele@ebi.ac.uk>;
 *    home:   http://circinus.ebi.ac.uk:6543/jalview/ )
 *
 * by Peter Ernst <P.Ernst@dkfz-heidelberg.de>
 *
 * Opens a popup window and asks for a filename on the server
 */

package forester.atv_awt;

import java.awt.*;
import java.awt.event.*;
import java.applet.*;
import java.net.*;
import java.io.*;

public class OutputFileRemotePopup extends PopupProtected {
  TextField tf;
  Label tfLabel;
  netscape.javascript.JSObject win;
  String setFile, saveFile;

  public OutputFileRemotePopup(Frame parent, String title, String filename,
			       netscape.javascript.JSObject win,
			       String js_setFileName_func,
			       String js_saveFile_func) {
    super(parent,title);
    this.win = win;

    tf = new TextField(filename, 40);
    tfLabel = new Label("Filename : ");
    setFile  = js_setFileName_func;
    saveFile = js_saveFile_func;

    gbc.fill = GridBagConstraints.NONE; 

    gbc.insets = new Insets(20,20,20,20);

    add(tfLabel,gb,gbc,0,0,1,1);
    add(tf,gb,gbc,1,0,4,1);

    gbc.fill = GridBagConstraints.HORIZONTAL;
    add(status,gb,gbc,0,2,1,1);
    gbc.fill = GridBagConstraints.NONE; 
    add(apply,gb,gbc,0,3,1,1);
    add(close,gb,gbc,1,3,1,1);

    pack();
    show();


  }

  public boolean handleEvent (Event e) {

   if (e.target == apply && e.id == 1001) {

       try {
	   status.setText("Saving file");
	   status.validate();

	   String fileStr = tf.getText();
	   win.eval(setFile + "('" + fileStr + "')");
	   win.eval(saveFile + "('_blank')");

	   status.setText("done");
	   status.validate();

	   this.hide();
	   //parent.hide();

	   this.dispose();
	   //parent.dispose();
       } catch (Exception exept) {
	   status.setText("Can't use JavaScript to save alignment");
	   status.validate();
       }

       return true;

   } else {
       return super.handleEvent(e);
   }
 }
}
/*
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */
