import com.sun.jna.Native;

class IViewInterface
{
  private IViewNative dll;

  public class IViewException extends Exception {
    public IViewException(String msg) {
      super(msg);
    }
  }

  /* ---------------- */

  public IViewInterface(String dllSearchPath) {
      dll = (IViewNative)Native.loadLibrary(dllSearchPath + "\\iViewXAPI.dll", IViewNative.class);
  }

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

    default:
      throw new IViewException("See Return code: " + iviewReturnCode);
    }
  }
}
