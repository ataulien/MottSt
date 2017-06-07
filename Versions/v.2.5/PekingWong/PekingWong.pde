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
    if (d != null) {
      d.display();
    }
    if (d == null)
    {
      if (pekingWong.waitList.peekMin() != null)
      {
        d = pekingWong.waitList.removeMin();
        d.wait.startTime();
      }
    }
    if (d.state == 4) {
      ling.points -= 5;
      ling.strikes++;
      d = null;
    }
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

//
void mouseDragged() 
{
  if (d != null) {
    d.checkState();
  }
}

void mouseReleased() 
{
  ling.waiterMoves = false;
  if (d != null)
  {
    d.locked = false;
    for (Table t : ling.getTables()) {
      if (t.inside(d.bx, d.by)) {
        if (t.getCust() == null) {
          d.setState(1);
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