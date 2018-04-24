//+------------------------------------------------------------------+
//|                                              candle_patterns.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

bool candlePattern_BigShadow() {
  if(iHigh(NULL,0,1)>iHigh(NULL,0,2) && iLow(NULL,0,1)<iLow(NULL,0,2))
    return true;
  return false;
}
bool candlePattern_BiggestRange(int barsBack) {
  double range1;
  int bindex=2;
  range1 = iHigh(NULL,0,1) - iLow(NULL,0,1);
  while(true) {
    if(iHigh(NULL,0,bindex) - iLow(NULL,0,bindex) > range1)
      return false;
    if(bindex>barsBack)
      return true;
    bindex++;
  }
}