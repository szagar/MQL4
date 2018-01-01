//+------------------------------------------------------------------+
//|                                               MovingAvgCross.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <zts\common.mqh>
#include <zts\Setup.mqh>
  
class Rsi : public Setup {
private:
 
public:
  Rsi(string, Enum_SIDE);
  ~Rsi();
  };

Rsi::Rsi(string _symbol, Enum_SIDE _side):Setup(_symbol) {
  name = "RSI";
  symbol = _symbol;
  side = _side;
}


Rsi::~Rsi() {
}


