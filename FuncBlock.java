import java.util.ArrayList;

public class FuncBlock extends Block
{
  public ArrayList<String> locals;
  public int stackSize;

  public FuncBlock()
  {
    super();
    locals = new ArrayList<String>();
    stackSize = 24;
  }
  
  public String getInstructions(boolean sparc)
  {
    String rstring = "";
    if(sparc){
       rstring += name + ":\n  !#PROLOGUE# 0\n  save %sp, -" + stackSize + ", %sp\n  !#PROLOGUE# 1\n";
    }
    else{
       rstring += name + ":\n";
    }
    for(Instruction i : instructions)
    {
      String inststr;
      inststr = (sparc ? i.toSparc() : i.toString());
      rstring += "  " + inststr + "\n";
    }
    for(Block b : successors)
    {
      if(!b.visited){
        b.visited = true;
        rstring += b.getInstructions(sparc);
      }
    }
    return rstring;
  }
  
  public String getHeader(boolean sparc){
    String rstring = "";
    for(String a: locals){
      if(!sparc) {
        rstring += "@local " + name + ":" + a + "\n";
      }
    }
    return rstring;
  }
}