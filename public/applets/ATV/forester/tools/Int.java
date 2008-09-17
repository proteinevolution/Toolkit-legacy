// Int.java
// A class to represent ints in HashMaps (in RIO).
//
// Copyright (C) 2000-2001 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved
//
// Created: 12/05/00
// Author: Christian M. Zmasek
// zmasek@genetics.wustl.edu
// http://www.genetics.wustl.edu/eddy/people/zmasek/

    
package forester.tools;



class Int {

    private int i_;

    Int() {
        i_ = 0;
    }

    Int( int i ) {
        i_ = i;
    }
    
    double doubleValue() { 
        return i_;
    }

    int intValue() { 
        return i_;
    }

    void increase() {
        i_++;
    }

    public String toString() {
        return Integer.toString( i_ );
    }

}
