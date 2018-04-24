//class Restaurant
import java.util.*;

public class Restaurant {

  //instance vars
  private Kitchen kitchen;
  private Time calcSpawn;
  ArrayList<Customer> waitList = new ArrayList<Customer>();
  ArrayList<Customer> serveList;
  Waiter BJB;

  // overloaded constructor
  public Restaurant(Waiter w) 
  {
    for (int i = 0; i < 5 ; i++)
    {
      waitList.add(new Customer());
    }
    kitchen = new Kitchen();
    serveList = new ArrayList<Customer>();
    BJB = w;
    calcSpawn = new Time();
    calcSpawn.startTime();
  }

  //Display Functions

  //Displays the kitchen and all the customers on the serveList
  void display()
  {
    kitchen.display();
    for (Customer d : serveList)
    {
     d.display(); //wofür?

    }
  }

  //Checks if another customer should be spawned
  void update()
  {
    if (shouldSpawn())
    {
      spawn();
    }
  }

  //spawns a new customer
  void spawn()
  {
    waitList.add(new Customer());
    //println("spawn");
    calcSpawn.startTime();
  }

  //Checks if the waiter has caused 5 or more customers to leave
  boolean strikeOut()
  {
    return BJB.getNumStrikes() >= 5;
  }

  //Checks if the time is right for there to be more customers
  boolean shouldSpawn()
  {
    if (calcSpawn.getElapsed() > 60/((int)(BJB.getNumPoints()/10)+2) && waitList.size() < 4) // vorher: calcSpawn.getElapsed() > 60/((int)(BJB.getNumPoints()/10)+2)
    { 
      return true;
    }
    return false;
  }
}
