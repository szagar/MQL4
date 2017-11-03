//+------------------------------------------------------------------+
//|                                                    stats_eod.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <zts\daily_pnl.mqh>

void StatsEndOfDay(string fname="") {
  int fh = FileOpen(fname, FILE_TXT | FILE_ANSI | FILE_WRITE | FILE_READ | FILE_CSV);
  if (fh != -1) {
    FileSeek(fh, 0, SEEK_END);
    ulong filePos = FileTell(fh);
    if (filePos == 0) {    // First write to this file
      FileWriteString(fh, StringFormat("Server Trade Date: %s\r\n", TimeToString(TimeCurrent(), TIME_DATE)));
      FileWrite(fh,"LocalDate","LocalTime","SrvrDate","SrvrTime","PIPs","RealPips","UnRealPips","PnL","RealPnL","UnRealPnL","Count","Balance");
    }
    datetime now = TimeLocal();
    FileWrite(fh,string(TimeYear(now)*10000+TimeMonth(now)*100+TimeDay(now)),TimeToString(TimeLocal(), TIME_SECONDS),
                 string(Year()*10000+Month()*100+Day()),TimeToString(TimeCurrent(), TIME_SECONDS),
                 DoubleToString(dailyPips_live(),2),
                 DoubleToStr(RealizedPipsToday(),2),
                 DoubleToStr(UnRealizedPipsToday(),2),
                 DoubleToStr(dailyPnL_live(),2),
                 DoubleToString(RealizedProfitToday(),2),
                 DoubleToString(UnRealizedProfitToday(),2),
                 0,string(AccountEquity()),string(AccountBalance()));
                
               
    FileClose(fh);
  }
  else {
      Alert("fh ("+FnEodStats+") is less than -1");
  }
}
