import java.util.*;


public class Kitchen {

  //Instance Vars
  private ArrayDeque<Order> pendingFoodList; //this is a deque
  private ALQueue<Order> finishedFoodList; //this is a queue
  private Order[] stovetops;
  Order currentOrder;
  int x;
  int y;
  PImage[] images;

  //default constructor
  public Kitchen() 
  {
    images = new PImage[2];
    images[0] = loadImage("Images/luckycat1.gif");
    images[1] = loadImage("Images/luckycat2.gif");
    pendingFoodList = new ArrayDeque<Order>();
    finishedFoodList = new ALQueue<Order>();
    stovetops = new Order[3];
    x = 510;
    y = 180;
  }

  //Displays the Kitchen and the current order on the counter
  void display()
  {
    noStroke();
    //fill(0);
    fill(20, 20, 150, 0);
    rect(500, 200, 300, 50);
    image(images[0], x, y);
    if (!finishedFoodList.isEmpty())
    {
      if (currentOrder == null) {
        currentOrder = finishedFoodList.dequeue();
      }
    }
    if (currentOrder != null) {
      if (currentOrder.table.sittingCustomer != null)
        currentOrder.display();
      else
        currentOrder = null;
    }
    makeFood();
  }

  //Checks if the mouse clicked over the kitchen
  boolean isMouseOverKitchen() {
    if (mouseX >= x && mouseX <= x+300 && 
      mouseY >= y && mouseY <= y+50) {
      //println("kitch");
      return true;
    } else {
      return false;
    }
  }

  //Mechanics

  //Checks if there are any openings on the stove
  public boolean hasStoveSpace()
  {
    return stovetops[0] == null || stovetops[1] == null || stovetops[2] == null;
  }

  //Places the food item on the stove to cook :)
  public void putOnStove(Order o)
  {
    if (stovetops[0] == null)
    {
      stovetops[0] = o;
    } else if (stovetops[1] == null)
    {
      stovetops[1] = o;
    } else if (stovetops[2] == null)
    {
      stovetops[2] = o;
    }
    o.t.startTime();
  }

  //removes items in pendingFoodList and cooks them on open stovetops
  public void makeFood() 
  {
    if (!pendingFoodList.isEmpty())
    {
      Order o = pendingFoodList.removeFirst();
      if (o != null && hasStoveSpace())
      {
        while (o != null && hasStoveSpace())
        {
          //println("placed on stove");
          putOnStove(o);
          if (!pendingFoodList.isEmpty() && hasStoveSpace())
          {
            o = pendingFoodList.removeFirst();
          }
        }
      } else
      {
        pendingFoodList.addFirst(o);
        o = null;
      }
    }
    for (int i = 0; i < 3; i ++)
    {
      Order ord = stovetops[i];
      if (ord != null)
      {
        if (ord.t.atGoal())
        {
          enqueueFinished(ord);
          stovetops[i] = null;
        }
      }
    }
  }

  //returns the pendingFoodList
  public ArrayDeque getPending() 
  {
    return pendingFoodList;
  }

  //returns the finishedFoodList
  public ALQueue getFinished() 
  {
    return finishedFoodList;
  }

  //adds order (e.g. small foods) to the front of pendingFoodList
  public void addFirstToPending(Order order) 
  {
    pendingFoodList.addFirst(order);
  }

  //adds order (e.g. large foods) to the end of pendingFoodList
  public void addLastToPending(Order order) 
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
  public void enqueueFinished(Order order) 
  {
    finishedFoodList.enqueue(order);
  }

  //dequeues first order from finishedFoodList when it is served
  public Order dequeueFinished() 
  {
    return finishedFoodList.dequeue();
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
}
