import java.util.*;

public class Node
{
  public Register reg;
  public TreeSet<Node> edges;
  
  /*private class NodeComparator<Node> implements Comparator<Node>
  {
    public int compare(Node a, Node b)
    {
      return new RegisterComparator().compare(a.reg, b.reg);
    }
  }*/
  
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
    while(!edges.isEmpty())
    {
      removeEdgeFrom(edges.last());
    }
  }
  
  private void removeEdgeFrom(Node n)
  {
    n.edges.remove(this);
    edges.remove(n);
  }
}
