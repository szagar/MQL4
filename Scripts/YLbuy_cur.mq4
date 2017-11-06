//+------------------------------------------------------------------+
//|                                                        YLbuy.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, SSTK Assoc"
#property link      "https://"
#property version   "1.00"
#property strict


#include <Position.mqh>
#include <Broker.mqh>
//#include <errordescription.mqh>
#include <zts\oneR.mqh>
#include <zts\trade_type.mqh>
#include <zts\common.mqh>
#include <zts\yellow_line.mqh>

//string Prefix = "PAT_";
Broker * broker;

//+------------------------------------------------------------------+
//| Script program start function                                    |
void OnStart() {
  int barOffset = 0;
  broker = new Broker();
  cdmLong(broker, barOffset);
  if (CheckPointer(broker) == POINTER_DYNAMIC) delete broker;
}
