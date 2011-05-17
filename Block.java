import java.util.*;

public class Block
{
  public static int counter = 0;
  
  public ArrayList<Instruction> instructions;
  public ArrayList<Block> successors;
  public ArrayList<Block> predecessors;
  public TreeSet<Register> gen;
  public TreeSet<Register> kill;
  public TreeSet<Register> liveOut;
  
  public String name;
  
  boolean visited;
  boolean genkill;

  public Block()
  {
    genkill = false;
    visited = false;
    //name = "exit";
    instructions = new ArrayList<Instruction>();
    successors = new ArrayList<Block>();
    predecessors = new ArrayList<Block>();
    RegisterComparator rc = new RegisterComparator();
    gen = new TreeSet<Register>(rc);
    kill = new TreeSet<Register>(rc);
    liveOut = new TreeSet<Register>(rc);
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
  
  public void createLocalInfo(){
    for(Instruction i : instructions)
    {
      for(Register src : i.getSources())
      {
        if(!kill.contains(src))
        {
          gen.add(src);
        }
      }
      for(Register dest : i.getDests())
      {
        kill.add(dest);
      }
    }
  }
  
  public boolean createGlobalInfo()
  {
    TreeSet<Register> ret = new TreeSet<Register>(new RegisterComparator());
    TreeSet<Register> liveoutm = new TreeSet<Register>(new RegisterComparator());
    for(Block b : successors){
      liveoutm = b.liveOut;
      liveoutm.removeAll(b.kill);
      liveoutm.addAll(b.gen);
      ret.addAll(liveoutm);
    }
    // TODO
    return ret.addAll(liveOut);
  }
}
