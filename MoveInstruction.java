import java.util.*;

public class MoveInstruction extends Instruction
{
  public Register src;
  public Register dest;
  
  public MoveInstruction(Register src, Register dest)
  {
    super("mov");
    this.src = src;
    this.dest = dest;
  }
  
  public String toSparc()
  {
    return new String(name + " " + src.sparcName + ", " + dest.sparcName);
  }
  
  public String toString()
  {
    return new String(name + " " + src + ", " + dest);
  }
  
  public ArrayList<Register> getSources(){
    ArrayList<Register> ret = new ArrayList<Register>();
    ret.add(src);
    return ret;
  }
  
  public ArrayList<Register> getDests(){
    ArrayList<Register> ret = new ArrayList<Register>();
    ret.add(dest);
    return ret;
  }
}
