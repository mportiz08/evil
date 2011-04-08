public class EvilUtil
{
  public final static int FAIL = 1;
  
  public static void die(String msg)
  {
    System.err.println(msg);
    System.exit(FAIL);
  }
}
