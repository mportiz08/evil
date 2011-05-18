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
  public TreeSet<Register> liveSet;
  
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
    liveSet = new TreeSet<Register>(rc);
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
  
  public void printTreeReverse(){
    System.out.println(name + ":" + subTreeStringReverse() + "\n");
    for(Block b : predecessors)
    {
      if(!b.visited){
        b.visited = true;
        b.printTreeReverse();
      }
    }
  }
  
  private String subTreeStringReverse()
  {
    String str = "";
    for(Block b : predecessors)
    {
      str += (b.name + ", ");
    }
    //System.out.println("finished subtree");
    
    return str;
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
      liveoutm = new TreeSet<Register>(new RegisterComparator());
      liveoutm.addAll(b.liveOut);
      liveoutm.removeAll(b.kill);
      liveoutm.addAll(b.gen);
      ret.addAll(liveoutm);
    }
    return liveOut.addAll(ret);
  }
  
  public void createLiveSet(InterferenceGraph ig)
  {
    // create nodes
    TreeSet<Register> allregs = getAllRegs();
    for(Register r : allregs)
    {
      ig.addNode(new Node(r));
    }
    
    for(int i = instructions.size() - 1; i >= 0; i--)
    {
      for(Register dest : instructions.get(i).getDests())
      {
        liveSet.remove(dest);
        Node destnode = ig.nodeForRegister(dest);
        for(Register r : liveSet)
        {
          destnode.addEdgeTo(ig.nodeForRegister(r));
        }
      }
    }
  }
  
  private TreeSet<Register> getAllRegs()
  {
    TreeSet<Register> allregs = new TreeSet<Register>(new RegisterComparator());
    for(Instruction i : instructions)
    {
      allregs.addAll(i.getSources());
      allregs.addAll(i.getDests());
    }
    return allregs;
  }
}
