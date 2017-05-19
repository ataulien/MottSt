import java.util.*;

public class Restaurant {

    //instance vars
    private int points;
    private int goal;
    private int level;
    ArrayList<Customer> clientList;

    //overloaded constructor
    public Restaurant(int levelNum) {
	level = levelNum;
	goal = level * 6;
	clientList = new ArrayList<Customer>();
	for (int i = 0; i < goal + 5; i++)
	    clientList.add(new Customer());
	points = 0;
    }

    //adds p points to the total points
    public void addPoints(int p) {
	points += p;
    }

    //returns true if there are still customers in clientList, false otherwise
    public boolean hasCust() {
	return clientList.size() != 0;
    }
    
    //creates a restaurant and a waiter,
    //and while there are still customers to serve, a waiter serves them
    public static void main(String[] args) {
	Restaurant pekingWong = new Restaurant(1);
	Waiter w = new Waiter();
        while (pekingWong.hasCust()) {
	}
    }

}