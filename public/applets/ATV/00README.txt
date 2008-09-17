FORESTER - a framework for phylogenomics
Version 1.92 (March 2002)
Copyright (C) 1999-2002 Washington University School of Medicine
and Howard Hughes Medical Institute
All rights reserved
----------------------------------------------------------------


o About this software.
  FORESTER is being developed as a framework for (automated) phylogenomics.
  
  Directly usable are:

  - SDI programs
    ------------
    Implement algorithms for Speciation - Duplication Inference.
    Manual: "SDI_manual.pdf" in directory "SDI_docs"
            http://www.genetics.wustl.edu/eddy/forester/SDI_manual.html


  - ATV
    ---
    A Tree Viewer to display large, anotated phylogenetic trees.
    Newer versions (greater than 1.7) of "ATVapp" include SDI
    functionality. 
    Documentation: "atv_documentation.pdf"
                   "atv_documentation.doc"     
                   http://www.genetics.wustl.edu/eddy/atv/


  - The FORESTER java programs are also part of RIO
    (phylogenomic protein function analysis using
     Resamlped Inference of Orthologs).


o This distribution contains five Java packages.
  
  1. "forester.tree" contains the basic datastructures
     for phylogenetic trees.
  2. "forester.tools" contains various algorithms (such
     as SDI = Speciation Duplication Inference) and tools.
     Requires Java 1.2 or greater.
  3. "forester.atv" contains classes to display trees in
     JApplets and applications (ATV = A Tree Viewer).
     Requires Java 1.1.x plus Swing, or Java 1.2 or greater
  4. "forester.atv_awt" contains classes to display trees
     in Applets and applications (ATV = A Tree Viewer).
     Requires Java 1.1.x or greater.  
  5. "forester.datastructures" contains additional
     datastructures.



o API specification for forester.
  http://www.genetics.wustl.edu/eddy/forester/forester_API_specification/
  Or point your browser to the file "index.html" in the
  directory "forester_API_specification" which is part of the
  distribution.


o Manual for SDI
  PDF: "SDI_manual.pdf" in directory "SDI_docs"
  WWW:  http://www.genetics.wustl.edu/eddy/forester/SDI_manual.html


o Documentation for ATV.
  PDF:     "atv_documentation.pdf"
  MS Word: "atv_documentation.doc"
  WWW:      http://www.genetics.wustl.edu/eddy/atv/


o Definition of NHX format.
  PDF: "NHX.pdf"
  WWW:  http://www.genetics.wustl.edu/eddy/forester/NHX.html


o Sample species trees (for SDI)
  
  Text files: "tree_of_life_bin_1-3.1.nhx"
              "tree_of_life_bin_1-4.nhx"
   


o Installing ATV (includes installation of FORESTER).
  See the file ATV_INSTALL.txt for instructions.


o Installing FORESTER.
  See the file FORESTER_INSTALL.txt for instructions.


o License for FORESTER.
  FORESTER is under the BSD license.
  See the file LICENSE.txt

  
o Getting FORESTER.
  ftp://ftp.genetics.wustl.edu/pub/eddy/software/
  http://www.genetics.wustl.edu/eddy/forester/


o References.
  ATV: Zmasek C.M. and Eddy S.R. (2001) ATV: display and manipulation of annotated
       phylogenetic trees.Bioinformatics, 17, 383-384.
  SDI: Zmasek C.M. and Eddy S.R. (2001) A simple algorithm to infer gene
       duplication and speciation events on a gene tree. Bioinformatics, in press.
  

o Reporting bugs, comments, suggestions, ...
  Please email me at: zmasek@genetics.wustl.edu
  Thanx!  



(last modified: 03/08/02)

Christian Zmasek

