/*****************************************************
 * class ALQueue
 * uses an ArrayList to implement abstract data type QUEUE
 * (a collection with FIFO property)
 *
 *       -------------------------------
 *   end |  --->   Q U E U E   --->    | front
 *       -------------------------------
 * 
 * index 0 of ArrayList is front of queue
 ******************************************************/

public class ALQueue<T> implements Queue<T> 
{
  private ArrayList<T> _queue;

  // default constructor
  public ALQueue() 
  { 
    _queue = new ArrayList<T>();
  }


  // means of adding an item to collection 
  public void enqueue( T x ) 
  {
    _queue.add(x);
  }//O(1) expected, O(n) rarely


  // means of removing an item from collection 
  public T dequeue() 
  {
    if (!isEmpty())
    {
      return _queue.remove(0);
    }
    return null;
  }//O(n) bc n-1 shifted


  // means of "peeking" at the front item
  public T peekFront() 
  {
    if (!isEmpty())
    {
      return _queue.get(0);
    }
    return null;
  }//O(1)


  // means of checking to see if collection is empty
  public boolean isEmpty() 
  {
    return _queue.size() == 0;
  }//O(1)


  public String toString() 
  {
    return _queue.toString();
  }//O(n)
}//end class ALQueue
