import java.util.*;

public class NewInstruction extends Instruction
{
  public HashSet<String> fields;
  public Register reg;
  public String structname;
  public Register sparcRegister;
  
  public NewInstruction(String structname, HashSet<String> fields, Register reg)
  {
    super("new");
    this.structname = structname;
    this.fields = fields;
    this.reg = reg;
    sparcRegister = new Register();
  }
  
  public String toSparc(){
    return new String("mov " + fields.size()*4 + ", " + sparcRegister + "\n  " + "call malloc\n  nop\n  mov " + sparcRegister
       + ", " + reg);
  }
  
  public String toString()
  {
    return new String(name + " " + structname + " " + fields + ", " + reg);
  }
}
