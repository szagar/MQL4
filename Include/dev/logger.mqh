#property strict


#ifndef LOGGER
#define LOGGER

enum Enum_LogLevels{
  LogAlert,
  LogWarn,
  LogInfo,
  LogDebug
};

#define LOG(level,text)  Print(level+": ",text)
#define LOG2(level,func,line,text)  Print(level+"::"+func+"("+IntegerToString(line)+"): ",text)

  bool DEBUG() { return(LogLevel>=LogDebug?true:false); }
  bool DEBUG0() { return(true); }
  bool DEBUG1() { return(true); }
  bool DEBUG2() { return(true); }
  bool DEBUG3() { return(true); }
  bool DEBUG4() { return(true); }

  bool INFO() { return(LogLevel>=LogInfo?true:false); }
  bool WARN() { return(LogLevel>=LogInfo?true:false); }

  void Warn(string msg)  { if(WARN())  LOG("WARN",msg); }
//  void Info(string msg)  { if(INFO())  LOG("INFO",msg); }
//  void Debug(string msg) { if(DEBUG()) LOG("DEBUG",msg); }
  void Debug0(string msg) { if(DEBUG0()) LOG("DEBUG",msg); }
  void Debug1(string msg) { if(DEBUG1()) LOG("DEBUG",msg); }
  void Debug2(string msg) { if(DEBUG2()) LOG("DEBUG",msg); }
  void Debug3(string msg) { if(DEBUG3()) LOG("DEBUG",msg); }
  void Debug(string f,int l,string msg) { if(DEBUG3()) LOG2("DEBUG",f,l,msg); }
  void Debug4(string f,int l,string msg) { if(DEBUG3()) LOG2("DEBUG",f,l,msg); }
  void Info(string f,int l,string msg) { if(INFO()) LOG2("INFO",f,l,msg); }
  void Zalert(string msg) { Alert(msg); }
#endif

void SetLogLevel(Enum_LogLevels level) {
  LogLevel = level;
}

