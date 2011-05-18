import java.util.*;

public class Node
{
  public Register reg;
  public TreeSet<Node> edges;
  
  public Node(Register r)
  {
    reg = r;
    edges = new TreeSet<Node>(new NodeComparator());
  }
  
  public void addEdgeTo(Node n)
  {
    edges.add(n);
    n.edges.add(this);
  }
  
  public void removeEdges()
  {
    for(Node n : edges)
    {
      removeEdgeFrom(n);
    }
  }
  
  private void removeEdgeFrom(Node n)
  {
    n.edges.remove(this);
  }
}
