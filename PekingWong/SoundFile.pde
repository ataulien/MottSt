import processing.sound.*;

public class SoundFile
{
  private boolean enable = true;
  private processing.sound.SoundFile realFile = null;

  public SoundFile(PApplet parent, String file) {
    if (enable) {
      realFile = new processing.sound.SoundFile(parent, file);
    }
  }

  public void play() {
    if (enable) {
      realFile.play();
    }
  }

  public void loop() {
    if (enable) {
      realFile.loop();
    }
  }

  public void amp(float v) {
    if (enable) {
      realFile.amp(v);
    }
  }

  public void pan(float v) {
    if (enable) {
      realFile.pan(v);
    }
  }
}