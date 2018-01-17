//+------------------------------------------------------------------+
//|                                                        zts01.mqh |
//+------------------------------------------------------------------+
#property strict

#include <zts\common.mqh>

class Robo {
private:
  bool pendingSetup;
  bool rangeIsSet;
  int exitStrats[5];
  int exitStratCnt;
  int setupList[5];
  int setupCnt;

  double rangeLower, rangeUpper;
  
  void checkForSetups();
  void newYellowLine(string);
  void setRangeForSession(string);
  void setRange(datetime, datetime, datetime&[], double&[], double&[]); 
public:
  Robo();
  ~Robo();
  
  int OnInit();
  void OnDeinit();
  void OnTick();
  void OnNewBar();
  
  void setExitStrategy(int);
  void addSetup(int);
  void cleanUpEOD();
  void startOfDay();
};

Robo::Robo() {
  pendingSetup = false;
  rangeIsSet = false;
  exitStratCnt = 0;
  setupCnt = 0;
}
  
Robo::~Robo() {
 }

int Robo::OnInit() {return(0);}
void Robo::OnDeinit() { }
void Robo::OnTick() { }
void Robo::OnNewBar() { }
  
void Robo::setExitStrategy(int _strategyIndex) { 
  exitStrats[exitStratCnt++] = _strategyIndex;
}
void Robo::addSetup(int _setupIndex) {
  setupList[setupCnt++] = _setupIndex;
}
void Robo::cleanUpEOD() { }
void Robo::startOfDay() { }

void Robo::checkForSetups() {
  for(int i=0;i<setupCnt;i++) {
    switch(i) {
      case 1:     // RBO
        if(!rangeIsSet) continue;
        break;
      case 2:     // CDM
        if(!rangeIsSet) continue;
        if((Close[0] - rangeUpper) >= 20)
          newYellowLine("Long");
        if((rangeLower - Close[0]) >= 20)
          newYellowLine("Short");
        break;
      default:
        Warn(__FUNCTION__+": setup ID not handled!");
    }
  }
}

void Robo::newYellowLine(string side) {
}

void Robo::setRangeForSession(string sessionName) {
  datetime TimeCopy[];
  ArrayCopy(TimeCopy, Time, 0, 0, WHOLE_ARRAY);
  double HighPrices[];
  ArrayCopy(HighPrices, High, 0, 0, WHOLE_ARRAY);
  double LowPrices[];
  ArrayCopy(LowPrices, Low, 0, 0, WHOLE_ARRAY);
  datetime startTime, endTime;

  startTime = TimeCopy[10];
  endTime =  TimeCopy[0];
  
  if(sessionName=="Asian") {
    startTime = TimeCopy[10];
    endTime = TimeCopy[0];
  } else if(sessionName=="London") {
    startTime = TimeCopy[10];
    endTime = TimeCopy[0];
  } else if(sessionName=="NewYork") {
    startTime = TimeCopy[10];
    endTime =  TimeCopy[0];
  }
  setRange(startTime, endTime, TimeCopy, HighPrices, LowPrices);
}

void Robo::setRange(datetime start, datetime end, 
                    datetime& TimeCopy[], double& HighPrices[], double& LowPrices[]) {
  double dayHi = 0.0;
  double dayLo = 9999.99;
  datetime dayHiTime, dayLoTime;
  
  datetime now = TimeCopy[0];
  if (now < end) end = now;
  int candlePeriod = int(TimeCopy[0] - TimeCopy[1]);
  int interval = int((now - start)/ candlePeriod); 
  while(TimeCopy[interval] <= end && interval > 0) {
    if (HighPrices[interval] >dayHi) {
      dayHi = HighPrices[interval];
      dayHiTime = TimeCopy[interval];
    }
    if (LowPrices[interval] < dayLo) {
      dayLo = LowPrices[interval];
      dayLoTime = TimeCopy[interval];
    }
    interval--;
  }
}

