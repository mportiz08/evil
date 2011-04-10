import java.io.*;
import org.antlr.runtime.*;
import org.antlr.runtime.debug.DebugEventSocketProxy;


public class __Test__ {

    public static void main(String args[]) throws Exception {
        EvilLexer lex = new EvilLexer(new ANTLRFileStream("/home/jdgood/csc431/evil/bool.ev", "UTF8"));
        CommonTokenStream tokens = new CommonTokenStream(lex);

        EvilParser g = new EvilParser(tokens, 49100, null);
        try {
            g.program();
        } catch (RecognitionException e) {
            e.printStackTrace();
        }
    }
}