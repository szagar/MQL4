//+------------------------------------------------------------------+
//|                                             order_management.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

/*
OrderType()
OP_BUY - buy order,
OP_SELL - sell order,
OP_BUYLIMIT - buy limit pending order,
OP_BUYSTOP - buy stop pending order,
OP_SELLLIMIT - sell limit pending order,
OP_SELLSTOP - sell stop pending order.
*/

void updateTrailingStop(double price) {
  double MinStopLossChange = OnePoint;
  currStopLoss = OrderStopLoss();
  ot = OrderType();
  if(ot == OP_BUY) {
    if( price > (currStopLoss + MinStopLossChange))
      ModifyStopLoss(stopLoss);
  } else if( ot == OP_SELL ) {
    if( price < (currStopLoss - MinStopLossChange))
      ModifyStopLoss(stopLoss);
  } else {
    Alert(__FUNCTION__+": OrderType: "+ot+" Not Recognized");
  }      
}

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
