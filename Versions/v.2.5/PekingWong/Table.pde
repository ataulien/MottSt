//Class Table
class Table
{
  //Instance Variables
  Customer c; 
  Order order;
  int tableNum;
  int state;
  int prevState;
  int x;
  int y;
  PImage visual;
  PFont cFood = createFont("AFont.ttf", 20);

  //New table with no customer, but a number assignment and (x,y)
  Table(int num, int setX, int setY)
  {
    tableNum = num;
    c = null;
    x = setX;
    y = setY; 
    order = null;
    visual = loadImage("Images/table2v2.png");
  }

  //Display Functions

  //Updates the mood of the customer at the table, and then displays. 
  void display() 
  {
    fill(255);
    //rect(x, y, 50, 50, 7);
    image(visual, x, y);
    textSize(25);
    textFont(cFood);
    text("" + tableNum, x +60, y + 40);
    if (order != null && order.state == 1)
    {
      //println("order");
      order.display();
    }
  }

  boolean overTable() {
    if (mouseX >= x && mouseX <= x+128 && 
      mouseY >= y && mouseY <= y+100) {
      return true;
    } else {
      return false;
    }
  }
  
  boolean inside(float currX, float currY)
  {
    //println("in");
    return currX >= x && currX <= x + 128 && currY <= y+120; //&& currY >= y ;
  }
  //Mutators
  //Sets the table# of the customer
  public void setTable(int num) 
  {
    tableNum = num;
  }
  
  //sets the customer seated at the table
  void setCust(Customer in)
  {
    c = in;
    //wait time is lower for customers of higher priority (lower VIPNum)
    //wait.setGoal(c.getVIPNum() * 20);
    ////wait.setGoal(5);
    c.wait.startTime();
  }
  
  void setOrder(Order o)
  {
    order = o;
  }
  
  //Accessors
  //returns order placed by table
  public Order getOrder()
  {
    return order;
  }
  
  //returns customer seated at table
  public Customer getCust()
  {
    return c;
  }
}