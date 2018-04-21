/*****************************************************
 * class LLStack
 * Implements ADT stack as specified in local Stack.java
 * Generically typed
 * Uses a LinkedList as underlying container
 *****************************************************/

import java.util.LinkedList;

public class LLStack<T> implements Stack<T> 
{
  private LinkedList<T> _stack;

  //constructor
  public LLStack() 
  { 
    _stack = new LinkedList<T>();
  }


  //means of insertion
  public void push( T s ) 
  {
    _stack.add(s);
  }


  //means of viewing top element without removing
  public T peek( ) 
  { 
    T retVal = null;
    if ( isEmpty() )  return null;
    retVal = _stack.get( _stack.size()-1 );
    return retVal;
  }


  //means of removal
  public T pop( ) 
  { 
    T retVal = null;
    if ( isEmpty() )  return null;
    retVal = _stack.remove( _stack.size()-1 );
    return retVal;
  }


  //chk for emptiness
  public boolean isEmpty() 
  {
    return _stack.size() == 0;
  }
}//end class LLStack
