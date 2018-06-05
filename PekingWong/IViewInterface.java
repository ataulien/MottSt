import com.sun.jna.Native;

class IViewInterface
{
  private IViewNative dll;
  private Native dllMisc1;
  private Native dllMisc2;

  public class IViewException extends Exception
  {
    public IViewException(String msg) {
      super(msg);
    }
  }

  /* ---------------- */

  public IViewInterface(String dllSearchPath)
  {
    dll = (IViewNative)Native.loadLibrary(dllSearchPath + "\\iViewXAPI.dll", IViewNative.class);
    
    // Must load these two DLLs as well, otherwise we get errorcode 401 (func not loaded) from all function calls to iview
    Native.loadLibrary(dllSearchPath + "\\iViewXAPIL.dll", IViewNative.class);
    Native.loadLibrary(dllSearchPath + "\\iViewXAPIR.dll", IViewNative.class);
  }

  public void connect(String sendIP, int sendPort, String receiveIP, int receivePort) throws IViewException
  {
    int result = dll.iV_Connect(sendIP, sendPort, receiveIP, receivePort);

    throwOnErrorCode(result);
  }
  
  public void setupCalibration(final IViewNative.CalibrationStruct c) throws IViewException
  {
    int result = dll.iV_SetupCalibration(c);
    
    throwOnErrorCode(result);
  }
  
  public void calibrate() throws IViewException
  {
    int result = dll.iV_Calibrate();
    
    throwOnErrorCode(result);
  }
  
  public void calibrate5Point() throws IViewException
  {
    IViewNative.CalibrationStruct c = new IViewNative.CalibrationStruct();
    c.displayDevice = 0; // use main monitor only
    c.autoAccept = 1;
    c.method = 5; // 5-point calibration
    c.visualization = 1;
    c.speed = 0;
    c.targetShape = 2;
    c.backgroundColor = 230;
    c.foregroundColor = 250;
    c.targetSize = 20;
    c.targetFilename = "";
    
    setupCalibration(c);
    calibrate();
  }
  
  public void setLogger(int logLevel, String filename) throws IViewException
  {
    int result = dll.iV_SetLogger(logLevel, filename);
    
    throwOnErrorCode(result);
  }

  public void disconnect() throws IViewException
  {
    int result = dll.iV_Disconnect();

    throwOnErrorCode(result);
  }

  public IViewNative.SampleData getSample() throws IViewException
  {
    final IViewNative.SampleData sampleData = new IViewNative.SampleData();

    int result = dll.iV_GetSample(sampleData); 

    throwOnErrorCode(result);

    return sampleData;
  }

  private void throwOnErrorCode(int iviewReturnCode) throws IViewException 
  {
    switch(iviewReturnCode)
    {
    case IViewNative.RET_SUCCESS: 
      return;

    default:
      throw new IViewException("See Return code: " + iviewReturnCode);
    }
  }
}
