//+------------------------------------------------------------------+
//|                                                  EntryModels.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|       Entry Model:                                                                      EntryModel=0
//|               when: after setup model confirms trade condition
//|               0 : enter now, Long at ask, Short at bid
//|               1 : enter on pullback to previous bar's H/L (bar offset)                  EntryPBbarOffset=1
//|               2 : enter on RBO of current session (pip offset)                          EntryRBOpipOffset=1
//|                                                                  |
//+------------------------------------------------------------------+

extern string commentString_EM_01 = "";  //*****************************************
extern string commentString_EM_02 = ""; //ENTRY MODEL SETTINGS
extern Enum_ENTRY_MODELS EM_Model = EM_HLest; //- Entry Model
extern int EM_BarOffset = 1;         //>> Bar Offset
extern double EM_PipOffset = 0.5;    //>> Pip offset
extern int EM_Consecutive = 1;       //>> # of bars
class EntryModels {
private:
  double prevBarHigh();
  double prevBarLow();
  bool higherHighs(int bars);
  bool lowerLows(int bars);
  bool engulfingBullish();
  bool engulfingBearish();

public:
  EntryModels();
  ~EntryModels();
  
  bool entrySignal(Position*);
  double entryPriceLong(Enum_PRICE_MODELS);
  double entryPriceShort(Enum_PRICE_MODELS);
};

EntryModels::EntryModels() {
}

EntryModels::~EntryModels() {
}

bool EntryModels::entrySignal(Position *trade) {
  bool go = false;
  switch(EM_Model) {
    case EM_GO4IT:
      go = true;
      break;
    case EM_HLest:
      go = (trade.Side==Long ? higherHighs(EM_Consecutive) : lowerLows(EM_Consecutive));
      break;
    case EM_Engulfing:
      go = (trade.Side==Long ? engulfingBullish() : engulfingBearish());
      break;
  }
  return(go);
}

bool EntryModels::higherHighs(int bars) {
  return(false);
}
bool EntryModels::lowerLows(int bars) {
  return(false);
}
bool EntryModels::engulfingBullish() {
  return(false);
}
bool EntryModels::engulfingBearish() {
  return(false);
}

double EntryModels::entryPriceLong(Enum_PRICE_MODELS _model=NULL) {
  double entryPrice;
  int model;
  
  model = (_model==NULL ? PM_Model : _model); 
    
  switch(model) {
    case PM_BidAsk:
    case PM_PrevHL:
      entryPrice = prevBarHigh();
      break;
    default:
      entryPrice = 0.0;
  }
  return(entryPrice);
}

double EntryModels::entryPriceShort(Enum_PRICE_MODELS _model=NULL) {
  double entryPrice;
  Enum_PRICE_MODELS model;
  model = (_model==NULL ? PM_Model : _model); 
    
  switch(model) {
    case 1:
      entryPrice = prevBarLow();
      break;
    default:
      entryPrice = Bid;
  }
  return(entryPrice);
}

double EntryModels::prevBarHigh() {
  return(iHigh(NULL,0,-1));
}

double EntryModels::prevBarLow() {
  return(iLow(NULL,0,-1));
}
