//+------------------------------------------------------------------+
//|                                              PriceModelsFake.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <ATS\PriceModelsBase.mqh>

//extern string commentString_PM_01 = "";  //*****************************************
//extern string commentString_PM_02 = ""; //PRICE MODEL SETTINGS
//extern Enum_PRICE_MODELS PM_Model = PM_BidAsk; //>> Price Model for entry
//extern int PM_BarShift = 1;         //>> Bar Offset
//extern double PM_PipAdj = 0.5;    //>> Price adjustment in pips
//extern int PM_Consecutive = 1;       //>> # of bars

class PriceModelsFake : public PriceModelsBase {
private:

public:
  PriceModelsFake() {};
  ~PriceModelsFake() {};
  
  //bool entrySignal(Position*);
  double entryPrice(Position*,Enum_PRICE_MODELS);
  double entryPrice(SetupStruct*,Enum_PRICE_MODELS);
  double entryPriceLong(Enum_PRICE_MODELS);
  double entryPriceShort(Enum_PRICE_MODELS);
};

double PriceModelsFake::entryPrice(SetupStruct *setup,Enum_PRICE_MODELS model=NULL) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  if(!model) model = PM_Model;
  double price = NULL;
  if(setup.side==Long) price = entryPriceLong(model);
  if(setup.side==Short) price = entryPriceShort(model);
  return(price);
}

double PriceModelsFake::entryPrice(Position *trade,Enum_PRICE_MODELS model=NULL) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  if(!model) model = PM_Model;
  double price = NULL;
  if(trade.Side==Long) price = entryPriceLong(model);
  if(trade.Side==Short) price = entryPriceShort(model);
  return(price);
}

double PriceModelsFake::entryPriceLong(Enum_PRICE_MODELS model) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  double price = NULL;
  Debug(__FUNCTION__,__LINE__,"PM_Model="+EnumToString(model));
  double spread;
  switch(model) {
    case PM_BidAsk:
      spread = MarketInfo(Symbol(),MODE_SPREAD)*Point;
      price = Close[0]+spread+PM_PipAdj*Point;     // fake ask
      break;
    case PM_PrevHL:
      price = iHigh(NULL,0,PM_BarShift)+PM_PipAdj*Point;
      break;
  }
  return(price);
}

double PriceModelsFake::entryPriceShort(Enum_PRICE_MODELS model) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  double price = NULL;
  Debug(__FUNCTION__,__LINE__,"PM_Model="+EnumToString(model));
  switch(model) {
    case PM_BidAsk:
      price = Close[0]-PM_PipAdj*Point;          // fake bid
      break;
    case PM_PrevHL:
      price = iLow(NULL,0,PM_BarShift)-PM_PipAdj*Point;
      break;
  }
  return(price);
}

