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
  return(atr);
}

int calcPatiPips(string symbol) {
  int defaultStopPips = 12;
  string PatiExceptionPairs = "EURUSD/8;AUDUSD,GBPUSD,EURJPY,USDJPY,USDCAD/10";

  int stop = defaultStopPips;
  int pairPosition = StringFind(PatiExceptionPairs, symbol, 0);
  if (pairPosition >=0) {
    int slashPosition = StringFind(PatiExceptionPairs, "/", pairPosition) + 1;
    stop =int( StringToInteger(StringSubstr(PatiExceptionPairs,slashPosition)));
  }
  return stop;
}
