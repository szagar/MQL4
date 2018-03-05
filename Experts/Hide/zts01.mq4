//+------------------------------------------------------------------+
//|                                                        zts01.mq4 |
//+------------------------------------------------------------------+
#property version   "1.00"
#property strict

#include <zts\zts02.mqh>

Robo *robo;

int OnInit() {
  //EventSetTimer(60);
  robo = new Robo();
  robo.OnInit();
  robo.setExitStrategy(1);
  robo.addSetup(1);

  return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
  EventKillTimer();
  robo.OnDeinit();
}

void OnTick() {
  robo.OnTick();   
  if(isEOD()) {
    robo.cleanUpEOD();
    cleanUpEOD();
  }
  if(isSOD()) {
    robo.startOfDay();
    startOfDay();
  }
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
}
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester() {
  double ret=0.0;
  return(ret);
}

bool isEOD() {
  return(false);
}

bool isSOD() {
  return(false);
}

void cleanUpEOD() {
}

void startOfDay() {
}