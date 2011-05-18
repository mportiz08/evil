import java.util.*;

public class Node
{
  public Register reg;
  private TreeSet<Node> edges;
  
  public Node(Register r)
  {
    reg = r;
    edges = new TreeSet<Node>();
  }
  
  public void addEdgeTo(Node n)
  {
    edges.add(n);
    n.addEdgeTo(this);
  }
}
