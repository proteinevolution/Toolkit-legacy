// BasketDataStructure.java
//
// Copyright (C) 1999-2001 Washington University School of Medicine
// and Howard Hughes Medical Institute
// All rights reserved
//
// Created: 2000
// Author: Christian M. Zmasek
// zmasek@genetics.wustl.edu
// http://www.genetics.wustl.edu/eddy/people/zmasek/
 



package forester.datastructures;



import java.io.*;


/**

An implementation of the "Basket" datastructure.
This datastructure is used in Eulenstein's algorithm for gene duplication
inference ("forester/tools/OE").
<p>
Reference:
Oliver Eulenstein (1998) Vorhersage von Genduplikationen und
deren Entwicklung in der Evolution. GMD Research Series, No 20/1998
GMD - Forschungszentrum Informationstechnik GmbH. - Sankt Augustin
(http://www.gmd.de/publications/research/1998/020/)

<p>
More information about FORESTER (including download) is available at: 
<A HREF ="http://www.genetics.wustl.edu/eddy/people/zmasek/forester/">
http://www.genetics.wustl.edu/eddy/people/zmasek/forester/
</A>
</p>

@author Christian M. Zmasek

@version 1.000 -- last modified: 10/12/00

*/
public class BasketDataStructure {

    
    /**

    Constructs a BasketDataStructure of size s.

    @param s initial size

    */
    public BasketDataStructure( int s ) {

         link = new int[ s ];
         rank = new int[ s ];
    }



    /**

    Creates a basket( s ), which is affiliated with the Node s
    of the species Tree and which contains the Node g of the gene Tree.
    (Corresponds to method makeSet of DisjointSet.)

    @param g a Node ID of the gene Tree 
    @param s a Node ID of the species Tree which will become 
             the representative of a basket

    */
    public void createBasket( int g, int s ) {

        link[ s ] = link[ g ] = s;
        rank[ s ] = rank[ g ] = DEFAULT_RANK;
  
    }


    
    /**

    Changes the affiliation of basket( s1 ) from s1 to s2.

    @param s1 a Node ID of the species Tree
              and representative of a existing basket( s1 )
    @param s2 a Node ID of the species Tree

    */
    public void moveBasket( int s1, int s2 ) {

        link[ s2 ] = link[ s1 ] = s2;

    }


     
    /**
    
    Adds the elements of basket( s1 ) to the elements of
    basket( s2 ) and deletes basket( s1 ).
    (Corresponds to method link of DisjointSet.)

    @param s1 a Node ID of the species Tree
              and representative of a existing basket( s1 )
    @param s2 a Node ID of the species Tree
              and representative of a existing basket( s2 )

    */
    public void mergeBasket( int s1, int s2  ) {
        
        link[ s1 ] = s2;

        if ( rank[ s1 ] == rank[ s2 ] ) {
            rank[ s2 ]++; 
        }    
  
    }
   


    /**
   
    Finds the basket containing the Node g of the gene Tree. 
    (Corresponds to method findSet of DisjointSet.)
  
    @param g a Node ID of the gene Tree

    @return the representative of the basket containing gene Tree node g

    */
    public int findBasket( int g ) {
        
        if ( link[ g ] == g ) {
            return g;
        }
        else {
            return link[ g ] = findBasket( link[ g ] );
        }

    }



    /**
    
    Inserts gene Tree Node g into basket( s ).

    @param g a Node ID of the gene Tree
    @param s a Node ID of the species Tree
             and representative of a existing basket( s1 )

    */
    public void insertIntoBasket( int g, int s ) {

        link[ g ] = s; 
  
    }



    /**

    Transfers this to a String.

    */
    public String toString() {
 
        String s = new String();

        for ( int i = 0; i < link.length; ++i ) {
            s += i + ":   ";
            s += "Link : " + link[ i ] + "    ";
            s += "Rank : " + rank[ i ] + "\n";
        }

        return s;
    }



    private int[] link;
            int[] rank;

    private final static int DEFAULT_RANK = 0;



} // End of class BasketDataStructure.
