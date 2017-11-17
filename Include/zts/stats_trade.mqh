//+------------------------------------------------------------------+
//|                                                  stats_trade.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <Position.mqh>
#include <zts\trade_type.mqh>
#include <zts\daily_pips.mqh>
#include <zts\daily_pnl.mqh>

const string orderTypeLookup[6] = {"Buy","Sell","BuyLimit","SellLimit","BuyStop","SellStop"};

void WriteTradeStats2File(Position *trade) {
  string fileName= TimeToStr(TimeCurrent(), TIME_DATE) +
          "_" + "trade_stats";
  StringReplace(fileName, ":", "_");
  fileName += ".csv";
  Alert(__FUNCTION__+": write trade stats to "+fileName);

  int fh1 = FileOpen(fileName, FILE_TXT | FILE_ANSI | FILE_WRITE | FILE_READ | FILE_CSV | FILE_SHARE_READ);
  if (fh1 != -1)
  {
    FileSeek(fh1, 0, SEEK_END);
    ulong filePos = FileTell(fh1);
    if (filePos == 0) {
      //FileWriteString(fh1,StringFormat("DataVersion: %i\r\n", DFVersion));
      //FileWriteString(fh1, StringFormat("Server Trade Date: %s\r\n", TimeToString(TimeCurrent(), TIME_DATE)));
      FileWrite(fh1,"LocalDate","LocalTime","SrvrDate","SrvrTime","Symbol","Strategy","PIPs","PnL","Point","Digits","LotSize","OpenPrice","ClosePrice","OrderType","OrderClosed",
              "OrderEntered","OrderOpened","StopPrice","TakeProfitPrice","TicketId",
              "UnRealPipsDay","RealPipsDay","UnReal$day","Real$day",robo.tradeStatsHeader());
    }
    double pips = trade.ClosePrice - trade.OpenPrice;
    if (trade.OrderType == OP_SELL) pips *= -1;
    double profit = NormalizeDouble(pips, Digits)/Point * trade.LotSize; 
    string strategy = GetTradeType();
    int now = int(TimeLocal());
    FileWrite(fh1,string(TimeYear(now)*10000+TimeMonth(now)*100+TimeDay(now)),TimeToString(TimeLocal(), TIME_SECONDS),
                  string(Year()*10000+Month()*100+Day()),TimeToString(TimeCurrent(), TIME_SECONDS),
                  trade.Symbol,strategy,DoubleToStr((pips)*MathPow(10,(Digits-1)),Digits),
                  DoubleToStr(profit,2),DoubleToStr(Point,Digits),Digits,
                  trade.LotSize,trade.OpenPrice,trade.ClosePrice,orderTypeLookup[trade.OrderType],trade.OrderClosed,
                  trade.OrderEntered,
                  trade.OrderOpened,DoubleToStr(trade.StopPrice,Digits),trade.TakeProfitPrice,
                  trade.TicketId,
                  DoubleToString(UnRealizedPipsToday(),2),
                  DoubleToString(RealizedPipsToday(),2),
                  DoubleToString(UnRealizedProfitToday(),2),
                  DoubleToString(RealizedProfitToday(),2),robo.tradeStats());
    FileClose(fh1);
  }
  else
  {
      Alert("fh1 is less than -1");
  }
}
