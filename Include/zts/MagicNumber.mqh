//+------------------------------------------------------------------+
//|                                                  MagicNumber.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <zts\common.mqh>

class MagicNumber {
  // min:  -2,147,483,648
  // max:   2,147,483,647
  //               strategy:         n,nxx,xxx,xxx
  //               trailing stop:    x,xnx,xxx,xxx
  //               partial profit:   x,xxn,xxx,xxx
  //               one R pips:       x,xxx,nnx,xxx
private:
  int magicTemplate;
  int strategyId;
  int trailingStopModel;
  int partialProfitModel;
  int oneR;
  
  int Strategy_mult;
  int TrailingStopModel_mult;
  int PartialProfitModel_mult;
  int OneR_mult;

  int Strategy_digits;
  int OneR_digits;
  int TrailingStopModel_digits;
  int PartialProfitModel_digits;
  
  string decodeStrategyName(int);

  
public:
  MagicNumber(int,int,int);
  ~MagicNumber();
  
  int get(string="",int=0);
  int encodeStrategyName(string);
  int getOneR(int);
  string getStrategy(int);
};

MagicNumber::MagicNumber(int _oneR=0,int _trailingStopModel=0,int _partialProfitModel=0) {
  oneR = _oneR;
  trailingStopModel = _trailingStopModel;
  partialProfitModel = _partialProfitModel;

  Strategy_mult           = 100000000;
  TrailingStopModel_mult  = 10000000;
  PartialProfitModel_mult = 1000000;
  OneR_mult               = 10000;

  Strategy_digits           = 2;
  OneR_digits               = 2;
  TrailingStopModel_digits  = 1;
  PartialProfitModel_digits = 1;
  
  magicTemplate = 0;
  magicTemplate *= oneR * OneR_mult;
  magicTemplate *= trailingStopModel * TrailingStopModel_mult;
  magicTemplate *= partialProfitModel * PartialProfitModel_mult;
  
}

MagicNumber::~MagicNumber() {
}

int MagicNumber::get(string _strategy="",int _oneR=0) {
  strategyId = encodeStrategyName(_strategy);
  Debug("strategyId="+string(strategyId));
  Debug("MagicNumber: _strategy="+_strategy+"  _oneR="+string(_oneR)+" magicTemplate="+string(magicTemplate)+" strategyId="+string(strategyId));
  Debug(string(magicTemplate)+" + "+string(strategyId)+"*"+string(Strategy_mult)+" + "+string(_oneR)+"*"+string(OneR_mult));
  return(magicTemplate + strategyId*Strategy_mult + _oneR*OneR_mult);
}

int MagicNumber::encodeStrategyName(string name) {
  if(StringCompare(name,"CDM-YL",false)==0) return(1);
  if(StringCompare(name,"RBO",false)==0) return 2;
  if(StringCompare(name,"MOMO",false)==0) return 3;
  if(StringCompare(name,"COD",false)==0) return 4;
  Print("Strategy ",name," NOT coded for in MagicNumber");
  return 0;
}

string MagicNumber::decodeStrategyName(int magicNumber) {
  if(magicNumber == 0) return "";
  int num = magicNumber/Strategy_mult;
  int den = int(MathPow(10,Strategy_digits));
  int id = int(MathMod(num,den));
  if(id == 1) return "CDM-YL";
  if(id == 2) return "RBO";
  if(id == 3) return "MOMO";
  if(id == 4) return "COD";
  return "";
}

string MagicNumber::getStrategy(int magicNumber) {
  return decodeStrategyName(magicNumber);
}

int MagicNumber::getOneR(int magicNumber) {
  int rtn = magicNumber / OneR_mult;
  Print("getOneR: ",magicNumber," => ",rtn);
  Print("return(int((",rtn," % ",int(MathPow(10,OneR_digits)),")*",OnePoint,"));");
  return(int((rtn % int(MathPow(10,OneR_digits)))  ));  //*OnePoint));
}
