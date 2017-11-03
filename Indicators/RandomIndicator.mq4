//+------------------------------------------------------------------+
//|                                              RandomIndicator.mq4 |
//|                                                     Antonuk Oleg |
//|                                                   banderass@i.ua |
//+------------------------------------------------------------------+
#property copyright "Antonuk Oleg"
#property link      "banderass@i.ua"

#property indicator_level1 800.0
#property indicator_level2 200.0
#property indicator_levelcolor LimeGreen
#property indicator_levelwidth 2
#property indicator_levelstyle STYLE_SOLID

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DarkOrchid



//---- input parameters
extern int       barsToProcess=100;
//---- buffers
double ExtMapBuffer1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
//----

   MathSrand(TimeLocal());
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars=IndicatorCounted(),
       limit;

   if(counted_bars>0)
      counted_bars--;
   
   limit=Bars-counted_bars;
   
   if(limit>barsToProcess)
      limit=barsToProcess;
  
   for(int i=0;i<limit;i++)
   {
      ExtMapBuffer1[i]=MathRand()%1001;
   }
   
   return(0);
}
//+------------------------------------------------------------------+