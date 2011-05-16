import java.util.*;

public class RegisterAllocator
{
  private ArrayList<FuncBlock> blocks;
  
  public RegisterAllocator(ArrayList<FuncBlock> blocks)
  {
    this.blocks = blocks;
  }
  
  public void color()
  {
    for(Block b : this.blocks)
    {
      localInfo(b);
      globalInfo(b);
      liveSet(b);
    }
  }
  
  private void localInfo(Block b)
  {
    for(Instruction i : b.instructions)
    {
      for(Register src : i.getSources())
      {
        if(!b.kill.contains(src))
        {
          b.gen.add(src);
        }
      }
      for(Register dest : i.getDests())
      {
        b.kill.add(dest);
      }
    }
  }
  
  private void globalInfo(Block b)
  {
    
  }
  
  private void liveSet(Block b)
  {
  
  }
  
  private void colorGraph(Block b)
  {
  
  }
}
