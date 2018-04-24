#include <ATS\enum_types.mqh>

extern string PmExterns_comment01="";       // -------------------------
extern string PmExterns_comment02="";       // Run Parameters     
extern bool Testing = false;
extern Enum_LogLevels LogLevel = LogDebug;  //>> Log Level
extern bool GoLong  = true;                 //>> Go Long
extern bool GoShort = false;                //>> Go Short
extern int Slippage = 5;                    //>> Slippage in pips
extern int Spread   = 3;                    //>> Spread in pips
extern bool SimulateStopEntry=false;        //>> Simulate stop entries
extern bool SimulateStopExit=false;         //>> Simulate stop exits

extern string PmExterns_comment11="";       // -------------------------
extern string PmExterns_comment12="";       // Risk Management Rules
extern double PercentRiskPerPosition = 0.5; //>> Percent to risk per position
extern double MinReward2RiskRatio    = 1.5; //>> Min Reward / Risk
extern int    MaxTradesPerDay        = 1;   //>> Max number of trades per day


extern string PmExterns_comment21="";       // -------------------------
extern string PmExterns_comment22="";       // Entry Filters     
extern bool UseEntryFilter = false;         //>> Use entry filter
extern bool UseDOWentryFilter = false;      //>> Use DOW for entries
extern bool UseBarsInPending  = false;      //>> Cancel pending orders after n bars
extern int  MaxBarsPending = 5;             //>>>> # bars until stop entry canceled
extern bool UseTradingSession = true;       //>> Enter only during trading session
extern bool UseSessionSegment = false;      //>> Enter only during segment(1-3) of session

extern string PmExterns_comment31="";       // -------------------------
extern string PmExterns_comment32="";       // Exit Rules       
extern bool UseEODexit      = true;         //>> Exit at EOD ?
extern bool UseEOSexit      = false;        //>> Exit at End Of Session ?
extern bool UseStopLoss     = false;        //>> Use Initial Stop Loss ?
extern bool UseTrailingStop = false;        //>> Use Trailing Stop Loss ?
extern bool UseTakeProfit   = false;        //>> Use Take Profit level ? 
extern bool UseTimeInExit   = false;        //>> Use 'Time in Trade' exit ?
extern bool UseBarsInExit   = false;        //>> Use Bar count exit ?
extern bool UseTODexit      = false;        //>> Use Time of day exit ?
extern bool ExitOnFriday = true;            //>> Exit Open trades, cancel pendings on Friday ?
