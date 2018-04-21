import com.sun.jna.Native;

class IViewInterface
{
  private static final IViewNative dll = (IViewNative)Native.loadLibrary("iViewXAPI.dll", IViewNative.class);

  public class IViewException extends Exception {
    public IViewException(String msg) {
      super(msg);
    }
  }

  /* ---------------- */

  public void connect(String sendIP, int sendPort, String receiveIP, int receivePort) throws IViewException {
    int result = dll.iV_Connect(sendIP, sendPort, receiveIP, receivePort);

    throwOnErrorCode(result);
  }

  public void disconnect() throws IViewException {
    int result = dll.iV_Disconnect();

    throwOnErrorCode(result);
  }

  public IViewNative.SampleData getSample() throws IViewException {

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

    case IViewNative.ERR_IVIEWX_NOT_FOUND: 
      throw new IViewException("IView not found");

    case IViewNative.ERR_EYETRACKING_APPLICATION_NOT_RUNNING: 
      throw new IViewException("Eyetracking application not running");

    case IViewNative.ERR_WRONG_PARAMETER: 
      throw new IViewException("Wrong parameter");

    case IViewNative.ERR_COULD_NOT_CONNECT: 
      throw new IViewException("Could not connect");

    default:
      throw new IViewException("Unknown IView-Return-Code");
    }
  }
}
