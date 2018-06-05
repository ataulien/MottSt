class Level
{
  public static int numTables = 3;
  public static int numCustomers = 10;
  public static int currentLevel = 1;
  public static float gazeMaskSize = 1.0f;
  private static boolean isDone = false;

  {
    configureLevel(currentLevel);
  }

  public static void configureLevel(int num)
  {
    switch(num) {
      case 1:
        numTables = 4;
        numCustomers = 20;
        gazeMaskSize = 1.0f;
        break;
      case 2:
        numTables = 5;
        numCustomers = 25;
        gazeMaskSize = 1.0f;
        break;
      case 3:
        numTables = 6;
        numCustomers = 30;
        gazeMaskSize = 0.75f;
        break;
      default:
        isDone = true;
        break;
    }
    currentLevel = num;
  }

  public static boolean isDone()
  {
    return isDone;
  }

  public static void nextLevel()
  {
    configureLevel(currentLevel + 1);
  }

  public static int getCurrentLevel()
  {
    return currentLevel;
  }
}
