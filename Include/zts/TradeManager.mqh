//+------------------------------------------------------------------+
//|                                                 TradeManager.mqh |
//+------------------------------------------------------------------+
#property strict

#include <zts\TradeStatus.mqh>

class TradeManager {
private:
  TradeStatus *ts;
  bool trailingStop;
  bool scalingIn;
  
public:
  TradeManager();
  ~TradeManager();
  
  void OnNewBar();
  
  void trailStop();
  void scaleIn();
  
  void configScalingIn(string params);
  void configTrailingStop(string params);
};

TradeManager::TradeManager(void) {
  ts = new TradeStatus();
  trailingStop = false;
  scalingIn = false;
}

TradeManager::~TradeManager(void) {
  if (CheckPointer(ts) == POINTER_DYNAMIC) delete ts;
}

void TradeManager::OnNewBar(void) {
  if(trailingStop)
    trailStop();
  if(scalingIn)
    scaleIn();
}

void TradeManager::trailStop(void) {
}

void TradeManager::scaleIn(void) {
}

void TradeManager::configScalingIn(string params) {
  scalingIn = true;
}

void TradeManager::configTrailingStop(string params) {
  trailingStop = true;
}