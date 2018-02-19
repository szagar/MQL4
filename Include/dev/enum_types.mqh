#property strict

enum Enum_EXIT_MODELS {
  EX_EOD,       // End of day
  EX_EOS,       // End of session
  EX_Fitch,     // Fitch strategy
  EX_SL_TP,     // use stop loss and limit orders
  EX_SL_TS,     // use stop loss and trailing stop
};
enum Enum_ENTRY_MODELS {
  EM_GO4IT,
  EM_HLest,     // Highest or lowest
  EM_Pullback,  //Enter on Pullback to prev H/L (bar offset)
  EM_Engulfing, // Engulfing candle
  EM_RBO        //RBO of current session (w/ pip offset)
};
enum Enum_POS_SIZE_MODELS {
  PS_VanTharp,  // Van Tharp basic
  PS_OneMini    // 0.10 lots
};
enum Enum_PRICE_MODELS {
  PM_BidAsk=0,  //Enter long at Ask, short at Bid (pip buffer)
  PM_PrevHL,    //Previous high/low price
};
enum Enum_RSI_MODELS {
  RSI_SETUP_01,  // Long: up thru Upper, Short: dn thru lower
  RSI_SETUP_02,  // Long: dn thru Upper, Short: up thru lower
};
enum Enum_EM_ENGULFINGS {
  EM_EG_Body,  //Engulfing Body
  EM_EG_Wicks  //Engulfing Bar
};
//########## Trend Following Models
enum Enum_TF_MODELS {
  TF_200_DMA,       // 200 day SMA
  TF_MA_CurrentTF,     // current TF, custom  period
  TF_MA_OtherTF,       // custom TF, cutom period MA 
  TF_MA_MultiMA,       // Multiple MAs
  TF_HLHB,             // HLHB Trend-Catcher
};
//########## Moving Average Cross Models
enum Enum_MA_MODELS {
  MA_200_DMA,       // 200 day SMA
  MA_CurrentTF,     // current TF, custom  period
  MA_OtherTF,       // custom TF, cutom period MA 
  MA_MultiMA,       // Multiple MAs
};
//########## Moving Average Cross Models
enum Enum_MX_MODELS {
  MX_SETUP_01,
  MX_SETUP_02 
};
//########## Channel Models
enum Enum_CS_MODELS {
  CS_MovingAvg,
};
//########## Bollinger Band Models
enum Enum_BOLLINGER_MODELS {
  BB_SETUP_01,   // cross up thru upper, dn thru lower
  BB_SETUP_02,   // cross dn thru upper, up thru lower
  BB_SETUP_03,   // cross thru mail line
};
enum Enum_MARKET_MODELS{
  MM_200DMA=0,  //200 DMA Market Indicator
  MM_MidPoint   //Range MidPoint Market Indicator
};
enum Enum_YESNO {
  YN_NO=0,    //No
  YN_YES      //Yes
};
enum Enum_SIDE{
  Long=1,    //Long
  Short=-1,  //Short
  NA=0       //No position
};

enum Enum_OP_ORDER_TYPES { 
  Z_BUY=0,      //Buy operation
  Z_SELL,       //Sell operation
  Z_BUYLIMIT,   //Buy limit pending order
  Z_SELLLIMIT,  //Sell limit pending order
  Z_BUYSTOP,    //Buy stop pending order
  Z_SELLSTOP    //Sell stop pending order
};
enum Enum_TS_WHEN { 
  TS_OneRx,       // One R factor,
  TS_PIPs         // PIPs
};
enum Enum_TS_TYPES { 
  TS_None=0,      // Not Applicable
  TS_CandleTrail, // Candle Trail
  TS_SwingHL,     // Swing High or Low
  TS_ATR,         // ATR factor
  TS_OneR,        // OneR X
};
enum Enum_PROFIT_TARGET_TYPES { 
  PT_None=0,      // Not Applicable
  PT_CandleTrail, // Candle Trail
  PT_ATR,         // ATR factor
  PT_OneR,        // One R factor
  PT_PATI_Level,  // next PATI level
};

//  Breakout System
enum Enum_BREAKOUT_PIO {
  BO_PreviousOpen,   // Previous Open, BO_BarsBack
  BO_PreviousHigh,   // Previous High, BO_BarsBack
  BO_PreviousLow,    // Previous Low, BO_BarsBack
  BO_HighestHigh,    // Highest High, BO_BarsBack
  BO_LowestLow,      // Lowest Low, BO_BarsBack
  BO_PreviousClose,  // Previous Close, BO_BarsBack
  BO_MovingAvg,      // MovAvg, BO_MAperiod, BO_MAtype, BO_MAshift
  BO_Retracement,    // Retracement, BO_PercentAway
};
enum Enum_BREAKOUT_DIST {
  BO_Atr,            // ATR(BO_AtrPeriod) * BO_AtrFactor
  BO_Pips,           // BO_Pips pips
};
enum Enum_BREAKOUT_TIME {
  BO_SessionSegment, // Use BO_SegmentNum segment number(1-3)
  BO_SOD,            // SOD + BO_TimeOffset
  BO_EOD,            // SOD + BO_TimeOffset
  BO_SOS,            // Start Of Session + BO_TimeOffset
  BO_EOS,            // End Of Session + BO_TimeOffset
};
enum Enum_BREAKOUT_FILTER {
  BO_DM_pm,          // DM+ / DM- cross, BO_DMplus,BO_DMneg, BO_FiletInverse to inverse
  BO_ADX,            // ADX, BO_ADXperiod, BO_ADXlevelLo, BO_ADXlevelHi
};
