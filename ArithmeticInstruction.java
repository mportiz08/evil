public class ArithmeticInstruction extends Instruction
{
  public Register src1;
  public Register src2;
  public Register dest;
  public Register sparcRegister;
  
  public ArithmeticInstruction(String name, Register src1, Register src2, Register dest)
  {
    super(name);
    this.src1 = src1;
    this.src2 = src2;
    this.dest = dest;
    sparcRegister = new Register("%o0");
  }
  
  public String toString()
  {
    return new String(name + " " + src1 + ", " + src2 + ", " + dest);
  }
  
  public String toSparc()
  {
    if(name.equals("mult"))
    {
      return new String("mov " + src1.sparcName + ", " + "%o0\n  mov " + src2.sparcName + ", " + "%o1\n  call .mul\n  nop\n  mov %o0, " + dest.sparcName);
    }
    else if(name.equals("div"))
    {
      return new String("mov " + src1.sparcName + ", " + "%o0\n  mov " + src2.sparcName + ", " + "%o1\n  call .div\n  nop\n  mov %o0, " + dest.sparcName);
    }
    else
    {
      return new String(name + " " + src1.sparcName + ", " + src2.sparcName + ", " + dest.sparcName);
    }
  }
}
