//#include <zts\common.mqh>
enum ENUM_PERSISTER {
  GlobalVar,
  File
 };  
 
 
class TradeStatus {
private:
  string StatusObjName;
  
  bool StatusObjExists();
  bool validateSide(string);
public:
  string setupType;
  string type;
  string side;
  double yellowLineLevel;
  double lowerLevel;
  double upperLevel;
  datetime dayHiTime;
  datetime dayLoTime;
  ENUM_PERSISTER Persister;
  
  TradeStatus();
  ~TradeStatus();

  string Encode();
  void Decode(string);

  void Persist();
  void UpdateObj();

  //void SetTradeObj(string);

  //void SetRange(double,double);
  //void SetYellowLevel(double);
  //void UpdateYellowLevel(double);
  //vode SetSetup(string);
  bool SetSetup(string, string, string);

  //void InitiateCDM(string);
  void InitiateRange(datetime, datetime end=NULL);
  //void InitiateRange();
  void UpdateRange();
  void loadFromChart();
};

string TradeStatus::Encode() {
  string str;
  if(setupType=="CDM")
    return("CDM:"+side+":"+DoubleToString(yellowLineLevel,Digits-1));
  if(setupType=="Range")
    return("R:"+side+":"+DoubleToString(lowerLevel,Digits-1)+":"+DoubleToString(upperLevel,Digits-1));
  return("TradeStatus: Type Unknown");
}

void TradeStatus::Decode(string str) {
}

void TradeStatus::loadFromChart() {
  string txt = ObjectGetString(MyChartId,StatusObjName,OBJPROP_TEXT);
  int error=GetLastError();
  if (error==4202) {
    Alert(__FUNCTION__+": Error in getting TradeType");
    txt = "NA";
  }
  string values[];
  int cnt = StringSplit(txt,StringGetCharacter(":",0),values);
  if(cnt<3) return;
  setupType = values[0];
  side = values[1];
  yellowLineLevel = double(values[2]);
}

void TradeStatus::UpdateObj() {
  string str = Encode();
  Print(__FUNCTION__,": check if Obj exists");
  if(!StatusObjExists()) {
    Print(__FUNCTION__,": Status Obj does not exist, create it");
    if(!LabelCreate(MyChartId,StatusObjName)) {
      Print(__FUNCTION__,": Could not create status label!");
      return;
    }
  }
  Print(__FUNCTION__,": set text for Status obj to ",str);
  if(!ObjectSetString(MyChartId,StatusObjName,OBJPROP_TEXT,str))
    Print(__FUNCTION__,": failed to change text! Error code = ",GetLastError());
}

TradeStatus::TradeStatus() {
  StatusObjName = "StatusObj";
}

TradeStatus::~TradeStatus() {
}

bool TradeStatus::SetSetup(string _setup, string arg1, string arg2) {
  setupType = _setup;
  if( setupType=="CDM") {
    if(!validateSide(arg1))
      return(false);
    side = arg1;
    yellowLineLevel = double(arg2);
    UpdateObj();
  } else if(setupType=="Range") {
    lowerLevel = double(arg1);
    upperLevel = double(arg2);
    UpdateObj();
  }
  else {
    Warn("SetupType: "+setupType+" not Defined. "+__FUNCTION__);
    return(false);
  } 
  return(true);
}

TradeStatus::Persist() {
  switch(Persister) {
    case GlobalVar:
      break;
    case File:
      break;
    default:
      break;
  }
}


void TradeStatus::UpdateRange() {
  lowerLevel = MathMin(lowerLevel,iLow(NULL,0,0));
  upperLevel = MathMax(upperLevel,iHigh(NULL,0,0));
}

/***
void TradeStatus::InitiateRange(datetime start, datetime end=NULL) {
  //lowerLevel = dayHi;
  //upperLevel = dayLo;

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
**/  
  
/************************************************************/
/*************** Helpers ************************************/
bool TradeStatus::StatusObjExists() {
  Print(__FUNCTION__,": check if ",StatusObjName," exists");
  int id = ObjectFind(StatusObjName);
  Print(__FUNCTION__,": id = ", id);
  return((id<0) ? false : true);
}

bool TradeStatus::validateSide(string s) {
  if(s=="Long" || s=="Short") return(true);
  return(false);
}