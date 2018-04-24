//+------------------------------------------------------------------+
//|                                                  BreakOutPOI_NoIn.mq4 |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

#include <dev\Poi_NoIn.mqh>
#include <dev\Distance_NoIn.mqh>

double longPoi[], shortPoi[];
Poi *poi;
Distance *dist;

int OnInit() {
  poi = new Poi();
  dist = new Distance();

  SetIndexBuffer(0,longPoi);
  SetIndexStyle(0,DRAW_LINE);
  SetIndexShift(0,0);
  SetIndexDrawBegin(0,0);
  SetIndexLabel(0,"UpperPOI");

  SetIndexBuffer(1,shortPoi);
  SetIndexStyle(1,DRAW_LINE);
  SetIndexShift(1,0);
  SetIndexDrawBegin(1,0);
  SetIndexLabel(1,"LowerPOI");
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
  int limit;

  limit=rates_total-prev_calculated;
  if(prev_calculated>0) limit++;

  //Print("limit="+limit);
  for(int i=limit-1; i>=0; i--) {
    poi.setPOI(i);
    //Print("longPoi[i] = "+poi.POI_Long+" + "+dist.getDistance());
    longPoi[i] = poi.POI_Long + dist.getDistance();
    shortPoi[i] = poi.POI_Short - dist.getDistance();
    //Print("longPoi["+i+"]="+longPoi[i]+"   shortPoi["+i+"]="+shortPoi[i]);   
  }
   
   return(rates_total);
  }
//+------------------------------------------------------------------+
