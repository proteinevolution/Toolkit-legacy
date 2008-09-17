// Iterator.java
//
// Copyright (C) 1999-2001 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved
//
// Created: 1999
// Author: Christian M. Zmasek
// zmasek@genetics.wustl.edu
// http://www.genetics.wustl.edu/eddy/people/zmasek/


// Interface for Iterator


package forester.tree;


/**

@author Christian M. Zmasek

@version .90 last modified: 04/26/00


*/
interface Iterator {

    abstract public void first();

    abstract public void next();

    abstract public boolean isDone();

    abstract public Node currentNode();

}

