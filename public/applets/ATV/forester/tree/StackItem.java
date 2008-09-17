// StackItem.java
//
// Copyright (C) 1999-2001 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved
//
// Created: 1999
// Author: Christian M. Zmasek
// zmasek@genetics.wustl.edu
// http://www.genetics.wustl.edu/eddy/people/zmasek/



// A helper class for Iterators. 


package forester.tree;


/**

@author Christian M. Zmasek

@version 1.00 -- last modified: 06/15/00


*/
class StackItem {

    StackItem( Node n, int i ) {
        node = n;
        phase = i;
    }

    Node getNode() {
        return node;
    }

    int getPhase() {
        return phase;
    }

    private Node node;
    private int phase;

}
