//+------------------------------------------------------------------+
//|                                             show_market_info.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  Alert(show_market_info("EURUSD"));
}

string show_market_info(string sym) {
  string str;
  str = "MODE_LOW = " + MarketInfo("EURUSD",MODE_LOW) + "\n"
        "MODE_HIGH = " + MarketInfo("EURUSD",MODE_HIGH) + "\n"
        "MODE_TIME = " + MarketInfo("EURUSD",MODE_TIME) + "\n"
        "MODE_BID = " + MarketInfo("EURUSD",MODE_BID) + "\n"
        "MODE_ASK = " + MarketInfo("EURUSD",MODE_ASK) + "\n"
        "MODE_POINT = " + MarketInfo("EURUSD",MODE_POINT) + "\n"
        "MODE_DIGITS = " + MarketInfo("EURUSD",MODE_DIGITS) + "\n"
        "MODE_SPREAD = " + MarketInfo("EURUSD",MODE_SPREAD) + "\n"
        "MODE_STOPLEVEL = " + MarketInfo("EURUSD",MODE_STOPLEVEL) + "\n"
        "MODE_LOTSIZE = " + MarketInfo("EURUSD",MODE_LOTSIZE) + "\n"
        "MODE_TICKVALUE = " + MarketInfo("EURUSD",MODE_TICKVALUE) + "\n"
        "MODE_TICKSIZE = " + MarketInfo("EURUSD",MODE_TICKSIZE) + "\n"
        "MODE_SWAPLONG = " + MarketInfo("EURUSD",MODE_SWAPLONG) + "\n"
        "MODE_SWAPLONG = " + MarketInfo("EURUSD",MODE_SWAPLONG) + "\n"
        "MODE_STARTING = " + MarketInfo("EURUSD",MODE_STARTING) + "\n"
        "MODE_EXPIRATION = " + MarketInfo("EURUSD",MODE_EXPIRATION) + "\n"
        "MODE_TRADEALLOWED = " + MarketInfo("EURUSD",MODE_TRADEALLOWED) + "\n"
        "MODE_MINLOT = " + MarketInfo("EURUSD",MODE_MINLOT) + "\n"
        "MODE_LOTSTEP = " + MarketInfo("EURUSD",MODE_LOTSTEP) + "\n"
        "MODE_MAXLOT = " + MarketInfo("EURUSD",MODE_MAXLOT) + "\n"
        "MODE_SWAPTYPE = " + MarketInfo("EURUSD",MODE_SWAPTYPE) + "\n"
        "MODE_PROFITCALCMODE = " + MarketInfo("EURUSD",MODE_PROFITCALCMODE) + "\n"
        "MODE_MARGINCALCMODE = " + MarketInfo("EURUSD",MODE_MARGINCALCMODE) + "\n"
        "MODE_MARGININIT = " + MarketInfo("EURUSD",MODE_MARGININIT) + "\n"
        "MODE_MARGINMAINTENANCE = " + MarketInfo("EURUSD",MODE_MARGINMAINTENANCE) + "\n"
        "MODE_MARGINHEDGED = " + MarketInfo("EURUSD",MODE_MARGINHEDGED) + "\n"
        "MODE_MARGINREQUIRED = " + MarketInfo("EURUSD",MODE_MARGINREQUIRED) + "\n"
        "MODE_FREEZELEVEL = " + MarketInfo("EURUSD",MODE_FREEZELEVEL) ;

   return str;
}
