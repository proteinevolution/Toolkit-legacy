// NameAndValues.java
// Helper class for RIO. For sorting of name - value combinations.
//
// Copyright (C) 2000-2002 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved
//
// Created: 11/28/00
// Author: Christian M. Zmasek
// zmasek@genetics.wustl.edu
// http://www.genetics.wustl.edu/eddy/people/zmasek/


package forester.tools;



/**

@author Christian M. Zmasek

@version 1.100 -- last modified: 10/06/01

*/
class NameAndValues implements Comparable {

    public static final int DEFAULT = -999;
  
    private String name_;
    private double value1_,
                   value2_,
                   value3_,
                   value4_;
    private int[]  p_;   // Since distance needs to be sorted in different
                         // direction than other values, and it is not
                         // known which value will be the distance. 


    NameAndValues( String name, double value1, double value2, double value3, double value4, int c ) {
        setSigns();
        name_   = name;
        value1_ = value1;
        value2_ = value2;
        value3_ = value3;
        value4_ = value4;
        if ( c >= 0 && c <= 3 ) {
            p_[ c ] = -1;
        }
    }
           
    

    NameAndValues( String name, double value1, double value2, double value3, int c ) {
        setSigns();
        name_   = name;
        value1_ = value1;
        value2_ = value2;
        value3_ = value3;
        value4_ = DEFAULT;
        if ( c >= 0 && c <= 2 ) {
            p_[ c ] = -1;
        }
    }

    NameAndValues( String name, double value1, double value2, int c ) {
        setSigns();
        name_   = name;
        value1_ = value1;
        value2_ = value2;
        value3_ = DEFAULT;
        value4_ = DEFAULT;
        if ( c >= 0 && c <= 1 ) {
            p_[ c ] = -1;
        }
    }

    NameAndValues( String name, double value1, int c ) {
        setSigns();
        name_   = name;
        value1_ = value1;
        value2_ = DEFAULT;
        value3_ = DEFAULT;
        value4_ = DEFAULT;
        if ( c == 0 ) {
            p_[ 0 ] = -1;
        }
    }

    NameAndValues( String name ) {
        setSigns();
        name_   = name;
        value1_ = DEFAULT;
        value2_ = DEFAULT;
        value3_ = DEFAULT;
        value4_ = DEFAULT;
    }
 
    NameAndValues() {
        setSigns();
        name_   = "";
        value1_ = DEFAULT;
        value2_ = DEFAULT;
        value3_ = DEFAULT;
        value4_ = DEFAULT;
    }

    


    public int compareTo( NameAndValues n ) {

        if ( this.getValue1() != DEFAULT && n.getValue1() != DEFAULT ) {
            if ( this.getValue1() < n.getValue1() ) {
                return p_[ 0 ];
            }
            if ( this.getValue1() > n.getValue1() ) {
                return ( -p_[ 0 ] );
            }
        }
        if ( this.getValue2() != DEFAULT && n.getValue2() != DEFAULT ) {
            if ( this.getValue2() < n.getValue2() ) {
                return p_[ 1 ];
            }
            if ( this.getValue2() > n.getValue2() ) {
                return ( -p_[ 1 ] );
            }
        }
        if ( this.getValue3() != DEFAULT && n.getValue3() != DEFAULT ) {
            if ( this.getValue3() < n.getValue3() ) {
                return p_[ 2 ];
            }
            if ( this.getValue3() > n.getValue3() ) {
                return ( -p_[ 2 ] );
            }
        }
        if ( this.getValue4() != DEFAULT && n.getValue4() != DEFAULT ) {
            if ( this.getValue4() < n.getValue4() ) {
                return p_[ 3 ];
            }
            if ( this.getValue4() > n.getValue4() ) {
                return ( -p_[ 3 ] );
            }
        }
        return ( this.getName().compareTo( n.getName() ) );
    }

    public int compareTo( Object o ) {
        return this.compareTo( ( NameAndValues ) o ); 
    }

    String getName() { 
        return name_;
    }

    double getValue1() { 
        return value1_;
    }

    double getValue2() { 
        return value2_;
    }

    double getValue3() { 
        return value3_;
    }

    double getValue4() { 
        return value4_;
    }

    private void setSigns() {
        p_ = new int[ 4 ];
        p_[ 0 ] = p_[ 1 ] = p_[ 2 ] = p_[ 3 ]= +1;
    }

}
