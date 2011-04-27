import java.util.*;

public class NewInstruction extends Instruction
{
  public HashSet<String> fields;
  public Register reg;
  public String structname;
  
  public NewInstruction(String structname, HashSet<String> fields, Register reg)
  {
    super("new");
    this.structname = structname;
    this.fields = fields;
    this.reg = reg;
  }
  
  public String toString()
  {
    return new String(name + " " + structname + " " + fields + ", " + reg);
  }
}
