import java.util.*;

public class JumpInstruction extends Instruction
{
  public String lbl;
  
  public JumpInstruction(String lbl)
  {
    super("jumpi");
    this.lbl = lbl;
  }
  
  public String toSparc()
  {
    return new String("ba " + lbl + "\n  nop");
  }
  
  public String toString()
  {
    return new String(name + " " + lbl);
  }
}
