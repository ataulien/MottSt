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

  public void pan(int tableNum) {
    if (enable) {
      switch (tableNum) {
        case 1: case 4:
          realFile.pan(panL);
          break;
        case 2: case 5:
          realFile.pan(panM);
          break;
        case 3: case 6:
          realFile.pan(panR);
          break;
        default:
          break;
      }
    }
  }
}
