//+------------------------------------------------------------------+
//|                                              OptimizerOutput.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

class OptimizerOutput {
private:

public:
  OptimizerOutput();
  ~OptimizerOutput();
  
  int openDailySummaryFile();
  string pmInputsHdr();
  string statsHdr();
  void writeDailySummaryHdr(int fh);
  void writeDailyTrades();
  void writeDailyTradesHdr(int fh);
  void writeDailySummary(string prefix="tbd");
};

OptimizerOutput::OptimizerOutput() {
}

OptimizerOutput::~OptimizerOutput() {
}

int OptimizerOutput::openDailySummaryFile() {
  bool writeHeader;
  string fn = "dailySummary_v"+(string)version+".csv";
  if(!FileIsExist(fn))
    writeHeader = true;
  else
    writeHeader = false;
  int fh=FileOpen(fn, FILE_CSV|FILE_READ|FILE_SHARE_READ|FILE_WRITE,';');
  if(writeHeader)
    writeDailySummaryHdr(fh);
  else
    FileSeek(fh, 0, SEEK_END);
  return(fh);  
}

string OptimizerOutput::pmInputsHdr() {   //(string& hdrArray[]) {
  string rtn="";
  string srcArray[] = {"Symbol","TimeFrame","pnlPips"};
  for(int i=0;i<ArraySize(srcArray);i++) {
    StringConcatenate(rtn,srcArray[i],";");
  }
  return(rtn);
  //ArrayResize(hdrArray,ArraySize(srcArray));
  //ArrayCopy(hdrArray,srcArray);
}

string OptimizerOutput::statsHdr() {   //string& hdrArray[]) {
  string rtn="";
  string srcArray[]={"STAT_TRADES",
                "STAT_PROFIT_TRADES",
                "STAT_LOSS_TRADES",
                "STAT_BALANCE_DD",
                "STAT_EQUITY_DD",
                "STAT_INITIAL_DEPOSIT",
                "STAT_PROFIT",
                "STAT_GROSS_PROFIT",
                "STAT_GROSS_LOSS",
                "STAT_MAX_PROFITTRADE",
                "STAT_MAX_LOSSTRADE",
                "STAT_CONPROFITMAX",
                "STAT_CONPROFITMAX_TRADES",
                "STAT_MAX_CONWINS",
                "STAT_MAX_CONPROFIT_TRADES",
                "STAT_CONLOSSMAX",
                "STAT_CONLOSSMAX_TRADES",
                "STAT_MAX_CONLOSSES",
                "STAT_MAX_CONLOSS_TRADES",
                "STAT_BALANCEMIN",
                "STAT_BALANCEDD_PERCENT",
                "STAT_BALANCE_DDREL_PERCENT",
                "STAT_BALANCE_DD_RELATIVE",
                "STAT_EQUITYMIN",
                "STAT_EQUITYDD_PERCENT",
                "STAT_EQUITY_DDREL_PERCENT",
                "STAT_EQUITY_DD_RELATIVE",
                "STAT_EXPECTED_PAYOFF",
                "STAT_PROFIT_FACTOR",
                "STAT_MIN_MARGINLEVEL",
                "STAT_CUSTOM_ONTESTER",
                "STAT_SHORT_TRADES",
                "STAT_LONG_TRADES",
                "STAT_PROFIT_SHORTTRADES",
                "STAT_PROFIT_LONGTRADES",
                "STAT_PROFITTRADES_AVGCON",
                "STAT_LOSSTRADES_AVGCON"};
  for(int i=0;i<ArraySize(srcArray);i++) {
    StringConcatenate(rtn,srcArray[i],";");
  }
  return(rtn);
  //ArrayResize(hdrArray,ArraySize(srcArray));
  //ArrayCopy(hdrArray,srcArray);
}

void OptimizerOutput::writeDailySummaryHdr(int fh) {
  FileWrite(fh,pmInputsHdr(),ats.inputsHdr(),statsHdr());
  //FileClose(fh);
}

void OptimizerOutput::writeDailyTradesHdr(int fh) {
  FileWrite(fh, "Symbol","TimeFrame","TBD");
}

void OptimizerOutput::writeDailySummary(string prefix="tbd") {
  if(TesterStatistics(STAT_TRADES)==0) return;
  int fh = openDailySummaryFile();
  
  //FileWrite(fh,Symbol(),Period(),NormalizeDouble(broker.pnlPipsToday(),2),
  //             POI_Model,POI_price,POI_ma_period,DIST_atr_period,DIST_atr_factor,Filter_Model,
  //             TesterStatistics(STAT_TRADES),
  //             TesterStatistics(STAT_PROFIT_TRADES),
  //             TesterStatistics(STAT_LOSS_TRADES),
  //             TesterStatistics(STAT_BALANCE_DD),
  //             TesterStatistics(STAT_EQUITY_DD),
  //             TesterStatistics(STAT_INITIAL_DEPOSIT),
  //             DoubleToStr(TesterStatistics(STAT_PROFIT),2),
  //             DoubleToStr(TesterStatistics(STAT_GROSS_PROFIT),2),
  //             DoubleToStr(TesterStatistics(STAT_GROSS_LOSS),2),
  //             TesterStatistics(STAT_MAX_PROFITTRADE),
  //             TesterStatistics(STAT_MAX_LOSSTRADE),
  //             TesterStatistics(STAT_CONPROFITMAX),
  //             TesterStatistics(STAT_CONPROFITMAX_TRADES),
  //             TesterStatistics(STAT_MAX_CONWINS),
  //             TesterStatistics(STAT_MAX_CONPROFIT_TRADES),
  //             TesterStatistics(STAT_CONLOSSMAX),
  //             TesterStatistics(STAT_CONLOSSMAX_TRADES),
  //             TesterStatistics(STAT_MAX_CONLOSSES),
  //             TesterStatistics(STAT_MAX_CONLOSS_TRADES),
  //             TesterStatistics(STAT_BALANCEMIN),
  //             TesterStatistics(STAT_BALANCEDD_PERCENT),
  //             TesterStatistics(STAT_BALANCE_DDREL_PERCENT),
  //             TesterStatistics(STAT_BALANCE_DD_RELATIVE),
  //             TesterStatistics(STAT_EQUITYMIN),
  //             TesterStatistics(STAT_EQUITYDD_PERCENT),
  //             TesterStatistics(STAT_EQUITY_DDREL_PERCENT),
  //             TesterStatistics(STAT_EQUITY_DD_RELATIVE),
  //             TesterStatistics(STAT_EXPECTED_PAYOFF),
  //             TesterStatistics(STAT_PROFIT_FACTOR),
  //             TesterStatistics(STAT_MIN_MARGINLEVEL),
  //             TesterStatistics(STAT_CUSTOM_ONTESTER),
  //             TesterStatistics(STAT_SHORT_TRADES),
  //             TesterStatistics(STAT_LONG_TRADES),
  //             TesterStatistics(STAT_PROFIT_SHORTTRADES),
  //             TesterStatistics(STAT_PROFIT_LONGTRADES),
  //             TesterStatistics(STAT_PROFITTRADES_AVGCON),
  //             TesterStatistics(STAT_LOSSTRADES_AVGCON)
  //              );
  FileClose(fh);
}


void OptimizerOutput::writeDailyTrades() {
}
/**
  bool writeHeader;
  string fn = "dailyTrades_v"+(string)version+".csv";
  if(!FileIsExist(fn))
    writeHeader = true;
  else
    writeHeader = false;
  int fh=FileOpen(fn, FILE_CSV|FILE_READ|FILE_SHARE_READ|FILE_WRITE,';');
  if(writeHeader)
    writeDailyTradesHdr(fh);
  else
    FileSeek(fh, 0, SEEK_END);
  for(int i=0;i<OrdersHistoryTotal();i++) {
    if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true && OrderSymbol() == Symbol()) {
      if(OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP) {
        continue;
      }
      if(TimeToStr( OrderOpenTime(), TIME_DATE) == todayTime) {
        Info("Comparing "+TimeToStr(OrderOpenTime(),TIME_DATE)+" = "+todayTime);
        if(OrderType() == OP_BUY) {
          FileWrite(fh,OrderSymbol(),OrderOpenTime(),OrderLots(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit(),OrderClosePrice(),OrderCloseTime(),OrderMagicNumber(),OrderProfit(),OrderTicket(),OrderType());
          plToday += OrderClosePrice()-OrderOpenPrice();
        } else {
          plToday += OrderOpenPrice()-OrderClosePrice();
        }
      }
    }
  }

}
**/
