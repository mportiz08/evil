import java.util.ArrayList;

public class FuncBlock extends Block
{
  public ArrayList<String> locals;

  public FuncBlock()
  {
    super();
    locals = new ArrayList<String>();
  }
  
  public String getHeader(){
    String rstring = "";
    for(String a: locals){
      rstring += "@local " + name + ":" + a + "\n";
    }
    return rstring;
  }
}