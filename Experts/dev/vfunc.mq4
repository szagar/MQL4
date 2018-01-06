//+------------------------------------------------------------------+
//|                                                        vfunc.mq4 |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include "vfunc.mqh"

TestRobo *robo;

int OnInit() {
  robo = new TestRobo();
  return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
  if (CheckPointer(robo) == POINTER_DYNAMIC) delete robo;
}

void OnTick() {
  robo.OnTick();   
}

double OnTester() {
//---
   double ret=0.0;
//---

//---
   return(ret);
}
//+------------------------------------------------------------------+
