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
    for(Block b : blocks)
    { 
      localInfo(b);
      globalInfo(b);
    }
    //globalInfo(b);
    //liveSet(b);
  }
  
  private void localInfo(Block b)
  {
     if(!b.genkill)
     {
       b.createLocalInfo();
       System.out.println("GEN for " + b.name);
       System.out.println(b.gen);
       System.out.println("KILL for " + b.name);
       System.out.println(b.kill);
       b.genkill = true;
       for(Block bs : b.successors)
       {
         localInfo(bs);
       }
     }
  }
  
  private void globalInfo(Block b)
  {
    if(b.genkill)
     {
       b.createGlobalInfo();
       System.out.println("GEN for " + b.name);
       System.out.println(b.gen);
       System.out.println("KILL for " + b.name);
       System.out.println(b.kill);
       b.genkill = false;
       for(Block bs : b.successors)
       {
         localInfo(bs);
       }
     } 
  }
  
  private void liveSet(Block b)
  {
  
  }
  
  private void colorGraph(Block b)
  {
  
  }
}
