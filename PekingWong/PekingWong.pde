import processing.sound.*; //<>//

import java.util.*;

//Driver //<>//

//Globals
Customer currentlyWaitingCustomer; 
Waiter ling;
Restaurant pekingWong;
CoffeeVendingMachine cvm;
Kitchen kitchen;
Time waitTime;
Time levelStartWait;
Gaze gaze;
PImage bgimg;
PImage bggaze;
PImage endimg;
PImage[] lvlIntroImgs;

//Soundfiles
SoundFile fWaiting, fOrdering, fHungry, fReceipt, mWaiting, mOrdering, mHungry, mReceipt, finishedFood, placeOrder, lOrdered, lDrinking, success, fail, door, bgSample;
PFont fontFood;

float mouseScaledX = 0;
float mouseScaledY = 0;

float gazeScaledX = 0;
float gazeScaledY = 0;

int[] waitPosx = {150, 115, 80, 45, 10}; 
int waitPosy = 190;

float displayScale = 1.5f;
float bgVol = 0.2f;
float speechVol = 0.5f;
float panL = -1.0f, panM = 0.0f, panR = 1.0f;
float levelIntroWaitTime = 2;

boolean hasEyetracker = false;
IViewNative.SampleData eyetrackingSample;

IViewInterface iview;

boolean startedLevel = false;
boolean levelIntroDone = false;
//Sets up the screen 
void setup()
{

  //size(1280, 720, P3D);
  //surface.setResizable(true);
  fullScreen(P3D);
  
  try {
    iview = new IViewInterface(sketchPath("") + "Data");
  
    try {
      iview.setLogger(1, "d:/iview.log");
  
      String iviewLaptopIP = "192.168.188.34";
      String thisComputerIP = "192.168.188.33";
  
      iview.connect(iviewLaptopIP, 4444, thisComputerIP, 5555);
  
      iview.calibrate5Point();
      updateEyetracker();
      
      hasEyetracker = true;
    } 
    catch(IViewInterface.IViewException e) {
      print(e);
      hasEyetracker = false;
      
    }
  } catch(UnsatisfiedLinkError e)
  {
     print("Could not find iViewXAPI.dll, or using 64-bit processing.\n");
     print("If you are sure the DLL is in place, consider switching to a 32-bit version of processing.\n");
     print("\n");
     print("------- Eyetracking will be disabled! -------\n");
     hasEyetracker = false;
  }
  levelStartWait = new Time();
  bgimg = loadImage("Images/RestaurantFloorV3.jpg");
  bggaze = loadImage("Images/RestaurantFloorGazeL1.jpg");
  endimg = loadImage("Images/endscreen.jpg");
  lvlIntroImgs = new PImage[3];
  lvlIntroImgs[0] = loadImage("Images/level1.png");
  lvlIntroImgs[1] = loadImage("Images/level2.png");
  lvlIntroImgs[2] = loadImage("Images/level3.png");
  
  fWaiting = new SoundFile(this, "sound/mono/Alice_waiting.mp3");
  fOrdering = new SoundFile(this, "sound/mono/Alice_ordering.mp3");
  fHungry = new SoundFile(this, "sound/mono/Alice_hungry.mp3");
  fReceipt = new SoundFile(this, "sound/mono/Alice_receipt.mp3");
  mWaiting = new SoundFile(this, "sound/mono/George_waiting.mp3");
  mOrdering = new SoundFile(this, "sound/mono/George_ordering.mp3");
  mHungry = new SoundFile(this, "sound/mono/George_hungry.mp3");
  mReceipt = new SoundFile(this, "sound/mono/George_receipt.mp3");
  finishedFood = new SoundFile(this, "sound/mono/finished_food.mp3");
  placeOrder = new SoundFile(this, "sound/mono/place_an_order.mp3");
  lOrdered = new SoundFile(this, "sound/mono/Ling_ordered.mp3");
  lDrinking = new SoundFile(this, "sound/mono/Ling_coffee.mp3");
  success = new SoundFile(this, "sound/mono/success.mp3");
  fail = new SoundFile(this, "sound/mono/fail.mp3");
  door = new SoundFile(this, "sound/mono/close_door.mp3");
  bgSample = new SoundFile(this, "sound/mono/bg-sample.mp3");
  
  gaze = new Gaze();
  gaze.backgroundImage = bggaze;

  fontFood = createFont("AFont.ttf", 20);

  //println(currentlyWaitingCustomer); //ist  hier noch leer!!!!

  bgSample.loop();
  bgSample.amp(bgVol);

  Level.configureLevel(1);
  setupGameplay();
}

void setupGameplay() {
  kitchen = new Kitchen();
  cvm = new CoffeeVendingMachine();
  ling = new Waiter(kitchen, cvm);
  waitTime = new Time();
  pekingWong = new Restaurant(ling);
  waitTime.startTime();
}

void updateEyetracker()
{
  try {
    eyetrackingSample = iview.getSample();
  } 
  catch(IViewInterface.IViewException e) {
    //print(e);
    //hasEyetracker = false;
  }
}

int getGazeXRaw()
{
  return (int)(eyetrackingSample.leftEye.gazeX * 0.5f + eyetrackingSample.rightEye.gazeX * 0.5f);
}

int getGazeYRaw()
{
  return (int)(eyetrackingSample.leftEye.gazeY * 0.5f + eyetrackingSample.rightEye.gazeY * 0.5f);
}

//Calls the display functions of the globals, and updates them if necessary
void draw()
{ 
  if(hasEyetracker) {
    updateEyetracker();
  }
  
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
  
  if(eyetrackingSample != null)
  {
    gazeScaledX = (getGazeXRaw() - offsetX) / displayScale;
    gazeScaledY = (getGazeYRaw() - offsetY) / displayScale;
  } 
  else if(!hasEyetracker)
  {
    gazeScaledX = mouseScaledX;
    gazeScaledY = mouseScaledY;
  }
  
  // Scale game-drawing
  scale(displayScale);

  drawGame();

  popMatrix();
}

void drawGame() {
  image(bgimg, 1, 1);

  if (hasWon()) {
    drawEndscreenWin();
  }
  else if(!startedLevel && !levelIntroDone){
    startedLevel = true;
    levelStartWait.startTime();
  }
  else if(startedLevel && levelStartWait.getElapsed() < levelIntroWaitTime){
    drawLevelIntro();
  } 
  else if (startedLevel && levelStartWait.getElapsed() >= levelIntroWaitTime && !levelIntroDone) {
    levelStartWait.endTime();
    levelIntroDone = true;
  }
  else{
    if (isDoneWithLevel() && Level.getCurrentLevel() < 3) {
      drawEndLevel();
      if (keyPressed && key == ENTER) {
        handlePotentialLevelSwitch();
      }
    } else {
      handlePotentialLevelSwitch();
      drawRestaurant();
      drawCurrentLevel();
    }
  }
}

boolean hasWon() {
  return Level.isDone();
}

void handlePotentialLevelSwitch() {
  if (isDoneWithLevel()) {
    Level.nextLevel();
    if (Level.currentLevel <= 3) {
      bggaze = loadImage("Images/RestaurantFloorGazeL" + Level.currentLevel + ".jpg");
      gaze.backgroundImage = bggaze;
    }
    setupGameplay();
  }
}

boolean isDoneWithLevel() {
  if (!ling.getCustomerList().isEmpty())
    return false;

  if (!pekingWong.hasSpawnedAllCustomersInLevel())
    return false;

  if (!pekingWong.isWaitListEmpty())
    return false;

  return true;
}

void drawRestaurant() {
  ling.frameUpdate();

  pekingWong.update();

  kitchen.display();
  cvm.display();

  checkCurrentlyWaitingCustomer();

  if (ling.isMoving)
    ling.moveToStateTarget();

  ling.display();

  gaze.size = Level.gazeMaskSize;
  gaze.display();
  ling.displayUI();
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
  text("You Win! End of game", 100, 475); // Very temporary, please improve.
}

void drawEndLevel() {                       
  image(bgimg, 1, 1);
  textSize(65);
  textFont(fontFood);
  text("Your Points: " + ling.getNumPoints(), 300, 400);
  text("You have completed the level :) Press Enter to continue", 100, 475);
}

void drawLevelIntro(){
  image(bgimg, 1, 1);
  float x = (bgimg.width - lvlIntroImgs[Level.getCurrentLevel() - 1].width) / 2;
  float y = (bgimg.height - lvlIntroImgs[Level.getCurrentLevel() - 1].height) / 2;
  image(lvlIntroImgs[Level.getCurrentLevel() - 1], x, y);
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

    if (!pekingWong.waitList.isEmpty()) {   
      int indexCustomer;
      int tableNum = 1;
      ArrayList<Customer> toRemove = new ArrayList<Customer>();
      for (Customer WaitingCustomer : pekingWong.waitList)
      {
        if (WaitingCustomer.state == CustomerState.LEFT_RESTAURANT_ANGRY) {
          toRemove.add(WaitingCustomer);
        }
        indexCustomer = pekingWong.waitList.indexOf(WaitingCustomer);
        WaitingCustomer.setPosition(waitPosx[indexCustomer], waitPosy);
        WaitingCustomer.display();
      }
      for (Customer CustomerToRemove : toRemove)
      {
        pekingWong.waitList.remove(CustomerToRemove);
        door.play();
        door.amp(speechVol);
        door.pan(tableNum);
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
