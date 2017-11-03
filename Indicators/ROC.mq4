//+------------------------------------------------------------------+
//|                                                          ROC.mq4 |
//|                                         Rate Of Change indicator |
//|                                         Copyright 2017, SSTL LLC |
//|                                                     https://www. |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, SSTK LLC"
#property link      "https://www..com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 clrGreen
#property indicator_width1 2

extern int barsBack=10;   // Fast EMA Period

double BufferROC2bar[];

#define ROC2minIndicator 0

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
  //--- indicator buffers mapping
  SetIndexBuffer(ROC2minIndicator,BufferROC2bar);
  SetIndexStyle(ROC2minIndicator,DRAW_HISTOGRAM);
  SetIndexLabel(ROC2minIndicator,"ROC 2bar");

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
                const int &spread[]) {
  int limit;
  double roc;
    
  limit=rates_total-prev_calculated;
  if(prev_calculated>0) limit++;
    
  for(int i=limit-barsBack-1; i>=0; i--) {
    roc = 100.0 * (Close[i] - Close[i+barsBack]) / Close[i+barsBack];
    BufferROC2bar[i] = roc;
    //range=High[i]-Low[i];
    //BufferBarRange[i] = int(range / MarketInfo(Symbol(),MODE_POINT)/10);
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
