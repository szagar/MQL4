enum Enum_Sessions{
  tbd=0,
   All,
   Asia,
   AsiaLast1,
   London,
   NewYork,
   NYSE,
   NYlast1,
   LondonClose,
   EnumLast
 };
enum Enum_SessionSegments {
  all=0,
  first=1,
  second=2,
  third=3
};
enum Enum_Seasons{ Winter, Summer };

extern string commentString_TS_01 = ""; //---------------------------------------------

extern Enum_Sessions Session = NewYork;           //TradingSession
extern Enum_SessionSegments SessionSegment = all; //>> segment (1-3)
