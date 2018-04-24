//+------------------------------------------------------------------+
//|                                                PositionSizer.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <ATS\positionSizer_externs.mqh>

class PositionSizer {
private:
public:
  PositionSizer();
  ~PositionSizer();
  
  double lotSize(Position*,Enum_POS_SIZE_MODELS);
  double sizer_vantharp(Position*);
};

PositionSizer::PositionSizer() {
}

PositionSizer::~PositionSizer() {
}

double PositionSizer::lotSize(Position *trade, Enum_POS_SIZE_MODELS _model = NULL) {
  Enum_POS_SIZE_MODELS model = (_model == NULL) ? PS_Model : _model;
  double lots=0.0;
  switch(model) {
    case PS_VanTharp:
      lots = sizer_vantharp(trade);
      break;
    case PS_Fixed:
      lots = PS_FixedLotSize;
      break;
  }
 lots = MathRound(lots/MarketInfo(Symbol(),MODE_LOTSTEP)) * MarketInfo(Symbol(),MODE_LOTSTEP);
  return(lots);
}

double PositionSizer::sizer_vantharp(Position *trade) {
  double dollarRisk = AccountFreeMargin() * PercentRiskPerPosition/100.0;

  //double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);

  double LotSize = dollarRisk /(trade.OneRpips * PipSize);
  LotSize = LotSize * Point;
  //LotSize=MathRound(LotSize/MarketInfo(Symbol(),MODE_LOTSTEP)) * MarketInfo(Symbol(),MODE_LOTSTEP);

  return(LotSize);
}
