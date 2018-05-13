
import java.util.ArrayList;

public enum CustomerState
{
  HIDDEN, // Doesn't seem to be set anywhere (was state -1 before)
    STANDING_ON_SIDE, 
    STANDING_ON_SIDE_ANGRY, 
    SITTING_ON_TABLE, 
    SITTING_ON_TABLE_HUNGRY, 
    LEFT_RESTAURANT_ANGRY,
    WAITING,
    READING_MENU,
    READY_TO_ORDER,
    READY_TO_PAY,
}

public class Customer extends Draggable implements Comparable<Customer>
{

  //Instance Variables
  private String name;
  private Table table;
  private int VIPNum;
  private int mood;
  private CustomerState state;
  int origX;
  int origY;
  float waitx;  
  float waity;   
  PImage waiting, sitting, attention, reading, paying;
  PImage heart1, heart2, heart3, heart4, heart5, heart6;
  int rand = (int) random(1,5);
  Time wait;
  PFont fontFood = createFont("AFont.ttf", 20);

  //Constructor: populates order with random dishes
  public Customer()
  {
    super(80, 150);
    name = "BJB";
    VIPNum = (int) (Math.random() * 10) + 1;
    state = CustomerState.WAITING;
    mood = 10;
    bx = 190;
    by = 210;
    origX = 190;
    origY = 210;

    wait = new Time();
    wait.startTime();
    //wait time is lower for customers of higher priority (lower VIPNum)
    wait.setGoal(getVIPNum() * 20);

    waiting = loadImage("Images/Customers/Customer" + rand + "_stand.png");
    sitting = loadImage("Images/Customers/Customer" + rand + "_idle.png");
    attention = loadImage("Images/Customers/Customer" + rand + "_attention.png"); 
    reading = loadImage("Images/Customers/Customer" + rand + "_read.png");
    paying = loadImage("Images/Customers/Customer" + rand + "_pay.png");
    
    heart1 = loadImage("Images/Mood_Hearts/heartState1.png");
    heart2 = loadImage("Images/Mood_Hearts/heartState2.png");
    heart3 = loadImage("Images/Mood_Hearts/heartState3.png");
    heart4 = loadImage("Images/Mood_Hearts/heartState4.png");
    heart5 = loadImage("Images/Mood_Hearts/heartState5.png");
    heart6 = loadImage("Images/Mood_Hearts/heartState6.png");
  }

  /********
   * Displays the customer based on her/his state
   * state = 0: waiting for table
   * state = 1: on the table
   ********/
  void display()
  {
    update();
    if (state == CustomerState.STANDING_ON_SIDE) {
      super.display();
      image(waiting, bx, by);
    }
    if (state == CustomerState.STANDING_ON_SIDE_ANGRY) {
      super.display();
      image(waiting, bx, by);
    }
    if (state == CustomerState.SITTING_ON_TABLE) {
      bx = table.x - 50;
      by = table.y-50;
      image(sitting, bx, by);
    }
    if (state == CustomerState.SITTING_ON_TABLE_HUNGRY) {
      bx = table.x - 50;
      by = table.y-50;
      image(sitting, bx, by);
    }
    if(state == CustomerState.READY_TO_PAY){
      bx = table.x - 50;
      by = table.y - 50;
      image(paying, bx, by);
    }
    if(state == CustomerState.READY_TO_ORDER){
      bx = table.x - 50;
      by = table.y - 50;
      image(attention, bx, by);
    }
    if(state == CustomerState.READING_MENU){
      bx = table.x - 50;
      by = table.y - 50;
      image(reading, bx, by);
    }
    if (state == CustomerState.WAITING) {
      image(waiting, waitx, waity);
      displayMood(waitx,waity);
    } 
    if (state == CustomerState.STANDING_ON_SIDE || state == CustomerState.STANDING_ON_SIDE_ANGRY || state == CustomerState.SITTING_ON_TABLE || state == CustomerState.SITTING_ON_TABLE_HUNGRY || state == CustomerState.READY_TO_PAY || state == CustomerState.READING_MENU || state == CustomerState.READY_TO_ORDER) {
      displayMood(bx,by);
  }
}

  //Checks if the customer has been waiting a certain amount of time. 
  void update()
  {
    if (wait != null && state != CustomerState.HIDDEN)
    {
      mood = 10 - (int)(((float)wait.getElapsed()/wait.target) * 10);
      if (mood <= 0)
      {
        state = CustomerState.LEFT_RESTAURANT_ANGRY;
      }
      if (wait.pause)
      {
        if (!wait.endInterval() && table.state == TableState.CUSTOMER_READING_MENU_OR_READY_TO_ORDER)
        {
          state = CustomerState.READING_MENU;
        }
        if (wait.endInterval() && table.state == TableState.CUSTOMER_READING_MENU_OR_READY_TO_ORDER)
        {
          wait.endPause();
          state = CustomerState.READY_TO_ORDER;
          //println("Table " + table.tableNum + " is ready to order.");
          cOrdering.play();
          cOrdering.amp(speechVol);
          cOrdering.pan(table.tableNum);
        } else {
          if (wait.endInterval() && table.state == TableState.CUSTOMER_WAITING_FOR_FOOD_OR_EATING)
          {
            //println("Table " + table.tableNum + " finished eating.");
            wait.endPause();
            table.order.state = OrderState.HIDDEN;
            table.state = TableState.CUSTOMER_READY_TO_PAY;
            state = CustomerState.READY_TO_PAY;
            cReceipt.play();
            cReceipt.amp(speechVol);
            cReceipt.pan(table.tableNum);
          }
        }
      }
    }
  }

  //If the customer not on a table, return to original x and y coordinates
  void checkState()
  {
    if (state == CustomerState.STANDING_ON_SIDE || state == CustomerState.STANDING_ON_SIDE_ANGRY)
    {
      if (locked) 
      {
        bx = mouseScaledX-xOffset; 
        by = mouseScaledY-yOffset;
      } else
      {
        bx = origX; 
        by = origY;
      }
    }
  }
  
  void displayMood(float posx, float posy){
  
    if(mood == 10){ 
      image(heart1, posx+15, posy-30); }
    if(mood == 9 || mood == 8){ 
      image(heart2, posx+15, posy-30); }
    if(mood == 7 || mood == 6){ 
      image(heart3, posx+15, posy-30); }
    if(mood == 5 || mood == 4){ 
      if (state == CustomerState.SITTING_ON_TABLE) {
        cHungry.play();
        cHungry.amp(speechVol);
        cHungry.pan(table.tableNum);
        state = CustomerState.SITTING_ON_TABLE_HUNGRY;
      } 
      image(heart4, posx+15, posy-30); }
    if(mood == 3 || mood == 2){
      if (state == CustomerState.STANDING_ON_SIDE) {
        int tableNum = 1;
        cWaiting.play();
        cWaiting.amp(speechVol);
        cWaiting.pan(tableNum);
        state = CustomerState.STANDING_ON_SIDE_ANGRY;
      }
      image(heart5, posx+15, posy-30); }
    if(mood == 1){ 
      image(heart6, posx+10, posy-30); } 
  }

  //two customers are equal if they are sitting at the same table
  public boolean equals(Customer c)
  {
    return this.getTable() == c.getTable();
  }

  //compares the VIPNums of two customers
  public int compareTo(Customer other)
  {
    if (this.VIPNum < other.VIPNum) {
      return -1;
    } else if (this.VIPNum > other.VIPNum) {
      return 1;
    }
    return 0;
  }

  //Mutators

  //sets the table for the customer
  public void setTable(Table t)
  {
    table = t;
  }

  //sets the state of the customer
  public void setState(CustomerState state)
  {
    this.state = state;
  }

  //Accessor

  //returns table number
  public Table getTable()
  {
    return table;
  }

  //returns VIP number
  public int getVIPNum() 
  {
    return VIPNum;
  }

  //returns mood
  public int getMood()
  {
    return mood;
  }

  //returns name
  public String getName()
  {
    return name;
  }
  
  public void setPosition(float posx, float posy) 
  { 
    waitx = posx;
    waity = posy;
  }
}
