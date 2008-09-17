/*
 * taken and slightly modified from
 *
 * Jalview - a java multiple alignment editor
 *   (author: Michele Clamp <michele@ebi.ac.uk>;
 *    home:   http://circinus.ebi.ac.uk:6543/jalview/ )
 *
 * by Peter Ernst <P.Ernst@dkfz-heidelberg.de>
 *
 * The variables of class: Button, Label, GridBagLayout and
 *			    GridBagConstraints
 *	has been made "protected" (from "default") because
 *	they need to be accessed from a different package
 *
 * Base class for opening popup windows
 */

package forester.atv_awt;

import java.awt.*;
import java.awt.event.*;

public abstract class PopupProtected extends Dialog {
  Frame parent;

  protected Button apply;
  protected Button close;
  protected Label status;

  protected GridBagLayout gb;
  protected GridBagConstraints gbc;

  public PopupProtected(Frame parent,String title) {
    super(parent,title,false);
    this.parent = parent;

    gb = new GridBagLayout();
    gbc = new GridBagConstraints();

    gbc.fill = GridBagConstraints.NONE;
    gbc.weightx = 100;
    gbc.weighty = 100;

    setLayout(gb);

    status = new Label("Status:                                                   ",Label.LEFT);
    status.setAlignment(Label.LEFT);
    apply = new Button("Apply");
    close = new Button("Close");

    pack();
    validate();
    show();

  }
  public void add(Component c,GridBagLayout gbl, GridBagConstraints gbc,
		  int x, int y, int w, int h) {
    gbc.gridx = x;
    gbc.gridy = y;
    gbc.gridwidth = w;
    gbc.gridheight = h;
    gbl.setConstraints(c,gbc);
    add(c);
  }
  public boolean handleEvent(Event evt) {
    if (evt.target == close && evt.id == 1001) {
      this.hide();
      this.dispose();
      return true;
    } else if (evt.id == Event.WINDOW_DESTROY) {
      status.setText("Closing window...");
      status.validate();
      this.hide();
      this.dispose();
      return true;
    } else {
      return super.handleEvent(evt);
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
