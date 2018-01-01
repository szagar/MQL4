#property strict

#include <zts\common.mqh>

void ShowSymbolProperties() {
  string str = "OnePoint = " + string(OnePoint) +"\n"+
               "PipAdj   = " + string(PipAdj) +"\n"+
               "BaseCcyTickValue = " + string(BaseCcyTickValue) +"\n"+
               "Point            = " + DoubleToString(Point,8) +"\n"+ 
               "MODE_LOTSTEP     = " + string(MarketInfo(Symbol(),MODE_LOTSTEP));
  Alert(str);
} 

/**
OnePoint = 0.0001
PipAdj   = 0.1
BaseCcyTickValue = 1
Point            = 0.00001000
MODE_LOTSTEP     = 0.01
**/