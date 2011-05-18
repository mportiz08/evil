import java.util.*;

public class InterferenceGraph
{
  public ArrayList<Node> nodes;
  
  public InterferenceGraph()
  {
    nodes = new ArrayList<Node>();
  }
  
  public void addNode(Node n)
  {
    nodes.add(n);
  }
  
  public Node nodeForRegister(Register r)
  {
    for(Node n : nodes)
    {
      if(n.reg.sparcEquals(r))
      {
        return n;
      }
    }
    System.out.println("couldn't find " + r + " yo");
    return null;
  }
}
