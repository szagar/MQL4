//+------------------------------------------------------------------+
//|                                                        Setup.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

// CFoo(string name) : m_name(name) { Print(m_name);}
//--- The base class Setup
class Setup {
protected:
public:
  string symbol;
  Enum_SIDE side;
  string name;
         Setup();
         Setup(string _symbol);  // : symbol(_symbol) {};  //{} // constructor
  virtual bool triggered(){return false;};
};

Setup::Setup() {
  //symbol = Symbol();
}

Setup::Setup(string _symbol) {
  symbol = _symbol;
}

  