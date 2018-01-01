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
class PositionSizer {
private:
  int model;
public:
  PositionSizer(int);
  ~PositionSizer();
  
  double lotSize(int);
  double sizer_vantharp();
};

PositionSizer::PositionSizer(int _model=0) {
  model = _model;
}

PositionSizer::~PositionSizer() {
}

double PositionSizer::lotSize(int _model = 0) {
  if(_model > 0) model = _model;
  double lots;
  switch(model) {
    case 0:
      lots = sizer_vantharp();
      break;
    case 1:
      lots = 0.1;
      break;
    default:
      sizer_vantharp();
  }
  lots = NormalizeDouble(lots,2);
  return(lots);
}

double PositionSizer::sizer_vantharp(void) {
  return(0.0);
}