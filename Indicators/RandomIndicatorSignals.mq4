//+------------------------------------------------------------------+
//|                                       RandomIndicatorSignals.mq4 |
//|                                                     Antonuk Oleg |
//|                                                   banderass@i.ua |
//+------------------------------------------------------------------+
#property copyright "Antonuk Oleg"
#property link      "banderass@i.ua"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Crimson
#property indicator_color2 RoyalBlue
//---- input parameters
extern int       barsToProcess=10000;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,236);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,238);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(1,0.0);
//----
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
      double randomValue=iCustom(NULL,0,"RandomIndicator",barsToProcess,0,i);
      
      if(randomValue>800.0)
         ExtMapBuffer1[i]=High[i]+5*Point;
      else
         ExtMapBuffer1[i]=0.0;
         
      if(randomValue<200.0)
         ExtMapBuffer2[i]=Low[i]-5*Point;         
      else
         ExtMapBuffer2[i]=0.0;         
   }
   
   return(0);
}
//+------------------------------------------------------------------+