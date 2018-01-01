#include <zts\TradeStatus.mqh>

class TradeSetup {
private:
  TradeStatus *ts;
  
  void CheckForSetup();

public:
  string type;
  string side;
  double lowerLevel;
  double upperLevel;

  TradeSetup(void);
  ~TradeSetup(void);

  void InitiateCDM(string);
  void setRangeLevels(datetime, datetime end=NULL);
  //void InitiateRange();
  void UpdateRange();
};

TradeSetup::TradeSetup(void) {
  ts = new TradeStatus();
  ts.loadFromChart();
}

void TradeSetup::InitiateCDM(string _side) {
  side = _side;
}

void TradeSetup::CheckForSetup() {
//  if(ts.type=="Range") {
//    if((iHigh(NULL,0,0) - setup.upperLevel) > 20) 
//      InitiateCDM("Long");
//    if((setup.lowerLevel - iLow(NULL,0,0)) > 20) 
//      InitiateCDM("Short");
//  }
}
void TradeSetup::UpdateRange() {
  lowerLevel = MathMin(lowerLevel,iLow(NULL,0,0));
  upperLevel = MathMax(upperLevel,iHigh(NULL,0,0));
}

void TradeSetup::setRangeLevels(datetime start, datetime end=NULL) {
  lowerLevel = dayHi;
  upperLevel = dayLo;

  datetime TimeCopy[];
  ArrayCopy(TimeCopy, Time, 0, 0, WHOLE_ARRAY);
  double HighPrices[];
  ArrayCopy(HighPrices, High, 0, 0, WHOLE_ARRAY);
  double LowPrices[];
  ArrayCopy(LowPrices, Low, 0, 0, WHOLE_ARRAY);
   
  end |= TimeCopy[0];
  double _dayHi = 0.0;
  double _dayLo = 9999.99;
  datetime now = TimeCopy[0];
  if (now < end) end = now;
  int candlePeriod = int(TimeCopy[0] - TimeCopy[1]);
  int interval = int((now - start)/ candlePeriod); 
  while(TimeCopy[interval] <= end && interval > 0) {
    if (HighPrices[interval] > _dayHi) {
      _dayHi = HighPrices[interval];
      dayHiTime = TimeCopy[interval];
    }
    if (LowPrices[interval] < _dayLo) {
      _dayLo = LowPrices[interval];
      dayLoTime = TimeCopy[interval];
    }
    interval--;
  }
  lowerLevel = _dayHi;
  upperLevel = _dayLo;
}
  
  
