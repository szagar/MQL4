#include <ATS\enum_types.mqh>

extern string PmExterns_comment01="";       // -------------------------
extern string PmExterns_comment02="";       // Run Parameters     
//extern string PmExterns_comment03="";       // -------------------------
extern bool Testing = false;
extern Enum_LogLevels LogLevel = LogDebug;    //>> Log Level
extern int Slippage = 5;             //>> Slippage in pips
extern int Spread   = 3;             //>> Spread in pips
extern bool SimulateStopEntry=false; //>> Simulate stop entries
extern bool SimulateStopExit=false;  //>> Simulate stop exits

extern string PmExterns_comment11="";       // -------------------------
extern string PmExterns_comment12="";       // Risk Management Rules
//extern string PmExterns_comment13="";       // -------------------------
extern double PercentRiskPerPosition = 0.5; //>> Percent to risk per position
extern double MinReward2RiskRatio    = 1.5; //>> Min Reward / Risk
extern int    MaxTradesPerDay        = 1;   //>> Max number of trades per day


extern string PmExterns_comment21="";  // -------------------------
extern string PmExterns_comment22="";  // Entry Filters     
extern bool GoLong  = true;            //>> Go Long
extern bool GoShort = false;           //>> Go Short
extern bool UseEntryFilter = false;    //>> Used entry filter
extern bool UseDOWentryFilter = false; //>> Used DOW for entries
extern bool UseBarsInPending  = false; //>> Candel pending orders after n bars
extern int  MaxBarsPending = 5;        //>>>> # bars until stop entry canceled

extern bool UseTradingSession = true;       //>> Enter only during trading session
extern bool UseSessionSegment = false;      //>> Enter only during segment(1-3) of session

extern string PmExterns_comment31="";       // -------------------------
extern string PmExterns_comment32="";       // Exit Rules       
//extern string PmExterns_comment33="";       // -------------------------
extern bool UseEODexit      = true;         //>> Exit at EOD ?
extern bool UseEOSexit      = false;        //>> Exit at End Of Session ?
extern bool UseStopLoss     = false;        //>> Initial Stop Loss ?
extern bool UseTrailingStop = false;        //>> Trailing Stop Loss ?
extern bool UseTakeProfit   = false;        //>> Take Profit level ? 
extern bool UseTimeInExit   = false;        //>> Time in trade exit ?
extern bool UseBarsInExit   = false;        //>> Bar count exit ?
extern bool UseTODexit      = false;        //>> Time of day exit ?
extern bool ExitOnFriday = true;            //>> Exit Open trades, cancel pendings on Friday ?
