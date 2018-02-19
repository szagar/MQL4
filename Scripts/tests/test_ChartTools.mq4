//+------------------------------------------------------------------+
//|                                          test_ChartTools.mqh.mq4 |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict
//#property show_inputs

#include <dev\logger.mqh>
#include <dev\ChartTools.mqh>
extern bool           Testing = false;
extern Enum_LogLevels LogLevel = LogInfo;  //- Log Level
extern Enum_Sessions  session  = NewYork;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
  ChartTools *chart = new ChartTools();
  chart.drawRange_session(Asia,false);
  chart.drawRange_session(London,false);
  chart.drawRange_session(NewYork,false);
  Debug(__FUNCTION__,__LINE__,"Asia High/Low: "+DoubleToStr(chart.getSessionHigh("Asia"),Digits)+" / "+DoubleToStr(chart.getSessionLow("Asia"),Digits));
  Debug(__FUNCTION__,__LINE__,"London High/Low: "+DoubleToStr(chart.getSessionHigh("London"),Digits)+" / "+DoubleToStr(chart.getSessionLow("London"),Digits));
  Debug(__FUNCTION__,__LINE__,"NewYork High/Low: "+DoubleToStr(chart.getSessionHigh("NewYork"),Digits)+" / "+DoubleToStr(chart.getSessionLow("NewYork"),Digits));
  if (CheckPointer(chart) == POINTER_DYNAMIC) delete chart;
}
