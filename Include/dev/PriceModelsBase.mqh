//+------------------------------------------------------------------+
//|                                               PriceModelsBase.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

// CFoo(string name) : m_name(name) { Print(m_name);}
//--- The base class PriceModelsBase
class PriceModelsBase {
protected:
public:
  PriceModelsBase() {}
  ~PriceModelsBase() {};

  //bool entrySignal(Position*);
  virtual void entryPrice(Position*)      { Debug4(__FUNCTION__,__LINE__,"Entered"); };
  virtual void entryPriceLong(Position*)  { Debug4(__FUNCTION__,__LINE__,"Entered"); };
  virtual void entryPriceShort(Position*) { Debug4(__FUNCTION__,__LINE__,"Entered"); };
};

