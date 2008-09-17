// StackItem.java
//
// Copyright (C) 2002 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved
//
// Created: 09/28/01
// Author: Christian M. Zmasek
// zmasek@genetics.wustl.edu
// http://www.genetics.wustl.edu/eddy/people/zmasek/




package forester.tree;


/**

@author Christian M. Zmasek

@version 1.000 -- last modified: 10/01/01


*/
public class Branch {

    public Branch( Node n1, Node n2 ) {

        node1_ = n1;
        node2_ = n2;
    }

    public Node getNode1() {
        return node1_;
    }
  
    public Node getNode2() {
        return node2_;
    }
   
    public String toString() {

        return( "Node 1:\n" + getNode1().toString() +  "\n\nNode 2:\n" + getNode2().toString() );

    }

    private Node node1_,
                 node2_;

}
