//+------------------------------------------------------------------+
//|                                              MarketCondition.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

class MarketCondition {
private:
  int marketModel;
  
public:
  MarketCondition(int);
  ~MarketCondition();
  
  void setModel(int);
  bool canGoLong();
  bool canGoShort();
  string snapshort();
};

MarketCondition::MarketCondition(int _model=1) {
  marketModel = _model;
}

MarketCondition::~MarketCondition() {
}

void MarketCondition::setModel(int _model) {
  marketModel = _model;
}

bool MarketCondition::canGoLong() {
  return false;
}

bool MarketCondition::canGoShort() {
  return false;
}

string MarketCondition::snapshort() {
  string str = "";
  return str;
}
