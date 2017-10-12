//+------------------------------------------------------------------+
//|                                       CloseAllPendingAdvance.mq4 |
//|                                                  ThinkTrustTrade |
//|                                        www.think-trust-trade.com |
//+------------------------------------------------------------------+
#property copyright "ThinkTrustTrade"
#property link      "www.think-trust-trade.com"
#property show_inputs

extern string  Visit="www.think-trust-trade.com";
extern string  Like="www.facebook.com/ThinkTrustTrade";
extern bool limit_buy=true;
extern bool stop_buy=true;
extern bool limit_sell=true;
extern bool stop_sell=true;
extern int only_magic=0;
extern int skip_magic=0;
extern bool only_below_symbol=false;
extern string symbol="EURUSD";

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
bool deleted;
if (OrdersTotal()==0) return(0);
for (int i=OrdersTotal()-1; i>=0; i--)
      {//pozicio kivalasztasa
       if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true)//ha kivalasztas ok
            {
            //Print ("order ticket: ", OrderTicket(), "order magic: ", OrderMagicNumber(), " Order Symbol: ", OrderSymbol());
            if (only_magic>0 && OrderMagicNumber()!=only_magic) continue;
            if (skip_magic>0 && OrderMagicNumber()==skip_magic) continue;
            if (only_below_symbol==true && OrderSymbol()!=symbol) 
            {Print("order symbol different"); continue;}
            if (OrderType()==2 && limit_buy==true)
               {//ha long
               //Print ("Error: ",  GetLastError());
               deleted=OrderDelete(OrderTicket());
               //Print ("Error: ",  GetLastError(), " price: ", MarketInfo(OrderSymbol(),MODE_BID));
               if (deleted==false) Print ("Error: ",  GetLastError());
               if (deleted==true) Print ("Order ", OrderTicket() ," Deleted. Thank you for using our script! Visit www.think-trust-trade.com for more free tools.");
               }
            if (OrderType()==4 && stop_buy==true)
               {//ha short
               //Print ("Error: ",  GetLastError());
               deleted=OrderDelete(OrderTicket());
               //Print ("Error: ",  GetLastError(), " price: ", MarketInfo(OrderSymbol(),MODE_ASK));
               if (deleted==false) Print ("Error: ",  GetLastError());
               if (deleted==true) Print ("Order ", OrderTicket() ," Deleted. Thank you for using our script! Visit www.think-trust-trade.com for more free tools.");
               
               }   
            if (OrderType()==3 && limit_sell==true)
               {//ha long
               //Print ("Error: ",  GetLastError());
               deleted=OrderDelete(OrderTicket());
               //Print ("Error: ",  GetLastError(), " price: ", MarketInfo(OrderSymbol(),MODE_BID));
               if (deleted==false) Print ("Error: ",  GetLastError());
               if (deleted==true) Print ("Order ", OrderTicket() ," Deleted. Thank you for using our script! Visit www.think-trust-trade.com for more free tools.");
               
               }
            if (OrderType()==5 && stop_sell==true)
               {//ha short
               //Print ("Error: ",  GetLastError());
               deleted=OrderDelete(OrderTicket());
               //Print ("Error: ",  GetLastError(), " price: ", MarketInfo(OrderSymbol(),MODE_ASK));
               if (deleted==false) Print ("Error: ",  GetLastError());
               if (deleted==true) Print ("Order ", OrderTicket() ," Deleted. Thank you for using our script! Visit www.think-trust-trade.com for more free tools.");
               
               }   
            }
      }//pozicio kivalszatas vege
  
//----
   return(0);
  }
//+------------------------------------------------------------------+ 

