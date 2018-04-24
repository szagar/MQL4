//+------------------------------------------------------------------+
//|                                                    SetupBase.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

//#include <ATS/MagicNumber.mqh>

class SetupBase {
protected:
  void markOnChart(datetime,double);
public:
  string strategyName;
  bool callOnTick;
  bool callOnBar;
  bool triggered;
  Enum_SIDE side;
  Enum_SIDE sideSave;

  string symbol;
  int roboID;
  int tradeNumber;
  
  double rboPrice;
  //MagicNumber *magic;
  
  SetupBase();
  ~SetupBase();
  SetupBase(string,Enum_SIDE);  // : symbol(_symbol) {};  //{} // constructor

  void closeOpenTrades();
  
  virtual void OnInit()        { Debug(__FUNCTION__,__LINE__,"Entered"); };
  virtual void startOfDay()    { Debug(__FUNCTION__,__LINE__,"Entered"); }
  virtual void OnTick()        { Debug(__FUNCTION__,__LINE__,"Entered"); };
  virtual void OnBar()         { Debug(__FUNCTION__,__LINE__,"Entered"); };
  virtual void defaultParameters() { Debug(__FUNCTION__,__LINE__,"Entered"); };
  virtual void reset();
  virtual string to_human();
};


SetupBase::SetupBase() {
  symbol = Symbol();
  //magic = new MagicNumber();
  triggered = false;
}

SetupBase::SetupBase(string _symbol,Enum_SIDE _side) {
  symbol = _symbol;
  side = _side;
  sideSave = _side;
  callOnTick = false;
  callOnBar = false;
  //magic = new MagicNumber();
  triggered = false;
}

SetupBase::~SetupBase() {
   if (CheckPointer(magic) == POINTER_DYNAMIC) delete magic;
}

void SetupBase::closeOpenTrades() {
  for(int x=0;x<OrdersTotal();x++) {
    if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES)) {
//      if(strategyName && magic.getStrategy(OrderMagicNumber()) != magic) continue;
      if(StringCompare(magic.getStrategy(OrderMagicNumber()),strategyName,false)==0) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(OrderType()==0 || OrderType()==1)
        broker.closeTrade(OrderTicket());
    }    
  }
}

void SetupBase::reset() {
  triggered=false;
  side = sideSave;
  //if(UseDefaultParameters) defaultParameters();
};  


void SetupBase::markOnChart(datetime time, double price) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  static int objCnt=0;
  string objname;
  Info("Draw arrow "+TimeToStr(time)+ "@ "+DoubleToStr(price,Digits));
  objname = strategyName+"_"+IntegerToString(objCnt++);
  //Comment("Draw Object: "+objname);
  ObjectCreate(objname,OBJ_ARROW,0,time,price);
  ObjectSetInteger(0,objname,OBJPROP_COLOR,clrBlack);
}
  
string SetupBase::to_human() {
  string str = "";
  str += "strategyName : "+strategyName +"\n";
  str += "callOnTick   : "+(string)callOnTick   +"\n";
  str += "tradeNumber  : "+(string)tradeNumber  +"\n";
  str += "callOnBar    : "+(string)callOnBar    +"\n";
  str += "triggered    : "+(string)triggered    +"\n";
  str += "side         : "+EnumToString(side) +"\n";
  str += "sideSave     : "+EnumToString(sideSave) +"\n";;

  str += "symbol       : "+symbol       +"\n";
  str += "roboID       : "+(string)roboID       +"\n";
  str += "tradeNumber  : "+(string)tradeNumber  +"\n";
  str += "rboPrice     : "+DoubleToStr(rboPrice,Digits)     +"\n";
  return str;
}
