//Driver

//Globals
Console console;
Customer currentlyWaitingCustomer;
Waiter ling;
Restaurant pekingWong;
Kitchen kitchen;
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
  kitchen = new Kitchen();
  ling = new Waiter(kitchen);
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
    ling.frameUpdate();

    console.display();
    
    pekingWong.update();
    
    kitchen.display();
    
    checkCurrentlyWaitingCustomer();
    
    if (ling.isMoving)
      ling.moveToStateTarget();
      
    ling.display();
    
  } else { 
    background(endimg);
    textSize(65);
    textFont(cFood);
    text("" + ling.getNumPoints(), 500, 475);
  }
}

//Checks the status of the current waiting customer
void checkCurrentlyWaitingCustomer()
{
  if (currentlyWaitingCustomer != null) 
  {
    currentlyWaitingCustomer.display();
    if (currentlyWaitingCustomer.state == CustomerState.LEFT_RESTAURANT_ANGRY) 
    {
      ling.points -= 5;
      ling.strikes++;
      currentlyWaitingCustomer = null;
    }
  } else  {
    if (!pekingWong.waitList.isEmpty()) {
      Customer mostImportant = (Customer)Collections.min(pekingWong.waitList);

      //println("new cust");
      pekingWong.waitList.remove(mostImportant);
      mostImportant.wait.startTime();
      
      currentlyWaitingCustomer = mostImportant;
    }
  }
}

//When mouse-clicked, update the state of the waiter based on the object clicked
void mouseClicked() 
{
  ling.isMoving = true;
  ling.onMouseClicked();
}

//When the mouse is pressed
void mousePressed()
{
  if (currentlyWaitingCustomer != null)
  {
    if (currentlyWaitingCustomer.overBox) { 
      currentlyWaitingCustomer.locked = true;
    } else {
      currentlyWaitingCustomer.locked = false;
    }
    currentlyWaitingCustomer.xOffset = mouseX - currentlyWaitingCustomer.bx; 
    currentlyWaitingCustomer.yOffset = mouseY - currentlyWaitingCustomer.by;
  }
}

//Utilized for the dragging mechanism of the customer
void mouseDragged() 
{
  if (currentlyWaitingCustomer != null) {
    currentlyWaitingCustomer.checkState();
  }
}

//Checks if the mouse releases the customer onto a table
void mouseReleased() 
{
  ling.isMoving = false;
  if (currentlyWaitingCustomer != null)
  {
    currentlyWaitingCustomer.locked = false;
    for (Table t : ling.getTableList()) {
      if (t.inside(currentlyWaitingCustomer.bx, currentlyWaitingCustomer.by)) {
        if (t.getSittingCustomer() == null) {
          
          currentlyWaitingCustomer.setState(CustomerState.SITTING_ON_TABLE);
          
          t.setSittingCustomer(currentlyWaitingCustomer);
          t.state = TableState.CUSTOMER_READING_MENU_OR_READY_TO_ORDER;
          t.setOrder(new Order(t));
          
          currentlyWaitingCustomer.setTable(t);
          
          ling.addCustomer(currentlyWaitingCustomer);
          
          currentlyWaitingCustomer = null;
          return;
        }
      }
    }
    currentlyWaitingCustomer.bx = currentlyWaitingCustomer.origX;
    currentlyWaitingCustomer.by = currentlyWaitingCustomer.origY;
  }
}
