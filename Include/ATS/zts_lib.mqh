//+------------------------------------------------------------------+
//|                                                      zts_lib.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property strict

double calc_ATR(string symbol, int period, int numBars) {
  double atr = iATR(symbol,     // symbol
                    period,     // timeframe
                    numBars,    // averaging period
                    0);         // shift
  Debug(__FUNCTION__,__LINE__,"atr="+DoubleToStr(atr,2));
  Debug(__FUNCTION__,__LINE__,"period="+string(period));
  Debug(__FUNCTION__,__LINE__,"numBars="+string(numBars));
  atr = NormalizeDouble(atr, int(MarketInfo(symbol, MODE_DIGITS)-1));
  //Info(__FUNCTION__+": atr "+string(numBars)+" bars. period = "+string(period)+"  atr="+string(atr));
  return(atr);
}