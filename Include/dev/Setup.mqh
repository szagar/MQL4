//+------------------------------------------------------------------+
//|                                                        Setup.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

//#include <dev/MagicNumber.mqh>

class Setup {
protected:
  void markOnChart(datetime,double);
public:
  string strategyName;
  bool callOnTick;
  bool callOnBar;
  bool triggered;
  Enum_SIDE side;
  Enum_SIDE Side;

  string symbol;
  int roboID;
  int tradeNumber;
  //MagicNumber *magic;
  
  Setup();
  Setup(string,Enum_SIDE);  // : symbol(_symbol) {};  //{} // constructor

  virtual void OnInit()        { Debug4(__FUNCTION__,__LINE__,"Entered"); };
  virtual void startOfDay()    { Debug4(__FUNCTION__,__LINE__,"Entered"); }
  virtual void OnTick()        { Debug4(__FUNCTION__,__LINE__,"Entered"); };
  virtual void OnBar()         { Debug4(__FUNCTION__,__LINE__,"Entered"); };
  virtual void reset();

};


Setup::Setup() {
  symbol = Symbol();
  //magic = new MagicNumber();
  triggered = false;
}

Setup::Setup(string _symbol,Enum_SIDE _side) {
  symbol = _symbol;
  side = _side;
  Side = _side;
  callOnTick = false;
  callOnBar = false;
  //magic = new MagicNumber();
  triggered = false;
}

void Setup::reset() {
  triggered=false;
  side = Side;
};  


void Setup::markOnChart(datetime time, double price) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  static int objCnt=0;
  string objname;
  Info("Draw arrow "+TimeToStr(time)+ "@ "+DoubleToStr(price,Digits));
  objname = strategyName+"_"+IntegerToString(objCnt++);
  Comment("Draw Object: "+objname);
  ObjectCreate(objname,OBJ_ARROW,0,time,price);
  ObjectSetInteger(0,objname,OBJPROP_COLOR,clrBlack);
}
  
