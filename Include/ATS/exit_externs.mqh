extern string ExExterns_comment01="";       // -------------------------
//extern string ExExterns_comment02="";       // | Exit Parameters       |
//extern string ExExterns_comment03="";       // -------------------------

//extern Enum_EXIT_MODELS EX_Model = EX_EOS;       //Exit Model
extern Enum_TS_TYPES    TS_Model = TS_ATR;       //Trailing Stop Model
//extern bool             EX_BarCount = YN_NO;     //>> add Bar Count Exit ?
extern double           TS_MinDeltaPips  = 2.0;  //>> TS: Min pips for SL change
extern int              TS_BarCount  = 3;        //>> TS: Bar Count or Bars back
extern int              TS_PadAmount = 10;       //>> TS: Pips to pad TS
extern Enum_TS_WHEN     TS_When      = TS_OneRx; //>> TS: When to start trailing
extern int              TS_WhenX     = 1;        //>> TS: When parameter (1Rx, pips)
extern ENUM_TIMEFRAMES  TS_ATRperiod= 0;         //>> TS: ATR Period
extern double           TS_ATRfactor = 2.7;      //>> TS: ATR Factor

extern string ExitTimeOnFriday="17:00";   //>> Time for Friday forced exits
