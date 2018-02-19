//+------------------------------------------------------------------+
//|                                                      Filters.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <dev/enum_types.mqh>

class Filters {
private:

public:
  Filters();
  ~Filters();
  bool passFail(Enum_SIDE);
};

Filters::Filters() {
}

Filters::~Filters() {
}

bool Filters::passFail(Enum_SIDE side) {
  return true;
}