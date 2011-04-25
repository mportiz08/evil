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
}
