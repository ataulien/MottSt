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
  PFont fontScore = createFont("AFont.ttf", 20);

  private int strikes;
  private int points;

  public Waiter(Kitchen kitchen) 
  {
    this.kitchen = kitchen;

    //creates six tables
    tables.add(new Table(1, 400, 400));
    tables.add(new Table(2, 656, 400));
    tables.add(new Table(3, 913, 400));
    tables.add(new Table(4, 400, 600));
    tables.add(new Table(5, 656, 600));
    tables.add(new Table(6, 912, 600));

    position.x = 300;
    position.y = 200;

    isMoving = false;
    state = WaiterState.IDLE;
    imageWaiterNoFood = loadImage("Images/WaiterRight.png");
  }

  void display()
  {
    drawTables();
    drawCustomers();
    drawWaiter();
    drawScore();
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
    image(imageWaiterNoFood, position.x, position.y);
  }

  private void drawScore() {
    fill(0);
    textSize(20);
    textFont(fontScore);
    text("POINTS: " + points, 155, 100);
    text("STRIKES: " + strikes + "/5", 155, 150);
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

      removeCustomer(t.c);
      strikes ++;
      t.c = null;

      t.state = TableState.EMPTY;
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
      if (kitchen.currentOrder.getTable().c == null)
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
        //Utilizes stack in order to maintain order
        LLStack<Order> l = new LLStack<Order>();
        for (int i = orders.size()-1; i >= 0; i --)
        {
          l.push(orders.remove(i));
          //println("placed order at kitchen");
        }
        
        for(Order o : orders) {
          kitchen.addLastToPending(o);
        }
        
        orders.clear();
        kitchen.state = 1;
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
      if (!t.c.wait.pause) {
        //println("took order of table " + t.tableNum);
        orders.add(t.getOrder());
        t.state = TableState.CUSTOMER_WAITING_FOR_FOOD_OR_EATING;
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
          t.c.wait.pauseTime();
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
          t.c.wait.pauseTime();
        }
      }
      break;

    case CUSTOMER_READY_TO_PAY:
      if (!t.c.wait.pause)
      {
        //println("finished serving table " + t.tableNum);
        removeCustomer(t.c);
        t.c = null;
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
}
