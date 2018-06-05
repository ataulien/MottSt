//Class Time
class Time
{
  //Instance variables
  //nanoseconds
  long start;
  long end;
  //seconds
  long elapsed;
  long target;
  //Variables for pausing mechanism
  boolean pause;
  long pauseTime;
  long pauseTimeStart;

  //Default Constructor, target time can be modified later
  Time()
  {
    start = 0;
    end = 0;
    elapsed = 0;
    target = 0;
    pauseTime = 0;
  }

  //Constructor sets the target time to be reached
  Time(long goalTime)
  {
    this();
    //should be in seconds
    target = goalTime;
    //threshold = (goalTime*7)/10;
  }

  //String representation of the time passed
  String toString()
  {
    return "Time passed: " + getElapsed();
  }

  //Starts the time
  void startTime()
  {
    start = System.nanoTime();
  }

  //Pauses the countdown time of the Customer
  void pauseTime()
  {
    pauseTimeStart = System.nanoTime();
    pause = true;
  }

  //Ends the pause and resumes time
  void endPause()
  {
    pauseTime += System.nanoTime() - pauseTimeStart;
    pause = false;
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
    if (start != 0 && !pause) {
      endTime();
      elapsed = toSeconds(end - start - pauseTime);
      //println(elapsed);
    } else if (pause) {
      //println("pause");
      elapsed = toSeconds(pauseTimeStart - start);
    }
    return elapsed;
  }

  //Returns whether or not elapsed time has surpassed goal time
  boolean atGoal()
  {
    return getElapsed() >= target;
  }

  //Returns whether or not an interval of 8 seconds has passed since pause was initiated
  boolean endInterval()
  {
    return toSeconds(System.nanoTime() - pauseTimeStart) >= 8;
  }

  //Converts nanoTime to seconds
  long toSeconds(long time)
  {
    return time / 1000000000;
  }

  //Converts seconds to nanoTime
  long toNano(long time)
  {
    return time * 1000000000;
  }

  //Sets the target time (should be in seconds)
  void setGoal(long goalTime)
  {
    target = goalTime;
    //threshold = (goalTime * 7) / 10;
  }

  /*
  //Returns whether or not elapsed time has surpassed an inputted time
  boolean atInputTime(long input)
  {
    return toSeconds(System.nanoTime()-pauseTimeStart) >= input;
  }
  
  //Returns whether or not elapsed time has surpassed a threshold
  boolean atThreshold()
  {
    return getElapsed() >= threshold;
  }
  */
}
