//+------------------------------------------------------------------+
//|                                           ProfitTargetModels.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

extern string commentString_10 = "*****************************************";
extern string commentString_11 = "PROFIT TARGET MODEL SETTINGS";
extern Enum_PROFIT_TARGET_TYPES ProfitTargetModel = PT_OneR;
extern double PT_multiplier = 2.0;
extern string commentString_12 = "*****************************************";

#include <zts\common.mqh>;

class ProfitTargetModels {
private:
  int defaultModel;
  double nextPatiLevel(Enum_SIDE side,double);
  
public:
  ProfitTargetModels();
  ~ProfitTargetModels();
  double getTargetPrice(Position*,Enum_PROFIT_TARGET_TYPES _model=0);
};

ProfitTargetModels::ProfitTargetModels() {
  defaultModel = PT_OneR;
}

ProfitTargetModels::~ProfitTargetModels() {
}

double ProfitTargetModels::getTargetPrice(Position *trade,
                                         Enum_PROFIT_TARGET_TYPES _model=PT_None) {
  int model = (_model>PT_None ? _model : defaultModel);
  double entryPrice;
  double price;
  int sideX;
  
  sideX = (trade.Side==Long?1:-1);
  entryPrice = trade.OpenPrice;
  switch(model) {
    case PT_PrevHL:
        price = entryPrice;
      break;
    case PT_ATR:
        price = entryPrice;
      break;
    case PT_OneR:
        price = entryPrice + sideX*trade.OneRpips*PT_multiplier*OnePoint;
      break;
    case PT_PATI_Level:
      price = nextPatiLevel(trade.Side,(trade.Side==Long ? Bid : Ask));
      trade.RewardPips = int((price-trade.OpenPrice)*decimal2points_factor(trade.Symbol) * trade.Side);
      while(trade.RewardPips/trade.OneRpips < MinReward2RiskRatio) {
        price = nextPatiLevel(trade.Side,price);
        trade.RewardPips = int((price-trade.OpenPrice)*decimal2points_factor(trade.Symbol) * trade.Side);
      }
      break;
    default:
      price = NULL;
  }
  return(price);
}

double ProfitTargetModels::nextPatiLevel(Enum_SIDE side, double currentLevel) {
  int direction = int(side);
  
  string baseString;
  double isolatedLevel;
  double nextLevel;
  if (currentLevel > 50) {     // Are we dealing with Yen's or other pairs?
    baseString = DoubleToStr(currentLevel, 3);
    baseString = StringSubstr(baseString, 0, StringLen(baseString) - 3);
    isolatedLevel = currentLevel -  StrToDouble(baseString) ;
  }
  else {
    baseString  = DoubleToStr(currentLevel, 5);
    baseString = StringSubstr(baseString,0, StringLen(baseString) - 3);
    isolatedLevel = (currentLevel - StrToDouble(baseString)) * 100;
  }
  if (direction > 0) {
    if (isolatedLevel >= .7999)
      nextLevel = 1.00;
    else if (isolatedLevel >= .4999)
      nextLevel = .80;
    else if (isolatedLevel >= .1999)
      nextLevel = .50;
    else nextLevel = .20;   
  }
  else {
    if (isolatedLevel >.79999)
      nextLevel = .80;
    else if (isolatedLevel > .49999)
      nextLevel = .50;
    else if (isolatedLevel > .19999)
      nextLevel = .20;
    else nextLevel = .00;
  }
  if (currentLevel > 50) {
    return StrToDouble(baseString) + nextLevel;
  }
  else
    return (StrToDouble(baseString) + nextLevel/100);
      
}
