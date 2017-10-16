//+------------------------------------------------------------------+
//|                                                     bar_size.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 clrGreen
#property indicator_width1 2

double BufferBarRange[];

#define BarRangeIndicator 0

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
    SetIndexBuffer(BarRangeIndicator,BufferBarRange);
    SetIndexStyle(BarRangeIndicator,DRAW_HISTOGRAM);
    SetIndexLabel(BarRangeIndicator,"Bar Range");
   
//---
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
//---
    int limit;
    double range;
    
    limit=rates_total-prev_calculated;
    if(prev_calculated>0) limit++;
    
    for(int i=limit-1; i>=0; i--) {
      range=High[i]-Low[i];
      BufferBarRange[i] = int(range / MarketInfo(Symbol(),MODE_POINT)/10);
    }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
