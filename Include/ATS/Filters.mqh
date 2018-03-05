//+------------------------------------------------------------------+
//|                                                      Filters.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <ATS\filter_externs.mqh>

/***
#include <ATS/enum_types.mqh>

extern string commentString_F01 = ""; //---------------------------------------------
extern string commentString_F02 = ""; //-------   Filter Setup

extern int Filter_Model = 1;   // Day Filters: 1-14 
extern bool inverseTheFilter = false;
extern ENUM_APPLIED_PRICE F_AppliedPrice = PRICE_CLOSE;
extern double F_ADXupper = 10;
***/

class Filters {
private:

public:
  Filters();
  ~Filters();
  void setDaily();
  bool dnBar(int barIndex);
  bool upBar(int barIndex);

  bool dayFilterLong,dayFilterShort;
  bool pass(Enum_SIDE);
};

Filters::Filters() {
}

Filters::~Filters() {
}


bool Filters::pass(Enum_SIDE side) {
  if(side==Long) return dayFilterLong;
  if(side==Short) return dayFilterShort;
  return false;
}

void Filters::setDaily() {
  switch(Filter_Model) {
    case 0:
      dayFilterLong = true;
      dayFilterShort = true;
    case 1:
      dayFilterLong = (iADX(NULL,PERIOD_D1,5,F_AppliedPrice,MODE_PLUSDI,0) < iADX(NULL,PERIOD_D1,5,F_AppliedPrice,MODE_MINUSDI,0));
      dayFilterShort = !dayFilterLong;
      break;
    case 2:
      dayFilterLong = (iADX(NULL,PERIOD_D1,5,F_AppliedPrice,MODE_MAIN,0) < F_ADXupper);
      dayFilterShort = dayFilterLong;
      break;
    case 3:
      dayFilterLong = (iADX(NULL,0,14,F_AppliedPrice,MODE_MAIN,0)>iADX(NULL,0,14,F_AppliedPrice,MODE_PLUSDI,0));
      dayFilterShort = dayFilterLong;
      break;
    case 4:
      dayFilterLong = (iMACD(NULL,0,12,26,9,F_AppliedPrice,MODE_MAIN,0)>iMACD(NULL,0,12,26,9,F_AppliedPrice,MODE_SIGNAL,0));
      dayFilterShort = dayFilterLong;
      break;
    case 5:
      dayFilterLong = (iRSI(NULL,0,14,F_AppliedPrice,0)>iRSI(NULL,0,14,F_AppliedPrice,1));
      dayFilterShort = !dayFilterLong;
      break;
    case 6:
      dayFilterLong = (iATR(NULL,0,12,0)>iATR(NULL,0,20,0));
      dayFilterShort = dayFilterLong;
      break;
    case 7:
      dayFilterLong = (iATR(NULL,0,12,0)>iATR(NULL,0,12,1) && iATR(NULL,0,12,1)>iATR(NULL,0,12,2) );
      dayFilterShort = dayFilterLong;
      break;
    case 8:
      dayFilterLong = (iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,0)>iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_SIGNAL,0));
      dayFilterShort = !dayFilterLong;
      break;
    case 9:            
      dayFilterLong = (Close[1]-iClose(NULL,PERIOD_D1,1)>0);
      dayFilterShort = (iClose(NULL,PERIOD_D1,1)-Close[1]>0);
      break;
    case 10:
      dayFilterLong = (Close[1]-iClose(NULL,PERIOD_D1,1)<0);
      dayFilterShort = (iClose(NULL,PERIOD_D1,1)-Close[1]<0);
      break;
    case 11:
      dayFilterLong = (Close[1]>iOpen(NULL,PERIOD_D1,0));
      dayFilterShort = (Close[1]<iOpen(NULL,PERIOD_D1,0));
      break;
    case 12:
      dayFilterLong = dnBar(1);
      dayFilterShort = upBar(1);
      break;
    case 13:
      dayFilterLong = upBar(2) && dnBar(1);
      dayFilterShort = dnBar(2) && upBar(1);
      break;
    case 14:
      dayFilterLong = upBar(3) && upBar(2) && dnBar(1);
      dayFilterShort = dnBar(3) && dnBar(2) && upBar(1);
    
  }
  if(inverseTheFilter) {
    dayFilterLong = !dayFilterLong;
    dayFilterShort = !dayFilterShort;
  }
}

bool Filters::upBar(int barIndex) {
  return (iClose(NULL,PERIOD_D1,barIndex) > iOpen(NULL,PERIOD_D1,barIndex));
}

bool Filters::dnBar(int barIndex) {
  return (iClose(NULL,PERIOD_D1,barIndex) < iOpen(NULL,PERIOD_D1,barIndex));
}
