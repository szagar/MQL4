//+------------------------------------------------------------------+
//|                                                  PriceModels.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|       Price Model:                                                                      EntryModel=0
//|               when: after setup model confirms trade condition
//|               0 : enter now, Long at ask, Short at bid
//|               1 : enter on pullback to previous bar's H/L (bar offset)                  EntryPBbarOffset=1
//|               2 : enter on RBO of current session (pip offset)                          EntryRBOpipOffset=1
//|                                                                  |
//+------------------------------------------------------------------+

extern string commentString_PM_01 = "";  //*****************************************
extern string commentString_PM_02 = ""; //PRICE MODEL SETTINGS
extern Enum_PRICE_MODELS PM_Model = PM_BidAsk; //>> Price Model for entry
extern int PM_BarShift = 1;         //>> Bar Offset
extern double PM_PipAdj = 0.5;    //>> Price adjustment in pips
extern int PM_Consecutive = 1;       //>> # of bars
class PriceModels {
private:

public:
  PriceModels();
  ~PriceModels();
  
  bool entrySignal(Position*);
  void entryPrice(Position*);
  void entryPriceLong(Position*);
  void entryPriceShort(Position*);
};

PriceModels::PriceModels() {
}

PriceModels::~PriceModels() {
}

void PriceModels::entryPrice(Position *trade) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  if(trade.Side==Long) entryPriceLong(trade);
  if(trade.Side==Short) entryPriceShort(trade);
}

void PriceModels::entryPriceLong(Position *trade) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  Debug(__FUNCTION__,__LINE__,"PM_Model="+EnumToString(PM_Model));
  switch(PM_Model) {
    case PM_BidAsk:
      trade.OpenPrice = Ask+PM_PipAdj;
      break;
    case PM_PrevHL:
      trade.OpenPrice = iHigh(NULL,0,PM_BarShift)+PM_PipAdj;
      break;
  }
  Debug(__FUNCTION__,__LINE__,"trade.OpenPrice="+DoubleToStr(trade.OpenPrice,Digits));
}

void PriceModels::entryPriceShort(Position *trade) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  switch(PM_Model) {
    case PM_BidAsk:
      trade.OpenPrice = Bid-PM_PipAdj;
      break;
    case PM_PrevHL:
      trade.OpenPrice = iLow(NULL,0,PM_BarShift)-PM_PipAdj;
      break;
  }
}

