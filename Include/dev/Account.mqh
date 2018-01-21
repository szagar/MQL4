//+------------------------------------------------------------------+
//|                                                      Account.mqh |
//|                                                    Stephen Zagar |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property version   "1.00"
#property strict
#include <dev\common.mqh>
/**
AccountBalance         : Returns balance value of the current account
AccountCredit          : Returns credit value of the current account
AccountCompany         : Returns the brokerage company name where the current account was registered
AccountCurrency        : Returns currency name of the current account
AccountEquity          : Returns equity value of the current account
AccountFreeMargin      : Returns free margin value of the current account
AccountFreeMarginCheck : Returns free margin that remains after the specified position has been 
                         opened at the current price on the current account
AccountFreeMarginMode  : Calculation mode of free margin allowed to open orders on the current account
AccountLeverage        : Returns leverage of the current account
AccountMargin          : Returns margin value of the current account
AccountName            : Returns the current account name
AccountNumber          : Returns the current account number
AccountProfit          : Returns profit value of the current account
AccountServer          : Returns the connected server name
AccountStopoutLevel    : Returns the value of the Stop Out level
AccountStopoutMode     : Returns the calculation mode for the Stop Out level
**/
class Account {
private:
public:
  Account();
  ~Account();
  string TypeName;
  string accountName;
  int accountNumber;
  virtual string serverName() {
    return AccountServer();
  }
  virtual double freeMargin() {
    return(AccountFreeMargin());
  }
};



Account::Account() {
  TypeName = "RealAccount";
  accountName = AccountName();
  accountNumber = AccountNumber();
}

Account::~Account() {
}



