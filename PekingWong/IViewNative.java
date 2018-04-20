
import com.sun.jna.Library;
import com.sun.jna.Native;
import com.sun.jna.Platform;
import com.sun.jna.Structure;

import java.util.List;
import java.util.Arrays;

interface IViewNative extends Library {

  public static final int RET_SUCCESS = 0;                             // Intended functionality has been fulfilled
  public static final int ERR_IVIEWX_NOT_FOUND = 1;                    // No SMI eye tracking application detected
  public static final int ERR_EYETRACKING_APPLICATION_NOT_RUNNING = 2; // No SMI eye tracking application running
  public static final int ERR_WRONG_PARAMETER = 4;                     // Parameter out of range
  public static final int ERR_COULD_NOT_CONNECT = 5;                   // Failed to establish connection

  public static class EyeData extends Structure {
    public static class ByReference extends EyeData implements Structure.ByReference {
    }

    protected List<String> getFieldOrder() {
      return Arrays.asList(new String[] { 
        "gazeX", 
        "gazeY", 
        "pupilDiameter", 
        "eyePostionX", 
        "eyePostionY", 
        "eyePostionZ", 
        });
    }

    public double gazeX;
    public double gazeY;
    public double pupilDiameter; // pixel/mm
    public double eyePositionX;
    public double eyePositionY;
    public double eyePositionZ;
  }

  public static class SampleData extends Structure {
    public static class ByReference extends SampleData implements Structure.ByReference {
    }


    protected List<String> getFieldOrder() {
      return Arrays.asList(new String[] { 
        "timestamp", 
        "leftEye", 
        "rightEye", 
        "planeNumber", 
        });
    }

    public long timesstamp;
    public EyeData leftEye;
    public EyeData rightEye;
    public int planeNumber;
  }

  public int iV_Connect(String sendIP, int sendPort, String receiveIP, int receivePort);
  public int iV_Disconnect();
  public int iV_GetSample(SampleData pSampleData);
}
