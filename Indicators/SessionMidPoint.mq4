//+------------------------------------------------------------------+
//|                                              SessionMidPoint.mq4 |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 clrWhite
#property indicator_color2 clrGreen
#property indicator_color3 clrWhite
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1

#property indicator_type1   DRAW_SECTION 
#property indicator_style1  STYLE_SOLID 
#property indicator_type2   DRAW_SECTION 
#property indicator_type3   DRAW_SECTION

#include <zts/logger.mqh>
#include <zts/TradingSessions.mqh>
extern Enum_LogLevels LogLevel = LogInfo;
extern bool Testing = false;

extern bool ShowSessionHigh = false;
extern bool ShowSessionMid = true;
extern bool ShowSessionLow = false;

double BufferSessionHighPoint[];
double BufferSessionMidPoint[];
double BufferSessionLowPoint[];

datetime sessionStart=0;
datetime sessionEnd;
int startBar;
int endBar;
TradingSessions *session;
double sessionHigh;
double sessionLow;

#define SessionHighPointIndicator 0
#define SessionMidPointIndicator 1
#define SessionLowPointIndicator 2

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
  Print("OnInit");
  SetIndexBuffer(SessionHighPointIndicator,BufferSessionHighPoint,INDICATOR_DATA);
  SetIndexLabel(SessionHighPointIndicator,"Session HighPoint");
  PlotIndexSetDouble(SessionHighPointIndicator,PLOT_EMPTY_VALUE,0);
  SetIndexStyle(SessionHighPointIndicator,DRAW_SECTION);

  SetIndexBuffer(SessionMidPointIndicator,BufferSessionMidPoint);
  //SetIndexStyle(SessionMidPointIndicator,DRAW_LINE);
  SetIndexLabel(SessionMidPointIndicator,"Session MidPoint");
  PlotIndexSetDouble(SessionMidPointIndicator,PLOT_EMPTY_VALUE,0);

  SetIndexBuffer(SessionLowPointIndicator,BufferSessionLowPoint);
  SetIndexLabel(SessionLowPointIndicator,"Session LowPoint");
  PlotIndexSetDouble(SessionLowPointIndicator,PLOT_EMPTY_VALUE,0);

   session = new TradingSessions();
   session.setSession(NYSE);
   Print(session.showSession(true));
   Print("start = "+session.startTradingSession_Server);
   Print("end = "+session.endTradingSession_Server);
   return(INIT_SUCCEEDED);
  }
  
void OnDeinit(const int reason) {
  //if (reason != REASON_CHARTCHANGE && reason!= REASON_PARAMETERS && reason != REASON_RECOMPILE)
  //  DeleteAllObjects();
  //for(int ix=totalActiveTrades - 1;ix >=0;ix--) {
  //  if (CheckPointer(activeTradesLastTick[ix]) == POINTER_DYNAMIC)
  //    delete activeTradesLastTick[ix];
  //}
  if (CheckPointer(session) == POINTER_DYNAMIC) delete session;
   
  return;
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
    
  int limit;
  int barShift;
  double midPoint;

  limit=rates_total-prev_calculated;
  if(limit == 0) return(rates_total);
    //Print("rates_toal="+rates_total+"  prec_calc="+prev_calculated);

  if(prev_calculated>0) limit++;

  //if(!inSession(time[0]))
  //  return 0;
  for(int i=limit-1; i>=0; i--) {
    BufferSessionHighPoint[i] = 0;
    BufferSessionMidPoint[i] = 0;
    BufferSessionLowPoint[i] = 0;
    if(session.tradeWindow(time[i],TradingSession)) {
      sessionStart = session.previousSessionStart(time[i]);
      Print(TimeToString(time[i])+" ======>"+sessionStart);
      barShift = iBarShift(NULL,0,sessionStart);
      Print("barShift="+barShift);
      Print("i="+i);
      Print("high bar#="+iHighest(NULL,0,MODE_HIGH,barShift-i,i));
      sessionHigh = high[iHighest(NULL,0,MODE_HIGH,barShift-i,i)];
      Print("sessionHigh="+sessionHigh);
      Print("low bar#="+iLowest(NULL,0,MODE_LOW,barShift-i,i));
      sessionLow = low[iLowest(NULL,0,MODE_LOW,barShift-i,i)];
      Print("sessionLow="+sessionLow);
      if(ShowSessionHigh)
        BufferSessionHighPoint[i] = sessionHigh;
      if(ShowSessionMid)
        BufferSessionMidPoint[i] = (sessionHigh+sessionLow)/2.0;
      if(ShowSessionLow)
        BufferSessionLowPoint[i] = sessionLow;
    }
  }   
  
  //if(time[0] > sessionEnd)
  //  setSessionTimes();
    
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

void initSessionTimes(datetime t) {
  Print("In initSessionTImes("+TimeToString(t)+")");
  //string sessionStart_str = "13:00";
  //string sessionEnd_str = "20:00";
  //sessionStart = StrToTime(sessionStart_str);
  sessionStart = t;
  sessionEnd = sessionStart + 5*60*60;  
  Comment("initSessionTImes(): sessionStart="+TimeToString(sessionStart));
}

void setSessionTimes() {
  sessionStart += 60*60*60;
  sessionEnd += 60*60*60;
}


bool inSession(datetime t) {
  return(t>=sessionStart && t<=sessionEnd);
}