public enum TableState
{
  EMPTY, 
    CUSTOMER_READING_MENU_OR_READY_TO_ORDER, 
    CUSTOMER_WAITING_FOR_FOOD_OR_EATING, 
    CUSTOMER_READY_TO_PAY,
}

class Table
{
  //Instance Variables
  Customer sittingCustomer; 
  Order order;
  int tableNum;
  TableState state;
  int prevState;
  int x;
  int y;
  PImage visual;
  PFont fontFood = createFont("AFont.ttf", 20);

  //New table with no customer, but a number assignment and (x,y)
  Table(int num, int setX, int setY)
  {
    tableNum = num;
    sittingCustomer = null;
    x = setX;
    y = setY; 
    order = null;
    state = TableState.EMPTY;
    visual = loadImage("Images/table2v2.png");
  }

  //Display Functions

  void display() 
  {
    displayTableImage();
    displayTableNummer();
    displayOrderIfVisible();
  }
  
  private void displayTableImage()
  {
    image(visual, x, y);
  }
  
  private void displayTableNummer()
  {
    fill(255);
    textSize(25);
    textFont(fontFood);
    text("" + tableNum, x + 60, y + 40);
  }

  private void displayOrderIfVisible()
  {
    if (order != null && order.state == OrderState.ON_TABLE_OR_KITCHEN)
    {
      order.display();
    }
  }

  //Checks if the mouse if over the table
  boolean isMouseOverTable()
  {
    if (mouseScaledX >= x && mouseScaledX <= x + 128 &&
        mouseScaledY >= y && mouseScaledY <= y + 100) {
      return true;
    } else {
      return false;
    }
  }

  //Checks if the inputted X and Y coordinate are within the table (doesn't set min Y boundary
  boolean inside(float currX, float currY)
  {
    return currX >= x && currX <= x + 128 && currY <= y + 120; //&& currY >= y ;
  }

  //Mutators
  
  //Sets the table# of the customer
  public void setTable(int num) 
  {
    tableNum = num;
  }

  //sets the customer seated at the table
  void setSittingCustomer(Customer in)
  {
    sittingCustomer = in;
    //wait time is lower for customers of higher priority (lower VIPNum)
    sittingCustomer.wait.startTime();
  }

  //sets the order of the table
  void setOrder(Order o)
  {
    order = o;
  }

  //Accessors
  
  //returns order placed by table
  public Order getOrder()
  {
    lOrdered.play();
    lOrdered.amp(speechVol);
    lOrdered.pan(tableNum);
    return order;
  }

  //returns customer seated at table
  public Customer getSittingCustomer()
  {
    return sittingCustomer;
  }
}
