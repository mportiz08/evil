import java.util.*;

public class NodeComparator implements Comparator<Node>
{
  public int compare(Node a, Node b)
  {
    return new RegisterComparator().compare(a.reg, b.reg);
  }
}
