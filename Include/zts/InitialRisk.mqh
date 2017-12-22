//+------------------------------------------------------------------+
//|                                                         InitialRisk.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <zts\Account.mqh>

extern int OneRmodel = 1;

class InitialRisk {
private:
  string PatiExceptionPairs;
  int defaultModel;

  int calcPatiPips(string symbol);

public:
  InitialRisk();
  ~InitialRisk();
  
  int getInPips(int,string);

};

InitialRisk::InitialRisk() {
  PatiExceptionPairs = "EURUSD/8;AUDUSD,GBPUSD,EURJPY,USDJPY,USDCAD/10";
}

InitialRisk::~InitialRisk() {
}

int InitialRisk::getInPips(int _model,string _symbol) {
  string symbol = _symbol;
  int pips=0;
  int model = (_model>0 ? _model : defaultModel); 
  
  switch(model) {
    case 1:      // PATI static pips
      pips = calcPatiPips(symbol);
      break;
    default:
      pips = 0;
  }
  Debug2(__FUNCTION__+"("+IntegerToString(__LINE__)+"): model="+IntegerToString(model)+"  symbol="+symbol);
  return(pips);
}

int InitialRisk::calcPatiPips(string symbol) {
  int defaultStopPips = 12;
  
  int stop = defaultStopPips;
  //Debug3(__FUNCTION__+"("+__LINE__+"): stop="+stop);
  //Debug3(__FUNCTION__+"("+__LINE__+"): PatiExceptionPairs="+PatiExceptionPairs);
  int pairPosition = StringFind(PatiExceptionPairs, symbol, 0);
  //Debug3(__FUNCTION__+"("+__LINE__+"): pairPosition="+pairPosition);
  if (pairPosition >=0) {
    int slashPosition = StringFind(PatiExceptionPairs, "/", pairPosition) + 1;
    //Debug3(__FUNCTION__+"("+__LINE__+"): slashPosition="+slashPosition);
    stop =int( StringToInteger(StringSubstr(PatiExceptionPairs,slashPosition)));
  //Debug3(__FUNCTION__+"("+__LINE__+"): stop="+stop);
  }
  return stop;
}

class RiskManagement {
private:

public:

};
