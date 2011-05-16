import java.util.ArrayList;
import java.util.HashSet;

public class Block
{
  public static int counter = 0;
  
  public ArrayList<Instruction> instructions;
  public ArrayList<Block> successors;
  public ArrayList<Block> predecessors;
  public HashSet<Register> gen;
  public HashSet<Register> kill;
  public HashSet<Register> liveOut;
  
  public String name;
  
  boolean visited;

  public Block()
  {
    visited = false;
    //name = "exit";
    instructions = new ArrayList<Instruction>();
    successors = new ArrayList<Block>();
    predecessors = new ArrayList<Block>();
    gen = new HashSet<Register>();
    kill = new HashSet<Register>();
    liveOut = new HashSet<Register>();
  }
  
  public void printTree(){
    System.out.println(name + ":" + subTreeString() + "\n");
    for(Block b : successors)
    {
      if(!b.visited){
        b.visited = true;
        b.printTree();
      }
    }
  }
  
  public String getInstructions(boolean sparc)
  {
    String rstring = "";
    rstring += name + ":\n";
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
  
  public String toString(){
    return name + ":" + subTreeString() + "\n";
    
  }
  
  private String subTreeString()
  {
    String str = "";
    for(Block b : successors)
    {
      str += (b.name + ", ");
    }
    //System.out.println("finished subtree");
    
    return str;
  }
}
