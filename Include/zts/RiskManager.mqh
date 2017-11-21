//+------------------------------------------------------------------+
//|                                                  RiskManager.mqh |
//+------------------------------------------------------------------+
#property strict

#include <zts\account.mqh>

class RiskManager {
private:
  int EquityModel;
  int RiskModel;
  Account *account;

  int oneR_calc_PATI(string);
  double availableFunds();

public:
  RiskManager(const int=1, const int=1);
  ~RiskManager();

  double oneR(string);
};

RiskManager::RiskManager(const int _equityModel=1, const int _riskModel=1) {
  EquityModel = _equityModel;
  RiskModel = _riskModel;
  account = new Account();
}
RiskManager::~RiskManager() {
  if (CheckPointer(account) == POINTER_DYNAMIC) delete account;
}

double RiskManager::oneR(string symbol) {
  double pips;

  switch (RiskModel) {
    case 1:
      pips = double(oneR_calc_PATI(symbol));
      break;
    default:
      pips=0;
  }
  return(pips);
}

double RiskManager::availableFunds() {
  double dollars;

  switch(EquityModel){
    case 1:
      dollars = account.freeMargin();
      break;
    default:
      dollars = 0.0;
  }
  return(dollars);
}

int RiskManager::oneR_calc_PATI(string __symbol) {;
  int __defaultStopPips = 12;
  string __exceptionPairs = "EURUSD/8;AUDUSD,GBPUSD,EURJPY,USDJPY,USDCAD/10";
  
  int stop = __defaultStopPips;
  int pairPosition = StringFind(__exceptionPairs, __symbol, 0);
  if (pairPosition >=0) {
     int slashPosition = StringFind(__exceptionPairs, "/", pairPosition) + 1;
     stop =int( StringToInteger(StringSubstr(__exceptionPairs,slashPosition)));
  }
  return stop;
}

