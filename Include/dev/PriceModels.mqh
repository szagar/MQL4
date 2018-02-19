//+------------------------------------------------------------------+
//|                                                  PriceModels.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <dev\PriceModelsBase.mqh>

//+------------------------------------------------------------------+
//|       Price Model:                                                                      EntryModel=0
//|               when: after setup model confirms trade condition
//|               0 : enter now, Long at ask, Short at bid
//|               1 : enter on pullback to previous bar's H/L (bar offset)                  EntryPBbarOffset=1
//|               2 : enter on RBO of current session (pip offset)                          EntryRBOpipOffset=1
//|                                                                  |
//+------------------------------------------------------------------+

extern string commentString_PM_01 = ""; //---------------------------------------------
extern string commentString_PM_02 = "";  //*** Price Model settings:
extern Enum_PRICE_MODELS PM_Model = PM_BidAsk; //>> Price Model for entry
extern int PM_BarShift = 1;          //- Bar Offset
extern double PM_PipAdj = 0.5;       //- Price adjustment in pips
extern int PM_Consecutive = 1;       //- # of bars

class PriceModels : public PriceModelsBase {
private:

public:
  PriceModels();
  ~PriceModels();
  
  //bool entrySignal(Position*);
  double entryPrice(SetupStruct*,Enum_PRICE_MODELS);
  double entryPrice(Position*,Enum_PRICE_MODELS);
  double entryPriceLong(Enum_PRICE_MODELS);
  double entryPriceShort(Enum_PRICE_MODELS);
};

PriceModels::PriceModels() {
}

PriceModels::~PriceModels() {
}

double PriceModels::entryPrice(SetupStruct *setup, Enum_PRICE_MODELS model=NULL) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  double price = NULL;
  if(!model) model = PM_Model;
  if(setup.side==Long) price = entryPriceLong(model);
  if(setup.side==Short) price = entryPriceShort(model);
  return(price);
}

double PriceModels::entryPrice(Position *trade, Enum_PRICE_MODELS model=NULL) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  double price = NULL;
  if(!model) model = PM_Model;
  if(trade.Side==Long) price = entryPriceLong(model);
  if(trade.Side==Short) price = entryPriceShort(model);
  return(price);
}

double PriceModels::entryPriceLong(Enum_PRICE_MODELS model) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  double price = NULL;
  Debug(__FUNCTION__,__LINE__,"PM_Model="+EnumToString(model));
  switch(model) {
    case PM_BidAsk:
      price = Ask+PM_PipAdj;
      break;
    case PM_PrevHL:
      price = iHigh(NULL,0,PM_BarShift)+PM_PipAdj;
      break;
  }
  Debug(__FUNCTION__,__LINE__,"price="+DoubleToStr(price,Digits));
  return(price);
}

double PriceModels::entryPriceShort(Enum_PRICE_MODELS model) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  double price = NULL;
  switch(model) {
    case PM_BidAsk:
      price = Bid-PM_PipAdj;
      break;
    case PM_PrevHL:
      price = iLow(NULL,0,PM_BarShift)-PM_PipAdj;
      break;
  }
  return(price);
}

