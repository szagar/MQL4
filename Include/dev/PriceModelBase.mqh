//+------------------------------------------------------------------+
//|                                               PriceModelBase.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

// CFoo(string name) : m_name(name) { Print(m_name);}
//--- The base class PriceModelBase
class PriceModelBase {
protected:
public:
  PriceModels() {}
  ~PriceModels() {};

  //bool entrySignal(Position*);
  virtual void entryPrice(Position*) { Debug4(__FUNCTION__,__LINE__,"Entered"); };
  virtual void entryPriceLong(Position*) { Debug4(__FUNCTION__,__LINE__,"Entered"); };
  virtual void entryPriceShort(Position*) {Models();
  ~PriceModels();

  void entryPrice(Position*);
  void entryPriceLong(Position*);
  void entryPriceShort(Position*);(__FUNCTION__,__LINE__,"Entered"); };
};

