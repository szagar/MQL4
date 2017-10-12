//+------------------------------------------------------------------+
//|                                             orderselect_info.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

static string OrderTypes[6] = {"Buy","Sell","Buy Limit","Sell Limit","Buy Stop","Sell Stop"};
string OrderSelectInfo() {
  string str;
  str = "Ticket      = " + string(OrderTicket()) + "\n"
        "Price       = " + string(OrderClosePrice()) + "\n"
        "CloseTime   = " + string(OrderCloseTime()) + "\n"
        "Comment     = " + OrderComment() + "\n"
        "Commission  = " + string(OrderCommission()) + "\n"
        "Expiration  = " + string(OrderExpiration()) + "\n"
        "Lots        = " + string(OrderLots()) + "\n"
        "MagicNumber = " + string(OrderMagicNumber()) + "\n"
        "OpenPrice   = " + string(OrderOpenPrice()) + "\n"
        "OpenTime    = " + string(OrderOpenTime()) + "\n"
//        "Print       = " + OrderPrint() + "\n"
        "Profit      = " + string(OrderProfit()) + "\n"
        "StopLoss    = " + string(OrderStopLoss()) + "\n"
        "Swap        = " + string(OrderSwap()) + "\n"
        "Symbol      = " + OrderSymbol() + "\n"
        "TakeProfit  = " + string(OrderTakeProfit()) + "\n"
        "Type        = " + string(OrderType()) + " (" + OrderTypes[OrderType()] + ")" ;
  return str;
}

//void ShowTradeInfo(Position *trade)
//{
//  printf("Account leverage = %f\n",AccountLeverage());
//  printf("Account margin = %f\n",AccountMargin());
//  Alert(
//    "TicketId        = " + string(trade.TicketId) + "\n" +     // = OrderTicket();
//    "OrderType       = " + string(trade.OrderType) + "\n"      // = OrderType();
//    "IsPending       = " + string(trade.IsPending) + "\n"      // = newTrade.OrderType != OP_BUY && newTrade.OrderType != OP_SELL;
//    "Symbol          = " + trade.Symbol + "\n"      // = NormalizeSymbol(OrderSymbol());
//    "OrderOpened     = " + string(trade.OrderOpened) + "\n"      // = OrderOpenTime();
//    "OpenPrice       = " + string(trade.OpenPrice) + "\n"      // = OrderOpenPrice();
//    "ClosePrice      = " + string(trade.ClosePrice) + "\n"      // = OrderClosePrice();
//    "OrderClosed     = " + string(trade.OrderClosed) + "\n"      // = OrderCloseTime();
//    "StopPrice       = " + string(trade.StopPrice) + "\n"      // = OrderStopLoss();
//    "TakeProfitPrice = " + string(trade.TakeProfitPrice) + "\n"      // = OrderTakeProfit();
//    "LotSize         = " + string(trade.LotSize) + "\n" );     // = OrderLots();
//  return;
//}
