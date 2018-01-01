//+------------------------------------------------------------------+
//|                                                   trade_type.mqh |
//+------------------------------------------------------------------+
#property strict

#include <zts/create_label.mqh>

string TradeTypeObjName = "TradeTypeObj";
const long MyChartId = 0;

void SetTradeTypeObj(string tradeType) {
  Print(__FUNCTION__,": check if Obj exists");
  if(!TradeTypeObjExists()) {
    Print(__FUNCTION__,": TradeType Obj does not exist, create it");
    if(!LabelCreate(MyChartId,TradeTypeObjName)) {
      Print(__FUNCTION__,": Could not create trade type label!");
      return;
    }
  }
  Print(__FUNCTION__,": set text for TradeType obj to ",tradeType);
  if(!ObjectSetString(MyChartId,TradeTypeObjName,OBJPROP_TEXT,tradeType)) 
    Print(__FUNCTION__,": failed to change text! Error code = ",GetLastError());
}

string GetTradeType() {
  string txt = ObjectGetString(MyChartId,TradeTypeObjName,OBJPROP_TEXT);  
  int error=GetLastError();
  if (error==4202) {
    Alert(__FUNCTION__+": Error in getting TradeType");
    txt = "NA";
  }
  return(txt);
}

void ClearTradeType() {
  ResetLastError();
  if(!ObjectDelete(MyChartId,TradeTypeObjName)) {
    Print(__FUNCTION__,": failed to delete \"Text\" object! Error code =", GetLastError());
  }
}

bool TradeTypeObjExists() {
  Print(__FUNCTION__,": check if ",TradeTypeObjName," exists");
  int id = ObjectFind(TradeTypeObjName);
  Print(__FUNCTION__,": id = ", id);
  return((id<0) ? false : true);
}

