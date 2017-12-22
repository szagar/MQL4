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
class EntryModels {
private:
  int defaultModel;
  
  double prevBarHigh();
  double prevBarLow();
public:
  EntryModels(int);
  ~EntryModels();
  
  double entryPriceLong(int);
  double entryPriceShort(int);
};

EntryModels::EntryModels(int _model=1) {
  defaultModel = _model;
}

EntryModels::~EntryModels() {
}

double EntryModels::entryPriceLong(int _model=0) {
  double entryPrice;
  int model;
  
  if(_model > 0)
    model = (_model>0 ? _model : defaultModel); 
    
  switch(model) {
    case 1:
      entryPrice = prevBarHigh();
      break;
    default:
      entryPrice = Ask;
  }
  return(entryPrice);
}

double EntryModels::entryPriceShort(int _model=0) {
  double entryPrice;
  int model;
  model = (_model>0 ? _model : defaultModel); 
    
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
