//+------------------------------------------------------------------+
//|                                              MarketModel.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

extern string commentString_mm0 = ""; //---------------------------------------------
extern string commentString_MM_01 = ""; //** Market Model settings:
extern Enum_MARKET_MODELS MM_Model = MM_200DMA;  //>> Market Model

class MarketModel {
private:
  int marketModel;
  
public:
  MarketModel();
  ~MarketModel();
  
  void setModel(int);
  bool canGoLong();
  bool canGoShort();
  string snapshort();
  string trendUpOrDown();
  int sessionMidpoint();


};

MarketModel::MarketModel() {
  marketModel = MM_Model;
}

MarketModel::~MarketModel() {
}

void MarketModel::setModel(int _model) {
  marketModel = _model;
}

string MarketModel::trendUpOrDown() {
  string trend="";
  //switch(marketModel) {
  //  case Mkt_SessionMidpoint:
  //    if(Low > 
  return trend;
}

bool MarketModel::canGoLong() {
  return GoLong;
}

bool MarketModel::canGoShort() {
  return GoShort;
}

string MarketModel::snapshort() {
  string str = "";
  return str;
}

int MarketModel::sessionMidpoint() {
  //int buffer = MktSessionMidpoit_buffer;
  //double smMid = iCustom(NULL,0,"SessionMidPoint",Red,White,Red,White,1,1);
  //if(Low[1]-buffer*Point > smMid)
  //  return(1);
  //if(High[1]+buffer*Point < smMid)
  //  return(1);
  return(0);
}
