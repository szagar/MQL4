//+------------------------------------------------------------------+
//| Candle Closing Time Remaining-(CCTR).mq4                           |
//| Copyright 2013,Foad Tahmasebi                                    |
//| Version 2.0                                                      |
//| http://www.daskhat.ir                                            |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013,Foad Tahmasebi"
#property link      "http://www.daskhat.ir"

#property indicator_chart_window
//--- input parameters

extern int       location=1;
extern int       displayServerTime=0;
extern int       fontSize=9;
extern color     colour=Silver;


//--- variables
double leftTime;
string sTime;
int days;
string sCurrentTime;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
  if(location != 0){
     ObjectCreate("CandleClosingTimeRemaining-CCTR",OBJ_LABEL,0,0,0);
     ObjectSet("CandleClosingTimeRemaining-CCTR",OBJPROP_CORNER,location);
     ObjectSet("CandleClosingTimeRemaining-CCTR",OBJPROP_XDISTANCE,5);
     ObjectSet("CandleClosingTimeRemaining-CCTR",OBJPROP_YDISTANCE,3);
 }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("CandleClosingTimeRemaining-CCTR");
   Comment("");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {

//----


   sCurrentTime=TimeToStr(TimeCurrent(),TIME_SECONDS);
   
   leftTime =(Period()*60)-(TimeCurrent()-Time[0]);
   sTime= TimeToStr(leftTime,TIME_SECONDS);
   if(DayOfWeek()==0 || DayOfWeek()==6){
      if(location == 0){
      
            Comment("Candle Closing Time Remaining: " + "Market Is Closed");

      }else{
         ObjectSetText("CandleClosingTimeRemaining-CCTR", "Market Is Closed",fontSize,"verdana",colour);
      }
   }else{
      if(Period() == PERIOD_MN1 || Period()==PERIOD_W1){
         days =((leftTime/60)/60)/24;
         if(location == 0){
            if(displayServerTime == 0){
               Comment("Candle Closing Time Remaining: " + days +"D - "+sTime);
            }else{
               Comment("Candle Closing Time Remaining: " + days +"D - "+sTime+ " ["+ sCurrentTime+"]");
            }
         }else{
            if(displayServerTime == 0){
                ObjectSetText("CandleClosingTimeRemaining-CCTR", days +"D - "+sTime,fontSize,"verdana",colour);
            }else{
                ObjectSetText("CandleClosingTimeRemaining-CCTR", days +"D - "+sTime+ " ["+ sCurrentTime+"]",fontSize,"verdana",colour);
            }
         }
      }else{  
         if(location == 0){
            if(displayServerTime == 0){
               Comment("Candle Closing Time Remaining: " + sTime);
            }else{
               Comment("Candle Closing Time Remaining: " + sTime+ " ["+ sCurrentTime+"]");
            }
         }else{ 
            if(displayServerTime == 0){
               ObjectSetText("CandleClosingTimeRemaining-CCTR", sTime,fontSize,"verdana",colour);
            }else{
               ObjectSetText("CandleClosingTimeRemaining-CCTR", sTime + " ["+ sCurrentTime+"]" ,fontSize,"verdana",colour);
            }
         }
      }
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+