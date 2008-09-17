// Message.java
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

import java.io.*;
import java.awt.*;
import java.awt.event.*;


/**

@author Christian M. Zmasek

@version AWT 1.00 -- last modified: 06/24/00

*/
class Message extends Dialog {
  
    final int SIZE_X = 500,
              SIZE_Y = 310;
    
    
    /**
    
    Displays a Dialog containing a TextArea displaying a
    message and a "OK" button to close.
    
    @param parent the parent Frame
    @param title the title for the Dialog
    @param message the message to be displayed
    
    */
    Message( Frame parent, String title, String message ) {
        super( parent, "ATV: " + title, true );
        
        System.err.println( "\nMessage:\n" + message + "\n" ); 
        
        setLayout( new BorderLayout() );
        
        Panel mp = new Panel();
        Panel bp = new Panel();
        
        mp.setLayout( new FlowLayout( FlowLayout.CENTER ) );
        bp.setLayout( new FlowLayout( FlowLayout.CENTER ) );
        
        TextArea ta = new TextArea( message, 15, 65, TextArea.SCROLLBARS_BOTH );
        ta.setEditable( false );
        
        mp.add( ta );
       
        
        Button okbutton = new Button( "OK" );
        bp.add( okbutton );
        
        add( mp, BorderLayout.CENTER );
        add( bp, BorderLayout.SOUTH );
        
        setSize( SIZE_X, SIZE_Y );
        
        addWindowListener( new WindowAdapter() {
            public void windowClosing( WindowEvent e ) {
                dispose();
                return;
            }
        } );
        
        okbutton.addActionListener( new ActionListener() {
            public void actionPerformed( ActionEvent e ) {
                dispose();
                return;
            }
        } );

        show();
        
    }  
    
}    
