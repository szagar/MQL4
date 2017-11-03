//+------------------------------------------------------------------+
//|                                                  robot_roc_1.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


#include <stderror.mqh>
#include <stdlib.mqh>

static color   clBuy = DodgerBlue;
static color   clSell = Crimson;

int debug = true;
#include <zts\position_sizing.mqh>
#include <zts\next_pati_level.mqh>

extern int     Magic = 12347;
static int     Dig;
   int     Slippage=30;
   
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
  Dig = MarketInfo(Symbol(), MODE_DIGITS);
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
  if(NewBar()) {
/*
   MqlRates rates[]; 
   ArraySetAsSeries(rates,true); 
   int copied=CopyRates(Symbol(),0,0,10,rates); 
   if(copied>0) 
     { 
      Print("Bars copied: "+copied); 
      string format="open = %G, high = %G, low = %G, close = %G, volume = %d"; 
      string out; 
      int size=fmin(copied,10); 
      for(int i=0;i<size;i++) 
        { 
         out=i+":"+TimeToString(rates[i].time); 
         out=out+" "+StringFormat(format, 
                                  rates[i].open, 
                                  rates[i].high, 
                                  rates[i].low, 
                                  rates[i].close, 
                                  rates[i].tick_volume); 
         Print(out); 
        } 
     } 
*/
    //RefreshRates();
    //Print("symbol=",Symbol()," ",iTime(NULL,PERIOD_M15,1),"  ",iOpen(NULL,PERIOD_M15,1),"/",iHigh(NULL,PERIOD_M15,1),"/",iLow(NULL,PERIOD_M15,1),"/",iClose(NULL,PERIOD_M15,1));
    if(checkBuySignal()) {
      //double entryStop = iHigh(NULL,PERIOD_M15,1);
      //double stopLoss = iLow(NULL,PERIOD_M15,1);
      double entryStop = iHigh(NULL,0,1);
      double stopLoss = iLow(NULL,0,1);
      double stopPts = MathMax(entryStop-stopLoss,0.0010);
      stopLoss = entryStop - stopPts;
      placeBuyOrder(Symbol(), entryStop, stopLoss, 1);
    }
  }
}
//---
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester() {
   double ret=0.0;
   return(ret);
  }
//+------------------------------------------------------------------+

bool NewBar() {
  static datetime lastbar;
  datetime curbar = Time[0];
  if(lastbar!=curbar) {
    lastbar=curbar;
    return (true);
  }
  else { 
    return(false);
  }
}
  
bool checkBuySignal() {
   double roc = iCustom(NULL,0,"rocseparate",5,0);
   double roc_prec = iCustom(NULL,0,"rocseparate",5,1);
   if(roc>roc_prec && (roc*roc_prec)<0 && MathAbs(roc-roc_prec/roc_prec)>0.5) {
     Alert("Buy Signal: " + DoubleToString(roc,4) + "   /  " + DoubleToString(roc_prec,4) + " ==> " +DoubleToString((roc-roc_prec)/roc_prec,2));
     return(true);
   }
   return(false);
}

void placeBuyOrder(string symbol, double stopEntry, double stopLoss, int tifBars) {
  bool status;
  Alert("Buy "+symbol+" stopEntry="+DoubleToStr(stopEntry,4)+" stopLoss="+DoubleToStr(stopLoss,4)+" tif="+string(tifBars)+" bars");

  double size = CalcTradeSize(0.5,stopLoss);
  double targetPrice = stopEntry + 0.00;  //GetNextLevel(stopEntry + 1.5*stopLoss, 1);
  status = Order(symbol, OP_BUY, stopEntry, size,
          targetPrice, stopLoss, "roc robot 1");
  if(status)
    Alert("New order sent");
  else
    Alert("Order failed, "+GetLastError());
}



//+------------------------------------------------------------------+
//| Closes an order at market                                        |
//+------------------------------------------------------------------+
int CloseMarket(int Ticket)
{
   //extern int     Slippage=30;

   #define SLEEP_OK     250
#define SLEEP_ERR    250

   int    Type, ErrorCode;
   double Price, Quantity;
   OrderSelect(Ticket, SELECT_BY_TICKET);
   Type = OrderType();
   Quantity = OrderLots();
   while (TRUE) {             // Keep trying until the order really is closed
      if (Type == OP_BUY)
         Price=Bid;
      else if (Type == OP_SELL)
         Price=Ask;
      else
         return (-1);
      Print("CLOSE ", Ticket, ", ", Quantity, ", ", Price);
      if (OrderClose(Ticket, Quantity, Price, Slippage, CLR_NONE) == TRUE) {
         Sleep(SLEEP_OK);
         return (0);
      }
      else {
         ErrorCode = GetLastError();
         Print("Error closing order ", Ticket, ": ", ErrorDescription(ErrorCode),
               " (", ErrorCode, ")", " size: ", Quantity, ", prices: ",
               Price, ", ", Bid, ", ", Ask);
         Sleep(SLEEP_ERR);
         RefreshRates();
      }
   }
   return (-1);
}

//+------------------------------------------------------------------+
//| Places an order                                                  |
//+------------------------------------------------------------------+
int Order(string symbol, int Type, double Entry, double Quantity,
          double TargetPrice, double StopPrice, string comment="") {
   string TypeStr;
   color  TypeCol;
   int    ErrorCode, Ticket;
   double Price, FillPrice;
   Price = NormalizeDouble(Entry, Dig);
   switch (Type) {
      case OP_BUY:
         TypeStr = "BUY";
         TypeCol = clBuy;
         break;
      case OP_SELL:
         TypeStr = "SELL";
         TypeCol = clSell;
         break;
      default:
         Print("Unknown order type ", Type);
         break;
   }
   Ticket = OrderSend(symbol, Type, Quantity, Price, Slippage,
              StopPrice, TargetPrice, comment, Magic, 0, TypeCol);
   if (Ticket >= 0) {
      Sleep(SLEEP_OK);
      if (OrderSelect(Ticket, SELECT_BY_TICKET) == TRUE) {
         FillPrice = OrderOpenPrice();
         if (Entry != FillPrice) {
            RefreshRates();
            Print("Slippage on order ", Ticket, " - Requested = ",
                  Entry, ", Fill = ", FillPrice, ", Current Bid = ",
                  Bid, ", Current Ask = ", Ask);
         }
      }
      else {
         ErrorCode = GetLastError();
         Print("Error selecting new order ", Ticket, ": ",
               ErrorDescription(ErrorCode), " (", ErrorCode, ")");
      }
      return (Ticket);
   }
   ErrorCode = GetLastError();
   RefreshRates();
   Print("Error opening ", TypeStr, " order: ", ErrorDescription(ErrorCode),
         " (", ErrorCode, ")", ", Entry = ", Price, ", Target = ",
         TargetPrice, ", Stop = ", StopPrice, ", Current Bid = ", Bid,
         ", Current Ask = ", Ask);
   Sleep(SLEEP_ERR);
   return (-1);
}