import java.util.*;

public class Kitchen {

    //instance vars
    private Deque<String> pendingFoodList; //this is a deque
    private Queue<String> finishedFoodList; //this is a queue

    //default constructor
    public Kitchen() 
	{
		pendingFoodList = new Deque<String>();
		finishedFoodList = new Queue<String>();
    }

    //removes the first item in pendingFoodList
    //and enqueues it to finishedFoodList
    public void makeFood() 
	{
		finishedFoodList.enqueue(pendingFoodList.removeFirst());
    }

    //adds order (e.g. small foods) to the front of pendingFoodList
    public void addFirstToPending(String order) 
	{
		pendingFoodList.addFirst(order);
    }

    //adds order (e.g. large foods) to the end of pendingFoodList
    public void addLastToPending(String order) 
	{
		pendingFoodList.addLast(order);
    }

    //removes first order from pendingFoodList when it is done
    public void removeFirstFromPending() 
	{
		pendingFoodList.removeFirst();
    }

    //returns true if pendingFoodList is empty, false otherwise
    public boolean pendingIsEmpty() 
	{
		return pendingFoodList.isEmpty();
    }

    //enqueues order to finishedFoodList when it is done
    public void enqueueFinished(String order) 
	{
		finishedFoodList.enqueue(order);
    }

    //dequeues first order from finishedFoodList when it is served
    public void dequeueFinished() 
	{
		finishedFoodList.dequeue();
    }

    //returns true if finishedFoodList is empty, false otherwise
    public boolean finishedIsEmpty() 
	{
		return finishedFoodList.isEmpty();
    }

    //returns the Stringified version of food lists
    public String toString() 
	{
		String retStr = "";
		retStr += "pending food: " + pendingFoodList.toString();
		retStr += "\n";
		retStr += "finished food: " + finishedFoodList.toString();
		retStr += "\n";
		return retStr;
    }

    public static void main(String[] args) 
	{
		Kitchen kitschKitch = new Kitchen();
		kitschKitch.addFirstToPending("soda");
		kitschKitch.addFirstToPending("water");
		kitschKitch.addLastToPending("chow mein");
		kitschKitch.addLastToPending("chow fun");
		kitschKitch.addLastToPending("lo mein");
		System.out.println(kitschKitch.toString());
		while (!kitschKitch.pendingIsEmpty()) 
		{
			kitschKitch.makeFood();
			System.out.println(kitschKitch.toString());
		}
	}

}