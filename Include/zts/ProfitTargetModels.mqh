//+------------------------------------------------------------------+
//|                                           ProfitTargetModels.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

extern int ProfitTargetModel = 1;

#include <zts\common.mqh>;

class ProfitTargetModels {
private:
  int defaultModel;
  double nextPatiLevel(Enum_SIDE side,double);
  
public:
  ProfitTargetModels();
  ~ProfitTargetModels();
  double getLongTarget(Position*,int _model=0);
};

ProfitTargetModels::ProfitTargetModels() {
  defaultModel = 1;
}

ProfitTargetModels::~ProfitTargetModels() {
}

double ProfitTargetModels::getLongTarget(Position *trade, int _model=0) {
  int model = (_model>0 ? _model : defaultModel);
  double price;
  
  switch(model) {
    case 1:
      price = nextPatiLevel(trade.Side,(trade.Side==Long ? Bid : Ask));
      trade.RewardPips = (price-trade.OpenPrice)*decimal2points_factor(trade.Symbol) * trade.Side;
      while(trade.RewardPips/trade.OneRpips < MinReward2RiskRatio) {
        price = nextPatiLevel(trade.Side,price);
        trade.RewardPips = (price-trade.OpenPrice)*decimal2points_factor(trade.Symbol) * trade.Side;
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
