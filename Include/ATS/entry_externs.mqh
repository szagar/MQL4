extern string EnExterns_comment01=""; // -------------------------
extern string EnExterns_comment51=""; // Entry Parameters

extern bool tickEntry = false;        //>> check new entry on tick
extern bool barEntry = true;          //>> check new entry on bar
extern bool UseDefaultParams=false;   //>> Use pre-configured parameters
//extern int  MaxBarsPending = 5;     //>> # bars until stop entry canceled



enum Enum_POI {POI_Close,POI_HighLow,POI_High,POI_Low,POI_Open,
               POI_Median,POI_Typical,POI_Weighted,POI_MovAvg,POI_HHLL};

//extern string PoiExterns_comment01="";       // -----------------------------
//extern string PoiExterns_comment02="";       // | Point Of Initiation (POI) |
//extern string PoiExterns_comment03="";       // -----------------------------

extern Enum_POI           POI_Model=POI_Close;      //>> POI model
extern ENUM_MA_METHOD     POI_ma_method=MODE_SMA;   //>>>> MA method
extern int                POI_ma_period=20;         //>>>> MA period
extern ENUM_APPLIED_PRICE POI_ma_price=PRICE_CLOSE; //>>>> MA price type

//extern bool barPOI        = true;
//extern ENUM_APPLIED_PRICE POI_price = PRICE_CLOSE;




enum Enum_DIST {DIST_DayAtr,DIST_Atr,DIST_Pips};

//extern string DistExterns_comment01="";       // -----------------------------
//extern string DistExterns_comment02="";       // | BreakOut Distance         |
//extern string DistExterns_comment03="";       // -----------------------------

extern Enum_DIST       Dist_Model=DIST_DayAtr; //>> Distance Model
extern ENUM_TIMEFRAMES DIST_atr_timeframe =0;  //>>>> ATR timeframe
extern int             DIST_atr_period=14;     //>>>> ATR period
extern double          DIST_atr_factor=0.10;   //>>>> ATR factor 1-15%

