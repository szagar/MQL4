//+------------------------------------------------------------------+
//|                                            close-all-orders.mq4  |
//|                                  Copyright © 2005, Matias Romeo. |
//|                                       Custom Metatrader Systems. |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2005, Matias Romeo."
#property link      "mailto:matiasDOTromeoATgmail.com"

int start()
{
  int total = OrdersTotal();
  for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();

    bool result = false;
    
    switch(type)
    {
      //Close opened long positions
      case OP_BUYSTOP    : result = OrderDelete( OrderTicket());
                          break;
      
      //Close opened short positions
      case OP_SELLSTOP   : result = OrderDelete( OrderTicket());
                          
    }
    
    if(result == false)
    {
      Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
      Sleep(3000);
    }  
  }
  
  return(0);
}