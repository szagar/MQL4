//+------------------------------------------------------------------+
//|                                                  BreakOutATS.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <ATS\Poi.mqh>
#include <ATS\Distance.mqh>

#include <ATS\common.mqh>
#include <ATS\candle_patterns.mqh>
#include <ATS\ATS.mqh>
#include <ATS\zts_lib.mqh>

class BreakOutATS : public ATS {

  void reset();
  void defaultParameters();

  bool barPOI, tickPOI;
  bool barDist, tickDist;

  Distance *dist;
  Poi *poi;
  
public:
  BreakOutATS(TradingSessions*,Trader*);
  ~BreakOutATS();
  
  void OnInit();
  void startOfDay();
  void endOfDay();
  void OnBar(bool);
  void OnTick();
  void checkForNewEntry(Enum_SIDE,double bid, double ask);
};

BreakOutATS::BreakOutATS(TradingSessions *st,Trader *t):ATS(st,t) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  strategyName = "BreakOutATS";
  callOnTick = true;
  callOnBar = false;
  barPOI = true;
  dist = new Distance();
  poi = new Poi();
  reset();
}


BreakOutATS::~BreakOutATS() {
  if (CheckPointer(poi) == POINTER_DYNAMIC) delete poi;
  if (CheckPointer(dist) == POINTER_DYNAMIC) delete dist;
}

void BreakOutATS::reset() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  ATS::reset();
}

void BreakOutATS::OnInit() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  ATS::OnInit();  
}

void BreakOutATS::defaultParameters() {
  Debug(__FUNCTION__,__LINE__,"Entered");
}

void BreakOutATS::OnTick() {
  //Debug(__FUNCTION__,__LINE__,"Entered");
  if(tickPOI)
    poi.setPOI(0);
  if(tickDist)
    dist.getDistance();
}

void BreakOutATS::OnBar(bool tradeable=false) {
  Info2(__FUNCTION__,__LINE__,"Entered");
  ATS::OnBar();

  if(tradeable) {
    Info2(__FUNCTION__,__LINE__,"tradeable()");
    Info("barPOI="+(string)barPOI+"  newSessionBar="+(string)sessionTool.newSessionBar);
    if(barPOI && sessionTool.newSessionBar)
      poi.setPOI(1);
    if(barDist)
      dist.getDistance();
    Info2(__FUNCTION__,__LINE__,"POI_Long="+DoubleToString(poi.POI_Long,Digits));
    Info2(__FUNCTION__,__LINE__,"POI_Short="+DoubleToString(poi.POI_Short,Digits));
    Info2(__FUNCTION__,__LINE__,"Distance="+DoubleToString(dist.distance,Digits));
  }
}

void BreakOutATS::startOfDay() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  reset();
  dist.getDistance();
}

void BreakOutATS::endOfDay() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  cleanUpEOD();
}

void BreakOutATS::checkForNewEntry(Enum_SIDE side,double b, double a) {
  Info2(__FUNCTION__,__LINE__,"Entered");
  SetupStruct *setup;
  if(side==Long) {
    Info2(__FUNCTION__,__LINE__,"if("+string(NormalizeDouble(b,Digits))+" >= "+
               string(NormalizeDouble(poi.POI_Long,Digits))+" + "+
               string(NormalizeDouble(dist.distance,Digits)));
      Info2(__FUNCTION__,__LINE__,"Long filter passed");
      if(b >= poi.POI_Long+dist.distance) {
        setup = new SetupStruct();
        setup.strategyName = strategyName;
        setup.side         = Long;
        setup.symbol       = Symbol();
        setup.stopPrice    = a+5*P2D;
        trader.stopEntryOrder(setup);
        submitTime = TimeCurrent();
        tradeCnt++;
      }
  }
  if(side==Short) {
    Info("if("+string(NormalizeDouble(a,Digits))+" >= "+
               string(NormalizeDouble(poi.POI_Short,Digits))+" + "+
               string(NormalizeDouble(dist.distance,Digits)));
      Info2(__FUNCTION__,__LINE__,"Short filter passed");
      if(a <= poi.POI_Short-dist.distance) {
        setup = new SetupStruct();
        setup.strategyName = strategyName;
        setup.side         = Short;
        setup.symbol       = Symbol();
        setup.stopPrice    = b;
        Info2(__FUNCTION__,__LINE__,"call stopEntryOrder for SHort");
        trader.stopEntryOrder(setup);
        tradeCnt++;
      }
  }
}

