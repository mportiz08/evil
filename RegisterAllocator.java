import java.util.*;

public class RegisterAllocator
{
  private ArrayList<Block> blocks;
  
  public RegisterAllocator(ArrayList<Block> blocks)
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
