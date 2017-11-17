enum ENTRY_TYPE
{
   Instant,
   Pending
};

extern bool ShowPortfolioRisk = false; // If true, current portfolio risk and potential portfolio risk will be shown.
extern bool ShowMargin = false; // If true, margin calculations for planned position will be shown.
extern ENTRY_TYPE EntryType = Instant; // If Instant, Entry level will be updated to current Ask/Bid price automatically; if Pending, Entry level will remain intact and StopLevel warning will be issued if needed.
extern double EntryLevel = 0;
extern double StopLossLevel = 0;
extern double TakeProfitLevel = 0; // Optional
extern double Risk = 1; // Risk tolerance in percentage points
extern double MoneyRisk = 0; // Risk tolerance in account currency
extern double CommissionPerLot = 0; // Commission charged per lot (one side) in account currency.
extern bool UseMoneyInsteadOfPercentage = false;
extern bool UseEquityInsteadOfBalance = false;
extern bool DeleteLines = false; // If true, will delete lines on deinitialization. Otherwise will leave lines, so levels can be restored.
extern bool CountPendingOrders = false; // If true, portfolio risk calculation will also involve pending orders.
extern bool IgnoreOrdersWithoutStopLoss = false; // If true, portfolio risk calculation will skip orders without stop-loss.
extern bool HideAccSize = false; // If true, account size line will not be shown.
extern bool HideSecondRisk = false; // If true, second risk line will not be shown.
extern bool HideEmpty = false; // If true, empty line before divider will not be shown.
extern bool ShowLineLabels = true; // If true, pip distance for TP and SL is shown near lines.
extern bool DrawTextAsBackground = false; // If true, all text label objects will be drawn as background.

extern color entry_font_color = clrBlue;
extern color sl_font_color = clrLime;
extern color sl_label_font_color = clrLime;
extern color tp_font_color = clrYellow;
extern color tp_label_font_color = clrYellow;
extern color ps_font_color = clrRed;
extern color rp_font_color = clrLightBlue;
extern color balance_font_color = clrLightBlue;
extern color rmm_font_color = clrLightBlue;
extern color margin_font_color = clrSlateBlue;
extern color stopout_font_color = clrRed;
extern color pp_font_color = clrLightBlue;
extern color rr_font_color = clrYellow;
extern color div_font_color = clrSlateGray;
extern int font_size = 13;
extern string font_face = "Courier";
extern int corner = 0; //0 - for top-left corner, 1 - top-right, 2 - bottom-left, 3 - bottom-right
extern int distance_x = 10;
extern int distance_y = 15;
extern int line_height = 15;
extern color entry_line_color = clrBlue;
extern color stoploss_line_color = clrLime;
extern color takeprofit_line_color = clrYellow;
extern ENUM_LINE_STYLE entry_line_style = STYLE_SOLID;
extern ENUM_LINE_STYLE stoploss_line_style = STYLE_SOLID;
extern ENUM_LINE_STYLE takeprofit_line_style = STYLE_SOLID;
extern int entry_line_width = 1;
extern int stoploss_line_width = 1;
extern int takeprofit_line_width = 1;

string SizeText; // Balance/Equity.
// Used in more than one function.
double Size, OutputRiskMoney;
double OutputPositionSize;
double StopLoss;
double tEntryLevel, tStopLossLevel, tTakeProfitLevel;
// -1 because it is checked in the initialization function.
double TickSize = -1, MarginMaintenance = 0, MarginHedging, LotSize, MinLot, MaxLot, LotStep;
int AccStopoutMode, AccStopoutLevel, LotStep_digits;

int Window = -1;

//+--------------------------------------------------------------------------+
//| Will be called from start() or OnTimer() after Window number is detected.|
//+--------------------------------------------------------------------------+
void Initialization()
{
   if (!DeleteLines)
   {
      if (ObjectFind("EntryLine") > -1)
      {
         EntryLevel = Round(ObjectGet("EntryLine", OBJPROP_PRICE1), _Digits);
         ObjectSet("EntryLine", OBJPROP_STYLE, entry_line_style);
         ObjectSet("EntryLine", OBJPROP_COLOR, entry_line_color);
         ObjectSet("EntryLine", OBJPROP_WIDTH, entry_line_width);
      }
      if (ObjectFind("StopLossLine") > -1)
      {
         StopLossLevel = Round(ObjectGet("StopLossLine", OBJPROP_PRICE1), _Digits);
         ObjectSet("StopLossLine", OBJPROP_STYLE, stoploss_line_style);
         ObjectSet("StopLossLine", OBJPROP_COLOR, stoploss_line_color);
         ObjectSet("StopLossLine", OBJPROP_WIDTH, stoploss_line_width);
      }
      if (ObjectFind("TakeProfitLine") > -1)
      {
         TakeProfitLevel = Round(ObjectGet("TakeProfitLine", OBJPROP_PRICE1), _Digits);
         ObjectSet("TakeProfitLine", OBJPROP_STYLE, takeprofit_line_style);
         ObjectSet("TakeProfitLine", OBJPROP_COLOR, takeprofit_line_color);
         ObjectSet("TakeProfitLine", OBJPROP_WIDTH, takeprofit_line_width);
      }
   }
   else
   {
      ObjectDelete("EntryLine");
      ObjectDelete("StopLossLine");
      ObjectDelete("TakeProfitLine");
   }
   
   if ((EntryLevel == 0) && (StopLossLevel == 0))
   {
      Print(Symbol() + ": Entry and Stop-Loss levels not given. Using local values.");
      EntryLevel = High[0];
      StopLossLevel = Low[0];
      if (EntryLevel == StopLossLevel) StopLossLevel -= Point;
   }
   if (EntryLevel - StopLossLevel == 0)
   {
      Alert("Entry and Stop-Loss levels should be different and non-zero.");
      return;
   }

   if (EntryType == Instant)
   {
      RefreshRates();
      if ((Ask > 0) && (Bid > 0))
      {
         // SL got inside Ask/Bid range.
         if ((StopLossLevel >= Bid) && (StopLossLevel <= Ask)) StopLossLevel = Bid - Point;
         // Long entry
         if (StopLossLevel < Bid) EntryLevel = Ask;
         // Short entry
         else if (StopLossLevel > Ask) EntryLevel = Bid;
      }
   }

   ObjectCreate("EntryLevel", OBJ_LABEL, Window, 0, 0);
   ObjectSet("EntryLevel", OBJPROP_CORNER, corner);
   ObjectSet("EntryLevel", OBJPROP_XDISTANCE, distance_x);
   ObjectSet("EntryLevel", OBJPROP_YDISTANCE, distance_y);
   ObjectSet("EntryLevel", OBJPROP_BACK, DrawTextAsBackground);
   ObjectSetText("EntryLevel", "Entry Lvl:    " + JustifyRight(DoubleToString(EntryLevel, Digits), MaxNumberLength), font_size, font_face, entry_font_color);
   ObjectSet("EntryLevel", OBJPROP_SELECTABLE, false);

   if (ObjectFind("EntryLine") == -1) 
   {
      ObjectCreate("EntryLine", OBJ_HLINE, 0, Time[0], EntryLevel);
      ObjectSet("EntryLine", OBJPROP_STYLE, entry_line_style);
      ObjectSet("EntryLine", OBJPROP_COLOR, entry_line_color);
      ObjectSet("EntryLine", OBJPROP_WIDTH, entry_line_width);
   }
   if (EntryType == Instant) ObjectSet("EntryLine", OBJPROP_SELECTABLE, false);
   else ObjectSet("EntryLine", OBJPROP_SELECTABLE, true);

   ObjectCreate("StopLoss", OBJ_LABEL, Window, 0, 0);
   ObjectSet("StopLoss", OBJPROP_CORNER, corner);
   ObjectSet("StopLoss", OBJPROP_XDISTANCE, distance_x);
   ObjectSet("StopLoss", OBJPROP_YDISTANCE, distance_y + line_height);
   ObjectSet("StopLoss", OBJPROP_BACK, DrawTextAsBackground);
   ObjectSetText("StopLoss", "Stop-Loss:    " + JustifyRight(DoubleToString(StopLossLevel, Digits), MaxNumberLength), font_size, font_face, sl_font_color);
   ObjectSet("StopLoss", OBJPROP_SELECTABLE, false);
      
   if (ObjectFind("StopLossLine") == -1)
   {
      ObjectCreate("StopLossLine", OBJ_HLINE, 0, Time[0], StopLossLevel);
      ObjectSet("StopLossLine", OBJPROP_STYLE, stoploss_line_style);
      ObjectSet("StopLossLine", OBJPROP_COLOR, stoploss_line_color);
      ObjectSet("StopLossLine", OBJPROP_WIDTH, stoploss_line_width);
   }
   StopLoss = MathAbs(EntryLevel - StopLossLevel);
   int y_shift = 2 * line_height;
   if (ShowLineLabels)
   {
   	ObjectCreate("StopLossLabel", OBJ_LABEL, 0, 0, 0);
   	ObjectSet("StopLossLabel", OBJPROP_COLOR, clrNONE);
   	ObjectSet("StopLossLabel", OBJPROP_SELECTABLE, false);
   	ObjectSet("StopLossLabel", OBJPROP_HIDDEN, false);
	   ObjectSet("StopLossLabel", OBJPROP_CORNER, CORNER_LEFT_UPPER);
		ObjectSet("StopLossLabel", OBJPROP_BACK, DrawTextAsBackground);
	}
	
   if (TakeProfitLevel > 0) // Show TP line and RR ratio only if TakeProfitLevel input parameter is set by user or found via chart object.
   {
      ObjectCreate("TakeProfit", OBJ_LABEL, Window, 0, 0);
      ObjectSet("TakeProfit", OBJPROP_CORNER, corner);
      ObjectSet("TakeProfit", OBJPROP_XDISTANCE, distance_x);
      ObjectSet("TakeProfit", OBJPROP_YDISTANCE, distance_y + y_shift);
      ObjectSet("TakeProfit", OBJPROP_BACK, DrawTextAsBackground);
      ObjectSetText("TakeProfit", "Take-Profit:  " + JustifyRight(DoubleToString(TakeProfitLevel, Digits), MaxNumberLength), font_size, font_face, tp_font_color);
      ObjectSet("TakeProfit", OBJPROP_SELECTABLE, false);
      y_shift += line_height;

      if (ObjectFind("TakeProfitLine") == -1) 
      {
         ObjectCreate("TakeProfitLine", OBJ_HLINE, 0, Time[0], TakeProfitLevel);
         ObjectSet("TakeProfitLine", OBJPROP_STYLE, takeprofit_line_style);
         ObjectSet("TakeProfitLine", OBJPROP_COLOR, takeprofit_line_color);
         ObjectSet("TakeProfitLine", OBJPROP_WIDTH, takeprofit_line_width);
      }
	   if (ShowLineLabels)
	   {
	   	ObjectCreate("TakeProfitLabel", OBJ_LABEL, 0, 0, 0);
	   	ObjectSet("TakeProfitLabel", OBJPROP_COLOR, clrNONE);
	   	ObjectSet("TakeProfitLabel", OBJPROP_SELECTABLE, false);
	   	ObjectSet("TakeProfitLabel", OBJPROP_HIDDEN, false);
		   ObjectSet("TakeProfitLabel", OBJPROP_CORNER, CORNER_LEFT_UPPER);
		   ObjectSet("TakeProfitLabel", OBJPROP_BACK, DrawTextAsBackground);
		}
   }
   
   if (UseEquityInsteadOfBalance)
   {
      SizeText = "Equity";
      Size = AccountEquity();
   }
   else
   {
      SizeText = "Balance";
      Size = AccountBalance();
   }
   if (!HideAccSize)
   {
      ObjectCreate("AccountSize", OBJ_LABEL, Window, 0, 0);
      ObjectSet("AccountSize", OBJPROP_CORNER, corner);
      ObjectSet("AccountSize", OBJPROP_XDISTANCE, distance_x);
      ObjectSet("AccountSize", OBJPROP_YDISTANCE, distance_y + y_shift);
      ObjectSet("AccountSize", OBJPROP_BACK, DrawTextAsBackground);
      ObjectSetText("AccountSize", "Acc. " + SizeText + ": " + JustifyRight(FormatDouble(DoubleToString(Size, 2)), MaxNumberLength), font_size, font_face, balance_font_color);
      ObjectSet("AccountSize", OBJPROP_SELECTABLE, false);
      y_shift += line_height;
   }
   
   if (CommissionPerLot > 0)
   {
      ObjectCreate("CommissionPerLot", OBJ_LABEL, Window, 0, 0);
      ObjectSet("CommissionPerLot", OBJPROP_CORNER, corner);
      ObjectSet("CommissionPerLot", OBJPROP_XDISTANCE, distance_x);
      ObjectSet("CommissionPerLot", OBJPROP_YDISTANCE, distance_y + y_shift);
      ObjectSet("CommissionPerLot", OBJPROP_BACK, DrawTextAsBackground);
      ObjectSetText("CommissionPerLot", "Com. per lot: " + JustifyRight(FormatDouble(DoubleToString(CommissionPerLot, 2)), MaxNumberLength), font_size, font_face, rp_font_color);
      ObjectSet("CommissionPerLot", OBJPROP_SELECTABLE, false);
      y_shift += line_height;
   }

   if (!HideEmpty) y_shift += 15;
   ObjectCreate("Divider", OBJ_LABEL, Window, 0, 0);
   ObjectSet("Divider", OBJPROP_CORNER, corner);
   ObjectSet("Divider", OBJPROP_XDISTANCE, distance_x);
   ObjectSet("Divider", OBJPROP_YDISTANCE, distance_y + y_shift);
   ObjectSet("Divider", OBJPROP_BACK, DrawTextAsBackground);
   ObjectSetText("Divider", "              " + JustifyRight("Input", MaxNumberLength) + JustifyRight("Result", MaxNumberLength), font_size, font_face, div_font_color);
   ObjectSet("Divider", OBJPROP_SELECTABLE, false);
   y_shift += line_height;

   if ((!HideSecondRisk) || ((HideSecondRisk) && (!UseMoneyInsteadOfPercentage)))
   {
      ObjectCreate("Risk", OBJ_LABEL, Window, 0, 0);
      ObjectSet("Risk", OBJPROP_CORNER, corner);
      ObjectSet("Risk", OBJPROP_XDISTANCE, distance_x);
      ObjectSet("Risk", OBJPROP_YDISTANCE, distance_y + y_shift);
      ObjectSet("Risk", OBJPROP_BACK, DrawTextAsBackground);
      ObjectSetText("Risk", "", font_size, font_face, rp_font_color);
      ObjectSet("Risk", OBJPROP_SELECTABLE, false);
      y_shift += line_height;
   }
   
   if ((!HideSecondRisk) || ((HideSecondRisk) && (UseMoneyInsteadOfPercentage)))
   {
      ObjectCreate("RiskMoney", OBJ_LABEL, Window, 0, 0);
      ObjectSet("RiskMoney", OBJPROP_CORNER, corner);
      ObjectSet("RiskMoney", OBJPROP_XDISTANCE, distance_x);
      ObjectSet("RiskMoney", OBJPROP_YDISTANCE, distance_y + y_shift);
      ObjectSet("RiskMoney", OBJPROP_BACK, DrawTextAsBackground);
      ObjectSetText("RiskMoney", "", font_size, font_face, rp_font_color);
      ObjectSet("RiskMoney", OBJPROP_SELECTABLE, false);
      y_shift += line_height;
   }
   
   if (TakeProfitLevel > 0)
   {
      ObjectCreate("PotentialProfit", OBJ_LABEL, Window, 0, 0);
      ObjectSet("PotentialProfit", OBJPROP_CORNER, corner);
      ObjectSet("PotentialProfit", OBJPROP_XDISTANCE, distance_x);
      ObjectSet("PotentialProfit", OBJPROP_YDISTANCE, distance_y + y_shift);
      ObjectSet("PotentialProfit", OBJPROP_BACK, DrawTextAsBackground);
      ObjectSetText("PotentialProfit", "", font_size, font_face, pp_font_color);
      ObjectSet("PotentialProfit", OBJPROP_SELECTABLE, false);
      y_shift += line_height;

      ObjectCreate("RR", OBJ_LABEL, Window, 0, 0);
      ObjectSet("RR", OBJPROP_CORNER, corner);
      ObjectSet("RR", OBJPROP_XDISTANCE, distance_x);
      ObjectSet("RR", OBJPROP_YDISTANCE, distance_y + y_shift);
      ObjectSet("RR", OBJPROP_BACK, DrawTextAsBackground);
      ObjectSetText("RR", "", font_size, font_face, rr_font_color);
      ObjectSet("RR", OBJPROP_SELECTABLE, false);
      y_shift += line_height;
   }

   ObjectCreate("PositionSize", OBJ_LABEL, Window, 0, 0);
   ObjectSet("PositionSize", OBJPROP_CORNER, corner);
   ObjectSet("PositionSize", OBJPROP_XDISTANCE, distance_x);
   ObjectSet("PositionSize", OBJPROP_YDISTANCE, distance_y + y_shift);
   ObjectSet("PositionSize", OBJPROP_BACK, DrawTextAsBackground);
   ObjectSetText("PositionSize", "", font_size, font_face, ps_font_color);
   ObjectSet("PositionSize", OBJPROP_SELECTABLE, false);
   y_shift += line_height;
   
   if (ShowPortfolioRisk)
   {
      if (second_column_x > 0) y_shift = line_height * 3;
      else y_shift += line_height;
      
      ObjectCreate("CurrentPortfolioMoneyRisk", OBJ_LABEL, Window, 0, 0);
      ObjectSet("CurrentPortfolioMoneyRisk", OBJPROP_CORNER, corner);
      ObjectSet("CurrentPortfolioMoneyRisk", OBJPROP_XDISTANCE, distance_x + second_column_x);
      ObjectSet("CurrentPortfolioMoneyRisk", OBJPROP_YDISTANCE, distance_y + y_shift);
      ObjectSet("CurrentPortfolioMoneyRisk", OBJPROP_BACK, DrawTextAsBackground);
      ObjectSetText("CurrentPortfolioMoneyRisk", "", font_size, font_face, rmm_font_color);
      ObjectSet("CurrentPortfolioMoneyRisk", OBJPROP_SELECTABLE, false);
      y_shift += line_height;

      ObjectCreate("CurrentPortfolioRisk", OBJ_LABEL, Window, 0, 0);
      ObjectSet("CurrentPortfolioRisk", OBJPROP_CORNER, corner);
      ObjectSet("CurrentPortfolioRisk", OBJPROP_XDISTANCE, distance_x + second_column_x);
      ObjectSet("CurrentPortfolioRisk", OBJPROP_YDISTANCE, distance_y + y_shift);
      ObjectSet("CurrentPortfolioRisk", OBJPROP_BACK, DrawTextAsBackground);
      ObjectSetText("CurrentPortfolioRisk", "", font_size, font_face, rmm_font_color);
      ObjectSet("CurrentPortfolioRisk", OBJPROP_SELECTABLE, false);
      y_shift += line_height;

      ObjectCreate("PotentialPortfolioMoneyRisk", OBJ_LABEL, Window, 0, 0);
      ObjectSet("PotentialPortfolioMoneyRisk", OBJPROP_CORNER, corner);
      ObjectSet("PotentialPortfolioMoneyRisk", OBJPROP_XDISTANCE, distance_x + second_column_x);
      ObjectSet("PotentialPortfolioMoneyRisk", OBJPROP_YDISTANCE, distance_y + y_shift);
      ObjectSet("PotentialPortfolioMoneyRisk", OBJPROP_BACK, DrawTextAsBackground);
      ObjectSetText("PotentialPortfolioMoneyRisk", "", font_size, font_face, rmm_font_color);
      ObjectSet("PotentialPortfolioMoneyRisk", OBJPROP_SELECTABLE, false);
      y_shift += line_height;
    
      ObjectCreate("PotentialPortfolioRisk", OBJ_LABEL, Window, 0, 0);
      ObjectSet("PotentialPortfolioRisk", OBJPROP_CORNER, corner);
      ObjectSet("PotentialPortfolioRisk", OBJPROP_XDISTANCE, distance_x + second_column_x);
      ObjectSet("PotentialPortfolioRisk", OBJPROP_YDISTANCE, distance_y + y_shift);
      ObjectSet("PotentialPortfolioRisk", OBJPROP_BACK, DrawTextAsBackground);
      ObjectSetText("PotentialPortfolioRisk", "", font_size, font_face, rmm_font_color);
      ObjectSet("PotentialPortfolioRisk", OBJPROP_SELECTABLE, false);
   }

   if (ShowMargin)
   {
      if (ShowPortfolioRisk) y_shift += line_height * 2; // One blank line.
      else if (second_column_x > 0) y_shift = line_height * 3;
      
      ObjectCreate("PositionMargin", OBJ_LABEL, Window, 0, 0);
      ObjectSet("PositionMargin", OBJPROP_CORNER, corner);
      ObjectSet("PositionMargin", OBJPROP_XDISTANCE, distance_x + second_column_x);
      ObjectSet("PositionMargin", OBJPROP_YDISTANCE, distance_y + y_shift);
      ObjectSet("PositionMargin", OBJPROP_BACK, DrawTextAsBackground);
      ObjectSetText("PositionMargin", "", font_size, font_face, margin_font_color);
      ObjectSet("PositionMargin", OBJPROP_SELECTABLE, false);
      y_shift += line_height;

      ObjectCreate("FutureUsedMargin", OBJ_LABEL, Window, 0, 0);
      ObjectSet("FutureUsedMargin", OBJPROP_CORNER, corner);
      ObjectSet("FutureUsedMargin", OBJPROP_XDISTANCE, distance_x + second_column_x);
      ObjectSet("FutureUsedMargin", OBJPROP_YDISTANCE, distance_y + y_shift);
      ObjectSet("FutureUsedMargin", OBJPROP_BACK, DrawTextAsBackground);
      ObjectSetText("FutureUsedMargin", "", font_size, font_face, margin_font_color);
      ObjectSet("FutureUsedMargin", OBJPROP_SELECTABLE, false);
      y_shift += line_height;

      ObjectCreate("FutureFreeMargin", OBJ_LABEL, Window, 0, 0);
      ObjectSet("FutureFreeMargin", OBJPROP_CORNER, corner);
      ObjectSet("FutureFreeMargin", OBJPROP_XDISTANCE, distance_x + second_column_x);
      ObjectSet("FutureFreeMargin", OBJPROP_YDISTANCE, distance_y + y_shift);
      ObjectSet("FutureFreeMargin", OBJPROP_BACK, DrawTextAsBackground);
      ObjectSetText("FutureFreeMargin", "", font_size, font_face, margin_font_color);
      ObjectSet("FutureFreeMargin", OBJPROP_SELECTABLE, false);
   }
   RecalculatePositionSize();
}

//+--------------------------------------------------------------------------+
//| Called every second to initialize the indicator if start fails to do so. |
//+--------------------------------------------------------------------------+
void OnTimer()
{
   if (Window == -1)
   {
      Window = WindowFind("Position Size Calculator");
      Initialization();
   }
   EventKillTimer();
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,      // size of input time series 
                 const int prev_calculated,  // bars handled in previous call 
                 const datetime& time[],     // Time 
                 const double& open[],       // Open 
                 const double& high[],       // High 
                 const double& low[],        // Low 
                 const double& close[],      // Close 
                 const long& tick_volume[],  // Tick Volume 
                 const long& volume[],       // Real Volume 
                 const int& spread[]         // Spread 
)
{
   if (Window == -1)
   {
      Window = WindowFind("Position Size Calculator");
      Initialization();
   }
   RecalculatePositionSize();
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Object dragging handler                                          |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event ID
                  const long& lparam,   // Parameter of type long event
                  const double& dparam, // Parameter of type double event
                  const string& sparam  // Parameter of type string events
)
{
   // Recalculate on chart changes, clicks, and certain object dragging.
   if ((id == CHARTEVENT_CLICK) || (id == CHARTEVENT_CHART_CHANGE) || 
   ((id == CHARTEVENT_OBJECT_DRAG) && ((sparam == "EntryLine") || (sparam == "StopLossLine") || (sparam == "TakeProfitLine"))))
   {
   	RecalculatePositionSize();
   	ChartRedraw();
   }
}

//+------------------------------------------------------------------+
//| Trade event handler                                              |
//+------------------------------------------------------------------+
void OnTrade()
{
   RecalculatePositionSize();
   ChartRedraw();   
}

//+------------------------------------------------------------------+
//| Main recalculation function used on every tick and on entry/SL   |
//| line drag                                                        |
//+------------------------------------------------------------------+
void RecalculatePositionSize()
{
   // Update Entry to Ask/Bid if needed.
   RefreshRates();
   if (EntryType == Instant)
   {
      if ((Ask > 0) && (Bid > 0))
      {
         tStopLossLevel = Round(ObjectGet("StopLossLine", OBJPROP_PRICE1), _Digits);
         // Long entry
         if (tStopLossLevel < Bid) tEntryLevel = Ask;
         // Short entry
         else if (tStopLossLevel > Ask) tEntryLevel = Bid;
         // Undefined entry
         else
         {
            // Move tEntryLevel to the nearest line.
            if ((tEntryLevel - Bid) < (tEntryLevel - Ask)) tEntryLevel = Bid;
            else tEntryLevel = Ask;
         }
         ObjectSet("EntryLine", OBJPROP_PRICE1, tEntryLevel);
      }
   }
   
   if (EntryLevel - StopLossLevel == 0) return;

   // If could not find account currency, probably not connected.
   if ((AccountCurrency() == "") || (!TerminalInfoInteger(TERMINAL_CONNECTED))) return;
   else if (TickSize == -1) // Run only once.
   {
      GetSymbolAndAccountData();
   }

   tEntryLevel = Round(ObjectGet("EntryLine", OBJPROP_PRICE1), _Digits);
   tStopLossLevel = Round(ObjectGet("StopLossLine", OBJPROP_PRICE1), _Digits);
   tTakeProfitLevel = Round(ObjectGet("TakeProfitLine", OBJPROP_PRICE1), _Digits);
   
   if (ShowLineLabels)
   {
   	DrawPipsDifference("StopLossLabel", tStopLossLevel, tEntryLevel, sl_label_font_color);
   	if (tTakeProfitLevel > 0)
   	{
   		DrawPipsDifference("TakeProfitLabel", tTakeProfitLevel, tEntryLevel, tp_label_font_color);
   	}
  	}
   
   double StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * _Point;
   string WarningEntry = "", WarningSL = "", WarningTP = "";
   double AskBid = 0;
   if (EntryType == Instant)
   {
      if ((tStopLossLevel < Ask) && (tStopLossLevel > Bid)) WarningSL = " (Wrong value!)";
      else if (tStopLossLevel < Ask) AskBid = Ask;
      else if (tStopLossLevel > Bid) AskBid = Bid;
   }
   else if (EntryType == Pending)
   {
      if (tStopLossLevel < tEntryLevel) AskBid = Ask;
      else if (tStopLossLevel > tEntryLevel) AskBid = Bid;
      if (AskBid)
      {
         if (MathAbs(AskBid - tEntryLevel) < StopLevel) WarningEntry = " (Too close!)";
      }
      else WarningSL = " (Wrong value!)";
   }
   
   ObjectSetText("EntryLevel", "Entry Lvl:    " + JustifyRight(DoubleToString(tEntryLevel, _Digits), MaxNumberLength) + WarningEntry, font_size, font_face, entry_font_color);
   if (MathAbs(tStopLossLevel - tEntryLevel) < StopLevel) WarningSL = " (Too close!)";
   ObjectSetText("StopLoss", "Stop-Loss:    " + JustifyRight(DoubleToString(tStopLossLevel, _Digits), MaxNumberLength) + WarningSL, font_size, font_face, sl_font_color);
   if (tTakeProfitLevel > 0)
   {
      if (MathAbs(tTakeProfitLevel - tEntryLevel) < StopLevel) WarningTP = " (Too close!)";
      ObjectSetText("TakeProfit", "Take-Profit:  " + JustifyRight(DoubleToString(tTakeProfitLevel, _Digits), MaxNumberLength) + WarningTP, font_size, font_face, tp_font_color);
   }
   StopLoss = MathAbs(tEntryLevel - tStopLossLevel);
   if (StopLoss == 0)
   {
      Print("Stop-loss should be different from Entry.");
      return;
   }

   if (UseEquityInsteadOfBalance) Size = AccountEquity();
   else Size = AccountBalance();
   if (!HideAccSize) ObjectSetText("AccountSize", "Acc. " + SizeText + ": " + JustifyRight(FormatDouble(DoubleToString(Size, 2)), MaxNumberLength), font_size, font_face, balance_font_color);

   CalculateRiskAndPositionSize();
}

//+------------------------------------------------------------------+
//| Gets basic info on Symbol and Account. It remains unchanged.     |
//+------------------------------------------------------------------+
void GetSymbolAndAccountData()
{
   TickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
   MinLot = MarketInfo(Symbol(), MODE_MINLOT);
   MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   LotStep_digits = CountDecimalPlaces(LotStep);
   if (ShowMargin)
   {
      MarginMaintenance = MarketInfo(Symbol(), MODE_MARGINMAINTENANCE); // Used when non-zero
      MarginHedging = MarketInfo(Symbol(), MODE_MARGINHEDGED);
      LotSize = MarketInfo(Symbol(), MODE_LOTSIZE);
      AccStopoutMode = AccountStopoutMode();
      AccStopoutLevel = AccountStopoutLevel();
   }
}

//+------------------------------------------------------------------+
//| Calculates risk size and position size. Sets object values.      |
//+------------------------------------------------------------------+
void CalculateRiskAndPositionSize()
{
   double RiskMoney, PositionSize;
   double DisplayRisk = Risk;
   if (!UseMoneyInsteadOfPercentage)
   {
      RiskMoney = RoundDown(Size * Risk / 100, 2);
   }
   else
   {
      RiskMoney = MoneyRisk;
      if (Size != 0) DisplayRisk = Round(MoneyRisk / Size * 100, 2);
      else DisplayRisk = 0;
   }

   double UnitCost = MarketInfo(Symbol(), MODE_TICKVALUE);
   if ((StopLoss != 0) && (UnitCost != 0) && (TickSize != 0)) PositionSize = RoundDown(RiskMoney / (StopLoss * UnitCost / TickSize + 2 * CommissionPerLot), 2);
   
   OutputPositionSize = PositionSize;
   if (PositionSize < MinLot) OutputPositionSize = MinLot;
   else if (PositionSize > MaxLot) OutputPositionSize = MaxLot;
   double steps = OutputPositionSize / LotStep;
   if (MathFloor(steps) < steps) OutputPositionSize = MathFloor(steps) * LotStep;

   OutputRiskMoney = Round((StopLoss * UnitCost / TickSize + 2 * CommissionPerLot) * OutputPositionSize, 2);
   if ((!HideSecondRisk) || ((HideSecondRisk) && (UseMoneyInsteadOfPercentage))) ObjectSetText("RiskMoney", "Risk, money:  " + JustifyRight(FormatDouble(DoubleToString(RiskMoney, 2)), MaxNumberLength) + JustifyRight(FormatDouble(DoubleToString(OutputRiskMoney, 2)), MaxNumberLength), font_size, font_face, rmm_font_color);
   if ((!HideSecondRisk) || ((HideSecondRisk) && (!UseMoneyInsteadOfPercentage))) ObjectSetText("Risk", "Risk:         " + JustifyRight(DoubleToString(DisplayRisk, 2), MaxNumberLength) + "%" + JustifyRight(DoubleToString(Round(OutputRiskMoney / Size * 100, 2), 2), MaxNumberLength - 1) + "%", font_size, font_face, rp_font_color);
   ObjectSetText("PositionSize", "Pos. Size:    " + JustifyRight("", MaxNumberLength) + JustifyRight(DoubleToString(OutputPositionSize, LotStep_digits), MaxNumberLength), font_size, font_face, ps_font_color);

   if (tTakeProfitLevel > 0)
   {
      string RR, OutputRR;
      double OutputReward = RoundDown(MathAbs(MathRound((tTakeProfitLevel - tEntryLevel) * UnitCost / TickSize)) * OutputPositionSize, 2);
      // Have valid take-profit level that is above entry for SL below entry, or below entry for SL above entry.
      if (((tTakeProfitLevel > tEntryLevel) && (tEntryLevel > tStopLossLevel)) || ((tTakeProfitLevel < tEntryLevel) && (tEntryLevel < tStopLossLevel)))
      {
         RR = DoubleToString(RoundDown(MathAbs((tTakeProfitLevel - tEntryLevel) / StopLoss), 2), 2);
         OutputRR = DoubleToString(RoundDown(OutputReward / OutputRiskMoney, 2), 2);
      }
      else
      {
         RR = "Invalid TP";
         OutputRR = RR;
      }
      if (OutputRR == RR) RR = "";
      ObjectSetText("RR", "Reward/Risk:  " + JustifyRight(RR, MaxNumberLength) + JustifyRight(OutputRR, MaxNumberLength), font_size, font_face, rr_font_color);
      ObjectSetText("PotentialProfit", "Reward:       " + JustifyRight(FormatDouble(DoubleToString(RoundDown(RiskMoney * MathAbs((tTakeProfitLevel - tEntryLevel) / StopLoss), 2), 2)), MaxNumberLength) + JustifyRight(FormatDouble(DoubleToString(OutputReward, 2)), MaxNumberLength), font_size, font_face, pp_font_color);
   }
   if (ShowPortfolioRisk) CalculatePortfolioRisk();
   if (ShowMargin) CalculateMargin();
}

//+------------------------------------------------------------------+
//| Calculates risk size and position size. Sets object values.      |
//+------------------------------------------------------------------+
void CalculatePortfolioRisk()
{
   double PortfolioLossMoney = 0;
   int total = OrdersTotal();
   for (int i = 0; i < total; i++)
   {
      double PipsLoss = 0;
      // Select an order.
      if (!OrderSelect(i, SELECT_BY_POS)) continue;
      // No stop-loss.
      if (OrderStopLoss() == 0)
      {
         if (IgnoreOrdersWithoutStopLoss) continue;
         // Buy orders
         if (OrderType() == ORDER_TYPE_BUY)
         {
            // Losing all the current value
            PipsLoss = OrderOpenPrice();
         }
         // Sell orders
         else if (OrderType() == ORDER_TYPE_SELL)
         {
            // Potential loss is infinite
            PipsLoss = DBL_MAX;
         }
         else if (CountPendingOrders)
         {
            // Buy orders
            if ((OrderType() == ORDER_TYPE_BUY_LIMIT) || (OrderType() == ORDER_TYPE_BUY_STOP))
            {
               // Losing all the current value
               PipsLoss = OrderOpenPrice();
            }
            // Sell orders
            else if ((OrderType() == ORDER_TYPE_SELL_LIMIT) || (OrderType() == ORDER_TYPE_SELL_STOP))
            {
               // Potential loss is infinite
               PipsLoss = DBL_MAX;
            }
         }
      }
      else
      // Some sotp-loss
      {
         // Buy orders
         if (OrderType() == ORDER_TYPE_BUY)
         {
            // Stop-loss below open price.
            PipsLoss = OrderOpenPrice() - OrderStopLoss();
         }
         // Sell orders
         else if (OrderType() == ORDER_TYPE_SELL)
         {
            // Stop-loss above open price.
            PipsLoss = OrderStopLoss() - OrderOpenPrice();
         }
         else if (CountPendingOrders)
         {
            // Buy orders
            if ((OrderType() == ORDER_TYPE_BUY_LIMIT) || (OrderType() == ORDER_TYPE_BUY_STOP))
            {
               // Stop-loss below open price.
               PipsLoss = OrderOpenPrice() - OrderStopLoss();
            }
            // Sell orders
            else if ((OrderType() == ORDER_TYPE_SELL_LIMIT) || (OrderType() == ORDER_TYPE_SELL_STOP))
            {
               // Stop-loss above open price.
               PipsLoss = OrderStopLoss() - OrderOpenPrice();
            }
         }
      }
      
      if (PipsLoss != DBL_MAX)
      {
         double UnitCost = MarketInfo(OrderSymbol(), MODE_TICKVALUE);
         double TickSize_local = MarketInfo(OrderSymbol(), MODE_TICKSIZE);
         if (TickSize_local > 0) PortfolioLossMoney += OrderLots() * PipsLoss * UnitCost / TickSize_local;
      }
      else
      // Infinite loss
      {
         PortfolioLossMoney = DBL_MAX;
         break;
      }
   }
   
   // If account size did not load yet.
   if (Size == 0) return;
   
   string PLM;
   if (PortfolioLossMoney == DBL_MAX) PLM = "      Infinity";
   else PLM = JustifyRight(FormatDouble(DoubleToString(PortfolioLossMoney, 2)), MaxNumberLength);
   ObjectSetText("CurrentPortfolioMoneyRisk", "Current Portfolio Money Risk:   " + PLM, font_size, font_face, rmm_font_color);
   string CPR;
   if (PortfolioLossMoney == DBL_MAX) CPR = "      Infinity";
   else CPR = JustifyRight(DoubleToString(PortfolioLossMoney / Size * 100, 2), MaxNumberLength);
   ObjectSetText("CurrentPortfolioRisk", "Current Portfolio Risk:         " + CPR + "%", font_size, font_face, rp_font_color);

   string PPMR;
   if (PortfolioLossMoney == DBL_MAX) PPMR = "      Infinity";
   else PPMR = JustifyRight(FormatDouble(DoubleToString(PortfolioLossMoney + OutputRiskMoney, 2)), MaxNumberLength);
   ObjectSetText("PotentialPortfolioMoneyRisk", "Potential Portfolio Money Risk: " + PPMR, font_size, font_face, rmm_font_color);
   string PPR;
   if (PortfolioLossMoney == DBL_MAX) PPR = "      Infinity";
   else PPR = JustifyRight(DoubleToString((PortfolioLossMoney + OutputRiskMoney) / Size * 100, 2), MaxNumberLength);
   ObjectSetText("PotentialPortfolioRisk", "Potential Portfolio Risk:       " + PPR + "%", font_size, font_face, rp_font_color);
}

//+------------------------------------------------------------------+
//| Calculates margin before and after position.                     |
//+------------------------------------------------------------------+
void CalculateMargin()
{
   int dir;
   if (tStopLossLevel < tEntryLevel) dir = OP_BUY;
   else if (tStopLossLevel > tEntryLevel) dir = OP_SELL;
   else return;

   double Margin1Lot;
   double ContractSize;

   if (MarginMaintenance == 0)
   {
      Margin1Lot = MarketInfo(Symbol(), MODE_MARGINREQUIRED);
      ContractSize = LotSize;
   }
   else
   {
      Margin1Lot = MarginMaintenance;
      ContractSize = MarginMaintenance;
   }

   double HedgedRatio = MarginHedging / ContractSize;
   double PositionMargin = OutputPositionSize * Margin1Lot;
   double _PositionMargin = PositionMargin;
   
   // Hedging on partial or no margin.
   if (NormalizeDouble(HedgedRatio, 2) < 1.00)
   {
      // Cycle through all open orders on this Symbol to find directional volume
      double volume = 0;
      int type = -1;
      int total = OrdersTotal();
      for (int i = 0; i < total; i++)
      {
         if (!OrderSelect(i, SELECT_BY_POS)) continue;
   
         if (OrderSymbol() != Symbol()) continue;
         
         if (OrderType() == OP_BUY)
         {
            if (type == OP_BUY) volume += OrderLots();
            else if (type == OP_SELL)
            {
               volume -= OrderLots();
               if (volume < 0)
               {
                  type = OP_BUY;
                  volume = -volume;
               }
            }
            else if (type == -1)
            {
               volume = OrderLots();
               type = OP_BUY;
            }
         }
         else if (OrderType() == OP_SELL)
         {
            if (type == OP_SELL) volume += OrderLots();
            else if (type == OP_BUY)
            {
               volume -= OrderLots();
               if (volume < 0)
               {
                  type = OP_SELL;
                  volume = -volume;
               }
            }
            else if (type == -1)
            {
               volume = OrderLots();
               type = OP_SELL;
            }
         }
      }
      // There is position to hedge and new position is in opposite direction.
      if ((volume > 0) && (type != dir))
      {
         double calculated_volume;
         if (OutputPositionSize <= volume) calculated_volume = OutputPositionSize * (HedgedRatio - 1);
         else calculated_volume = volume * HedgedRatio + OutputPositionSize - 2 * volume;
         PositionMargin = calculated_volume * Margin1Lot;
         _PositionMargin = PositionMargin;
      }
   }
   
   double UsedMargin = AccountMargin() + _PositionMargin;
   ObjectSetText("PositionMargin", "Position Margin:    " + JustifyRight(FormatDouble(DoubleToString(NormalizeDouble(PositionMargin, 2), 2)), MaxNumberLength), font_size, font_face, margin_font_color);
   ObjectSetText("FutureUsedMargin", "Future Used Margin: " + JustifyRight(FormatDouble(DoubleToString(UsedMargin, 2)), MaxNumberLength), font_size, font_face, margin_font_color);

   color mod_margin_font_color = margin_font_color;
   double FutureMargin = RoundDown(AccountFreeMargin() - PositionMargin, 2);
   double _FutureMargin = RoundDown(AccountFreeMargin() - _PositionMargin, 2);
   string MarginSuffix = "";
   
   // Percentage mode.
   if (AccStopoutMode == 0)
   {
      double ML = 0;
      
      if (UsedMargin != 0) ML = AccountEquity() / UsedMargin * 100;
      if ((ML > 0) && (ML <= AccStopoutLevel)) mod_margin_font_color = stopout_font_color;
   }
   // Absolute value mode.
   else
   {
      if (_FutureMargin <= AccStopoutLevel) mod_margin_font_color = stopout_font_color;
   }
   
   if (_FutureMargin < 0) mod_margin_font_color = stopout_font_color;
   if (_FutureMargin < FutureMargin)
   {
      if (mod_margin_font_color == stopout_font_color) MarginSuffix = " (" + FormatDouble(DoubleToString(_FutureMargin, 2)) + ")";
   }

   ObjectSetText("FutureFreeMargin", "Future Free Margin: " + JustifyRight(FormatDouble(DoubleToString(FutureMargin, 2)), MaxNumberLength) + MarginSuffix, font_size, font_face, mod_margin_font_color);
}

//+------------------------------------------------------------------+
//| Round down a double value to a given decimal place.              |
//+------------------------------------------------------------------+
double RoundDown(const double value, const double digits)
{
   int norm = MathPow(10, digits);
   return(MathFloor(value * norm) / norm);
}

//+------------------------------------------------------------------+
//| Round a double value to a given decimal place.                   |
//+------------------------------------------------------------------+
double Round(const double value, const double digits)
{
   int norm = MathPow(10, digits);
   return(MathRound(value * norm) / norm);
}

//+------------------------------------------------------------------+
//| Justify a string to the right adding enough spaces to the left.  |
//| length - target length of the resulting string.                  |
//+------------------------------------------------------------------+
string JustifyRight(string str, const int length = 14)
{
   int difference = length - StringLen(str);
   if (difference < 0) return("Error: String is longer than target length.");
   
   for (int i = 0; i < difference; i++) str = StringConcatenate(" ", str);
   
   return(str);
}

//+------------------------------------------------------------------+
//| Formats double with thousands separator.                         |
//+------------------------------------------------------------------+
string FormatDouble(const string number)
{
   // Find "." position.
   int pos = StringFind(number, ".");
   string integer = StringSubstr(number, 0, pos);
   string decimal = StringSubstr(number, pos, 3);
   string formatted = "";
   string comma = "";
   
   while (StringLen(integer) > 3)
   {
      int length = StringLen(integer);
      string group = StringSubstr(integer, length - 3, 0);
      formatted = group + comma + formatted;
      comma = ",";
      integer = StringSubstr(integer, 0, length - 3);
   }
   if (integer == "-") comma = "";
   if (integer != "") formatted = integer + comma + formatted;
   
   return(formatted + decimal);
}

//+------------------------------------------------------------------+
//| Counts decimal places.                                           |
//+------------------------------------------------------------------+
int CountDecimalPlaces(double number)
{
   // 100 as maximum length of number.
   for (int i = 0; i < 100; i++)
   {
		if (MathAbs(MathRound(number) - number) <= FLT_EPSILON) return(i);
      number *= 10;
   }
   return(-1);
}

//+------------------------------------------------------------------+
//| Draws a pips distance for SL or TP.                              |
//+------------------------------------------------------------------+
void DrawPipsDifference(string label, double price1, double price2, color col)
{
   int x, y, real_x;
   uint w, h;
	string pips = IntegerToString((int)MathRound((MathAbs(price1 - price2) / Point)));

	ObjectSetText(label, pips, font_size, font_face, col);
   real_x = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS) - 2;
   // Needed only for y, x is derived from the chart width.
   ChartTimePriceToXY(0, 0, Time[0], price1, x, y);
   // Get the width of the text based on font and its size. Negative because OS-dependent, *10 because set in 1/10 of pt.
   TextSetFont(font_face, -font_size * 10);
   TextGetSize(pips, w, h);
   ObjectSet(label, OBJPROP_XDISTANCE, real_x - w);
   ObjectSet(label, OBJPROP_YDISTANCE, y);
}
//+------------------------------------------------------------------+