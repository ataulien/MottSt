
class CoffeeVendingMachine
{
  PVector position;
  PVector size;
  PVector progressBarPosition;
  PImage vendingMachineImage;
  PImage [] progressBarImages;
  Time drinkWait;
  Time effectWait;
  
  private int coffeeCharges;
  boolean startedDrinking;
  boolean startedCoffeeEffect;
  float oldGazeMaskSize;
  private int drinkTime = 3;
  private int effectTime = 10;
  private float gazeSizeScaleFactor = 1.5f;
  
  public CoffeeVendingMachine()
  {
    drinkWait = new Time();
    effectWait = new Time();
    
    startedDrinking = false;
    startedCoffeeEffect = false;
    position = new PVector(1000, 75);
    progressBarPosition = new PVector(1000,25);
    size = new PVector(430 * .2f, 711 * .2f);
    vendingMachineImage = loadImage("Images/CoffeeVendingMachine.png");
    progressBarImages = new PImage[4];
    progressBarImages[0] = loadImage("Images/Mood_Hearts/heartState6.png");
    progressBarImages[1] = loadImage("Images/Mood_Hearts/heartState4.png");
    progressBarImages[2] = loadImage("Images/Mood_Hearts/heartState2.png");
    progressBarImages[3] = loadImage("Images/Mood_Hearts/heartState1.png");
  }
  
  void display()
  {
    pushMatrix();
    scale(.2f);
    image(vendingMachineImage, position.x * 5, position.y * 5);
    popMatrix();
    update();
  }
  
  void displayUI()
  {
    pushStyle();
    fill(255);
    textSize(20);
    text("COFFEES: " + coffeeCharges, 5, 175);
    popStyle();
  }
  
  public void setCoffeeCharges(int charges){
    coffeeCharges = charges;
  }
  
  public void update()
  {
    if(startedDrinking && !startedCoffeeEffect)
    {
      if(drinkWait.getElapsed() <= drinkTime)
      {
        image(progressBarImages[(int) drinkWait.getElapsed()], progressBarPosition.x, progressBarPosition.y);
      }
      else if(drinkWait.getElapsed() > drinkTime)
      {
        startedDrinking = false;
        drinkWait.endTime();
        startedCoffeeEffect = true;
        Level.gazeMaskSize *= gazeSizeScaleFactor;
        effectWait.startTime();
        lDrinking.play();
        lDrinking.amp(speechVol);
      }
    }
    else if(!startedDrinking && startedCoffeeEffect)
    {
      if(effectWait.getElapsed() > effectTime)
      {
        effectWait.endTime();
        startedCoffeeEffect = false;
        Level.gazeMaskSize = oldGazeMaskSize;
      }
    }
  }
  
  public void drinkCoffee()
  {
    if(!startedDrinking && !startedCoffeeEffect)
    {
      drinkWait.startTime();
      startedDrinking = true;
      coffeeCharges--;
      oldGazeMaskSize = Level.gazeMaskSize;
    } 
  }
  
  boolean hasChargesLeft(){
    return coffeeCharges > 0;
  }
  
  boolean isMouseOverCoffeeVendingMachine()
  {
    if (mouseScaledX >= position.x && mouseScaledX <= position.x + size.x &&
      mouseScaledY >= position.y && mouseScaledY <= position.y + size.y) {
      return true;
    } else {
      return false;
    } 
  }
}
