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
  
  public String toString()
  {
    return new String(name + " " + src + ", " + dest);
  }
}