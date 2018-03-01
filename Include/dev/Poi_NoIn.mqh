//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

//extern bool Testing = false;
string commentString_POIO0 = ""; //---------------------------------------------
string commentString_POIO1 = ""; //--------- BreakOut POI
string commentString_POIO2 = ""; //---------------------------------------------
//extern bool UseDefaultParameters = true; // Use pre-configured parameters for pattern
enum Enum_POI {POI_Close,POI_HighLow,POI_High,POI_Low,POI_Open,POI_Median,POI_Typical,POI_Weighted,
                 POI_MovAvg,POI_HHLL};

Enum_POI POI_Model   = POI_Close;

string commentString_POIO3 = ""; //---------------------------------------------
ENUM_APPLIED_PRICE POI_price = PRICE_CLOSE;
ENUM_MA_METHOD     POI_ma_method = MODE_SMA;
int                POI_ma_period = 20;
ENUM_APPLIED_PRICE POI_ma_price = PRICE_CLOSE;
string commentString_BO5 = ""; //---------------------------------------------

#include <dev\logger.mqh>
//#include <dev\common.mqh>
//#include <dev\zts_lib.mqh>

class Poi {
public:
  Poi();
  ~Poi();
  
  double POI_Long,POI_Short;

  void setPOI(int barShift);
};

Poi::Poi() {
  Debug(__FUNCTION__,__LINE__,"Entered");
}

Poi::~Poi() {
}

void Poi::setPOI(int barShift=0) {
  Info2(__FUNCTION__,__LINE__,"Entered, Model="+EnumToString(POI_Model));
  switch (POI_Model) {
    case POI_Close:
      POI_Long = iClose(NULL,0,barShift);
      POI_Short = POI_Long;
      break;
    case POI_High:
      POI_Long = iHigh(NULL,0,barShift);
      POI_Short = POI_Long;
      break;
    case POI_HighLow:
      //Print("POI_Long = iHigh(NULL,0,"+barShift+");    ="+iHigh(NULL,0,barShift));
      POI_Long = iHigh(NULL,0,barShift);
      POI_Short = iLow(NULL,0,barShift);
      break;
    case POI_Low:
      POI_Long = iLow(NULL,0,barShift);
      POI_Short = POI_Long;
      break;
    case POI_Open:
      POI_Long = iOpen(NULL,0,barShift);
      POI_Short = POI_Long;
      break;
    case POI_Median:
      POI_Long = (iHigh(NULL,0,barShift)+iLow(NULL,0,barShift)) / 2.0;
      POI_Short = POI_Long;
      break;
    case POI_Typical:
      POI_Long = (iHigh(NULL,0,barShift)+iLow(NULL,0,barShift) + iClose(NULL,0,barShift)) / 3.0;
      POI_Short = POI_Long;
      break;
    case POI_Weighted:
      POI_Long = (iHigh(NULL,0,barShift)+iLow(NULL,0,barShift) + iClose(NULL,0,barShift) + iClose(NULL,0,barShift)) / 4.0;;
      POI_Short = POI_Long;
      break;
    case POI_MovAvg:
      POI_Long = iMA(NULL,0,POI_ma_period,0,POI_ma_method,POI_ma_price,barShift);
      POI_Short = POI_Long;
      break;
  }
}

