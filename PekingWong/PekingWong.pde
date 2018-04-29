//Driver

import processing.sound.*;

//Globals
Console console;
Customer currentlyWaitingCustomer; 
Waiter ling;
Restaurant pekingWong;
Kitchen kitchen;
Time waitTime;
PImage bgimg;
PImage endimg;
SoundFile bgSample;
SoundFile cHungry;
PFont fontFood;

float mouseScaledX = 0;
float mouseScaledY = 0;
int[] waitPosx = {150, 115, 80, 45, 10}; 
int waitPosy = 190; 

float displayScale = 1.5f;

IViewInterface iview;

//Sets up the screen 
void setup()
{
  /*iview = new IViewInterface(sketchPath("") + "Data");
  
  try {
    iview.connect("123", 123, "123", 123);
  } catch(IViewInterface.IViewException e) {
    print(e);
  }*/
  
  size(1280, 720, P3D);
  surface.setResizable(true);

  bgimg = loadImage("Images/RestaurantFloorV3.jpg");
  endimg = loadImage("Images/endscreen.jpg");

  kitchen = new Kitchen();
  ling = new Waiter(kitchen);
  waitTime = new Time();
  pekingWong = new Restaurant(ling);
  fontFood = createFont("AFont.ttf", 20);
  waitTime.startTime();
  console = new Console(ling);
  //  println(currentlyWaitingCustomer); //ist  hier noch leer!!!!
  
  bgSample = new SoundFile(this, "sound/bg-sample.mp3");
  bgSample.loop();
  bgSample.amp(0.5);
  
  cHungry = new SoundFile(this, "sound/Alice_hungry.mp3");
}

//Calls the display functions of the globals, and updates them if necessary
void draw()
{
  background(0);

  pushMatrix(); 

  float displayScaleX = width / 1280.0f;
  float displayScaleY = height / 720.0f;

  // Keep the aspect ratio
  displayScale = min(displayScaleX, displayScaleY);

  // Calculate blank space to both sides of the window
  float spaceX = width - (1280.0f * displayScale);
  float spaceY = height - (720.0f * displayScale);

  // We want the screen centered, so shift for half the empty space
  float offsetX = spaceX / 2;
  float offsetY = spaceY / 2;

  translate(offsetX, offsetY);

  // Scale mouse coords back to the size the game expects
  mouseScaledX = (mouseX - offsetX) / displayScale;
  mouseScaledY = (mouseY - offsetY) / displayScale;

  // Scale game-drawing
  scale(displayScale);
  
  drawGame();

  popMatrix();
}

void drawGame() {
  image(bgimg, 1, 1);

  if (!pekingWong.strikeOut()) {
    drawRestaurant();
  } else {
    drawEndscreen();
  }
}

void drawRestaurant() {
  ling.frameUpdate();

  console.display();
  
  pekingWong.update();

  kitchen.display();
  
  checkCurrentlyWaitingCustomer();

  if (ling.isMoving)
    ling.moveToStateTarget();

  ling.display();
}

void drawEndscreen() {
  image(endimg, 1, 1);
  textSize(65);
  textFont(fontFood);
  text("" + ling.getNumPoints(), 500, 475);
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
    
    if (!pekingWong.waitList.isEmpty()){   
      int indexCustomer;
      for (Customer WaitingCustomer : pekingWong.waitList)
      {
        WaitingCustomer.state = CustomerState.WAITING;
        indexCustomer = pekingWong.waitList.indexOf(WaitingCustomer);
        WaitingCustomer.setPosition(waitPosx[indexCustomer], waitPosy);
        WaitingCustomer.display();
      }
    }
  } else {
    if (!pekingWong.waitList.isEmpty()) {
    //Customer mostImportant = (Customer)Collections.min(pekingWong.waitList);
      Customer mostImportant = pekingWong.waitList.get(0);
      pekingWong.waitList.remove(mostImportant);
      mostImportant.wait.startTime();

      currentlyWaitingCustomer = mostImportant; 
      currentlyWaitingCustomer.state = CustomerState.STANDING_ON_SIDE;
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
    currentlyWaitingCustomer.xOffset = mouseScaledX - currentlyWaitingCustomer.bx; 
    currentlyWaitingCustomer.yOffset = mouseScaledY - currentlyWaitingCustomer.by;
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
