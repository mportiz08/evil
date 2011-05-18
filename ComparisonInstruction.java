import java.util.*;

public class ComparisonInstruction extends Instruction
{
  public Register src1;
  public Register src2;
  
  public ComparisonInstruction(String name, Register src1, Register src2)
  {
    super(name);
    this.src1 = src1;
    this.src2 = src2;
  }
  
  public String toString()
  {
    return new String(name + " " + src1 + ", " + src2);
  }
  
  public String toSparc()
  {
    String tempname = new String(name);
    if(name.equals("comp")){
      tempname = "cmp";
    }
    return new String(tempname + " " + src1.sparcName + ", " + src2.sparcName);
  }
  
  public ArrayList<Register> getSources(){
    ArrayList<Register> ret = new ArrayList<Register>();
    ret.add(src1);
    ret.add(src2);
    return ret;
  }
}
