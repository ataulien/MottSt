import java.util.ArrayList;

//Class Waiter
public class Waiter 
{
  //instance vars
  private ArrayList<Customer> customers;
  private Table currTable;
  private Kitchen k;
  private ArrayList<Table> tables;
  private ArrayList<Order> orders;
  private Order[] finishedOrders;
  float x;
  float y;
  int ind;
  boolean waiterMoves;
  int state;
  private int strikes;
  private int points;
  PImage waiterNoFood;
  PFont cFood = createFont("AFont.ttf", 20);

  //create a waiter
  public Waiter(Kitchen kitch) 
  {
    customers = new ArrayList<Customer>();
    tables = new ArrayList<Table>();
    //creates six tables
    tables.add(new Table(1, 400, 400));
    tables.add(new Table(2, 656, 400));
    tables.add(new Table(3, 913, 400));
    tables.add(new Table(4, 400, 600));
    tables.add(new Table(5, 656, 600));
    tables.add(new Table(6, 912, 600));

    orders = new ArrayList<Order>(); 
    finishedOrders = new Order[2];
    k = kitch;

    x = 300;
    y = 200;
    waiterMoves = false;
    state = 0;
    waiterNoFood = loadImage("Images/WaiterRight.png");
  }

  //Displaying Functions

  //Displays the customers, the tables, and the waiter her/himself
  void display()
  {
    for (int i = 0; i < 6; i++) {
      tables.get(i).display();
    }
    for (int i = customers.size()-1; i >= 0; i --) {
      Customer c = customers.get(i);
      if (c.state == CustomerState.LEFT_RESTAURANT_ANGRY)
      {
        Table t = c.getTable();
        //println("The customer at table " + t.tableNum + " has left...");
        removeCustomer(t.c);
        strikes ++;
        t.c = null;
        t.state = TableState.EMPTY;
      } else
      {
        c.display();
      }
    }
    image(waiterNoFood, x, y);
    fill(0);
    textSize(20);
    textFont(cFood);
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
    if (k.overKitchen())
    {
      if (k.currOrder != null && k.currOrder.overOrder())
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
            currTable = t;
          }
          break;
        }
      }
    }
  }

  //Moves to the specified coordinates by calling the helper goTo(x,y) function.
  void move()
  {
    if (state == 1) {
      goTo(k.x+250, k.y);
    } else if (state == 2) {
      goTo(k.x-15, k.y);
    } else if (state == 3) {
      goTo(currTable.x+105, currTable.y-15);
    }
    ind ++;
    delay(10);
  }

  //Goes to the target X and Y coordinates by incrementing by 10 each time the function is invoked if the waiter is not yet at those coordinates.
  void goTo(int targetX, int targetY) {
    if (x < targetX) {
      if (x + 8 > targetX) {
        x = targetX;
        return;
      }
      x+=8;
    } else if (x > targetX) {
      x-=8;
    } else {
      if (y < targetY) {
        if (y + 8 > targetY) {
          y = targetY;
          return;
        }
        y+=8;
      } else if (y > targetY) {
        y-=8;
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
      if (k.currOrder.getTable().c == null)
      {
        //println("The customer has already left...");
        k.currOrder.getTable().order = null;
        k.currOrder = null;
        return;
      }
      if (finishedOrders[0] == null) {
        finishedOrders[0] = k.currOrder;
        k.currOrder = null;
      } 
      if (finishedOrders[1] == null) {
        finishedOrders[1] = k.currOrder;
        k.currOrder = null;
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
          k.addLastToPending(l.pop());
        }
        k.state = 1;
      }
    } else if (state == 3)
    {
      detAct(currTable);
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
          t.order.state = 1;
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
          t.order.state = 1;
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


  //Accessors

  //returns customer list
  public ArrayList<Customer> getCustomers()
  {
    return customers;
  }

  //returns list of tables
  public ArrayList<Table> getTables()
  {
    return tables;
  }

  //returns current number of points
  public int getPoints()
  {
    return points;
  }

  //returns the current amount of strikes
  public int getStrikes()
  {
    return strikes;
  }
}
