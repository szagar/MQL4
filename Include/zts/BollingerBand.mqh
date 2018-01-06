//+------------------------------------------------------------------+
//|                                               BollingerBand.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <zts\common.mqh>
#include <zts\Setup.mqh>
  
extern string Setup_BB_notes = "========= Setup: Bollinger Bands params ========";
extern int BollingerBandModel = 1;
//extern bool Setup_BollingerBandLong = true;
//extern bool Setup_BollingerBandShort = true;
extern int BB_Period = 200;          //Period of the Bollinger Bands
extern double BB_Deviation = 2;      //Deviation of the Bollinger Bands
extern int BB_BarsSincePierce = 5;

class BollingerBand : public Setup {
//private:
  //Setup setupBase;
  int model;
  bool longCriteria();
  bool shortCriteria();
  int movingPeriod;
  int BB_PiercedUpper;
  int BB_PiercedLower;
  bool bullish();
  bool bearish();
  
public:
  //BollingerBand():Setup() {
  //name = "BollingerBand";
//};
//  BollingerBand(string);
//  BollingerBand(string,Enum_SIDE,int);
  BollingerBand(string,Enum_SIDE);
//  BollingerBand(Enum_SIDE,int); // : setupBase(_symbol);
  ~BollingerBand();
  
  void OnTick(bool tradeWindow);
  virtual void OnTick();
  virtual void OnBar(void);
  virtual void startOfDay();

  void reset();
  //bool triggered();

};


void BollingerBand::BollingerBand(string _symbol,Enum_SIDE _side):Setup(_symbol,_side) {
  strategyName = "BollingerBand";
  side = _side;
  triggered = false;
}

/**
void BollingerBand::BollingerBand(string _symbol):Setup() {
  name = "BollingerBand";
  side = Long;
  model = 1;
  movingPeriod = 100;
}

BollingerBand::BollingerBand(string _symbol, Enum_SIDE _side, int _model):Setup(_symbol) {
  name = "BollingerBand";
  side = _side;
  model = _model;
  movingPeriod = 100;
}

BollingerBand::BollingerBand(Enum_SIDE _side, int _model):Setup() {
  name = "BollingerBand";
  side = _side;
  model = _model;
  movingPeriod = 100;
}
**/

BollingerBand::~BollingerBand() {
}

void BollingerBand::reset() {
  BB_PiercedUpper = 0;
  BB_PiercedLower = 0;
}

void BollingerBand::startOfDay() {
  reset();
}

//bool BollingerBand::triggered(void) {
void BollingerBand::OnBar(void) {
  Debug4(__FUNCTION__,__LINE__,"BollingerBandModel="+IntegerToString(BollingerBandModel));
  //bool pass = false;
  switch(BollingerBandModel) {
    case 1:
      if(goLong) triggered = longCriteria();
      if(goShort) triggered = shortCriteria();
      break;
    default:;
      //pass = false;
  }
}

void BollingerBand::OnTick() {  
  Debug4(__FUNCTION__,__LINE__,"Entered");

  double BandsTopCurr=iBands(Symbol(),0,BB_Period,BB_Deviation,0,PRICE_CLOSE,MODE_UPPER,0);
  double BandsLowCurr=iBands(Symbol(),0,BB_Period,BB_Deviation,0,PRICE_CLOSE,MODE_LOWER,0);
  double BandsTopPrev=iBands(Symbol(),0,BB_Period,BB_Deviation,0,PRICE_CLOSE,MODE_UPPER,1);
  double BandsLowPrev=iBands(Symbol(),0,BB_Period,BB_Deviation,0,PRICE_CLOSE,MODE_LOWER,1);
  if(Close[1]<BandsTopPrev && Close[0]>BandsTopCurr) BB_PiercedUpper = dayBarNumber;
  if(Close[1]>BandsLowPrev && Close[0]<BandsLowCurr) BB_PiercedLower = dayBarNumber;
  Debug4(__FUNCTION__,__LINE__,"BollingerBand::OnTick ("+IntegerToString(dayBarNumber)+") =======> "+IntegerToString(BB_PiercedUpper)+" :: "+IntegerToString(BB_PiercedLower));
}

bool BollingerBand::longCriteria() {
  Debug4(__FUNCTION__,__LINE__,IntegerToString(dayBarNumber-BB_PiercedLower)+" > "+IntegerToString(BB_BarsSincePierce));
  if (BB_PiercedLower && dayBarNumber-BB_PiercedLower > BB_BarsSincePierce) return false;
  if (bullish()) return true;
  return false;
}

bool BollingerBand::shortCriteria() {
  if (BB_PiercedUpper && dayBarNumber-BB_PiercedUpper > BB_BarsSincePierce) return false;
  if (bearish()) return true;
  return false;
}

bool BollingerBand::bullish() {
  Debug4(__FUNCTION__,__LINE__,"BollingerBandModel="+IntegerToString(BollingerBandModel));
  switch(BollingerBandModel) {
    case 1:
      if (Close[0] > Close[1]) return true;
      break;
    case 2:
      if (Close[0] > Close[1] && Close[1] > Close[2]) return true;
      break;
    case 3:
      if (Close[0] > iBands(Symbol(),0,BB_Period,BB_Deviation,0,PRICE_CLOSE,MODE_MAIN,0))
        return true;
      break;
    default:
      return false;
  }
  return false;
}

bool BollingerBand::bearish() {
  switch(BollingerBandModel) {
    case 1:
      if (Close[0] < Close[1]) return true;
      break;
    case 2:
      if (Close[0] < Close[1] && Close[1] < Close[2]) return true;
      break;
    case 3:
      if (Close[0] < iBands(Symbol(),0,BB_Period,BB_Deviation,0,PRICE_CLOSE,MODE_MAIN,0))
        return true;
    default:
      return false;
  }
  return false;
}
