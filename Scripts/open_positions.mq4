//+------------------------------------------------------------------+
//|                                               open_positions.mq4 |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

#include <zts\MagicNumber.mqh>
void OnStart() {
  string side;
  int lastError;
  int oneR;
  int numLongPositions = 0;
  int numShortPositions = 0;
  MagicNumber *magic;
  
  magic = new MagicNumber();
  for(int i=OrdersTotal()-1; i>=0; i--)  {
    if(!OrderSelect(i,SELECT_BY_POS)) {
      lastError = GetLastError();
      Print("OrderSelect("+string(i)+", SELECT_BY_POS) - Error #"+string(lastError));
      continue;
    }

    if(OrderType() != OP_BUY && OrderType() != OP_SELL) continue;
    //if(StringCompare(magic.getStrategy(OrderMagicNumber()), "CDM-YL", false)!=0) continue;
    if(OrderType() == OP_BUY ) {
      numLongPositions++;
      oneR = magic.getOneR(OrderMagicNumber());
      Print("OrderMagicNumber=",OrderMagicNumber());
      Print("oneR=",oneR);
      side = "long";
    }
    if(OrderType() == OP_SELL) {
      numShortPositions++;
      oneR = magic.getOneR(OrderMagicNumber());
      Print("OrderMagicNumber=",OrderMagicNumber());
      Print("oneR=",oneR);
      side = "short";
    }
    string format_header=StringFormat("%6s: %5s %4s %5s %6s","Symbol","side","oneR","Size","Basis");
    PrintFormat(format_header);

    string format_string=StringFormat("%%6s: %%5s %%4d %%5.2f @%%6.%df",Digits); //*CommonSetPipAdj());
    Print(format_string);
    PrintFormat(format_string,OrderSymbol(),side,oneR,OrderLots(),OrderOpenPrice());
    //Print(side,"  ",OrderSymbol(),"  ",oneR,"  ",OrderLots()," @",OrderOpenPrice(),"  ",OrderProfit(),"  ",OrderComment(),"  ",magic.getStrategy(OrderMagicNumber()),string(OrderMagicNumber()),oneR);

  }
  //sampleFormatted();
}

void sampleFormatted() {
// FXChoice-Classic Demo 89337: leverage = 1:200
  string server=AccountInfoString(ACCOUNT_SERVER);
  int login=(int)AccountInfoInteger(ACCOUNT_LOGIN);
  long leverage=AccountInfoInteger(ACCOUNT_LEVERAGE);
  PrintFormat("%s %d: leverage = 1:%I64d",
               server,login,leverage);

// FXChoice-Classic Demo 89337: account equity = 2898.36 USD
  string currency=AccountInfoString(ACCOUNT_CURRENCY);               
  double equity=AccountInfoDouble(ACCOUNT_EQUITY);
  PrintFormat("%s %d: account equity = %.2f %s",
               server,login,equity,currency);


// FXChoice-Classic Demo 89337: current result for open orders = +224.36 USD
  double profit=AccountInfoDouble(ACCOUNT_PROFIT);
  PrintFormat("%s %d: current result for open orders = %+.2f %s",
               server,login,profit,currency);
               
//BTCUSD,Daily: BTCUSD: point value  = 0.01
  double point_value=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
  string format_string=StringFormat("%%s: point value  = %%.%df",_Digits);
  PrintFormat(format_string,_Symbol,point_value);
  
// BTCUSD: current spread in points = 3808 

  int spread=(int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
  PrintFormat("%s: current spread in points = %d ",
               _Symbol,spread);
               
// DBL_MAX = 1.79769313486231571e+308
  PrintFormat("DBL_MAX = %.17e",DBL_MAX);  
   
//EMPTY_VALUE = 2.14748364700000000e+09
  PrintFormat("EMPTY_VALUE = %.17e",EMPTY_VALUE); 
  
// PrintFormat(EMPTY_VALUE) = 2.147484e+09
  PrintFormat("PrintFormat(EMPTY_VALUE) = %e",EMPTY_VALUE);
  
// Print(EMPTY_VALUE) = 2147483647
  Print("Print(EMPTY_VALUE) = ",EMPTY_VALUE);


}