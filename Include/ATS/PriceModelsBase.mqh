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
  virtual double entryPrice(SetupStruct*,Enum_PRICE_MODELS model=NULL)      { Debug4(__FUNCTION__,__LINE__,"Entered");return(NULL); };
  virtual double entryPrice(Position*,Enum_PRICE_MODELS model=NULL)      { Debug4(__FUNCTION__,__LINE__,"Entered");return(NULL); };
  virtual double entryPriceLong(Enum_PRICE_MODELS)  { Debug4(__FUNCTION__,__LINE__,"Entered");return(NULL); };
  virtual double entryPriceShort(Enum_PRICE_MODELS) { Debug4(__FUNCTION__,__LINE__,"Entered");return(NULL); };
};

