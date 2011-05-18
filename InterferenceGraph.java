import java.util.*;

public class InterferenceGraph
{
  private ArrayList<Node> nodes;
  
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
      if(n.reg.equals(r))
      {
        return n;
      }
    }
    return null;
  }
}
