//+------------------------------------------------------------------+
//|                                                 	PSC-Trader.mq4 |
//|                               Copyright 2015-2017, EarnForex.com |
//|                                        https://www.earnforex.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2017, EarnForex.com"
#property link      "https://www.earnforex.com/metatrader-indicators/Position-Size-Calculator/"
#property version   "1.05"
#property strict
#include <stdlib.mqh>

/*

This script works with Position Size Calculator indicator:
https://www.earnforex.com/metatrader-indicators/Position-Size-Calculator/
It works both with the new version (graphical panel) and legacy version (text labels).

It can open pending or instant orders using the position size calculated by PSC.

Works with Market Execution (ECN) too - first opens the order, then sets SL/TP.

You can control script settings via Position Size Calculator panel (Script tab).

*/

bool DisableTradingWhenLinesAreHidden;
int MaxSlippage = 0, MaxSpread, MaxEntrySLDistance, MinEntrySLDistance, MagicNumber = 0;
double MaxPositionSize;

string Commentary = "PSC-Trader";

enum ENTRY_TYPE
{
   Instant,
   Pending
};

//+------------------------------------------------------------------+
//| Script execution function.                                       |
//+------------------------------------------------------------------+
void OnStart()
{
   int Window;

   string ps = ""; // Position size string.
   double el = 0, sl = 0, tp = 0; // Entry level, stop-loss, and take-profit.
   int ot; // Order type.
   ENTRY_TYPE entry_type;

   Window = WindowFind("Position Size Calculator" + IntegerToString(ChartID()));
   if (Window == -1)
   {
      // Trying to find the new version's position size object.
      ps = FindEditObjectByPostfix("m_EdtPosSize");
      ps = ObjectGetString(0, ps, OBJPROP_TEXT);
      // Trying to find the legacy version's position size object.
     	if (StringLen(ps) == 0) ps = ObjectGetString(0, "PositionSize", OBJPROP_TEXT);
	   if (StringLen(ps) == 0)
      {
         Alert("Position Size Calculator not found!");
         return;
      }
   }

	if (StringLen(ps) == 0)
	{
		// Trying to find the new version's position size object.
	   ps = FindEditObjectByPostfix("m_EdtPosSize");
	   ps = ObjectGetString(0, ps, OBJPROP_TEXT);
	   // Trying to find the legacy version's position size object.
	   if (StringLen(ps) == 0) ps = ObjectGetString(0, "PositionSize", OBJPROP_TEXT);
		if (StringLen(ps) == 0)
	   {
	      Alert("Position Size object not found!");
	      return;
	   }
	}
   int len = StringLen(ps);
   string ps_proc = "";
   for (int i = len - 1; i >= 0; i--)
   {
      string c = StringSubstr(ps, i, 1);
      if (c != " ") ps_proc = c + ps_proc;
      else break;
   }
   
   double PositionSize = StringToDouble(ps_proc);
   
   Print("Detected position size: ", DoubleToString(PositionSize, 2), ".");

   if (PositionSize <= 0)
   {
      Print("Wrong position size value!");
      return;
   }
   
   el = ObjectGetDouble(0, "EntryLine", OBJPROP_PRICE);
   if (el <= 0)
   {
      Alert("Entry Line not found!");
      return;
   }
   
   el = NormalizeDouble(el, Digits);
   Print("Detected entry level: ", DoubleToString(el, Digits), ".");

   RefreshRates();
   
   if ((el == Ask) || (el == Bid)) entry_type = Instant;
   else entry_type = Pending;
   
   Print("Detected entry type: ", EnumToString(entry_type), ".");
   
   sl = ObjectGetDouble(0, "StopLossLine", OBJPROP_PRICE);
   if (sl <= 0)
   {
      Alert("Stop-Loss Line not found!");
      return;
   }
   
   sl = NormalizeDouble(sl, Digits);
   Print("Detected stop-loss level: ", DoubleToString(sl, Digits), ".");
   
   tp = ObjectGetDouble(0, "TakeProfitLine", OBJPROP_PRICE);
   if (tp > 0)
   {
      tp = NormalizeDouble(tp, Digits);
      Print("Detected take-profit level: ", DoubleToString(tp, Digits), ".");
   }
   else Print("No take-profit detected.");
   
	// Magic number
   string EdtMagicNumber = FindEditObjectByPostfix("m_EdtMagicNumber");
   if (EdtMagicNumber != "") MagicNumber = (int)StringToInteger(ObjectGetString(0, EdtMagicNumber, OBJPROP_TEXT));
   Print("Magic number = ", MagicNumber);

	// Order commentary
   string EdtScriptCommentary = FindEditObjectByPostfix("m_EdtScriptCommentary");
   if (EdtScriptCommentary != "") Commentary = ObjectGetString(0, EdtScriptCommentary, OBJPROP_TEXT);
   Print("Order commentary = ", Commentary);

   // Checkbox
   string ChkDisableTradingWhenLinesAreHidden = FindCheckboxObjectByPostfix("m_ChkDisableTradingWhenLinesAreHiddenButton");
   if (ChkDisableTradingWhenLinesAreHidden != "") DisableTradingWhenLinesAreHidden = ObjectGetInteger(0, ChkDisableTradingWhenLinesAreHidden, OBJPROP_STATE);
   Print("Disable trading when lines are hidden = ", DisableTradingWhenLinesAreHidden);

	// Entry line
   bool EntryLineHidden = false;
   int EL_Hidden = (int)ObjectGetInteger(0, "EntryLine", OBJPROP_TIMEFRAMES);
   if (EL_Hidden == OBJ_NO_PERIODS) EntryLineHidden = true; 
   Print("Entry line hidden = ", EntryLineHidden);

	if ((DisableTradingWhenLinesAreHidden) && (EntryLineHidden))
	{
		Print("Not taking a trade - lines are hidden, and indicator says not to trade when they are hidden.");
		return;
	}

	// Other fuses
   string EdtMaxSlippage = FindEditObjectByPostfix("m_EdtMaxSlippage");
   if (EdtMaxSlippage != "") MaxSlippage = (int)StringToInteger(ObjectGetString(0, EdtMaxSlippage, OBJPROP_TEXT));
   Print("Max slippage = ", MaxSlippage);

   string EdtMaxSpread = FindEditObjectByPostfix("m_EdtMaxSpread");
   if (EdtMaxSpread != "") MaxSpread = (int)StringToInteger(ObjectGetString(0, EdtMaxSpread, OBJPROP_TEXT));
   Print("Max spread = ", MaxSpread);
   
   if (MaxSpread > 0)
   {
	   int spread = (int)((Ask - Bid) / Point);
	   if (spread > MaxSpread)
	   {
			Print("Not taking a trade - current spread (", spread, ") > maximum spread (", MaxSpread, ").");
			return;
	   }
	}
	
   string EdtMaxEntrySLDistance = FindEditObjectByPostfix("m_EdtMaxEntrySLDistance");
   if (EdtMaxEntrySLDistance != "") MaxEntrySLDistance = (int)StringToInteger(ObjectGetString(0, EdtMaxEntrySLDistance, OBJPROP_TEXT));
   Print("Max Entry/SL distance = ", MaxEntrySLDistance);

   if (MaxEntrySLDistance > 0)
   {
	   int CurrentEntrySLDistance = (int)(MathAbs(sl - el) / Point);
	   if (CurrentEntrySLDistance > MaxEntrySLDistance)
	   {
			Print("Not taking a trade - current Entry/SL distance (", CurrentEntrySLDistance, ") > maximum Entry/SL distance (", MaxEntrySLDistance, ").");
			return;
	   }
	}
	
   string EdtMinEntrySLDistance = FindEditObjectByPostfix("m_EdtMinEntrySLDistance");
   if (EdtMinEntrySLDistance != "") MinEntrySLDistance = (int)StringToInteger(ObjectGetString(0, EdtMinEntrySLDistance, OBJPROP_TEXT));
   Print("Min Entry/SL distance = ", MinEntrySLDistance);

   if (MinEntrySLDistance > 0)
   {
	   int CurrentEntrySLDistance = (int)(MathAbs(sl - el) / Point);
	   if (CurrentEntrySLDistance < MinEntrySLDistance)
	   {
			Print("Not taking a trade - current Entry/SL distance (", CurrentEntrySLDistance, ") < minimum Entry/SL distance (", MinEntrySLDistance, ").");
			return;
	   }
	}
	
   string EdtMaxPositionSize = FindEditObjectByPostfix("m_EdtMaxPositionSize");
   if (EdtMaxPositionSize != "") MaxPositionSize = StringToDouble(ObjectGetString(0, EdtMaxPositionSize, OBJPROP_TEXT));
   Print("Max position size = ", DoubleToString(MaxPositionSize, 2));
	   
   if (MaxPositionSize > 0)
   {
	   if (PositionSize > MaxPositionSize)
	   {
			Print("Not taking a trade - position size (", PositionSize, ") > maximum position size (", MaxPositionSize, ").");
			return;
	   }
	}
	
	ENUM_SYMBOL_TRADE_EXECUTION Execution_Mode = (ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(Symbol(), SYMBOL_TRADE_EXEMODE);
	Print("Execution mode: ", EnumToString(Execution_Mode));

   if (entry_type == Pending)
   {
      // Sell
      if (sl > el)
      {
         // Stop
         if (el < Bid) ot = OP_SELLSTOP;
         // Limit
         else ot = OP_SELLLIMIT;
      }
      // Buy
      else
      {
         // Stop
         if (el > Ask) ot = OP_BUYSTOP;
         // Limit
         else ot = OP_BUYLIMIT;
      }
   }
   // Instant
   else
   {
      // Sell
      if (sl > el) ot = OP_SELL;
      // Buy
      else ot = OP_BUY;
   }
   
   double order_sl = sl;
   double order_tp = tp;      

	// Market execution mode - preparation.
	if ((Execution_Mode == SYMBOL_TRADE_EXECUTION_MARKET) && (entry_type == Instant))
	{
		// No SL/TP allowed on instant orders.
		order_sl = 0;
		order_tp = 0;
	}
	
   int ticket = OrderSend(Symbol(), ot, PositionSize, el, MaxSlippage, order_sl, order_tp, Commentary, MagicNumber);
   if (ticket == -1)
      Print("Execution failed. Error: ", ErrorDescription(GetLastError()), ".");
   else Print("Order executed. Ticket: ", ticket, ".");

	// Market execution mode - applying SL/TP.
	if ((Execution_Mode == SYMBOL_TRADE_EXECUTION_MARKET) && (entry_type == Instant) && (ticket != -1))
	{
		if (!OrderSelect(ticket, SELECT_BY_TICKET))
		{
			Print("Failed to find the order to apply SL/TP.");
			return;
		}
		for (int i = 0; i < 10; i++)
		{
		   bool result = OrderModify(ticket, OrderOpenPrice(), sl, tp, OrderExpiration());
		   if (result) break;
		   else Print("Error modifying the order: ", GetLastError());
		}
	}
}

string FindEditObjectByPostfix(const string postfix)
{
	int obj_total = ObjectsTotal(0, 0, OBJ_EDIT);
	string name = "";
	bool found = false;
	for (int i = 0; i < obj_total; i++)
	{
		name = ObjectName(0, i, 0, OBJ_EDIT);
		string pattern = StringSubstr(name, StringLen(name) - StringLen(postfix));
		if (StringCompare(pattern, postfix) == 0)
		{
			found = true;
			break;
		}
	}
	if (found) return(name);
	else return("");
}

string FindCheckboxObjectByPostfix(const string postfix)
{
	int obj_total = ObjectsTotal(0, 0, OBJ_BITMAP_LABEL);
	string name = "";
	bool found = false;
	for (int i = 0; i < obj_total; i++)
	{
		name = ObjectName(0, i, 0, OBJ_BITMAP_LABEL);
		string pattern = StringSubstr(name, StringLen(name) - StringLen(postfix));
		if (StringCompare(pattern, postfix) == 0)
		{
			found = true;
			break;
		}
	}
	if (found) return(name);
	else return("");
}
//+------------------------------------------------------------------+