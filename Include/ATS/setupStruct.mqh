class SetupStruct {
public:
  string    strategyName;
  string    symbol;
  Enum_SIDE side;
  int       sideX;
  bool      isPending;
  int       orderType;
  double    limitPrice;
  double    stopPrice;
  double    entryPrice;
  int       oneRpips;
  
  string    to_human();
};

string SetupStruct::to_human() {
  string str;
  str="strategyName="+strategyName                   +"\n"+
       "symbol     ="+symbol                         +"\n"+
       "side       ="+EnumToString(side)             +"\n"+
       "sideX      ="+string(sideX)                  +"\n"+
       "isPending  ="+string(isPending)              +"\n"+
       "orderType  ="+string(orderType)              +"\n"+
       "limitPrice ="+DoubleToStr(limitPrice,Digits) +"\n"+
       "stopPrice  ="+DoubleToStr(stopPrice,Digits)  +"\n"+
       "entryPrice ="+DoubleToStr(entryPrice,Digits) +"\n"+
       "oneRpips   ="+string(oneRpips);
  return(str);
}

