#property strict

#ifndef LOGGER
#define LOGGER

#include <ATS\enum_types.mqh>

//enum Enum_LogLevels{
//  LogAlert,
//  LogWarn,
//  LogInfo,
//  LogDebug
//};
//extern Enum_LogLevels LogLevel = LogDebug;  //> Log Level
//Enum_LogLevels LogLevel = LogDebug;  //> Log Level

#define LOG(level,text)  Print(level+": ",text)
#define LOG2(level,func,line,text)  Print(level+"::"+func+"("+IntegerToString(line)+"): ",text)

  bool DEBUG() { return(LogLevel>=LogDebug?true:false); }
  bool DEBUG0() { return(true); }
  bool DEBUG1() { return(true); }
  bool DEBUG2() { return(true); }
  bool DEBUG3() { return(true); }
  bool DEBUG4() { return(true); }

  bool INFO() { return(LogLevel>=LogInfo?true:false); }
  bool WARN() { return(LogLevel>=LogWarn?true:false); }

  void Warn(string msg)  { if(WARN())  LOG("WARN",msg); }
  void Warn2(string f,int l,string msg) { if(WARN()) LOG2("WARN",f,l,msg); }
//  void Info(string msg)  { if(INFO())  LOG("INFO",msg); }
//  void Debug(string msg) { if(DEBUG()) LOG("DEBUG",msg); }
  void Debug0(string msg) { if(DEBUG0()) LOG("DEBUG",msg); }
  void Debug1(string msg) { if(DEBUG1()) LOG("DEBUG",msg); }
  void Debug2(string msg) { if(DEBUG2()) LOG("DEBUG",msg); }
  void Debug3(string msg) { if(DEBUG3()) LOG("DEBUG",msg); }
  void Debug(string f,int l,string msg) { if(DEBUG()) LOG2("DEBUG",f,l,msg); }
  void Debug4(string f,int l,string msg) { if(DEBUG3()) LOG2("DEBUG",f,l,msg); }
  void Info(string msg) { if(INFO()) LOG("INFO",msg); }
  void Info2(string f,int l,string msg) { if(INFO()) LOG2("INFO",f,l,msg); }
  void LogTrade(string f,int l,string msg) { if(INFO()) LOG2("TRADE",f,l,msg); }
  void Zalert(string msg) { Alert(msg); }
#endif

void SetLogLevel(Enum_LogLevels level) {
  LogLevel = level;
}

