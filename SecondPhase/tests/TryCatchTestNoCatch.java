
public class TryCatchTestNoCatch {
	
    public static void main (String[] args) {
    	int a = 1, b = 5;
        int c = 0;
        Object o = new Object();
        o.toString();
        try {
        	Object b;
        	Object a = new Object();
        	b.toString();
        	System.out.println("No exceptions here");
        } finally {
        	System.out.println("Finlly is executed");
        }
        //System.out.println(a&&c);
    }
}
