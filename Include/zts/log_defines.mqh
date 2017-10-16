//+------------------------------------------------------------------+
//|                                                  log_defines.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

int debug = 0x0080;
#define DEBUG_EXIT  ((debug & 0x0001) == 0x0001)
#define DEBUG_GLOBAL  ((debug & 0x0002) == 0x0002)
#define DEBUG_ENTRY ((debug & 0x0004) == 0x0004)
#define DEBUG_CONFIG ((debug & 0x0008) == 0x0008)
#define DEBUG_ORDER ((debug & 0x0010) == 0x0010)
#define DEBUG_OANDA ((debug & 0x0020) == 0x0020)
#define DEBUG_TICK  ((debug & 0x0040) == 0x0040)
#define DEBUG_ANALYTICS  ((debug & 0x0080) == 0x0040)
#ifndef LOG
  #define LOG(text)  Print(__FILE__,"(",__LINE__,") :",text)
#endif
