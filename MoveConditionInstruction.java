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
    String tempname = new String(name);
    if(name.equals("movlt")){
      tempname = "movl";
    }
    else if(name.equals("movgt")){
      tempname = "movg";
    }
    //have to move immediate into a register!!
    return new String(tempname + " " + immediate + ", " + dest.sparcName);
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
