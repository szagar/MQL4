//+------------------------------------------------------------------+
//|                                           ProfitTargetModels.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

//extern string commentString_10 = "";  //*****************************************
//extern string commentString_11 = ""; //PROFIT TARGET MODEL SETTINGS
extern Enum_PROFIT_TARGET_TYPES PT_Model = PT_OneR;  //- Profit Target Model
extern double PT_multiplier = 2.0;  //>> Multiplier
//extern string commentString_12 = "";  //*****************************************

#include <dev\common.mqh>;

class ProfitTargetModels {
private:
  double nextPatiLevel(Enum_SIDE side,double);
  
public:
  ProfitTargetModels();
  ~ProfitTargetModels();
  double getTargetPrice(Position*,Enum_PROFIT_TARGET_TYPES _model=0);
};

ProfitTargetModels::ProfitTargetModels() {
}

ProfitTargetModels::~ProfitTargetModels() {
}

double ProfitTargetModels::getTargetPrice(Position *trade,
                                         Enum_PROFIT_TARGET_TYPES _model=PT_None) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  Enum_PROFIT_TARGET_TYPES model = (_model>PT_None ? _model : PT_Model);
  double entryPrice;
  double price;
  
  entryPrice = trade.OpenPrice;
  Debug(__FUNCTION__,__LINE__,"model="+EnumToString(model));
  switch(model) {
    case PT_CandleTrail:
        price = entryPrice;
      break;
    case PT_ATR:
        price = entryPrice;
      break;
    case PT_OneR:
        Debug(__FUNCTION__,__LINE__,"price = "+DoubleToString(entryPrice,Digits)+" + "+string(trade.SideX)+"*"+string(trade.OneRpips)+"*"+string(PT_multiplier)+"*"+string(OnePoint));
        price = entryPrice + trade.SideX*trade.OneRpips*PT_multiplier*OnePoint;
      break;
    case PT_PATI_Level:
      price = nextPatiLevel(trade.Side,(trade.Side==Long ? Bid : Ask));
      trade.RewardPips = int((price-trade.OpenPrice)*PipFact * trade.Side);
      while(trade.RewardPips/trade.OneRpips < MinReward2RiskRatio) {
        price = nextPatiLevel(trade.Side,price);
        trade.RewardPips = int((price-trade.OpenPrice)*PipFact * trade.Side);
      }
      break;
    default:
      price = NULL;
  }
  Debug(__FUNCTION__,__LINE__,"price="+DoubleToString(price,Digits));
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
