//+------------------------------------------------------------------+
//|                                                        Setup.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <dev/MagicNumber.mqh>

// CFoo(string name) : m_name(name) { Print(m_name);}
//--- The base class Setup
class Setup {
protected:
  void markOnChart(datetime,double);
public:
  string symbol;
  Enum_SIDE side;
  //bool goShort;
  bool callOnTick;
  bool callOnBar;
  string strategyName;
  int roboID;
  int tradeNumber;
  bool triggered;
  MagicNumber *magic;
  
  Setup();
  Setup(string,Enum_SIDE);  // : symbol(_symbol) {};  //{} // constructor

  virtual void reset() {triggered=false;};  
  virtual void OnInit()        { Debug4(__FUNCTION__,__LINE__,"Entered"); };
  virtual void OnTick()        { Debug4(__FUNCTION__,__LINE__,"Entered"); };
  virtual void OnBar()         { Debug4(__FUNCTION__,__LINE__,"Entered"); };
  virtual void startOfDay()    { Debug4(__FUNCTION__,__LINE__,"Entered"); }
  //virtual bool entrySignaled() {
  //  Debug4(__FUNCTION__,__LINE__,"Entered");
  //  return(false);
  //}
};


Setup::Setup() {
  symbol = Symbol();
  magic = new MagicNumber();
  triggered = false;
}

Setup::Setup(string _symbol,Enum_SIDE _side) {
  symbol = _symbol;
  side = _side;
  callOnTick = false;
  callOnBar = false;
  magic = new MagicNumber();
  triggered = false;
}

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
  
