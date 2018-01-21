#property strict

enum Enum_BOLLINGER_MODELS {
  BB_SETUP_01,   // cross up thru upper, dn thru lower
  BB_SETUP_02,   // cross dn thru upper, up thru lower
  BB_SETUP_03,   // cross thru mail line
};
enum Enum_YESNO {
  YN_NO=0,    //No
  YN_YES      //Yes
};
enum Enum_PRICE_MODELS {
  PM_BidAsk=0,  //Enter long at Ask, short at Bid (pip buffer)
  PM_PrevHL,    //Previous high/low price
};
enum Enum_ENTRY_MODELS {
  EM_GO4IT,
  EM_HLest,     // Highest or lowest
  EM_Pullback,  //Enter on Pullback to prev H/L (bar offset)
  EM_Engulfing, // Engulfing candle
  EM_RBO        //RBO of current session (w/ pip offset)
};
enum Enum_MARKET_MODELS{
  MM_200DMA=0,  //200 DMA Market Indicator
  MM_MidPoint   //Range MidPoint Market Indicator
};

enum Enum_SIDE{ Long=1, Short=-1, NA=0 };
enum Enum_OP_ORDER_TYPES { 
  Z_BUY=0,      //Buy operation
  Z_SELL,       //Sell operation
  Z_BUYLIMIT,   //Buy limit pending order
  Z_SELLLIMIT,  //Sell limit pending order
  Z_BUYSTOP,    //Buy stop pending order
  Z_SELLSTOP    //Sell stop pending order
};
enum Enum_EXITMODEL {
  EX_Fitch,     // Fitch strategy
  EX_SL_TP      // use stop loss and limit orders
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


