//+------------------------------------------------------------------+
//|                                                message_alert.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+


//--------------------------------------------------------------------
// dialogue.mq4
// The code should be used for educational purpose only.
//--------------------------------------------------------------- 1 --
#include <WinUser32.mqh>               // Needed to MessageBox
extern double Time_News=15.30;         // Time of important news
bool Question=false;                   // Flag (question is not put yet)
//--------------------------------------------------------------- 2 --
int start()                            // Special function start
  {
   PlaySound("tick.wav");              // At each tick
   double Time_cur=Hour()+ Minute()/100.0;// Current time (double)
   if (OrdersTotal()>0 && Question==false && Time_cur<=Time_News-0.05)
     {                                 // Providing some conditions
      PlaySound("news.wav");           // At each tick
      Question=true;                   // Flag (question is already put)
      int ret=MessageBox("Time of important news release. Close all orders?",
      "Question", MB_YESNO|MB_ICONQUESTION|MB_TOPMOST); // Message box
      //--------------------------------------------------------- 3 --
      if(ret==IDYES)                   // If the answer is Yes
         Close_Orders();               // Close all orders
     }
   return;                             // Exit 
  }
//--------------------------------------------------------------- 4 --
void Close_Orders()                    // Cust. funct. for closing orders
  {
   Alert("Function of closing all orders is being executed.");// For illustration
   return;                             // Exit 
  }
//--------------------------------------------------------------- 5 --