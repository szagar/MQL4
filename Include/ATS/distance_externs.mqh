enum Enum_DIST {DIST_DayAtr,DIST_Atr,DIST_Pips};

extern string DistExterns_comment01="";       // -----------------------------
//extern string DistExterns_comment02="";       // | BreakOut Distance         |
//extern string DistExterns_comment03="";       // -----------------------------

extern Enum_DIST Dist_Model   = DIST_DayAtr;   // Distance Model
extern ENUM_TIMEFRAMES DIST_atr_timeframe = 0; //>> ATR timeframe
extern int             DIST_atr_period = 14;   //>> ATR period
extern double          DIST_atr_factor = 0.10; //>> ATR factor 1-15%
