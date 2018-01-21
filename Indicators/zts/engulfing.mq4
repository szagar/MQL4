//+------------------------------------------------------------------+
//|                                                    engulfing.mq4 |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 clrBlue
#property indicator_color2 clrBlue
#property indicator_width1 13
#property indicator_width2 13

extern bool Bullish=true;
extern bool Bearish=true;

double BodyHigh[],BodyLow[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BodyHigh);
   SetIndexBuffer(1,BodyLow);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
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
  for(int i=MathMax(Bars-2-IndicatorCounted(),1);i>=0;i--) {
    double hi=high[i],lo=low[i],prevhi=high[i+1],prevlo=low[i+1];
    double bodyhigh=MathMax(close[i],open[i]);
    double bodylow=MathMin(close[i],open[i]);
    if(hi>prevhi && lo<prevlo)
      if( (Bullish && Bearish) ||
          (Bullish && close[i]>open[i]) ||
          (Bearish && close[i]<open[i]) )
        drawbody(i,bodyhigh,bodylow);
  }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
  
void drawbody(int b,double hi, double lo) {
      BodyHigh[b] = hi;
      BodyLow[b] = lo;
}
//+------------------------------------------------------------------+
