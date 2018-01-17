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
  string trendUpOrDown();
  int sessionMidpoint();


};

MarketCondition::MarketCondition(int _model=1) {
  marketModel = _model;
}

MarketCondition::~MarketCondition() {
}

void MarketCondition::setModel(int _model) {
  marketModel = _model;
}

string MarketCondition::trendUpOrDown() {
  string trend="";
  //switch(marketModel) {
  //  case Mkt_SessionMidpoint:
  //    if(Low > 
  return trend;
}

bool MarketCondition::canGoLong() {
  return true;
}

bool MarketCondition::canGoShort() {
  return false;
}

string MarketCondition::snapshort() {
  string str = "";
  return str;
}

int MarketCondition::sessionMidpoint() {
  //int buffer = MktSessionMidpoit_buffer;
  //double smMid = iCustom(NULL,0,"SessionMidPoint",Red,White,Red,White,1,1);
  //if(Low[1]-buffer*Point > smMid)
  //  return(1);
  //if(High[1]+buffer*Point < smMid)
  //  return(1);
  return(0);
}