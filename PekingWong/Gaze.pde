class Gaze
{
  PImage gazemask;
  PGraphics layer_gazeMask;
  PGraphics layer_cutObjects;
  PGraphics layer_cutBackground;
  
  public float blueness = 0.9f;
  public float size = 1.0f;
  public float brightness = 0.10f;
  public PImage backgroundImage = null;
  
  public Gaze() {
    gazemask = loadImage("Images/gazemask3.png");
    layer_gazeMask = createGraphics(1280, 720, P3D);
    layer_cutObjects = createGraphics(1280, 720, P3D);
    layer_cutBackground = createGraphics(1280, 720, P3D);
  }
  
  public void display() {
    
    removeGameObjects();
    
    layer_gazeMask.beginDraw();
    layer_gazeMask.background(255 * brightness, 
                              255 * brightness, 
                              255 * blueness);
    layer_gazeMask.blendMode(ADD);
    drawGazeSpotOntoLayer(layer_gazeMask);
    layer_gazeMask.endDraw();
        
    blendMode(MULTIPLY);
    image(layer_gazeMask, 0, 0);
    blendMode(BLEND);
  }
  
  public void removeGameObjects() {
    if(backgroundImage == null) {
      return;
    }
    
    layer_cutObjects.beginDraw();
    layer_cutObjects.clear();
    layer_cutObjects.background(0, 0, 0);
    layer_cutObjects.blendMode(ADD);
    drawGazeSpotOntoLayer(layer_cutObjects);
    layer_cutObjects.endDraw();
    
    blendMode(MULTIPLY);
    image(layer_cutObjects, 0, 0);
    
    layer_cutBackground.beginDraw();
    layer_cutBackground.clear();
    layer_cutBackground.background(255);
    layer_cutBackground.blendMode(SUBTRACT);
    drawGazeSpotOntoLayer(layer_cutBackground);
    layer_cutBackground.blendMode(MULTIPLY);
    layer_cutBackground.image(backgroundImage, 0, 0);
    layer_cutBackground.endDraw();
    
    blendMode(ADD);
    image(layer_cutBackground, 0, 0);
    blendMode(BLEND);
  }
  
  private void drawGazeSpotOntoLayer(PGraphics layer) {
    layer.pushMatrix();
    layer.scale(size);
    
    float x = (mouseScaledX / size) - gazemask.width / 2;
    float y = (mouseScaledY / size) - gazemask.height / 2;
    layer.image(gazemask, x, y);
    layer.popMatrix();
  }
}