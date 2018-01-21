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
  atr = NormalizeDouble(atr, int(MarketInfo(symbol, MODE_DIGITS)-1));
  //Info(__FUNCTION__+": atr "+string(numBars)+" bars. period = "+string(period)+"  atr="+string(atr));
  return(atr);
}