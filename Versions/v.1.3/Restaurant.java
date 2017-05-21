import java.util.*;

public class Restaurant {

    //instance vars
    private int points;
    private int goal;
    private int level;
    ArrayList<Customer> waitList;
    ALHeap waitListVIP;
    ArrayList<Customer> serveList;

    //overloaded constructor
    public Restaurant(int levelNum) 
	{
		level = levelNum;
		goal = level * 6;
		waitList = new ArrayList<Customer>();
		for (int i = 0; i < goal + 5; i++)
		{
			waitList.add(new Customer());
		}
		waitListVIP = new ALHeap();
		for (int i = 0; i < waitList.size(); i++) {
		    waitListVIP.add(waitList.get(i).getVIPNum());
		}
		serveList = new ArrayList<Customer>();
		points = 0;
    }

    //sorts waitList where highest priority customers are first
    public void prioritize() {
	ArrayList<Customer> tempWaitList = waitList;
	for (int i = 0; i < waitList.size(); i++) {
	    for (int n = 0; n < waitList.size(); n++) {
		if (tempWaitList.get(i).getVIPNum() == waitListVIP.peekMin()) {
		    waitList.set(n,tempWaitList.get(i));
		    waitListVIP.removeMin();
		}
	    }
	}
    }
	
	//removes the customer c from serveList
    public void removeCustomer(Customer c) 
	{
		for (int i = 0; i < serveList.size(); i++) 
		{
			if (serveList.get(i).equals(c))
			{
				serveList.remove(i);
			}
		}
    }
	
	//adds p points to the total points
    public void addPoints(int p) 
	{
		points += p;
    }

    //returns true if there are still customers in clientList, false otherwise
    public boolean hasCust() 
	{
		return serveList.size() != 0 || waitList.size() != 0;
    }
	
	//Accessors
	
	//return wait list
	public ArrayList<Customer> getWaitList()
	{
		return waitList;
	}
    
	//return serving list
	public ArrayList<Customer> getServeList()
	{
		return serveList;
	}
	
	public int getPoints()
	{
		return points;
	}
}
