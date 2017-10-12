//+------------------------------------------------------------------+
//|                                                 account_info.mq4h|
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, zts"
#property link      "https://"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+:
class ZtsAccountInfo {
  private:
  public:
    string toString(){
      return "Free Margin Mode \t: " + FreeMarginMode() + "\n" +
             "Balance          \t: " + string(AccountBalance()) + "\n" +
             "Credit           \t: " + string(AccountCredit()) + "\n" +
             "Equity           \t: " + string(AccountEquity()) + "\n" +
             "Company          \t: " + AccountCompany() + "\n" +
             "Free Margin      \t: " + string(AccountFreeMargin()) + "\n" +
             "Margin           \t: " + string(AccountMargin()) + "\n" +
             "Profit           \t: " + string(AccountProfit()) + "\n" +
             "Name             \t: " + AccountName() + "\n" +
             "Leverage         \t: " + string(AccountLeverage()) + "\n" +
             "Number           \t: " + string(AccountNumber()) + "\n" +
             "Server           \t: " + AccountServer() + "\n" +
             "Stopout Level    \t: " + string(AccountStopoutLevel()) + (AccountStopoutMode()==0?"%":AccountCurrency()) + "\n" +
             "Stopout Mode     \t: " + StopoutMode();
    }

string StopoutMode() {
  string rtn;
  switch (AccountStopoutMode()) {
    case 0: 
      return("calculation of percentage ratio between margin and equity");
    case 1:
      return("comparison of the free margin level to the absolute value");
    default:
      return("Unknown");
  }
}

string FreeMarginMode() {
  string rtn;
  Alert("Free Margin Mode = " + string(AccountFreeMarginMode()));
  switch (AccountFreeMarginMode()) {
    case 0:
      rtn = "floating profit/loss is not used for calculation";
      break;
    case 1:
      rtn = "both floating profit and loss on opened orders are used for free margin calculation";
      break;
    case 2:
      rtn = "only profit value is used for calculation, the current loss on opened orders is not considered";
      break;
    case 3:
      rtn = "only loss value is used for calculation, the current loss on opened orders is not considered";
      break;
    default:
      rtn = "not found";
    }
    Print(rtn);
    return rtn;

  //0 - floating profit/loss is not used for calculation;
  //1 - both floating profit and loss on opened orders on the current account are used for free margin calculation;
  //2 - only profit value is used for calculation, the current loss on opened orders is not considered;
  //3 - only loss value is used for calculation, the current loss on opened orders is not considered.
}

ZtsAccountInfo::ZtsAccountInfo(){
}

ZtsAccountInfo::~ZtsAccountInfo(){
}