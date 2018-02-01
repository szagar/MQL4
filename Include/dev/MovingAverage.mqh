//+------------------------------------------------------------------+
//|                                               MovingAverage.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

extern string commentString_MA_0 = ""; //---------------------------------------------
extern string commentString_MA1 = "";  //*** Moving Average settings:
extern Enum_MA_MODELS MA_Model = MA_200_DMA;              //>> Model
extern int                MA_NumberOfMAs = 1;              //- Number of moving averages
extern int                MA_Slope_Long = 5;               //- MA Slope criteria for longs
extern int                MA_Slope_Short = -5;             //- MA Slope criteria for shorts
extern ENUM_MA_METHOD     MA_1_Type = MODE_SMA;            //- MA-1 type (fastest)
extern ENUM_APPLIED_PRICE MA_1_Price = PRICE_CLOSE;        //- MA-1 price to use
extern int                MA_1_Periods = 200;              //- MA-1 #periods
extern ENUM_TIMEFRAMES    MA_1_TimeFrame = PERIOD_D1;      //- MA-1 timeframe
extern ENUM_MA_METHOD     MA_2_Type = MODE_EMA;            //- MA-2 type (slow)
extern ENUM_APPLIED_PRICE MA_2_Price = PRICE_CLOSE;        //- MA-2 price to use
extern int                MA_2_Periods = 21;               //- MA-2 #periods
extern ENUM_TIMEFRAMES    MA_2_TimeFrame = PERIOD_CURRENT; //- MA-2 timeframe
extern ENUM_MA_METHOD     MA_3_Type = MODE_SMA;            //- MA-3 type (fastest)
extern ENUM_APPLIED_PRICE MA_3_Price = PRICE_CLOSE;        //- MA-3 price to use
extern int                MA_3_Periods = 200;              //- MA-3 #periods
extern ENUM_TIMEFRAMES    MA_3_TimeFrame = PERIOD_D1;      //- MA-3 timeframe
extern ENUM_MA_METHOD     MA_4_Type = MODE_SMA;            //- MA-4 type (fastest)
extern ENUM_APPLIED_PRICE MA_4_Price = PRICE_CLOSE;        //- MA-4 price to use
extern int                MA_4_Periods = 200;              //- MA-4 #periods
extern ENUM_TIMEFRAMES    MA_4_TimeFrame = PERIOD_D1;      //- MA-4 timeframe
extern ENUM_MA_METHOD     MA_5_Type = MODE_SMA;            //- MA-5 type (fastest)
extern ENUM_APPLIED_PRICE MA_5_Price = PRICE_CLOSE;        //- MA-5 price to use
extern int                MA_5_Periods = 200;              //- MA-5 #periods
extern ENUM_TIMEFRAMES    MA_5_TimeFrame = PERIOD_D1;      //- MA-5 timeframe
extern ENUM_MA_METHOD     MA_6_Type = MODE_SMA;            //- MA-6 type (fastest)
extern ENUM_APPLIED_PRICE MA_6_Price = PRICE_CLOSE;        //- MA-6 price to use
extern int                MA_6_Periods = 200;              //- MA-6 #periods
extern ENUM_TIMEFRAMES    MA_6_TimeFrame = PERIOD_D1;      //- MA-6 timeframe
extern ENUM_MA_METHOD     MA_7_Type = MODE_SMA;            //- MA-7 type (fastest)
extern ENUM_APPLIED_PRICE MA_7_Price = PRICE_CLOSE;        //- MA-7 price to use
extern int                MA_7_Periods = 200;              //- MA-7 #periods
extern ENUM_TIMEFRAMES    MA_7_TimeFrame = PERIOD_D1;      //- MA-7 timeframe
extern int                MA_BarsSetupActive = 5;          //- Bars active

#include <dev\common.mqh>
#include <dev\Setup.mqh>
  
class MovingAverage : public Setup {

  int crossFastUp;
  int crossFastDn;
  void reset();

  void criteriaData();
  bool longCriteria();
  bool shortCriteria();
  
  double ma_curr[8], ma_prev[8];
  double ma_v_px[8], ma_slope[8];
  double ma_curr_sod;
  double ma_prev_sod;
  double ma_slope_sod;

public:
  MovingAverage(Enum_SIDE);
  ~MovingAverage();
  
  //bool triggered();
  void startOfDay();
  void OnBar();
  void OnTick();
};

MovingAverage::MovingAverage(Enum_SIDE _side):Setup(Symbol(),_side) {
  strategyName = "MovingAverage";
  side = _side;
  callOnTick = false;
  callOnBar = true;
  reset();
}


MovingAverage::~MovingAverage() {
}

void MovingAverage::reset() {
  Setup::reset();
  crossFastUp = -100;
  crossFastDn = -100;
}

void MovingAverage::startOfDay() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  reset();
  ma_curr_sod = iMA(NULL,PERIOD_D1,200,0,MA_1_Type,MA_1_Price,1);
  Debug(__FUNCTION__,__LINE__,"ma_curr_sod="+DoubleToStr(ma_curr_sod,Digits));
//  ma_curr_sod = iMA(NULL,PERIOD_D1,200,0,MA_1_Type,MA_1_Price,2);
//  Debug(__FUNCTION__,__LINE__,"ma_curr_sod="+DoubleToStr(ma_curr_sod,Digits));
  ma_prev_sod = iMA(NULL,PERIOD_D1,200,0,MA_1_Type,MA_1_Price,5);
  Debug(__FUNCTION__,__LINE__,"ma_prev_sod="+DoubleToStr(ma_prev_sod,Digits));
  ma_slope_sod = (ma_curr_sod-ma_prev_sod)*PipFact / (5-1);
  Debug(__FUNCTION__,__LINE__,"ma_slope_sod="+DoubleToStr(ma_slope_sod,Digits));
}

void MovingAverage::OnBar() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  criteriaData();
  if(GoLong)
    triggered = longCriteria();
  else if(GoShort)
    triggered = shortCriteria();
  
}

void MovingAverage::OnTick() {
  Debug(__FUNCTION__,__LINE__,"Entered");
}

bool MovingAverage::longCriteria() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  if(Volume[0]>1) return false;
  double price = iClose(NULL,0,1);
  switch(MA_Model) {
    case MA_200_DMA:
      Debug(__FUNCTION__,__LINE__,"price="+DoubleToStr(price,Digits)+"  ma="+DoubleToStr(ma_curr[0],Digits)+"  slope="+DoubleToStr(ma_slope[0],Digits)+"  / "+MA_Slope_Long);
      if(price>ma_curr[0] && ma_slope[0] >= MA_Slope_Long)
        return true;
      break;
    case MA_CurrentTF:
      if(price>ma_curr[0] && ma_slope[0] >= MA_Slope_Long)
        return true;
      break;
    case MA_OtherTF:
      break;
    case MA_MultiMA:
      break;
  }
  return false;
}

bool MovingAverage::shortCriteria() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  if(Volume[0]>1) return false;
  double price = iClose(NULL,0,1);
  switch(MA_Model) {
    case MA_200_DMA:
      if(price<ma_curr[0] && ma_slope[0] <= MA_Slope_Short)
        return true;
      break;
    case MA_CurrentTF:
      if(price<ma_curr[0] && ma_slope[0] <= MA_Slope_Short)
        return true;
      break;
    case MA_OtherTF:
      break;
    case MA_MultiMA:
      break;
  }
  return false;
}

void MovingAverage::criteriaData() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  //double price = iClose(NULL,0,1);
  int i=0;
  switch (MA_Model) {
    case MA_200_DMA:
      ma_curr[i] = ma_curr_sod;
      ma_prev[i] = ma_prev_sod;
      ma_slope[i] = ma_slope_sod;
      Debug(__FUNCTION__,__LINE__,"MA="+DoubleToStr(ma_curr[0],Digits)+"  slope="+DoubleToStr(ma_slope[0],Digits));
      Debug(__FUNCTION__,__LINE__,"MA="+DoubleToStr(ma_curr[i],Digits)+"  slope="+DoubleToStr(ma_slope[i],Digits));
      Debug(__FUNCTION__,__LINE__,"SD="+DoubleToStr(ma_curr_sod,Digits)+"  slope="+DoubleToStr(ma_slope_sod,Digits));
      break;
    case MA_CurrentTF:
      ma_curr[i] = iMA(NULL,0,MA_1_Periods,0,MA_1_Type,MA_1_Price,1);
      ma_prev[i] = iMA(NULL,0,MA_1_Periods,0,MA_1_Type,MA_1_Price,5);
      ma_slope[i] = (ma_curr[i]-ma_prev[i])*PipFact / (5-2);
      break;
    case MA_OtherTF:
      ma_curr[i] = iMA(NULL,MA_1_TimeFrame,MA_1_Periods,0,MA_1_Type,MA_1_Price,1);
      ma_prev[i] = iMA(NULL,MA_1_TimeFrame,MA_1_Periods,0,MA_1_Type,MA_1_Price,5);
      ma_slope[i] = (ma_curr[i]-ma_prev[i])*PipFact / (5-2);
      break;
    case MA_MultiMA:
      ma_curr[i] = iMA(NULL,MA_1_TimeFrame,MA_1_Periods,0,MA_1_Type,MA_1_Price,1);
      ma_prev[i] = iMA(NULL,MA_1_TimeFrame,MA_1_Periods,0,MA_1_Type,MA_1_Price,5);
      i += 1;
      ma_curr[i++] = iMA(NULL,MA_2_TimeFrame,MA_2_Periods,0,MA_2_Type,MA_2_Price,1);
      if(MA_BarsSetupActive>2)
        ma_curr[i++] = iMA(NULL,MA_3_TimeFrame,MA_3_Periods,0,MA_3_Type,MA_3_Price,1);
      if(MA_BarsSetupActive>3)
        ma_curr[i++] = iMA(NULL,MA_4_TimeFrame,MA_4_Periods,0,MA_4_Type,MA_4_Price,1);
      if(MA_BarsSetupActive>4)
        ma_curr[i++] = iMA(NULL,MA_5_TimeFrame,MA_5_Periods,0,MA_5_Type,MA_5_Price,1);
      if(MA_BarsSetupActive>5)
        ma_curr[i++] = iMA(NULL,MA_6_TimeFrame,MA_6_Periods,0,MA_6_Type,MA_6_Price,1);
      if(MA_BarsSetupActive>6)
        ma_curr[i++] = iMA(NULL,MA_7_TimeFrame,MA_7_Periods,0,MA_7_Type,MA_7_Price,1);
      break;
  };
}

