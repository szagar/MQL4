//+------------------------------------------------------------------+
//|                                                       common.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

double CommonSetPoint() {
  return((Digits==5||Digits==3)?Point*10:Point);
}
double CommonSetPipAdj() {
  //if(Digits==5||Digits==3) return(10);
  //return(1);
  return(0.1);
}

#ifndef ZCOMMON
#define ZCOMMON

double OnePoint = CommonSetPoint();
double PipAdj = CommonSetPipAdj();
double BaseCcyTickValue = MarketInfo(Symbol(),MODE_TICKVALUE); // Tick value in the deposit currency
// Point - The current symbol point value in the quote currency
// MODE_POINT - Point size in the quote currency. For the current symbol, it is stored in the predefined variable Point

//#define LOG(llevel,text)  Print(llevel,"::",__FILE__,"(",__LINE__,") ::::::",text)
//#define LOG(llevel,text)  Print(llevel,"::",__LINE__,"::",text)

//#ifndef LOG
//  #define LOG(level,text)  Print(__FILE__,"(",__LINE__,") :",text)
//#endif


#endif

#ifndef LOGGING
#define LOGGING
#define LOG(level,text)  Print(__FILE__,"(",__LINE__,") :",text)
#define LOG_DEBUG 3
#define LOG_INFO  2
#define LOG_WARN  1
#define LOG_ALERT 0
  bool DEBUG() { return(LogLevel>=LOG_DEBUG?true:false); }
  bool INFO() { return(LogLevel>=LOG_INFO?true:false); }
  bool WARN() { return(LogLevel>=LOG_WARN?true:false); }

  void Warn(string msg) { if(WARN()) LOG("WARN",msg); }
  void Info(string msg) { if(INFO()) LOG("INFO",msg); }
  void Debug(string msg) { if(DEBUG()) LOG("DEBUG",msg); }
  void Zalert(string msg) { LOG("ALERT",msg); Alert(msg);}
#endif


int LogLevel = LOG_INFO;
void SetLogLevel(int level) {
  LogLevel = level;
}
