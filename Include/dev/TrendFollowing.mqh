//+------------------------------------------------------------------+
//|                                               TrendFollowing.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

extern string commentString_TF0 = ""; //---------------------------------------------
extern string commentString_TF1 = "";  //*** Moving Average settings:
//
// TF_200_DMA:  
//
// TF_MA_CurrentTF:  
//
// TF_MA_OtherTF:  
//
// TF_MA_MultiMA:  
//
// TF_HLHB: HLHB Trend-Catcher System, BabyPips.com
//      * catch short term forex trends
//      * patterned after the Amazing Crossover System (Robopip)
//   - Settings:
//      *  EUR/USD 1H
//      *  GBP/USD 1H
//      *  5 EMA (blue)
//      * 10 EMA (red)
//      *  RSI(10) applied to median price (HL/2)
//   - Entry:
//      * Buy:  1) 5 EMA corsses above the 10 EMA from under &
//              2) RSI crosses above the 50 level from the bottom
//      * Sell: 1) 5 EMA crosses below the 10 EMA &
//              2) RSI crosses below the 50 level from the top
//   - Exit:
//      * 50 pip trailing stop
//      * 200 pip profit target
//      * close trade when new signal
//      * close trades by end of week
//   - Enhancements:
//      * Entry, add: ADX > 25 (weed out fakeouts)
//      * Stops, 150 pip trailing stop
//      * Profit Target, 400 pips

extern Enum_TF_MODELS TF_Model = TF_200_DMA;              //>> Model
extern int                TF_NumberOfMAs = 1;              //- Number of moving averages
extern int                TF_Slope_Long = 5;               //- MA Slope criteria for longs
extern int                TF_Slope_Short = -5;             //- MA Slope criteria for shorts
extern ENUM_MA_METHOD     TF_1_Type = MODE_SMA;            //- MA-1 type (fastest)
extern ENUM_APPLIED_PRICE TF_1_Price = PRICE_CLOSE;        //- MA-1 price to use
extern int                TF_1_Periods = 200;              //- MA-1 #periods
extern ENUM_TIMEFRAMES    TF_1_TimeFrame = PERIOD_D1;      //- MA-1 timeframe
extern ENUM_MA_METHOD     TF_2_Type = MODE_EMA;            //- MA-2 type (slow)
extern ENUM_APPLIED_PRICE TF_2_Price = PRICE_CLOSE;        //- MA-2 price to use
extern int                TF_2_Periods = 21;               //- MA-2 #periods
extern ENUM_TIMEFRAMES    TF_2_TimeFrame = PERIOD_CURRENT; //- MA-2 timeframe
extern ENUM_MA_METHOD     TF_3_Type = MODE_SMA;            //- MA-3 type (fastest)
extern ENUM_APPLIED_PRICE TF_3_Price = PRICE_CLOSE;        //- MA-3 price to use
extern int                TF_3_Periods = 200;              //- MA-3 #periods
extern ENUM_TIMEFRAMES    TF_3_TimeFrame = PERIOD_D1;      //- MA-3 timeframe
extern ENUM_MA_METHOD     TF_4_Type = MODE_SMA;            //- MA-4 type (fastest)
extern ENUM_APPLIED_PRICE TF_4_Price = PRICE_CLOSE;        //- MA-4 price to use
extern int                TF_4_Periods = 200;              //- MA-4 #periods
extern ENUM_TIMEFRAMES    TF_4_TimeFrame = PERIOD_D1;      //- MA-4 timeframe
extern ENUM_MA_METHOD     TF_5_Type = MODE_SMA;            //- MA-5 type (fastest)
extern ENUM_APPLIED_PRICE TF_5_Price = PRICE_CLOSE;        //- MA-5 price to use
extern int                TF_5_Periods = 200;              //- MA-5 #periods
extern ENUM_TIMEFRAMES    TF_5_TimeFrame = PERIOD_D1;      //- MA-5 timeframe
extern ENUM_MA_METHOD     TF_6_Type = MODE_SMA;            //- MA-6 type (fastest)
extern ENUM_APPLIED_PRICE TF_6_Price = PRICE_CLOSE;        //- MA-6 price to use
extern int                TF_6_Periods = 200;              //- MA-6 #periods
extern ENUM_TIMEFRAMES    TF_6_TimeFrame = PERIOD_D1;      //- MA-6 timeframe
extern ENUM_MA_METHOD     TF_7_Type = MODE_SMA;            //- MA-7 type (fastest)
extern ENUM_APPLIED_PRICE TF_7_Price = PRICE_CLOSE;        //- MA-7 price to use
extern int                TF_7_Periods = 200;              //- MA-7 #periods
extern ENUM_TIMEFRAMES    TF_7_TimeFrame = PERIOD_D1;      //- MA-7 timeframe
extern int                TF_BarsSetupActive = 5;          //- Bars active

#include <dev\common.mqh>
#include <dev\SetupBase.mqh>
  
class TrendFollowing : public SetupBase {

  int crossFastUp;
  int crossFastDn;
  void reset();
  void defaultParameters();

  void criteriaData();
  bool longCriteria();
  bool shortCriteria();
  
  double ma_curr[8], ma_prev[8];
  double ma_v_px[8], ma_slope[8];
  double ma_curr_sod;
  double ma_prev_sod;
  double ma_slope_sod;
  
  double ma_01_curr, ma_02_curr;

public:
  TrendFollowing(Enum_SIDE);
  ~TrendFollowing();
  
  //bool triggered();
  void startOfDay();
  void OnBar();
  void OnTick();
};

TrendFollowing::TrendFollowing(Enum_SIDE _side):SetupBase(Symbol(),_side) {
  strategyName = "TrendFollowing";
  side = _side;
  callOnTick = false;
  callOnBar = true;
  reset();
}


TrendFollowing::~TrendFollowing() {
}

void TrendFollowing::reset() {
  SetupBase::reset();
  crossFastUp = -100;
  crossFastDn = -100;
}

void TrendFollowing::startOfDay() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  reset();
  switch (TF_Model) {
    case TF_HLHB:
      break;
    case TF_200_DMA:
      ma_curr_sod = iMA(NULL,PERIOD_D1,200,0,TF_1_Type,TF_1_Price,1);
      Debug(__FUNCTION__,__LINE__,"ma_curr_sod="+DoubleToStr(ma_curr_sod,Digits));
      ma_prev_sod = iMA(NULL,PERIOD_D1,200,0,TF_1_Type,TF_1_Price,5);
      Debug(__FUNCTION__,__LINE__,"ma_prev_sod="+DoubleToStr(ma_prev_sod,Digits));
      ma_slope_sod = (ma_curr_sod-ma_prev_sod)*PipFact / (5-1);
      Debug(__FUNCTION__,__LINE__,"ma_slope_sod="+DoubleToStr(ma_slope_sod,Digits));
      break;
  }
}

void TrendFollowing::defaultParameters() {
  switch (TF_Model) {
    case TF_HLHB:
      TF_1_Type = MODE_EMA;            //- MA-1 type (fastest)
      TF_1_Price = PRICE_CLOSE;        //- MA-1 price to use
      TF_1_Periods = 5;                //- MA-1 #periods
      TF_1_TimeFrame = PERIOD_H1;      //- MA-1 timeframe
      TF_2_Type = MODE_EMA;            //- MA-2 type (slow)
      TF_2_Price = PRICE_CLOSE;        //- MA-2 price to use
      TF_2_Periods = 10;               //- MA-2 #periods
      TF_2_TimeFrame = PERIOD_H1;      //- MA-2 timeframe
      break;
  }
}

void TrendFollowing::OnBar() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  criteriaData();
  if(GoLong)
    triggered = longCriteria();
  else if(GoShort)
    triggered = shortCriteria();
  
}

void TrendFollowing::OnTick() {
  Debug(__FUNCTION__,__LINE__,"Entered");
}

bool TrendFollowing::longCriteria() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  if(Volume[0]>1) return false;
  double price = iClose(NULL,0,1);
  switch(TF_Model) {
    case TF_200_DMA:
      Debug(__FUNCTION__,__LINE__,"price="+DoubleToStr(price,Digits)+"  ma="+DoubleToStr(ma_curr[0],Digits)+"  slope="+DoubleToStr(ma_slope[0],Digits)+"  / "+TF_Slope_Long);
      if(price>ma_curr[0] && ma_slope[0] >= TF_Slope_Long)
        return true;
      break;
    //case TF_CurrentTF:
    //  if(price>ma_curr[0] && ma_slope[0] >= TF_Slope_Long)
    //    return true;
    //  break;
    //case TF_OtherTF:
    //  break;
    //case TF_MultiMA:
    //  break;
  }
  return false;
}

bool TrendFollowing::shortCriteria() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  if(Volume[0]>1) return false;
  double price = iClose(NULL,0,1);
  switch(TF_Model) {
    case TF_200_DMA:
      if(price<ma_curr[0] && ma_slope[0] <= TF_Slope_Short)
        return true;
      break;
    //case TF_CurrentTF:
    //  if(price<ma_curr[0] && ma_slope[0] <= TF_Slope_Short)
    //    return true;
    //  break;
    //case TF_OtherTF:
    //  break;
    //case TF_MultiMA:
    //  break;
  }
  return false;
}

void TrendFollowing::criteriaData() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  //double price = iClose(NULL,0,1);
  int i=0;
  switch (TF_Model) {
    case TF_HLHB:
      ma_01_curr = iMA(NULL,TF_1_TimeFrame,TF_1_Periods,0,TF_1_Type,TF_1_Price,1);
      ma_02_curr = iMA(NULL,TF_2_TimeFrame,TF_2_Periods,0,TF_2_Type,TF_2_Price,1);
      
      break;
    case TF_200_DMA:
      ma_curr[i] = ma_curr_sod;
      ma_prev[i] = ma_prev_sod;
      ma_slope[i] = ma_slope_sod;
      Debug(__FUNCTION__,__LINE__,"MA="+DoubleToStr(ma_curr[0],Digits)+"  slope="+DoubleToStr(ma_slope[0],Digits));
      Debug(__FUNCTION__,__LINE__,"MA="+DoubleToStr(ma_curr[i],Digits)+"  slope="+DoubleToStr(ma_slope[i],Digits));
      Debug(__FUNCTION__,__LINE__,"SD="+DoubleToStr(ma_curr_sod,Digits)+"  slope="+DoubleToStr(ma_slope_sod,Digits));
      break;
    case TF_MA_CurrentTF:
      ma_curr[i] = iMA(NULL,0,TF_1_Periods,0,TF_1_Type,TF_1_Price,1);
      ma_prev[i] = iMA(NULL,0,TF_1_Periods,0,TF_1_Type,TF_1_Price,5);
      ma_slope[i] = (ma_curr[i]-ma_prev[i])*PipFact / (5-2);
      break;
    case TF_MA_OtherTF:
      ma_curr[i] = iMA(NULL,TF_1_TimeFrame,TF_1_Periods,0,TF_1_Type,TF_1_Price,1);
      ma_prev[i] = iMA(NULL,TF_1_TimeFrame,TF_1_Periods,0,TF_1_Type,TF_1_Price,5);
      ma_slope[i] = (ma_curr[i]-ma_prev[i])*PipFact / (5-2);
      break;
    case TF_MA_MultiMA:
      ma_curr[i] = iMA(NULL,TF_1_TimeFrame,TF_1_Periods,0,TF_1_Type,TF_1_Price,1);
      ma_prev[i] = iMA(NULL,TF_1_TimeFrame,TF_1_Periods,0,TF_1_Type,TF_1_Price,5);
      i += 1;
      ma_curr[i++] = iMA(NULL,TF_2_TimeFrame,TF_2_Periods,0,TF_2_Type,TF_2_Price,1);
      if(TF_BarsSetupActive>2)
        ma_curr[i++] = iMA(NULL,TF_3_TimeFrame,TF_3_Periods,0,TF_3_Type,TF_3_Price,1);
      if(TF_BarsSetupActive>3)
        ma_curr[i++] = iMA(NULL,TF_4_TimeFrame,TF_4_Periods,0,TF_4_Type,TF_4_Price,1);
      if(TF_BarsSetupActive>4)
        ma_curr[i++] = iMA(NULL,TF_5_TimeFrame,TF_5_Periods,0,TF_5_Type,TF_5_Price,1);
      if(TF_BarsSetupActive>5)
        ma_curr[i++] = iMA(NULL,TF_6_TimeFrame,TF_6_Periods,0,TF_6_Type,TF_6_Price,1);
      if(TF_BarsSetupActive>6)
        ma_curr[i++] = iMA(NULL,TF_7_TimeFrame,TF_7_Periods,0,TF_7_Type,TF_7_Price,1);
      break;
  };
}

