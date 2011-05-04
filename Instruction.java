public abstract class Instruction
{
  public String name;
  
  public Instruction(String name)
  {
    this.name = new String(name);
  }
  
  public String toSparc()
  {
    return new String();
  }
  
  // used to test instructions
  public static void main(String[] args)
  {
    System.out.println(new ArithmeticInstruction("add", new Register(), new Register(), new Register()).toSparc());
    System.out.println(new ComparisonInstruction("cmp", new Register(), new Register()).toSparc());
    System.out.println(new CallInstruction("foo", null).toSparc());
  }
}
