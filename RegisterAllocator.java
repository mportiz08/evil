import java.util.*;

public class RegisterAllocator
{
  private ArrayList<FuncBlock> blocks;
  //private TreeSet<Register> liveOut;
  
  
  public RegisterAllocator(ArrayList<FuncBlock> blocks)
  {
    this.blocks = blocks;
    //this.liveOut = new TreeSet<Register>(new RegisterComparator());
  }
  
  public void color()
  {
    for(FuncBlock b : blocks)
    { 
      localInfo(b);
      while(globalInfo(b.exit,b.genkill));
      InterferenceGraph ig = new InterferenceGraph();
      populateNodes(b, b.genkill, ig);
      // debug
      System.out.println("Graph Nodes ~~> " + b.name);
      for(Node n : ig.nodes)
        System.out.println(n.reg.sparcName);
      
      interGraph(b, b.genkill, ig);
      colorGraph(b, ig);
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
  
  private void populateNodes(Block b, boolean genkill, InterferenceGraph ig)
  {
    b.addAllNodes(ig);
    for(Block bs : b.successors)
    {
      if(bs.genkill == genkill) {
        bs.genkill = !genkill;
        populateNodes(bs, genkill, ig);
      }
    }
  }
  
  private void interGraph(Block b, boolean genkill, InterferenceGraph ig)
  {
    b.createInterGraph(ig);
    for(Block bs : b.successors)
    {
      if(bs.genkill == genkill) {
        bs.genkill = !genkill;
        interGraph(bs, genkill, ig);
      }
    }
  }
  
  private void colorGraph(Block b, InterferenceGraph ig)
  {
    Stack<Node> nstack = new Stack<Node>();
    // destruct graph
    while(!ig.nodes.isEmpty())
    {
      Node selected = ig.nodes.get(0);
      selected.removeEdges();
      ig.nodes.remove(selected);
      nstack.push(selected);
    }
    // reconstruct graph
    
  }
}
