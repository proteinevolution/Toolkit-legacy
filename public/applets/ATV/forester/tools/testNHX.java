package forester.tools;
import forester.tree.*;
import java.io.*;

public class testNHX {

    public static void main( String[] args ) {
        Tree t = null;
        try {
            t = TreeHelper.readNHtree( new File( args[ 0 ] ) );
        }
        catch ( Exception e ) {
            System.exit( -1 );
        } 
        if ( t == null || !t.isRooted() || !t.isCompletelyBinary() ) {
            System.exit( -1 );
        }
        System.exit( 0 );
    }
}
