//+------------------------------------------------------------------+
//|                                                          poi.mq4 |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
//#property version   "1.00"
//#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 White

#include <dev\logger.mqh>
#include <dev\enum_types.mqh>
#include <dev\Poi.mqh>
#include <dev\Distance.mqh>
#include <dev\TradingSessions.mqh>

extern bool Testing = false;

extern Enum_LogLevels LogLevel = LogDebug;  //> Log Level
extern int Slippage=5;                     //> Slippage in pips

double longPoi[], shortPoi[], distance[];
Poi *poi;
Distance *dist;
TradingSessions *session;
  
int init() {
  poi = new Poi();
  dist = new Distance();
  session = new TradingSessions();
  
  session.setSession(NewYork);
  
  SetIndexStyle(0,DRAW_LINE);
  SetIndexShift(0,0);
  SetIndexDrawBegin(0,0);
  SetIndexBuffer(0,longPoi);

  SetIndexStyle(1,DRAW_LINE);
  SetIndexShift(1,0);
  SetIndexDrawBegin(1,0);
  SetIndexBuffer(1,shortPoi);

  SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_DOT);
  SetIndexShift(2,0);
  SetIndexDrawBegin(2,0);
  SetIndexBuffer(2,distance);
  return(0);
}
  
int deinit() {
  return(0);
}

int start() {
   int limit;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   for(int x=0; x<limit; x++) {
     Comment(TimeCurrent()+"   :   "+Time[0]);
     if(session.isSOS(Time[0]))
       poi.setPOI(x);
     longPoi[x] = poi.POI_Long + dist.getDistance();
     shortPoi[x] = poi.POI_Short - dist.getDistance();
     distance[x]= 1;

   }
   return(0);
  }
  
