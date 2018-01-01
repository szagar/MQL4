//+------------------------------------------------------------------+
//|                                                  FakeAccount.mqh |
//|                                                    Stephen Zagar |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property version   "1.00"
#property strict

class FakeAccount : public Account {
private:
public:
  FakeAccount();
  ~FakeAccount();
  
  virtual double freeMargin() {
    return 3323.82;
  }

};

FakeAccount::FakeAccount() {
  TypeName = "FakeAccount";
}

FakeAccount::~FakeAccount() {
}

