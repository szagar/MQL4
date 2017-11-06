//+------------------------------------------------------------------+
//|                                                       common.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
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

double CommonSetPoint() {
  return((Digits==5||Digits==3)?Point*10:Point);
}

#ifndef ZCOMMON
#define ZCOMMON

double OnePoint = CommonSetPoint();

//#define LOG(llevel,text)  Print(llevel,"::",__FILE__,"(",__LINE__,") ::::::",text)
#define LOG(llevel,text)  Print(llevel,"::",__LINE__,"::",text)

void Zalert(string msg) { LOG("ALERT",msg); Alert(msg);}

#ifndef LOG_LEVEL
  #define LOG_LEVEL set
  #define LOG_DEBUG set
  #undef LOG_INFO
  #undef LOG_WARN
  #undef LOG_ALERT
#endif

#ifdef LOG_DEBUG
  void Warn(string msg) { LOG("WARN",msg); }
  void Info(string msg) { LOG("INFO",msg); }
  void Debug(string msg) { LOG("DEBUG",msg); }
#endif
#ifdef LOG_INFO
  void Warn(string msg) { LOG("WARN",msg); }
  void Info(string msg) { LOG("INFO",msg); }
  void Debug(string msg) {  }
#endif
#ifdef LOG_WARN
  void Warn(string msg) { LOG("WARN",msg); }
  void Info(string msg) {  }
  void Debug(string msg) {  }
#endif
#ifdef LOG_ALERT
  void Warn(string msg) {  }
  void Info(string msg) {  }
  void Debug(string msg) {  }
#endif

#endif
