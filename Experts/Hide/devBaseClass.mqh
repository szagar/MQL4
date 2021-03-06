class PatiParameters {
public:
  int DefaultStopPips;
  string StopPips;

  PatiParameters() {  
    DefaultStopPips = 12;
    StopPips = "EURUSD/8;AUDUSD,GBPUSD,EURJPY,USDJPY,USDCAD/10";
  }
};

class DevBase {
private:
  string TypeName;
  int DefaultStopPips;
  string StopPips;
  PatiParameters *params;
  bool BuySignal();

public:
  string ClassName;
  string Version;
  string Title;

  DevBase(string name = "DevBase class");
  ~DevBase();

  void OnInit();
  void OnDeinit(const int reason);
  void OnTick();
  void OnNewBar();
  void OnChartEvent(const int id, const long& lParam, const double& dParam, const string& sParam);

  int InitialStopInPips(string symbol);
  string tradeStatsHeader();
  string tradeStats();
  void Buy();
  
  void HelloWorld() {
    Print(__FUNCTION__+"**************************************************");                        
    Print(__FUNCTION__+"**************************************************");                        
    Print(__FUNCTION__+": Hellow World!");                        
    Print(__FUNCTION__+"**************************************************");                        
    Print(__FUNCTION__+"**************************************************");                        
  }
  string getTypeName() {
    return(TypeName);
  }
};


DevBase::DevBase(string _name = "DevBase class") {
   TypeName = "Mock class";
   ClassName = _name;
   Version = "0.013";
   Title = "ZTS Robo Framework dev";
   params = new PatiParameters();
  }

DevBase::~DevBase() {
  if (CheckPointer(params) == POINTER_DYNAMIC) delete params;
}
  
void DevBase::OnInit() {
  Print(__FUNCTION__,":  Entry");
}
 
void DevBase::OnDeinit(const int reason) {
  Print(__FUNCTION__,":  Entry");
}

void DevBase::OnTick() {
  //Print(__FUNCTION__,":  Entry");
}

void DevBase::OnNewBar() {
  Print(__FUNCTION__,":  Entry");
  double position;
  if(BuySignal()) {
    position = broker.GetOpenLots();
    if(position == 0)
      Buy();
    if(position < 0)
      broker.ExitLong();
  }        
}

void DevBase::Buy() {
  Print(__FUNCTION__,": buy code here");
}

void DevBase::OnChartEvent(const int id, const long& lParam, const double& dParam, const string& sParam) {
  Print(__FUNCTION__,":  Entry");
}

int DevBase::InitialStopInPips(string symbol) {
  Print(__FUNCTION__,":  Entry");
  int stop = _defaultStopPips;
  int pairPosition = StringFind(_exceptionPairs, symbol, 0);
  if (pairPosition >=0) {
    int slashPosition = StringFind(_exceptionPairs, "/", pairPosition) + 1;
    stop = int(StringToInteger(StringSubstr(_exceptionPairs,slashPosition)));
  }
  return stop;
}

string DevBase::tradeStatsHeader() {
  return("TBD1,TBD2");
}

string DevBase::tradeStats() {
  return("tbd1,tbd2");
}

bool DevBase::BuySignal() {
  int    Period_MA_1=11;      // Period of MA 1
  int    Period_MA_2=31;      // Period of MA 2

  double MA_1_t=iMA(NULL,0,Period_MA_1,0,MODE_LWMA,PRICE_TYPICAL,0); // МА_1
  double MA_2_t=iMA(NULL,0,Period_MA_2,0,MODE_LWMA,PRICE_TYPICAL,0); // МА_2
  return(MA_1_t > MA_2_t + 28*Point);
}
/****************************************************************************************/
/****************************************************************************************/
