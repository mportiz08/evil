import java.util.*;

public class MoveConditionInstruction extends Instruction
{
  public String immediate;
  public Register dest;
  
  public MoveConditionInstruction(String name, String immediate, Register dest)
  {
    super(name);
    this.immediate = immediate;
    this.dest = dest;
  }
  
  public String toSparc()
  {
    return new String(name + " " + immediate + ", " + dest.sparcName);
  }
  
  public String toString()
  {
    return new String(name + " " + immediate + ", " + dest);
  }
  
  public ArrayList<Register> getDests(){
    ArrayList<Register> ret = new ArrayList<Register>();
    ret.add(dest);
    return ret;
  }
}
