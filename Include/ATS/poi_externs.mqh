enum Enum_POI {POI_Close,POI_HighLow,POI_High,POI_Low,POI_Open,
               POI_Median,POI_Typical,POI_Weighted,POI_MovAvg,POI_HHLL};

extern string PoiExterns_comment01="";       // -----------------------------
//extern string PoiExterns_comment02="";       // | Point Of Initiation (POI) |
//extern string PoiExterns_comment03="";       // -----------------------------

extern Enum_POI POI_Model = POI_Close;      // POI model
//extern bool barPOI        = true;
//extern ENUM_APPLIED_PRICE POI_price = PRICE_CLOSE;
extern ENUM_MA_METHOD     POI_ma_method = MODE_SMA;   //>> MA method
extern int                POI_ma_period = 20;         //>> MA period
extern ENUM_APPLIED_PRICE POI_ma_price = PRICE_CLOSE; //>> MA price type
