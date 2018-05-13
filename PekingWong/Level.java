class Level
{
    public static int numTables = 3;
    public static int numCustomers = 10;
    public static float gazeMaskShrinkingSpeed = 0.0f;
    private static boolean isDone = false;
    private static int currentLevel = 1;

    {
        configureLevel(currentLevel);
    }

    public static void configureLevel(int num) {
        switch(num) {
        case 1:
            numTables = 5;
            numCustomers = 5;
            break;
        case 2:
            numTables = 4;
            numCustomers = 7;
            break;
        case 3:
            numTables = 5;
            numCustomers = 8;
            break;

        default:
            isDone = true;
            break;
        }

        currentLevel = num;
    }

    public static boolean isDone() {
        return isDone;
    }

    public static void nextLevel() {
        configureLevel(currentLevel + 1);
    }

    public static int getCurrentLevel() {
        return currentLevel;
    }
}
