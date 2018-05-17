import java.util.ArrayList;

public enum WaiterState
{
  IDLE, 
    MOVING_TO_PICK_UP_ORDER, 
    MOVING_TO_PLACE_ORDER, 
    MOVING_TO_TABLE,
}

public class Waiter 
{
  //instance vars
  private ArrayList<Customer> customers = new ArrayList<Customer>();
  private ArrayList<Table> tables = new ArrayList<Table>();
  ;
  private ArrayList<Order> orders = new ArrayList<Order>();
  private Order[] finishedOrders = new Order[2];
  PVector position = new PVector();

  private Table currentTable;

  Kitchen kitchen;

  boolean isMoving;
  WaiterState state;
  PImage imageWaiterNoFood;
  PImage imageWaiterOneFood;
  PImage imageWaiterTwoFood;
  PFont fontScore = createFont("AFont.ttf", 20);

  private int strikes;
  private int points;
  
  private int orderNumberTextSize = 16;
  private float orderNumberYOffset = 40f;
  
  private float orderNumberXOffsetRight = 90f;
  private float orderNumberXOffsetLeft = -15f;

  public Waiter(Kitchen kitchen) 
  {
    this.kitchen = kitchen;

    //creates six tables
    if (Level.numTables >= 1)
        tables.add(new Table(1, 400, 400));

    if (Level.numTables >= 2)
        tables.add(new Table(2, 656, 400));

    if (Level.numTables >= 3)
        tables.add(new Table(3, 913, 400));

    if (Level.numTables >= 4)
        tables.add(new Table(4, 400, 600));

    if (Level.numTables >= 5)
        tables.add(new Table(5, 656, 600));

    if (Level.numTables >= 6)
        tables.add(new Table(6, 912, 600));

    position.x = 300;
    position.y = 200;

    isMoving = false;
    state = WaiterState.IDLE;
    imageWaiterNoFood = loadImage("Images/WaiterNoFood.png");
    imageWaiterOneFood = loadImage("Images/WaiterOneFood.png");
    imageWaiterTwoFood = loadImage("Images/WaiterTwoFood.png");
  }

  void display()
  {
    drawTables();
    drawCustomers();
    drawWaiter();
  }
  
  public void displayUI()
  {
    drawScoreAndStrikes();
  }

  private void drawTables() {
    for (Table t : tables) {
      t.display();
    }
  }

  private void drawCustomers() {
    for (Customer c : customers) {
      c.display();
    }
  }

  private void drawWaiter() {
    pushStyle();
    textSize(orderNumberTextSize);
    
    if(getNumDishes() == 0)
      image(imageWaiterNoFood, position.x, position.y);
    else if(getNumDishes() == 1)
    {
      image(imageWaiterOneFood, position.x, position.y);
      Order finishedOrder;
      
      if(finishedOrders[0] == null)
        finishedOrder = finishedOrders[1];
      else
        finishedOrder = finishedOrders[0];
    
      text(finishedOrder.table.tableNum, position.x + orderNumberXOffsetRight, position.y + orderNumberYOffset);
    }
    else
    {
      image(imageWaiterTwoFood, position.x, position.y);
      
      text(finishedOrders[0].table.tableNum, position.x + orderNumberXOffsetRight, position.y + orderNumberYOffset);
      text(finishedOrders[1].table.tableNum, position.x - orderNumberXOffsetLeft, position.y + orderNumberYOffset);
    }
    
    popStyle();
  }

  private void drawScoreAndStrikes() {
    pushStyle();
    fill(255);
    textSize(20);
    textFont(fontScore);
    text("POINTS: " + points, 5, 75);
    text("STRIKES: " + strikes + "/5", 5, 125);
    popStyle();
  }

  void onMouseClicked()
  {
    if (kitchen.isMouseOverKitchen())
    {
      onClickedOnKitchen();
    } else {
      for (Table t : tables) {
        if (t.isMouseOverTable()) {
          onClickedOnTable(t);
          break;
        }
      }
    }
  }

  private void onClickedOnKitchen() {
    if (kitchen.currentOrder != null && kitchen.currentOrder.isMouseOverOrder()) {
      state = WaiterState.MOVING_TO_PICK_UP_ORDER;
    } else {
      state = WaiterState.MOVING_TO_PLACE_ORDER;
    }
  }

  private void onClickedOnTable(Table t) {
    if (t.state != TableState.EMPTY) {
      state = WaiterState.MOVING_TO_TABLE;
      currentTable = t;
    }
  }

  /**
   * Called every mainloop-cycle
   */
  public void frameUpdate() {
    checkForStrikesAndRemoveCustomers();
  }

  private void checkForStrikesAndRemoveCustomers() {
    ArrayList<Customer> toRemove = new ArrayList<Customer>();

    for (Customer c : customers) {
      if (c.state == CustomerState.LEFT_RESTAURANT_ANGRY) {
        toRemove.add(c);
      }
    }

    for (Customer c : toRemove) {
      Table t = c.getTable();

      removeCustomer(t.sittingCustomer);
      strikes ++;
      t.sittingCustomer = null;

      t.state = TableState.EMPTY;
      for(int i = 0; i<finishedOrders.length ; i++)
        if(finishedOrders[i] != null && finishedOrders[i].equals(t.order))
          finishedOrders[i] = null;  

      t.order = null;
    }
  }

  //Moves to the specified coordinates
  void moveToStateTarget()
  {
    switch(state)
    {
    case MOVING_TO_PICK_UP_ORDER:
      goTo(kitchen.x+250, kitchen.y);
      break;

    case MOVING_TO_PLACE_ORDER:
      goTo(kitchen.x-15, kitchen.y);
      break;

    case MOVING_TO_TABLE:
      goTo(currentTable.x+105, currentTable.y-15);
      break;
    }

    delay(10);
  }

  //Goes to the target X and Y coordinates by incrementing by 10 each time the function is invoked if the waiter is not yet at those coordinates.
  void goTo(int targetX, int targetY) {
    if (position.x < targetX) {
      if (position.x + 8 > targetX) {
        position.x = targetX;
        return;
      }
      position.x+=8;
    } else if (position.x > targetX) {
      position.x-=8;
    } else {
      if (position.y < targetY) {
        if (position.y + 8 > targetY) {
          position.y = targetY;
          return;
        }
        position.y+=8;
      } else if (position.y > targetY) {
        position.y-=8;
      } else {
        isMoving = false;
        onReachedTargetPosition();
      }
    }
  }

  void onReachedTargetPosition() {
    performAction();
  }

  void performAction()
  {
    switch(state)
    {
    case MOVING_TO_PICK_UP_ORDER:
      if (kitchen.currentOrder.getTable().sittingCustomer == null)
      {
        //println("The customer has already left...");
        kitchen.currentOrder.getTable().order = null;
        kitchen.currentOrder = null;
        return;
      }
      if (finishedOrders[0] == null) {
        finishedOrders[0] = kitchen.currentOrder;
        kitchen.currentOrder = null;
      } 
      if (finishedOrders[1] == null) {
        finishedOrders[1] = kitchen.currentOrder;
        kitchen.currentOrder = null;
      }
      break;

    case MOVING_TO_PLACE_ORDER:
      if (orders.size() > 0)
      {
        for(Order o : orders) {
          kitchen.addLastToPending(o);
        }
        
        orders.clear();
      }
      break;

    case MOVING_TO_TABLE:
      performActionOnTable(currentTable);
      break;
    }

    state = WaiterState.IDLE;
  }

  /**
   * Performs the next action depending on the given tables state
   */
  void performActionOnTable(Table t)
  {    
    switch(t.state)
    {
    case CUSTOMER_READING_MENU_OR_READY_TO_ORDER:
      if (!t.sittingCustomer.wait.pause) {
        //println("took order of table " + t.tableNum);
        orders.add(t.getOrder());
        t.state = TableState.CUSTOMER_WAITING_FOR_FOOD_OR_EATING;
        t.sittingCustomer.state = CustomerState.SITTING_ON_TABLE;
      }
      break;

    case CUSTOMER_WAITING_FOR_FOOD_OR_EATING:
      if (finishedOrders[0] != null)
      {
        if (finishedOrders[0].getTable().tableNum == t.tableNum)
        {
          //println("served order of table " + t.tableNum);
          finishedOrders[0] = null;
          t.order.state = OrderState.ON_TABLE_OR_KITCHEN;
          t.state = TableState.CUSTOMER_WAITING_FOR_FOOD_OR_EATING;
          t.sittingCustomer.wait.pauseTime();
        }
      }
      if (finishedOrders[1] != null)
      {
        if (finishedOrders[1].getTable().tableNum == t.tableNum)
        {
          //println("served order of table " + t.tableNum);
          finishedOrders[1] = null;
          t.order.state = OrderState.ON_TABLE_OR_KITCHEN;
          t.state = TableState.CUSTOMER_WAITING_FOR_FOOD_OR_EATING;
          t.sittingCustomer.wait.pauseTime();
        }
      }
      break;

    case CUSTOMER_READY_TO_PAY:
      if (!t.sittingCustomer.wait.pause)
      {
        //println("finished serving table " + t.tableNum);
        removeCustomer(t.sittingCustomer);
        success.play();
        success.amp(speechVol);
        success.pan(t.tableNum);
        t.sittingCustomer = null;
        t.order = null;
        t.state = TableState.EMPTY;
      }
      break;
    }
  }

  //Mutators

  //adds a customer to the customers ArrayList
  public void addCustomer(Customer c) 
  {
    customers.add(c);
    c.wait.pauseTime();
  }

  //removes the customer c from customers, changes the points
  public void removeCustomer(Customer c) 
  {
    if (c.state == CustomerState.LEFT_RESTAURANT_ANGRY) {
    } else
    {
      //The points increase the higher the VIP number of the customer
      points += calculatePointsFromCustomer(c);
    }
    
    customers.remove(c);
  }

  private int calculatePointsFromCustomer(Customer c) {
    // Smaller VIP-num, less bonus?
    double vipPart = 1.0 / c.getVIPNum() * 100.0;
    
    return c.getMood() + (int)(vipPart);
  }

  // Accessors
  public ArrayList<Customer> getCustomerList()
  {
    return customers;
  }

  public ArrayList<Table> getTableList()
  {
    return tables;
  }

  public int getNumPoints()
  {
    return points;
  }

  public int getNumStrikes()
  {
    return strikes;
  }
  
  public int getNumDishes()
  {  
    int dishes = 0;
    if(finishedOrders[0] != null)
      dishes++;
    
    if(finishedOrders[1] != null)
      dishes++;
      
    return dishes;
  }
}
