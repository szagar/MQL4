//+------------------------------------------------------------------+
//|                                                        YLbuy.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, SSTK Assoc"
#property link      "https://"
#property version   "1.00"
#property strict

#include <zts\Broker.mqh>
#include <zts\Account.mqh>
//#include <zts\oneR.mqh>
//#include <zts\trade_type.mqh>
//#include <zts\common.mqh>
#include <zts\yellow_line.mqh>

extern Enum_LogLevels LogLevel = LogInfo;
extern int Slippage=5;

void OnStart() {
  Broker *broker;
  Account *account;
  int barOffset = 1; 
  broker = new Broker();
  account = new Account();
  cdmShort(account, broker, barOffset);
  if (CheckPointer(broker) == POINTER_DYNAMIC) delete broker;
  if (CheckPointer(account) == POINTER_DYNAMIC) delete account;   
}