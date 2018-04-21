//Driver

//Globals
Console console;
Customer d;
Waiter ling;
Restaurant pekingWong;
Kitchen k;
Time waitTime;
PImage bgimg;
PImage endimg;
PFont cFood;

//Sets up the screen 
void setup()
{
  bgimg = loadImage("Images/RestaurantFloorV3.jpg");
  endimg = loadImage("Images/endscreen.jpg");
  size(1280, 720);
  k = new Kitchen();
  ling = new Waiter(k);
  waitTime = new Time();
  pekingWong = new Restaurant(ling);
  cFood = createFont("AFont.ttf", 20);
  waitTime.startTime();
  console = new Console(ling);
}

//Calls the display functions of the globals, and updates them if necessary
void draw()
{
  background(bgimg);
  //ellipse(775,205, 50,50);
  if (!pekingWong.strikeOut())
  {
    console.display();
    pekingWong.update();
    k.display();
    checkD();
    if (ling.waiterMoves)
      ling.move();
    ling.display();
  } else { 
    background(endimg);
    textSize(65);
    textFont(cFood);
    text("" + ling.getPoints(), 500, 475);
  }
}

//Checks the status of the current waiting customer
void checkD()
{
  if (d != null) 
  {
    d.display();
    if (d.state == CustomerState.LEFT_RESTAURANT_ANGRY) 
    {
      ling.points -= 5;
      ling.strikes++;
      d = null;
    }
  }
  if (d == null)
  {
    if (pekingWong.waitList.peekMin() != null)
    {
      //println("new cust");
      d = pekingWong.waitList.removeMin();
      d.wait.startTime();
    }
  }
}

//When mouse-clicked, update the state of the waiter based on the object clicked
void mouseClicked() 
{
  ling.waiterMoves = true;
  ling.update();
}

//When the mouse is pressed
void mousePressed()
{
  if (d != null)
  {
    if (d.overBox) { 
      d.locked = true;
    } else {
      d.locked = false;
    }
    d.xOffset = mouseX-d.bx; 
    d.yOffset = mouseY-d.by;
  }
}

//Utilized for the dragging mechanism of the customer
void mouseDragged() 
{
  if (d != null) {
    d.checkState();
  }
}

//Checks if the mouse releases the customer onto a table
void mouseReleased() 
{
  ling.waiterMoves = false;
  if (d != null)
  {
    d.locked = false;
    for (Table t : ling.getTables()) {
      if (t.inside(d.bx, d.by)) {
        if (t.getCust() == null) {
          d.setState(CustomerState.SITTING_ON_TABLE);
          t.setCust(d);
          t.state = 1;
          t.setOrder(new Order(t));
          d.setTable(t);
          ling.addCustomer(d);
          d = null;
          return;
        }
      }
    }
    d.bx = d.origX;
    d.by = d.origY;
  }
}
