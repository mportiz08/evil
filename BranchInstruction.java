import java.util.*;

public class BranchInstruction extends Instruction
{
  public String lbl1;
  public String lbl2;
  
  public BranchInstruction(String name, String lbl1, String lbl2)
  {
    super(name);
    this.lbl1 = lbl1;
    this.lbl2 = lbl2;
  }
  
  public String toString()
  {
    return new String(name + " " + lbl1 + ", " + lbl2);
  }
  
  public String toSparc()
  {
    if(name.equals("cbreq"))
    {
      return new String("be" + " " + lbl1 + "\n  nop\n  bne " + lbl2 + "\n  nop");
    }
    else
    {
      return new String(name + " " + lbl1);
    }
  }
}
