//Driver

//Globals
Customer currentlyWaitingCustomer; 
Waiter ling;
Restaurant pekingWong;
Kitchen kitchen;
Time waitTime;
Gaze gaze;
PImage bgimg;
PImage endimg;

//Soundfiles
SoundFile wWaiting;
SoundFile wOrdering;
SoundFile wHungry;
SoundFile wReceipt;
SoundFile mWaiting;
SoundFile mOrdering;
SoundFile mHungry;
SoundFile mReceipt;
SoundFile finishedFood;
SoundFile placeOrder;
SoundFile ordered;
SoundFile bgSample;
PFont fontFood;

float mouseScaledX = 0;
float mouseScaledY = 0;
int[] waitPosx = {150, 115, 80, 45, 10}; 
int waitPosy = 190;

float displayScale = 1.5f;
float bgVol = 0.2f;
float speechVol = 0.5f;
float panL = -1.0f;
float panM = 0.0f;
float panR = 1.0f;

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

  gaze = new Gaze();
  gaze.backgroundImage = bgimg;
  
  fontFood = createFont("AFont.ttf", 20);
  
  //  println(currentlyWaitingCustomer); //ist  hier noch leer!!!!
  
  bgSample = new SoundFile(this, "sound/mono/bg-sample.mp3");
  wWaiting = new SoundFile(this, "sound/mono/Alice_waiting.mp3");
  wOrdering = new SoundFile(this, "sound/mono/Alice_ordering.mp3");
  wHungry = new SoundFile(this, "sound/mono/Alice_hungry.mp3");
  wReceipt = new SoundFile(this, "sound/mono/Alice_receipt.mp3");
  mWaiting = new SoundFile(this, "sound/mono/George_waiting.mp3");
  mOrdering = new SoundFile(this, "sound/mono/George_ordering.mp3");
  mHungry = new SoundFile(this, "sound/mono/George_hungry.mp3");
  mReceipt = new SoundFile(this, "sound/mono/George_receipt.mp3");
  finishedFood = new SoundFile(this, "sound/mono/Finished_Food.mp3");
  placeOrder = new SoundFile(this, "sound/mono/Place_an_order.mp3");
  ordered = new SoundFile(this, "sound/mono/Ling_ordered.mp3");
  
  bgSample.loop();
  bgSample.amp(bgVol);

  Level.configureLevel(1);
  setupGameplay();
}

void setupGameplay() {
  kitchen = new Kitchen();
  ling = new Waiter(kitchen);
  waitTime = new Time();
  pekingWong = new Restaurant(ling);
  waitTime.startTime();
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

  if (hasLost()) {
    drawEndscreenLose();
  } else if(hasWon()) {
    drawEndscreenWin();
  } else {
    handlePotentialLevelSwitch();
    drawCurrentLevel();
    drawRestaurant();
  }
}

boolean hasLost() {
  return pekingWong.strikeOut();
}

boolean hasWon() {
  return Level.isDone();
}

void handlePotentialLevelSwitch() {
  if(isDoneWithLevel()) {
    Level.nextLevel();
    setupGameplay();
  }
}

boolean isDoneWithLevel() {
  if(!ling.getCustomerList().isEmpty())
      return false;

  if(!pekingWong.hasSpawnedAllCustomersInLevel())
      return false;

  if(!pekingWong.isWaitListEmpty())
      return false;

  return true;
}

void drawRestaurant() {
  ling.frameUpdate();
  
  pekingWong.update();

  kitchen.display();
  
  checkCurrentlyWaitingCustomer();

  if (ling.isMoving)
    ling.moveToStateTarget();

  ling.display();
  
  gaze.display();
}

void drawCurrentLevel() {
  pushStyle();
  fill(255);
  textSize(20);
  textFont(fontFood);
  text("Level: " + Level.getCurrentLevel(), 5, 25);
  popStyle();
}

void drawEndscreenLose() {
  image(endimg, 1, 1);
  textSize(65);
  textFont(fontFood);
  text("" + ling.getNumPoints(), 500, 475);
}

void drawEndscreenWin() {
    image(bgimg, 1, 1);
    textSize(65);
    textFont(fontFood);
    text("You Win!", 100, 475); // Very temporary, please improve.
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
      ArrayList<Customer> toRemove = new ArrayList<Customer>();
      for (Customer WaitingCustomer : pekingWong.waitList)
      {
        if (WaitingCustomer.state == CustomerState.LEFT_RESTAURANT_ANGRY){
        toRemove.add(WaitingCustomer);
        }
        indexCustomer = pekingWong.waitList.indexOf(WaitingCustomer);
        WaitingCustomer.setPosition(waitPosx[indexCustomer], waitPosy);
        WaitingCustomer.display();
      }
      for (Customer CustomerToRemove : toRemove)
      {
       pekingWong.waitList.remove(CustomerToRemove);
       ling.points -= 5;
       ling.strikes++;
      }
    }
  } else {
    if (!pekingWong.waitList.isEmpty()) {
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
