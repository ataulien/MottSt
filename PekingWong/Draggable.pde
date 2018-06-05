//Class Draggable
class Draggable
{
  //Instance Variables
  float bx;
  float by;
  int xSize;
  int ySize;
  boolean overBox;
  boolean locked;
  float xOffset; 
  float yOffset;

  Draggable(int x, int y)
  {
    xSize = x;
    ySize = y;
    overBox = false;
    locked = false;
    xOffset = 0.0; 
    yOffset = 0.0;
    bx = width / 2.0;
    by = height / 2.0;
  }

  void display() 
  { 
    // Test if the cursor is over the box 
    if (mouseScaledX > bx - xSize && mouseScaledX < bx + xSize && 
        mouseScaledY > by - ySize && mouseScaledY < by + ySize) {
      overBox = true;
    } else  {
      overBox = false;
    }
  }
}
