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
	
    //creates a restaurant and a waiter, and serves if there are still people waiting/to be served
	
    public static void main(String[] args) 
	{
		Restaurant pekingWong = new Restaurant(1);
		Waiter ling = new Waiter();
			while (pekingWong.hasCust()) 
			{
				//While there are still customers waiting
				while(pekingWong.waitList.size() != 0)
				{
				    pekingWong.prioritize();
					//Get the next customer
					Customer c = pekingWong.getWaitList().get(0);
					//assign customer to a table, if possible
					if (ling.assignTable(c))
					{
						//was possible to assign to table, add to waiter's customer list
						ling.addCustomer(c);
						//move the customer from the waitList to the serveList
						pekingWong.getServeList().add(pekingWong.getWaitList().remove(0));
					}
					//if not possible to assign to table, just leave the loop, no tables will open up until you serve
					else
					{
						break;
					}
				}
				
				//Serve dem customers
				//while there are still customers to be served
				while(pekingWong.getServeList().size() != 0)
				{
					//For every customer in the waiter's customer list
					for (int i = 0; i < ling.getCustomers().size(); i ++)
					{
						//Specify a customer
						Customer c = ling.getCustomers().get(i);
						//if the customer still has orders pending
						if (ling.getNextOrder(c) != null)
						{
							//serve the customer her/his next order
							ling.serve(c, ling.getNextOrder(c));
						}
						//no more orders? 
						else
						{
							//customer leaves, remove from both the waiter's customer list and serveList
							ling.removeCustomer(c);
							pekingWong.removeCustomer(c);
							//add 5 pts to score
							pekingWong.addPoints(5);
						}
					}
				}
			}
			System.out.println("Points: " + pekingWong.points);
    }

}