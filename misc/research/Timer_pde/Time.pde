class Time
{
  //Instance variables
  
  //nanoseconds
  long start;
  long end;
  //seconds
  long elapsed;
  long target;
  
  //Default Constructor, target time can be modified later
  Time()
  {
    start = 0;
    end = 0;
    elapsed = 0;
    target = 0;
  }
  
  //Constructor sets the target time to be reached
  Time(long goalTime)
  {
    this();
    //should be in seconds
    target = goalTime;
  }
  
  //Starts the time
  void startTime()
  {
    start = System.nanoTime();
  }
  
  //Ends the current time
  void endTime()
  {
    end = System.nanoTime();
  }
  
  //Finds the elapsed time 
  long getElapsed()
  {
    elapsed = 0;
    if (start != 0)
    {
      endTime();
      elapsed = toSeconds(end-start);
    }
    return elapsed;
  }
  
  //Returns whether or not elapsed time has surpassed goal time
  boolean atGoal()
  {
    return getElapsed() >= target;
  }
  
  //Converts nanoTime to seconds
  long toSeconds(long time)
  {
  return time / 1000000000;
  }
  
  //Sets the target time (should be in seconds)
  void setGoal(long goalTime)
  {
    target = goalTime;
  }
}