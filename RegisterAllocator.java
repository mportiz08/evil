import java.util.*;

public class RegisterAllocator
{
  private ArrayList<FuncBlock> blocks;
  private TreeSet<Register> liveOut;
  
  public RegisterAllocator(ArrayList<FuncBlock> blocks)
  {
    this.blocks = blocks;
    this.liveOut = new TreeSet<Register>(new RegisterComparator());
  }
  
  public void color()
  {
    for(FuncBlock b : blocks)
    { 
      localInfo(b);
      while(globalInfo(b.exit,b.genkill));
    }
    //globalInfo(b);
    //liveSet(b);
  }
  
  private void localInfo(Block b)
  {
     if(!b.genkill)
     {
       b.createLocalInfo();
       /*System.out.println("GEN for " + b.name);
       System.out.println(b.gen);
       System.out.println("KILL for " + b.name);
       System.out.println(b.kill);*/
       b.genkill = true;
       for(Block bs : b.successors)
       {
         localInfo(bs);
       }
     }
  }
  
  private boolean globalInfo(Block b, boolean doworkson)
  {
     /*if(b.genkill == doworkson)
     {
       boolean change = b.createGlobalInfo();
       System.out.println("Liveout for " + b.name);
       System.out.println(b.liveOut);
       b.genkill = !doworkson;
       for(Block bs : b.predecessors)
       {
         change = change || globalInfo(bs, doworkson);
       }
       return change;
     }
     return false;*/
    
    boolean change = b.createGlobalInfo();
    System.out.println("Liveout for " + b.name);
    System.out.println(b.liveOut);
    for(Block bs : b.predecessors)
    {
      if(bs.genkill == doworkson){
        bs.genkill = !doworkson;
        change = change || globalInfo(bs, doworkson);
      }
    }
    return change;
  }
  
  private void liveSet(Block b)
  {
  
  }
  
  private void colorGraph(Block b)
  {
  
  }
}
