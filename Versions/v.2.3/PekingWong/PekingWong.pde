//Driver

//Globals
Customer d;
Waiter ling;
Restaurant pekingWong;
Kitchen k;
PImage bgimg;

//Sets up the screen 
void setup()
{
  //bgimg = loadImage("Images/RestaurantFloorV3.jpg");
  size(1280, 720);
  k = new Kitchen();
  ling = new Waiter(k);
  pekingWong = new Restaurant(ling);
  d = pekingWong.waitList.removeMin();
}

//Calls the display functions of the globals, and updates them if necessary
void draw()
{
  //background(bgimg);
  background(0);
  if (!pekingWong.strikeOut())
  {
    pekingWong.update();
    ling.display();
    k.display();
    if (d != null) {
      d.display();
    }
    if (d == null)
    {
      if (pekingWong.waitList.peekMin() != null)
      {
        d = pekingWong.waitList.removeMin();
      }
    }
    if (ling.waiterMoves)
      ling.move();
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
          if (pekingWong.waitList.peekMin() != null)
            d = pekingWong.waitList.removeMin();
          else{d = null;}
          return;
        }
      }
    }
    d.bx = d.origX;
    d.by = d.origY;
  }
}