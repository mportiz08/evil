import java.util.*;

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
    System.out.println(new UnaryInstruction("del", new Register()).toSparc());
    String[] fieldset = {"blah1","blah2","blah3"};
    System.out.println(new NewInstruction("A", new HashSet<String>(Arrays.asList(fieldset)), new Register()).toSparc());
    System.out.println(new ArithmeticInstruction("add", new Register(), new Register(), new Register()).toSparc());
    System.out.println(new ComparisonInstruction("cmp", new Register(), new Register()).toSparc());
    System.out.println(new BranchInstruction("cbreq", "if", "if-else").toSparc());
    System.out.println(new CallInstruction("foo", null).toSparc());
  }
}
