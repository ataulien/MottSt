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

public class Customer extends Draggable //implements Comparable<Customer>
{
  //Instance Variables
  private String name;
  private Table table;
  private int mood;
  private CustomerState state;
  int origX;
  int origY;
  float waitx;  
  float waity;   
  PImage waiting, sitting, attention, reading, paying;
  PImage smiley1, smiley2, smiley3, smiley4, smiley5, smiley6;
  int rand = (int) random(1,5);
  int tableNum = 1;
  Time wait;
  SoundFile gWaiting, gOrdering, gHungry, gReceipt;
  PFont fontFood = createFont("AFont.ttf", 20);

  //Constructor: populates order with random dishes
  public Customer()
  {
    super(80, 150);
    name = "BJB";
    state = CustomerState.WAITING;
    mood = 10;
    bx = 190;
    by = 210;
    origX = 190;
    origY = 210;

    wait = new Time();
    wait.startTime();
    wait.setGoal(100); //wait time

    waiting = loadImage("Images/Customers/Customer" + rand + "_stand.png");
    sitting = loadImage("Images/Customers/Customer" + rand + "_idle.png");
    attention = loadImage("Images/Customers/Customer" + rand + "_attention.png"); 
    reading = loadImage("Images/Customers/Customer" + rand + "_read.png");
    paying = loadImage("Images/Customers/Customer" + rand + "_pay.png");
    
    smiley1 = loadImage("Images/Smiley/smil1.png");
    smiley2 = loadImage("Images/Smiley/smil2.png");
    smiley3 = loadImage("Images/Smiley/smil3.png");
    smiley4 = loadImage("Images/Smiley/smil4.png");
    smiley5 = loadImage("Images/Smiley/smil5.png");
    smiley6 = loadImage("Images/Smiley/smil6.png");
    
    //Sounds male/female
    if (rand == 2 || rand == 3) {
      gWaiting = fWaiting;
      gOrdering = fOrdering;
      gHungry = fHungry;
      gReceipt = fReceipt;
    } else if (rand == 1 || rand == 4) {
      gWaiting = mWaiting;
      gOrdering = mOrdering;
      gHungry = mHungry;
      gReceipt = mReceipt;
    }
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
    if(state == CustomerState.READY_TO_PAY) {
      bx = table.x - 50;
      by = table.y - 50;
      image(paying, bx, by);
    }
    if(state == CustomerState.READY_TO_ORDER) {
      bx = table.x - 50;
      by = table.y - 50;
      image(attention, bx, by);
    }
    if(state == CustomerState.READING_MENU) {
      bx = table.x - 50;
      by = table.y - 50;
      image(reading, bx, by);
    }
    if (state == CustomerState.WAITING) {
      image(waiting, waitx, waity);
      displayMood(waitx,waity);
    } 
    if (state == CustomerState.STANDING_ON_SIDE || state == CustomerState.STANDING_ON_SIDE_ANGRY ||
        state == CustomerState.SITTING_ON_TABLE || state == CustomerState.SITTING_ON_TABLE_HUNGRY ||
        state == CustomerState.READY_TO_PAY || state == CustomerState.READING_MENU || state == CustomerState.READY_TO_ORDER) {
      displayMood(bx,by);
  }
}

  //Checks if the customer has been waiting a certain amount of time. 
  void update()
  {
    if (wait != null && state != CustomerState.HIDDEN) {
      mood = 10 - (int)(((float)wait.getElapsed() / wait.target) * 10);
      if (mood <= 0) {
        state = CustomerState.LEFT_RESTAURANT_ANGRY;
        fail.play();
        fail.amp(speechVol);
        fail.pan(tableNum);
      }
      if (wait.pause) {
        if (!wait.endInterval() && table.state == TableState.CUSTOMER_READING_MENU_OR_READY_TO_ORDER) {
          state = CustomerState.READING_MENU;
        }
        if (wait.endInterval() && table.state == TableState.CUSTOMER_READING_MENU_OR_READY_TO_ORDER) {
          wait.endPause();
          state = CustomerState.READY_TO_ORDER;
          //println("Table " + table.tableNum + " is ready to order.");
          gOrdering.play();
          gOrdering.amp(speechVol);
          gOrdering.pan(table.tableNum);
        } else {
          if (wait.endInterval() && table.state == TableState.CUSTOMER_WAITING_FOR_FOOD_OR_EATING) {
            //println("Table " + table.tableNum + " finished eating.");
            wait.endPause();
            table.order.state = OrderState.HIDDEN;
            table.state = TableState.CUSTOMER_READY_TO_PAY;
            state = CustomerState.READY_TO_PAY;
            gReceipt.play();
            gReceipt.amp(speechVol);
            gReceipt.pan(table.tableNum);
          }
        }
      }
    }
  }

  //If the customer not on a table, return to original x and y coordinates
  void checkState()
  {
    if (state == CustomerState.STANDING_ON_SIDE || state == CustomerState.STANDING_ON_SIDE_ANGRY) {
      if (locked) {
        bx = mouseScaledX-xOffset; 
        by = mouseScaledY-yOffset;
      } else {
        bx = origX; 
        by = origY;
      }
    }
  }
  
  void displayMood(float posx, float posy)
  {
    if (mood == 10) { 
      image(smiley1, posx + 30, posy - 25);
    }
    if (mood == 9 || mood == 8) { 
      image(smiley2, posx + 30, posy - 25);
    }
    if (mood == 7 || mood == 6) { 
      image(smiley3, posx + 30, posy - 25);
    }
    if (mood == 5 || mood == 4) { 
      if (state == CustomerState.SITTING_ON_TABLE) {
        gHungry.play();
        gHungry.amp(speechVol);
        gHungry.pan(table.tableNum);
        state = CustomerState.SITTING_ON_TABLE_HUNGRY;
      } 
      image(smiley4, posx + 30, posy - 25);
    }
    if (mood == 3 || mood == 2) {
      if (state == CustomerState.STANDING_ON_SIDE) {
        gWaiting.play();
        gWaiting.amp(speechVol);
        gWaiting.pan(tableNum);
        state = CustomerState.STANDING_ON_SIDE_ANGRY;
      }
      image(smiley5, posx + 30, posy - 25);
    }
    if (mood == 1) { 
      image(smiley6, posx + 30, posy - 25);
    } 
  }

  //two customers are equal if they are sitting at the same table
  public boolean equals(Customer c)
  {
    return this.getTable() == c.getTable();
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
