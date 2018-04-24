//+------------------------------------------------------------------+
//|                                                        zts01.mq4 |
//+------------------------------------------------------------------+
#property version   "1.00"
#property strict

#include <zts\zts02.mqh>

string Prefix="ZTS_";
string Version="0.001";
string TextFont="Verdana";
color TextColor=Goldenrod;

Robo *robo;

int OnInit() {
  //EventSetTimer(60);
  robo = new Robo();
  robo.OnInit();
  robo.setExitStrategy(1);
  robo.addSetup(1);
  
  DrawSystemStatus();

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

void DrawSystemStatus() {
  string name;
  name = StringConcatenate(Prefix,"Version");
  
  ObjectCreate(name,OBJ_LABEL,0,0,0);
  string text = "ver:"+Version+" / offset:"+string(TimeGMTOffset()/60/60);
  ObjectSetText(name,text,8,TextFont,TextColor);
  ObjectSet(name,OBJPROP_CORNER,2);
  ObjectSet(name,OBJPROP_XDISTANCE,5);
  ObjectSet(name,OBJPROP_YDISTANCE,2);
} 

