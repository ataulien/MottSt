import java.util.ArrayList;

public class Waiter 
{
  //instance vars
  private ArrayList<Customer> customers = new ArrayList<Customer>();
  private ArrayList<Table> tables = new ArrayList<Table>();;
  private ArrayList<Order> orders = new ArrayList<Order>();
  private Order[] finishedOrders = new Order[2];
  PVector position = new PVector();
  
  private Table currentTable;
  
  Kitchen kitchen;
  
  boolean waiterMoves;
  int state;
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
    
    waiterMoves = false;
    state = 0;
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
      if (c.state == CustomerState.LEFT_RESTAURANT_ANGRY)
      {
        Table t = c.getTable();

        removeCustomer(t.c);
        strikes ++; // Game logic inside rendering-method, great!
        t.c = null;

        t.state = TableState.EMPTY;
      } else
      {
        c.display();
      }
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

  /*------
   * Updates the state of the waiter. Invoked when the mouse is clicked. 
   * If the mouse has clicked on the Order at the Kitchen, state = 1.
   *                                 Kitchen and NOT an Order, state = 2.
   *                                 a table, state = 3.
   * state == 1: The waiter is moving to pick up an order from the Kitchen. 
   * state == 2:                      to place an order at the Kitchen. 
   * state == 3:                      to a table. 
   -----*/
  void update()
  {
    if (kitchen.isMouseOverKitchen())
    {
      if (kitchen.currentOrder != null && kitchen.currentOrder.isMouseOverOrder())
      {
        state = 1;
        return;
      }
      state = 2;
    } else {
      for (Table t : tables) {
        if (t.overTable()) {
          if (t.state == TableState.EMPTY) {
            return;
          } else {
            state = 3;
            currentTable = t;
          }
          break;
        }
      }
    }
  }

  //Moves to the specified coordinates
  void move()
  {
    if (state == 1) {
      goTo(kitchen.x+250, kitchen.y);
    } else if (state == 2) {
      goTo(kitchen.x-15, kitchen.y);
    } else if (state == 3) {
      goTo(currentTable.x+105, currentTable.y-15);
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

        waiterMoves = false;
        performAct();
      }
    }
    display();
  }

  //Mechanics Functions

  /*------
   * Performs an action based on the state of the waiter. 
   * States and what they represent are delineated above, before the "update" method. 
   ------*/
  void performAct()
  {
    if (state == 1)
    {
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
    } else if (state == 2)
    {
      if (orders.size() > 0)
      {
        //Utilizes stack in order to maintain order
        LLStack<Order> l = new LLStack<Order>();
        for (int i = orders.size()-1; i >= 0; i --)
        {
          l.push(orders.remove(i));
          //println("placed order at kitchen");
        }
        while (!l.isEmpty())
        {
          kitchen.addLastToPending(l.pop());
        }
        kitchen.state = 1;
      }
    } else if (state == 3)
    {
      detAct(currentTable);
    }
    state = 0;
  }

  /*------
   * Specifically determines the act to be performed if the waiter is dealing with tables. 
   * Table states and corresponding actions: 
   * t.state == 1: The customers are ready to place an order. 
   * t.state == 2: The customers are waiting to be served. 
   * t.state == 3: The customers are done eating and waiting for their bill. 
   ------*/
  void detAct(Table t)
  {
    //Customers are ready to order
    if (t.state == TableState.CUSTOMER_READING_MENU_OR_READY_TO_ORDER && !t.c.wait.pause)
    {
      //println("took order of table " + t.tableNum);
      orders.add(t.getOrder());
      t.state = TableState.CUSTOMER_WAITING_FOR_FOOD_OR_EATING;
    }
    //Customers are ready to be served
    else if (t.state == TableState.CUSTOMER_WAITING_FOR_FOOD_OR_EATING)
    {
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
    }
    //Customers are done eating
    else if (t.state == TableState.CUSTOMER_READY_TO_PAY && !t.c.wait.pause)
    {
      //println("finished serving table " + t.tableNum);
      removeCustomer(t.c);
      t.c = null;
      t.order = null;
      t.state = TableState.EMPTY;
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
      points += c.getMood() + (int)((1.0/c.getVIPNum())*100);
    }
    for (int i = 0; i < customers.size(); i++) 
    {
      if (customers.get(i).equals(c))
      {
        customers.remove(i);
      }
    }
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
