// PostorderTreeIterator.java
//
// Copyright (C) 1999-2001 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved
//
// Created: 1999
// Author: Christian M. Zmasek
// zmasek@genetics.wustl.edu
// http://www.genetics.wustl.edu/eddy/people/zmasek/



// Implements the Iterator pattern as described in Gamma et al.
// "Design Patterns Elements of Reusable Object-Oriented Software".


package forester.tree;

import java.util.Stack;


/**

@author Christian M. Zmasek

@version 1.020 last modified: 05/04/01

*/
public class PostorderTreeIterator implements Iterator {


    /**
 
    Constructor which creates a postorder Iterator for Tree t.
    This implements the Iterator pattern as described in Gamma et al.
    "Design Patterns Elements of Reusable Object-Oriented Software".

    @param t Tree for which a Iterator is to be constructed.

    */
    public PostorderTreeIterator( Tree t ) throws Exception {

        if ( t.isEmpty() ) {
            String message = "PostorderTreeIterator: Tree is empty.";
            throw new Exception( message );
        }

        tree = t;
        first();

    }


    
    /**

    Resets the Iterator.

    */
    public void first() {

        is_done = false;
        node = null;
        stack = new Stack();
        stack.push( new StackItem( tree.getRoot(), 1 ) );
        next();

    }



    /**
    
    Advances the Iterator by one.
    
    */
    public void next() {

        if ( node != null && node == tree.getRoot() ) {
            is_done = true;
            return;
        }

        while ( true ) {
            si = ( StackItem ) stack.pop();
            if ( si.getNode() != null ) {
                switch( si.getPhase() ) {
                    case 1:
                    stack.push( new StackItem( si.getNode(), 2 ) );
                    stack.push( new StackItem( si.getNode().getChild1(), 1 ) );
                    break;
                    case 2:
                    stack.push( new StackItem( si.getNode(), 3 ) );
                    stack.push( new StackItem( si.getNode().getChild2(), 1 ) );
                    break;
                    case 3:
                    node = si.getNode();
                    return;
                }
            }
        }
    }


    
    /**
    
    Returns true if all Nodes have been visited.    
    
    */
    public boolean isDone() {
        return is_done;
    }



    /**
    
    Returns the current Node, unless all Nodes have
    been visited (isDone() returns true), in which case it returns 
    null.
    
    */
    public Node currentNode() {
        if ( isDone() ) {
            return null;
        }
        else {
            return node;
        }
    }



    private Tree tree;
    private Node node;
    private StackItem si;
    private boolean is_done;
    private Stack stack;


}
