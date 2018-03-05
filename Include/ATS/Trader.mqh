//+------------------------------------------------------------------+
//|                                                       Trader.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <ATS\Position.mqh>
#include <ATS\PositionSizer.mqh>
#include <ATS\InitialRisk.mqh>
#include <ATS\ExitManager.mqh>
#include <ATS\ProfitTargetModels.mqh>
#include <ATS\SetupBase.mqh>
#include <ATS\setupStruct.mqh>
#include <ATS\MagicNumber.mqh>
#include <ATS\PriceModels.mqh>
#include <ATS\PriceModelsFake.mqh>

class Trader {
private:
  PositionSizer      *sizer;
  MagicNumber        *magic;
  PriceModelsBase    *price;
  ExitManager        *exitMgr;
  InitialRisk        *initRisk;
  ProfitTargetModels *profitTgt;
public:
  Trader(ExitManager*,InitialRisk*,ProfitTargetModels*);
  ~Trader();
  
  Position *newTrade(SetupBase*);
  Position *createTrade(SetupStruct*);
  
  int marketEntryOrder(SetupStruct*);
  int limitEntryOrder(SetupStruct*);
  int stopEntryOrder(SetupStruct*);

  //Position *newStopEntry(SetupStruct*);
  //Position *newLimitEntry(Enum_SIDE side,double limitPrice=NULL);

  double calcStopLoss(Position *);
  //int enterCurrentMarket(Enum_SIDE);
  //int stopEntryOrder(Enum_SIDE);
  void closeOpenPositions(Enum_SIDE,int);
};

Trader::Trader(ExitManager* em,InitialRisk* ir, ProfitTargetModels *pt) {
  sizer = new PositionSizer();
  magic = new MagicNumber();
  if(Testing)
    price = new PriceModelsFake();
  else
    price = new PriceModels();
  profitTgt = pt;
  exitMgr = em;
  initRisk = ir;
}

Trader::~Trader() {
 if (CheckPointer(sizer)    == POINTER_DYNAMIC) delete sizer;
 if (CheckPointer(initRisk) == POINTER_DYNAMIC) delete initRisk;
 if (CheckPointer(magic)    == POINTER_DYNAMIC) delete magic;
 if (CheckPointer(price)    == POINTER_DYNAMIC) delete price;
 //if (CheckPointer(ptgt)     == POINTER_DYNAMIC) delete ptgt;
}
//+------------------------------------------------------------------+

Position *Trader::newTrade(SetupBase *setup) {
  Debug(__FUNCTION__,__LINE__,"Entered");

  Position *trade = new Position();
  if(setup.side == Long) {
    Debug(__FUNCTION__,__LINE__,"Long");
    trade.OrderType = OP_BUYSTOP;
    trade.SideX = 1;
  }
  if(setup.side == Short) {
    Debug(__FUNCTION__,__LINE__,"Short");
    trade.OrderType = OP_SELLSTOP;
    trade.SideX = -1;
  }
  trade.Symbol = setup.symbol;
  trade.Side = setup.side;

  int oneR = initRisk.getInPips(trade);
  double entryPrice = price.entryPrice(trade);
  Info2(__FUNCTION__,__LINE__,"strategyName="+setup.strategyName);
  if(StringCompare(setup.strategyName,"RboSetup")==0) {
    Info2(__FUNCTION__,__LINE__,"rboPrice="+DoubleToStr(setup.rboPrice,Digits));
    entryPrice = setup.rboPrice;
  }

  trade.IsPending = true;
  trade.OpenPrice = entryPrice;

  if(UseStopLoss) {
    trade.StopPrice = (setup.side==Long ? trade.OpenPrice - oneR*PipSize :
                                          trade.OpenPrice + oneR*PipSize);
  }
  
  trade.Symbol = setup.symbol;
  trade.OneRpips = oneR;
  trade.LotSize = sizer.lotSize(trade);
  trade.Reference = __FILE__;
  trade.Magic = magic.get(setup.strategyName,oneR);
  Info2(__FUNCTION__,__LINE__,"mark");
  if(UseTakeProfit) {
    Info2(__FUNCTION__,__LINE__,"mark");
    trade.TakeProfitPrice = profitTgt.getTargetPrice(trade,PT_Model);
    trade.RewardPips = int((trade.TakeProfitPrice-entryPrice)*trade.SideX*PipFact);
  }
  Info2(__FUNCTION__,__LINE__,"mark");
  
  return(trade);
};

int Trader::marketEntryOrder(SetupStruct *setup) {
  Info2(__FUNCTION__,__LINE__,"Entered.");
  setup.limitPrice = price.entryPrice(setup,PM_BidAsk);
  return limitEntryOrder(setup);
}

int Trader::limitEntryOrder(SetupStruct *setup) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  if(setup.symbol==NULL) setup.symbol = Symbol();
  if(setup.side==NULL) return(-1);
  if(setup.limitPrice==NULL) return(-1);
  setup.entryPrice = setup.limitPrice;
  setup.sideX = 1;
  if(setup.side == Long) 
    setup.orderType = OP_BUYLIMIT;
  if(setup.side == Short) {
    setup.orderType = OP_SELLLIMIT;
    setup.sideX = -1;
  }  
  setup.isPending = true;
  Info2(__FUNCTION__,__LINE__,"setup="+setup.to_human());
  //if(!setup.oneRpips) setup.oneRpips = initRisk.getInPips(setup);

  Position *trade = createTrade(setup);
  if (CheckPointer(setup)    == POINTER_DYNAMIC) delete setup;
  
  if((double)trade.RewardPips/trade.OneRpips < MinReward2RiskRatio) {
    Info2(__FUNCTION__,__LINE__,(string)trade.RewardPips+"/"+(string)trade.OneRpips+" < "+DoubleToStr(MinReward2RiskRatio,2));
    Info("a Trade did not meet min reward-to-risk ratio");
    if (CheckPointer(trade) == POINTER_DYNAMIC) delete trade;
      return(-1);
  }
  int tid=broker.CreateOrder(trade);
  if (CheckPointer(trade) == POINTER_DYNAMIC) delete trade;
  return(tid);
}

int Trader::stopEntryOrder(SetupStruct *setup) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  Info2(__FUNCTION__,__LINE__,setup.to_human());
  if(setup.symbol==NULL) setup.symbol = Symbol();
  if(setup.side==NULL) return(-1);
  if(setup.stopPrice==NULL) return(-1);
  setup.entryPrice = setup.stopPrice;
  setup.sideX = 1;
  if(setup.side == Long) 
    setup.orderType = OP_BUYSTOP;
  if(setup.side == Short) {
    setup.orderType = OP_SELLSTOP;
    setup.sideX = -1;
  }  
  setup.isPending = true;
  //if(!setup.oneRpips) setup.oneRpips = initRisk.getInPips(setup);

  Info2(__FUNCTION__,__LINE__,setup.to_human());
  Position *trade = createTrade(setup);
  Info2(__FUNCTION__,__LINE__,setup.to_human());
  if (CheckPointer(setup)    == POINTER_DYNAMIC) delete setup;
  
  Info2(__FUNCSIG__,__LINE__,trade.to_human());
  if(!(trade.OneRpips>0)) return(-1);
  Info2(__FUNCTION__,__LINE__,"mark");
  if(UseTakeProfit) {
    Info2(__FUNCTION__,__LINE__,"mark");
    trade.TakeProfitPrice = profitTgt.getTargetPrice(trade,PT_Model);
    Info2(__FUNCTION__,__LINE__,"mark");
    if((double)trade.RewardPips/trade.OneRpips < MinReward2RiskRatio) {
      //Info2(__FUNCTION__,__LINE__,"mark");
      //Info2(__FUNCTION__,__LINE__,trade.RewardPips+"/"+trade.OneRpips+" < "+MinReward2RiskRatio);
      Info("b Trade did not meet min reward-to-risk ratio");
      if (CheckPointer(trade) == POINTER_DYNAMIC) delete trade;
        return(-1);
    }
  }
  //Info2(__FUNCTION__,__LINE__,"Bid/Ask: "+Bid+"/"+Ask);
  int tid=broker.CreateOrder(trade);
  if (CheckPointer(trade) == POINTER_DYNAMIC) delete trade;
  return(tid);
}

double Trader::calcStopLoss(Position *pos) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  double newStopLoss;
  double px = iClose(NULL,0,1);
  if(px-OrderOpenPrice()>exitMgr.pips2startTS(pos)*P2D)
    return(NULL);
  newStopLoss = exitMgr.getTrailingStop(pos);
  if(newStopLoss > 0) {
    pos.StopPrice = newStopLoss;
    return(newStopLoss);
  }
  return(NULL);
}

void Trader::closeOpenPositions(Enum_SIDE side, int magicN=0) {
  Info2(__FUNCTION__,__LINE__,"Entered.");
  broker.closeOpenTrades(Symbol(),side,magicN);
}

Position *Trader::createTrade(SetupStruct *setup) {
  Info2(__FUNCTION__,__LINE__,"Entered.");
  Info2(__FUNCTION__,__LINE__,"setup="+setup.to_human());
  Position *trade = new Position();
  trade.Symbol = setup.symbol;
  trade.Side = setup.side;
  trade.SideX = setup.sideX;
  trade.OrderType = setup.orderType;
  trade.OpenPrice = setup.entryPrice;
  if(!setup.oneRpips) setup.oneRpips = initRisk.getInPips(setup);
  trade.OneRpips = setup.oneRpips;
  trade.LotSize = sizer.lotSize(trade);
  trade.Reference = __FILE__;
  trade.Magic = magic.get(setup.strategyName,setup.oneRpips);

  if(UseStopLoss)
    trade.StopPrice = (setup.side==Long ? trade.OpenPrice - setup.oneRpips*PipSize :
                                          trade.OpenPrice + setup.oneRpips*PipSize);
  Info2(__FUNCTION__,__LINE__,"mark");
  if(UseTakeProfit) {
    Info2(__FUNCTION__,__LINE__,"mark");
    trade.TakeProfitPrice = profitTgt.getTargetPrice(trade,PT_Model);
    Info2(__FUNCTION__,__LINE__,"mark");
    trade.RewardPips = int((trade.TakeProfitPrice-setup.entryPrice)*trade.SideX*PipFact);
  }
  Info2(__FUNCTION__,__LINE__,"trade="+trade.to_human());
  
  return(trade);
}
