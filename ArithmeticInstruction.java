public class ArithmeticInstruction extends Instruction
{
  public Register src1;
  public Register src2;
  public Register dest;
  
  public ArithmeticInstruction(String name, Register src1, Register src2, Register dest)
  {
    super(name);
    this.src1 = src1;
    this.src2 = src2;
    this.dest = dest;
  }
  
  public String toString()
  {
    return new String(name + " " + src1 + ", " + src2 + ", " + dest);
  }
}
