//Class Console
class Console
{
  //Instance Variables
  Waiter w;
  PFont type;
  PImage paper;

  //Console: takes in a Waiter
  Console(Waiter wait)
  {
    w = wait;
    type = createFont("A2Font.ttf", 15);
    paper = loadImage("Images/paper.jpg");
    paper.resize(300, 200);
  }

  //Displays the console and the statuses of the table and the waiter's platter
  void display()
  {
    //rect(950,160,300,200);
    image(paper, 950, 160);
    textSize(14);
    textFont(type);
    text("Current Status:", 960, 175);
    //Displays the status of the food the waiter is carrying
    if (w.finishedOrders[0] == null)
    {
      if (w.finishedOrders[1] == null)
      {
        text("Platter: nothing", 960, 195);
      } else
      {
        text("Platter: Table #" + w.finishedOrders[1].table.tableNum, 960, 195);
      }
    } else if (w.finishedOrders[1] == null)
    {
      text("Platter: Table #" + w.finishedOrders[0].table.tableNum, 960, 195);
    } else {
      text("Platter: Table #" + w.finishedOrders[0].table.tableNum + ", Table #" + w.finishedOrders[1].table.tableNum, 960, 195);
    }

    //Displays the status of the tables
    int y = 195;
    for (Table t : w.tables)
    {
      //Based on the state, would display different messages. 
      String s = "Table #" + t.tableNum + ":";
      if (t.state == TableState.EMPTY)
      {
        s += " No customer.";
      } else if (t.state == TableState.CUSTOMER_READING_MENU_OR_READY_TO_ORDER)
      {
        if (!t.sittingCustomer.wait.pause)
          s += " Ready to order.";
        else
          s += " Reading menu...";
      } else if (t.state == TableState.CUSTOMER_WAITING_FOR_FOOD_OR_EATING)
      {
        if (!t.sittingCustomer.wait.pause)
          s += " Waiting for food.";
        else
          s += " Eating food...";
      } else if (t.state == TableState.CUSTOMER_READY_TO_PAY)
      {
        s += " Ready to pay.";
      }
      text(s, 960, y + 20);
      y += 28;
    }
  }
}
