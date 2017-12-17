//+------------------------------------------------------------------+
//|                                                       Trader.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <zts\Position.mqh>

class Trader {
private:

public:
  Trader();
  ~Trader();
  
  Position *newTrade();
};

Trader::Trader() {
}

Trader::~Trader() {
}
//+------------------------------------------------------------------+

Position *Trader::newTrade() {
  Position *trade = new Position();
  return(trade);
};