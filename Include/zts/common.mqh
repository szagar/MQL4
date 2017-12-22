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
double pips2dollars(string sym, double pips, double lots) {
   double result;
   result = pips * lots * (1 / MarketInfo(sym, MODE_POINT)) * MarketInfo(sym, MODE_TICKVALUE);
   return ( result );
}

int decimal2points_factor(string sym) {
  int factor = 10000;
  if(StringFind(sym,"JPY",0)>0) factor = 100;         // JPY pairs
  Debug(__FUNCTION__+": sym="+sym+"  factor="+string(factor)); 
  return factor;
}

double points2decimal_factor(string sym) {
  double factor = 1.0/10000.0;
  if(StringFind(sym,"JPY",0)>0) factor = 1.0/100.0;         // JPY pairs
  Debug(__FUNCTION__+" "+sym+": factor="+string(factor));
  return factor;
}

#ifndef ZCOMMON
#define ZCOMMON

double OnePoint = CommonSetPoint();
double PipAdj = CommonSetPipAdj();
double BaseCcyTickValue = MarketInfo(Symbol(),MODE_TICKVALUE); // Tick value in the deposit currency
// Point - The current symbol point value in the quote currency
// MODE_POINT - Point size in the quote currency. For the current symbol, it is stored in the predefined variable Point

#endif

enum Enum_SIDE{ Long=1, Short=-1 };
enum Enum_OP_ORDER_TYPES { 
  Z_BUY=0,        //Buy operation
  Z_SELL=1,       //Sell operation
  Z_BUYLIMIT=2,   //Buy limit pending order
  Z_SELLLIMIT=3,  //Sell limit pending order
  Z_BUYSTOP=4,    //Buy stop pending order
  Z_SELLSTOP=5,   //Sell stop pending order
};
enum Enum_TRAILING_STOP_TYPES { 
  NA=0,      // Not Applicable
  PrevHL=1,  // Previous Hi/Lo
  ATR=2,     // ATR factor
  OneR=3,    // One R pips
};

#ifndef LOGGING
#define LOGGING
enum Enum_LogLevels{
  LogAlert,
  LogWarn,
  LogInfo,
  LogDebug
};

#ifndef LOG
//#define LOG(level,text)  Print(__FILE__,"(",__LINE__,") :",text)
#define LOG(level,text)  Print(level+": ",text)
#endif
  bool DEBUG() { return(LogLevel>=LogDebug?true:false); }
  bool DEBUG0() { return(true); }
  bool DEBUG1() { return(true); }
  bool DEBUG2() { return(true); }
  bool DEBUG3() { return(true); }

  bool INFO() { return(LogLevel>=LogInfo?true:false); }
  bool WARN() { return(LogLevel>=LogInfo?true:false); }

  void Warn(string msg)  { if(WARN())  LOG("WARN",msg); }
  void Info(string msg)  { if(INFO())  LOG("INFO",msg); }
  void Debug(string msg) { if(DEBUG()) LOG("DEBUG",msg); }
  void Debug0(string msg) { if(DEBUG0()) LOG("DEBUG",msg); }
  void Debug1(string msg) { if(DEBUG1()) LOG("DEBUG",msg); }
  void Debug2(string msg) { if(DEBUG2()) LOG("DEBUG",msg); }
  void Debug3(string msg) { if(DEBUG3()) LOG("DEBUG",msg); }
  void Zalert(string msg) { Alert(msg); }
#endif


extern Enum_LogLevels LogLevel = LogInfo;
void SetLogLevel(Enum_LogLevels level) {
  LogLevel = level;
}

/**
enum ENUM_PERSISTER {
  GlobalVar,
  File
 }; 
 **/ 