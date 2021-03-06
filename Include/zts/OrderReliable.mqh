//=============================================================================
//						OrderReliable.mqh
//
//	A library for MT4 expert advisors, intended to give more reliable 
//	order handling.	This is under development.
//
//						  Instructions:
//
//  Put this file in the experts/include directory.
//  Include the line:
//
//	  #include <OrderReliable_V?_?_?.mqh>
// 
//	...in the beginning of your EA with the question marks replaced by the 
//	actual version number (in file name) of the library, i.e. this file.  
// 
//	YOU MUST EDIT THE EA MANUALLY IN ORDER TO USE THIS LIBRARY, BY BOTH 
//	SPECIFYING THE INCLUDE FILE AND THEN MODIFYING THE EA CODE TO USE 
//	THE FUNCTIONS.  
//
//	In particular you must change, in the EA, OrderSend() commands to 
//	OrderSendReliable() and OrderModify() commands to OrderModifyReliable(), 
//	or any others which are appropriate.
//
//	DO NOT COMPILE THIS FILE ON ITS OWN.  It is meaningless.  You only
//	compile your "main" EA. 
//
//=============================================================================
//
//  Version:	0.2.5
//
//  Contents:
//
//		OrderSendReliable()  
//			This is intended to be a drop-in replacement for OrderSend() 
//			which, one hopes is more resistant to various forms of errors 
//			prevalent with MetaTrader.
//
//		OrderModifyReliable
//			A replacement for OrderModify with more error handling, similar 
//			to OrderSendReliable()
//
//		OrderModifyReliableSymbol()
//			Adds a "symbol" field to OrderModifyReliable (not drop in any 
//			more) so that it can fix problems with stops/take profits which 
//			are too close to market, as well as normalization problems.
// 
//		OrderCloseReliable
//			A replacement for OrderClose with more error handling, similar 
//			to OrderSendReliable()
//
//		OrderReliableLastErr()
//			Returns the last error seen by an Order*Reliable() call.
//			NOTE: GetLastError()  WILL NOT WORK to return the error
//			after a call.  This is a flaw in Metatrader design, in that
//			GetLastError() also clears it.  Hence in this way
//			this library cannot be a total drop-in replacement.
// 
//===========================================================================
//  History:
//
//	2006-07-19: 0.2.5:	Modified by Derk Wehler
//						Cleaned up commenting and code, to make more 
//						readable; added additional comments
//						Added OrderCloseReliable(), modeling largely 
//						after OrderModifyReliable()
//
//	2006-07-14: 0.2.4:	ERR_TRADE_TIMEOUT now a retryable error for modify	
//						only.  Unclear about what to do for send. 
//						Adds OrderReliableLastErr()
//
//	2006-06-07: 0.2.3:	Version number now in log comments.  Docs updated.	
//						OP_BUYLIMIT/OP_SELLLIMIT added. Increase retry time
//
//	2006-06-07: 0.2.2:	Fixed int/bool type mismatch compiler ignored
//
//	2006-06-06: 0.2.1:	Returns success if modification is redundant
//
//	2006-06-06: 0.2.0:	Added OrderModifyReliable
//
//	2006-06-05: 0.1.2:	Fixed idiotic typographical bug.
//
//	2006-06-05:	0.1.1:	Added ERR_TRADE_CONTEXT_BUSY to retryable errors.
//
//	2006-05-29: 0.1:	Created.  Only OrderSendReliable() implemented.
//		 
//	LICENSING:  This is free, open source software, licensed under
//				Version 2 of the GNU General Public License (GPL). 
// 
// In particular, this means that distribution of this software in a binary 
// format, e.g. as compiled in as part of a .ex4format, must be accompanied
// by the non-obfuscated source code of both this file, AND the .mq4 source 
// files which it is compiled with, or you must make such files available at 
// no charge to binary recipients.	If you do not agree with such terms you 
// must not use this code.  Detailed terms of the GPL are widely available 
// on the Internet.  The Library GPL (LGPL) was intentionally not used, 
// therefore the source code of files which link to this are subject to
// terms of the GPL if binaries made from them are publicly distributed or 
// sold. 
//  
// Copyright (2006), Matthew Kennel
//===========================================================================

#property strict
#include <stdlib.mqh>
#include <stderror.mqh> 

string OrderReliableVersion = "Z0_0_1"; 

int retry_attempts 		= 10; 
double sleep_time 		= 2.0;
double sleep_maximum 	= 10.0;  // in seconds

string OrderReliable_Fname = "OrderReliable fname unset";

static int _OR_err = 0;



//=============================================================================
//							 OrderSendReliable()
//
//	This is intended to be a drop-in replacement for OrderSend() which, 
//	one hopes, is more resistant to various forms of errors prevalent 
//	with MetaTrader.
//			  
//	RETURN VALUE: 
//
//	Ticket number or -1 under some error conditions. 
//
//
//	FEATURES:
//
//		 * Re-trying under some error conditions, sleeping a random 
//		   time defined by an exponential probability distribution.
//
//		 * Automatic normalization of Digits
//
//		 * Automatically makes sure that stop levels are more than
//		   the minimum stop distance, as given by the server. If they
//		   are too close, they are adjusted.
//
//		 * Automatically converts limit orders to market orders 
//		   when the limit orders are rejected by the server for 
//		   being to close to market.
//
//		 * Displays various error messages on the log for debugging.
//
//
//	Matt Kennel, mbkennel@gmail.com  	2006-05-28
//
//=============================================================================
int OrderSendReliable(string symbol, int cmd, double volume, double price,
					  int slippage, double stoploss, double takeprofit,
					  string comment, int _magic, datetime expiration = 0, 
					  color arrow_color = CLR_NONE) {
  static bool bridge=false;
  double servers_min_stop;
  // ------------------------------------------------
  // Check basic conditions see if trade is possible. 
  // ------------------------------------------------
  OrderReliable_Fname = "OrderSendReliable";
  OrderReliablePrint("attempted " + OrderReliable_CommandString(cmd) + " " + string(volume) + 
                     " lots @" + string(price) + " sl:" + string(stoploss) + " tp:" + string(takeprofit)); 
  // limit/stop order. 
  int ticket=-1;
  int err = GetLastError(); // clear the global variable.
   
  if(bridge==true) {
    Print("This broker uses a bridge, bridge = ",bridge," Ln 171");
    Print("bridge = ",bridge," Ln 172, stoploss = ",stoploss,", takeprofit = ",takeprofit);
    ticket = OrderReSendReliable(symbol, cmd, volume, price, slippage, 0, 0, comment, _magic, expiration, arrow_color);
    Print("ticket = ",ticket," Ln 174, stoploss = ",stoploss,", takeprofit = ",takeprofit);
    if(!OrderSelect(ticket, SELECT_BY_TICKET))
      Print(__FUNCTION__,": OrderSelect NOT successful");
    Print("OrderReSendReliable ticket = ",OrderTicket(),", price = ",OrderOpenPrice(),", stoploss = ",stoploss,", takeprofit = ",takeprofit);
    if(ticket!=-1) 
      OrderModifyReliable(ticket, price, stoploss, takeprofit, expiration);
    if(!OrderSelect(ticket, SELECT_BY_TICKET))
          Print(__FUNCTION__,": OrderSelect NOT successful");
    Print("OrderModifyReliable ticket = ",OrderTicket(),", price = ",OrderOpenPrice(),", stoploss = ",OrderStopLoss(),", takeprofit = ",OrderTakeProfit());
    err = GetLastError();
    _OR_err = err;
	 return(ticket); // SUCCESS!
  }
   
/*	
  if (!IsConnected()) {
    OrderReliablePrint("error: IsConnected() == false");
    _OR_err = ERR_NO_CONNECTION;
    return(-1);
  }
*/	
  if (IsStopped()) {
    OrderReliablePrint("error: IsStopped() == true");
    _OR_err = ERR_COMMON_ERROR; 
    return(-1);
  }

  int cnt = 0;
  while(!IsTradeAllowed() && cnt < retry_attempts) {
    OrderReliable_SleepRandomTime(5*sleep_time, 12*sleep_maximum); 
    cnt++;
  }
	
  if (!IsTradeAllowed()) {
    OrderReliablePrint("error: no operation possible because IsTradeAllowed()==false, even after retries.");
    _OR_err = ERR_TRADE_CONTEXT_BUSY; 
    return(-1);  
  }

  // Normalize all price / stoploss / takeprofit to the proper # of digits.
  int digits = int(MarketInfo(symbol, MODE_DIGITS));
  if (digits > 0) {
    price = NormalizeDouble(price, digits);
    stoploss = NormalizeDouble(stoploss, digits);
    takeprofit = NormalizeDouble(takeprofit, digits); 
  }
	
  if (stoploss != 0) 
    OrderReliable_EnsureValidStop(cmd,symbol, price, stoploss);
  err = 0; 
  _OR_err = 0; 
  bool exit_loop = false;
  bool limit_to_market = false; 
	
  if ((cmd == OP_BUYSTOP) || (cmd == OP_SELLSTOP) || (cmd == OP_BUYLIMIT) || (cmd == OP_SELLLIMIT)) {
    cnt = 0;
    while (!exit_loop) {
      if (IsTradeAllowed()) {
        ticket = OrderSend(symbol, cmd, volume, price, slippage, stoploss, 
                           takeprofit, comment, _magic, expiration, arrow_color);
        err = GetLastError();
        _OR_err = err; 
      } 
      else {
        cnt++;
      }

      switch (err) {
        case ERR_NO_ERROR:
          exit_loop = true;
          break;

        // retryable errors
        case ERR_SERVER_BUSY:
        case ERR_NO_CONNECTION:
        case ERR_INVALID_PRICE:
        case ERR_OFF_QUOTES:
        case ERR_BROKER_BUSY:
        case ERR_TRADE_CONTEXT_BUSY: 
          cnt++; 
          break;
        case ERR_PRICE_CHANGED:
        case ERR_REQUOTE:
          RefreshRates();
          continue;	// we can apparently retry immediately according to MT docs.
        case ERR_INVALID_STOPS:
          servers_min_stop = MarketInfo(symbol, MODE_STOPLEVEL) * MarketInfo(symbol, MODE_POINT); 
          if (cmd == OP_BUYSTOP) {
            // If we are too close to put in a limit/stop order so go to market.
            if (MathAbs(Ask - price) <= servers_min_stop)	
              limit_to_market = true; 

          } 
          else if (cmd == OP_SELLSTOP) {
            // If we are too close to put in a limit/stop order so go to market.
            if (MathAbs(Bid - price) <= servers_min_stop)
              limit_to_market = true; 
          }
          exit_loop = true; 
          break; 
        default:
          // an apparently serious error.
          exit_loop = true;
          break; 
      }  // end switch 

      if (cnt > retry_attempts) 
        exit_loop = true; 

      if (exit_loop) {
        if (err != ERR_NO_ERROR) {
          OrderReliablePrint("non-retryable error: " + OrderReliableErrTxt(err));
        }
        if (cnt > retry_attempts) {
          OrderReliablePrint("retry attempts maxed at " + string(retry_attempts)); 
        }
      }
      if (!exit_loop) {
        OrderReliablePrint("retryable error (" + string(cnt) + "/" + string(retry_attempts) + 
                           "): " + OrderReliableErrTxt(err)); 
        OrderReliable_SleepRandomTime(sleep_time, sleep_maximum); 
        RefreshRates(); 
      }
    }
		 
    // We have now exited from loop. 
    if (err == ERR_NO_ERROR) {
      //OrderReliablePrint("apparently successful OP_BUYSTOP or OP_SELLSTOP order placed, details follow.");
      //OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES); 
      //OrderPrint(); 
      return(ticket); // SUCCESS! 
    } 
    if (!limit_to_market) {
      OrderReliablePrint("failed to execute stop or limit order after " + string(cnt) + " retries");
      OrderReliablePrint("failed trade: " + OrderReliable_CommandString(cmd) + " " + symbol + 
                         "@" + string(price) + " tp@" + string(takeprofit) + " sl@" + string(stoploss)); 
      OrderReliablePrint("last error: " + OrderReliableErrTxt(err)); 
      return(-1); 
    }
  }  // end	  
  
  if (limit_to_market) {
    OrderReliablePrint("going from limit order to market order because market is too close.");
    if ((cmd == OP_BUYSTOP) || (cmd == OP_BUYLIMIT)) {
      cmd = OP_BUY;
      price = Ask;
    } 
    else if ((cmd == OP_SELLSTOP) || (cmd == OP_SELLLIMIT)) {
      cmd = OP_SELL;
      price = Bid;
    }	
  }
	
  // we now have a market order.
  err = GetLastError(); // so we clear the global variable.  
  err = 0; 
  _OR_err = 0; 
  ticket = -1;

  if ((cmd == OP_BUY) || (cmd == OP_SELL)) {
    cnt = 0;
    while (!exit_loop) {
      if (IsTradeAllowed()) {
        RefreshRates();
        if (cmd == OP_BUY) {
          price = Ask;
        }
        else if (cmd == OP_SELL) {
          price = Bid;
        }
        if(bridge==false) {
          ticket = OrderSend(symbol, cmd, volume, price, slippage, 
                             stoploss, takeprofit, comment, _magic, 
                             expiration, arrow_color);
          err = GetLastError();
          _OR_err = err;
        }
        if(err==ERR_INVALID_STOPS) {
//        Print("This broker uses a bridge, bridge = ",bridge," Ln 382");
          bridge=true;
//        Print("bridge = ",bridge," Ln 384, stoploss = ",stoploss,", takeprofit = ",takeprofit);
          ticket = OrderReSendReliable(symbol, cmd, volume, price, slippage, 0, 0, comment, _magic, expiration, arrow_color);
//        Print("ticket = ",ticket," Ln 386, stoploss = ",stoploss,", takeprofit = ",takeprofit);
          if(!OrderSelect(ticket, SELECT_BY_TICKET))
            Print(__FUNCTION__,": OrderSelect NOT successful");

//        Print("OrderReSendReliable ticket = ",OrderTicket(),", price = ",OrderOpenPrice(),", stoploss = ",stoploss,", takeprofit = ",takeprofit);
          if(ticket!=-1) OrderModifyReliable(ticket, price, stoploss, takeprofit, expiration);
          if(!OrderSelect(ticket, SELECT_BY_TICKET))
                Print(__FUNCTION__,": OrderSelect NOT successful");

//        Print("OrderModifyReliable ticket = ",OrderTicket(),", price = ",OrderOpenPrice(),", stoploss = ",OrderStopLoss(),", takeprofit = ",OrderTakeProfit());
          err = GetLastError();
          _OR_err = err;
        }
      } else {
        cnt++;
      } 
      switch (err) {
        case ERR_NO_ERROR:
          exit_loop = true;
          break;
        case ERR_SERVER_BUSY:
        case ERR_NO_CONNECTION:
        case ERR_INVALID_PRICE:
        case ERR_OFF_QUOTES:
        case ERR_BROKER_BUSY:
        case ERR_TRADE_CONTEXT_BUSY: 
          cnt++; // a retryable error
          break;
        case ERR_PRICE_CHANGED:
        case ERR_REQUOTE:
          RefreshRates();
          if(cmd == OP_BUY) {
            price = Ask;
          } 
          else if (cmd == OP_SELL) {
            price = Bid;
          }
          continue; // we can apparently retry immediately according to MT docs.

        default:
          // an apparently serious, unretryable error.
          exit_loop = true;
          break; 

      }  // end switch 

      if (cnt > retry_attempts) 
        exit_loop = true;
      if (!exit_loop) {
        RefreshRates();
        OrderReliablePrint("retryable error (" + string(cnt) + "/" + 
                           string(retry_attempts) + "): " + OrderReliableErrTxt(err)+ " (price = "+ string(price) + ", Ask = "+ string(Ask) +", and Bid = "+ string(Bid) +")"); 
        OrderReliable_SleepRandomTime(sleep_time,sleep_maximum); 
        RefreshRates();
        if (cmd == OP_BUY) {
          price = Ask;
        }
        else if (cmd == OP_SELL) {
          price = Bid;
        }
      }

      if (exit_loop) {
        if (err != ERR_NO_ERROR) {
          OrderReliablePrint("non-retryable error: " + OrderReliableErrTxt(err)); 
        }
        if (cnt > retry_attempts) {
          OrderReliablePrint("retry attempts maxed at " + string(retry_attempts)); 
        }
      }
    }
    // we have now exited from loop. 
    if (err == ERR_NO_ERROR) {
      //OrderReliablePrint("apparently successful OP_BUY or OP_SELL order placed, details follow.");
      //OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES); 
      //OrderPrint(); 
      return(ticket); // SUCCESS! 
    } 
    OrderReliablePrint("failed to execute OP_BUY/OP_SELL, after " + string(cnt) + " retries");
    OrderReliablePrint("failed trade: " + OrderReliable_CommandString(cmd) + " " + symbol + 
                       "@" + string(price) + " tp@" + string(takeprofit) + " sl@" + string(stoploss));
    OrderReliablePrint("failed to execute OP_BUY/OP_SELL, after " + string(cnt) + " retries");
    OrderReliablePrint("last error: " + OrderReliableErrTxt(err)+ " (price = "+ string(price) + ", Ask = "+ string(Ask) +", and Bid = "+ string(Bid) +")"); 
    return(-1); 
  }
  return(-1);  // smz 
}
	
	
//=============================================================================
//							 OrderModifyReliable()
//
//	This is intended to be a drop-in replacement for OrderModify() which, 
//	one hopes, is more resistant to various forms of errors prevalent 
//	with MetaTrader.
//			  
//	RETURN VALUE: 
//
//		TRUE if successful, FALSE otherwise
//
//
//	FEATURES:
//
//		 * Re-trying under some error conditions, sleeping a random 
//		   time defined by an exponential probability distribution.
//
//		 * Displays various error messages on the log for debugging.
//
//
//	Matt Kennel, mbkennel@gmail.com  	2006-05-28
//
//=============================================================================
bool OrderModifyReliable(int ticket, double price, double stoploss, 
						 double takeprofit, datetime expiration, 
						 color arrow_color = CLR_NONE) 
{
	OrderReliable_Fname = "OrderModifyReliable";

	OrderReliablePrint(" attempted modify of #" + string(ticket) + " price:" + string(price) + 
						" sl:" + string(stoploss) + " tp:" + string(takeprofit)); 

/*	if (!IsConnected()) 
	{
		OrderReliablePrint("error: IsConnected() == false");
		_OR_err = ERR_NO_CONNECTION; 
		return(false);
	}
*/	
	if (IsStopped()) 
	{
		OrderReliablePrint("error: IsStopped() == true");
		return(false);
	}
	
	int cnt = 0;
	while(!IsTradeAllowed() && cnt < retry_attempts) 
	{
		OrderReliable_SleepRandomTime(5*sleep_time,12*sleep_maximum); 
		cnt++;
	}
	if (!IsTradeAllowed()) 
	{
		OrderReliablePrint("error: no operation possible because IsTradeAllowed()==false, even after retries.");
		_OR_err = ERR_TRADE_CONTEXT_BUSY; 
		return(false);  
	}


	
	if (false) {
		 // This section is 'nulled out', because
		 // it would have to involve an 'OrderSelect()' to obtain
		 // the symbol string, and that would change the global context of the
		 // existing OrderSelect, and hence would not be a drop-in replacement
		 // for OrderModify().
		 //
		 // See OrderModifyReliableSymbol() where the user passes in the Symbol 
		 // manually.
		 
		 if(!OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
		       Print(__FUNCTION__,": OrderSelect NOT successful");

		 string symbol = OrderSymbol();
		 int digits = int(MarketInfo(symbol,MODE_DIGITS));
		 if (digits > 0) {
			 price = NormalizeDouble(price,digits);
			 stoploss = NormalizeDouble(stoploss,digits);
			 takeprofit = NormalizeDouble(takeprofit,digits); 
		 }
		 if (stoploss != 0) OrderReliable_EnsureValidStop(7,symbol,price,stoploss); 
	}



	int err = GetLastError(); // so we clear the global variable.  
	err = 0; 
	_OR_err = 0; 
	bool exit_loop = false;
	cnt = 0;
	bool result = false;
	
	while (!exit_loop) 
	{
		if (IsTradeAllowed()) 
		{
			result = OrderModify(ticket, price, stoploss, 
								 takeprofit, expiration, arrow_color);
			err = GetLastError();
			_OR_err = err; 
		} 
		else 
			cnt++;

		if (result == true) 
			exit_loop = true;

		switch (err) 
		{
			case ERR_NO_ERROR:
				exit_loop = true;
				break;
				
			case ERR_NO_RESULT:
				// modification without changing a parameter. 
				// if you get this then you may want to change the code.
				exit_loop = true;
				break;
				
			case ERR_SERVER_BUSY:
			case ERR_NO_CONNECTION:
			case ERR_INVALID_PRICE:
			case ERR_OFF_QUOTES:
			case ERR_BROKER_BUSY:
			case ERR_TRADE_CONTEXT_BUSY: 
			case ERR_TRADE_TIMEOUT:		// for modify this is a retryable error, I hope. 
				cnt++; 	// a retryable error
				break;
				
			case ERR_PRICE_CHANGED:
			case ERR_REQUOTE:
				RefreshRates();
				continue; 	// we can apparently retry immediately according to MT docs.
				
			default:
				// an apparently serious, unretryable error.
				exit_loop = true;
				break; 
				
		}  // end switch 

		if (cnt > retry_attempts) 
			exit_loop = true; 
			
		if (!exit_loop) 
		{
			OrderReliablePrint("retryable error (" + string(cnt) + "/" + string(retry_attempts) + 
								"): "  +  OrderReliableErrTxt(err)); 
			OrderReliable_SleepRandomTime(sleep_time,sleep_maximum); 
			RefreshRates(); 
		}
		
		if (exit_loop) 
		{
			if ((err != ERR_NO_ERROR) && (err != ERR_NO_RESULT)) 
				OrderReliablePrint("non-retryable error: "  + OrderReliableErrTxt(err)); 

			if (cnt > retry_attempts) 
				OrderReliablePrint("retry attempts maxed at " + string(retry_attempts)); 
		}
	}  
	
	// we have now exited from loop. 
	if ((result == true) || (err == ERR_NO_ERROR)) 
	{
		//OrderReliablePrint("apparently successful modification order, updated trade details follow.");
		//OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES); 
		//OrderPrint(); 
		return(true); // SUCCESS! 
	} 
	
	string symbol = "NA";    // smz
	if (err == ERR_NO_RESULT) 
	{
		OrderReliablePrint("Server reported modify order did not actually change parameters.");
		OrderReliablePrint("redundant modification: "  + string(ticket) + " " + symbol + 
							"@" + string(price) + " tp@" + string(takeprofit) + " sl@" + string(stoploss)); 
		OrderReliablePrint("Suggest modifying code logic to avoid."); 
		return(true);
	}
	
	OrderReliablePrint("failed to execute modify after " + string(cnt) + " retries");
	OrderReliablePrint("failed modification: "  + string(ticket) + " " + symbol + 
						"@" + string(price) + " tp@" + string(takeprofit) + " sl@" + string(stoploss)); 
	OrderReliablePrint("last error: " + OrderReliableErrTxt(err)); 
	
	return(false);  
}
 
 
//=============================================================================
//
//						OrderModifyReliableSymbol()
//
//	This has the same calling sequence as OrderModify() except that the 
//	user must provide the symbol.
//
//	This function will then be able to ensure proper normalization and 
//	stop levels.
//
//=============================================================================
bool OrderModifyReliableSymbol(string symbol, int ticket, double price, 
							   double stoploss, double takeprofit, 
							   datetime expiration, color arrow_color = CLR_NONE) 
{
	int digits = int(MarketInfo(symbol, MODE_DIGITS));
	
	if (digits > 0) 
	{
		price = NormalizeDouble(price, digits);
		stoploss = NormalizeDouble(stoploss, digits);
		takeprofit = NormalizeDouble(takeprofit, digits); 
	}
	
	if (stoploss != 0) 
		OrderReliable_EnsureValidStop(7,symbol, price, stoploss); 
		
	return(OrderModifyReliable(ticket, price, stoploss, 
								takeprofit, expiration, arrow_color)); 
	
}
 
 
//=============================================================================
//							 OrderCloseReliable()
//
//	This is intended to be a drop-in replacement for OrderClose() which, 
//	one hopes, is more resistant to various forms of errors prevalent 
//	with MetaTrader.
//			  
//	RETURN VALUE: 
//
//		TRUE if successful, FALSE otherwise
//
//
//	FEATURES:
//
//		 * Re-trying under some error conditions, sleeping a random 
//		   time defined by an exponential probability distribution.
//
//		 * Displays various error messages on the log for debugging.
//
//
//	Derk Wehler, ashwoods155@yahoo.com  	2006-07-19
//
//=============================================================================
bool OrderCloseReliable(int ticket, double lots, double price, 
						int slippage, color arrow_color = CLR_NONE) 
{
	OrderReliable_Fname = "OrderCloseReliable";
   		if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)==true)
            {
					RefreshRates();
      		if (OrderType() == OP_BUY)
		         {
      			price = Bid;
               }
      		else if (OrderType() == OP_SELL)
         		{
      			price = Ask;
		         }
            }

	OrderReliablePrint(" attempted close of #" + string(ticket) + " price:" + string(price) + 
						" lots:" + string(lots) + " slippage:" + string(slippage)); 

/*	if (!IsConnected()) 
	{
		OrderReliablePrint("error: IsConnected() == false");
		_OR_err = ERR_NO_CONNECTION; 
		return(false);
	}
*/	
	if (IsStopped()) 
	{
		OrderReliablePrint("error: IsStopped() == true");
		return(false);
	}
	
	int cnt = 0;
	while(!IsTradeAllowed() && cnt < retry_attempts) 
	{
		OrderReliable_SleepRandomTime(5*sleep_time,12*sleep_maximum); 
		cnt++;
	}
	if (!IsTradeAllowed()) 
	{
		OrderReliablePrint("error: no operation possible because IsTradeAllowed()==false, even after retries.");
		_OR_err = ERR_TRADE_CONTEXT_BUSY; 
		return(false);  
	}


	int err = GetLastError(); // so we clear the global variable.  
	err = 0; 
	_OR_err = 0; 
	bool exit_loop = false;
	cnt = 0;
	bool result = false;
	
	while (!exit_loop) 
	{
		if (IsTradeAllowed()) 
		{
   		if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)==true)
            {
					RefreshRates();
      		if (OrderType() == OP_BUY)
		         {
      			price = Bid;
               }
      		else if (OrderType() == OP_SELL)
         		{
      			price = Ask;
		         }
            }
			result = OrderClose(ticket, lots, price, slippage, arrow_color);
			err = GetLastError();
			_OR_err = err; 
		} 
		else 
			cnt++;

		if (result == true) 
			exit_loop = true;

		switch (err) 
		{
			case ERR_NO_ERROR:
				exit_loop = true;
				break;
				
			case ERR_SERVER_BUSY:
			case ERR_NO_CONNECTION:
			case ERR_INVALID_PRICE:
			case ERR_OFF_QUOTES:
			case ERR_BROKER_BUSY:
			case ERR_TRADE_CONTEXT_BUSY: 
			case ERR_TRADE_TIMEOUT:		// for modify this is a retryable error, I hope. 
				cnt++; 	// a retryable error
				break;
				
			case ERR_PRICE_CHANGED:
			case ERR_REQUOTE:
   		if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)==true)
            {
					RefreshRates();
      		if (OrderType() == OP_BUY)
		         {
      			price = Bid;
               }
      		else if (OrderType() == OP_SELL)
         		{
      			price = Ask;
		         }
            }
				continue; 	// we can apparently retry immediately according to MT docs.
				
			default:
				// an apparently serious, unretryable error.
				exit_loop = true;
				break; 
				
		}  // end switch 

		if (cnt > retry_attempts) 
			exit_loop = true; 
			
		if (!exit_loop) 
		{
		RefreshRates();
			OrderReliablePrint("retryable error (" + string(cnt) + "/" + string(retry_attempts) + 
								"): "  +  OrderReliableErrTxt(err)+ " (price = "+ string(price) + ", Ask = "+ string(Ask) +", and Bid = "+ string(Bid) +")"); 
			OrderReliable_SleepRandomTime(sleep_time,sleep_maximum); 
   		if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)==true)
            {
					RefreshRates();
      		if (OrderType() == OP_BUY)
		         {
      			price = Bid;
               }
      		else if (OrderType() == OP_SELL)
         		{
      			price = Ask;
		         }
            }
		}
		
		if (exit_loop) 
		{
		RefreshRates();
			if ((err != ERR_NO_ERROR) && (err != ERR_NO_RESULT)) 
				OrderReliablePrint("non-retryable error: "  + OrderReliableErrTxt(err)+ " (price = "+ string(price) + ", Ask = "+ string(Ask) +", and Bid = "+ string(Bid) +")"); 

			if (cnt > retry_attempts) 
				OrderReliablePrint("retry attempts maxed at " + string(retry_attempts)); 
		}
	}  
	
	// we have now exited from loop. 
	if ((result == true) || (err == ERR_NO_ERROR)) 
	{
		//OrderReliablePrint("apparently successful modification order, updated trade details follow.");
		//OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES); 
		//OrderPrint(); 
		return(true); // SUCCESS! 
	} 
	RefreshRates();
	OrderReliablePrint("failed to execute close after " + string(cnt) + " retries");
	OrderReliablePrint("failed close: Ticket #" + string(ticket) + ", Price: " + 
						string(price) + ", Slippage: " + string(slippage)); 
	OrderReliablePrint("last error: " + OrderReliableErrTxt(err)+ " (price = "+ string(price) + ", Ask = "+ string(Ask) +", and Bid = "+ string(Bid) +")"); 
	
	return(false);  
}
 
 

//=============================================================================
//=============================================================================
//								Utility Functions
//=============================================================================
//=============================================================================



int OrderReliableLastErr() 
{
	return (_OR_err); 
}


string OrderReliableErrTxt(int err) 
{
	return ("" + string(err) + ":" + ErrorDescription(err)); 
}


void OrderReliablePrint(string s) 
{
	// Print to log prepended with stuff;
	//Print(OrderReliable_Fname + " " + OrderReliableVersion + ":" + s);
	Print("****OR:",s);
}


string OrderReliable_CommandString(int cmd) 
{
	if (cmd == OP_BUY) 
		return("OP_BUY");

	if (cmd == OP_SELL) 
		return("OP_SELL");

	if (cmd == OP_BUYSTOP) 
		return("OP_BUYSTOP");

	if (cmd == OP_SELLSTOP) 
		return("OP_SELLSTOP");

	if (cmd == OP_BUYLIMIT) 
		return("OP_BUYLIMIT");

	if (cmd == OP_SELLLIMIT) 
		return("OP_SELLLIMIT");

	return("(CMD==" + string(cmd) + ")"); 
}


//=============================================================================
//
//						 OrderReliable_EnsureValidStop()
//
// 	Adjust stop loss so that it is legal.
//
//	Matt Kennel mbkennel@gmail.com.
//
//=============================================================================
void OrderReliable_EnsureValidStop(int cmd,string symbol, double& price, double& sl) 
{
	// Return if no S/L
	if (sl == 0) 
		return;
	
	double servers_min_stop = MarketInfo(symbol, MODE_STOPLEVEL) * MarketInfo(symbol, MODE_POINT); 
	
	RefreshRates();
   
   if (cmd == OP_BUY) price=MarketInfo(symbol, MODE_ASK);
   if (cmd == OP_SELL) price=MarketInfo(symbol, MODE_BID);
   
	if (MathAbs(price - sl) <= servers_min_stop) 
	{
		// we have to adjust the stop.
		if (price > sl)
			sl = price - servers_min_stop;	// we are long
			
		else if (price < sl)
			sl = price + servers_min_stop;	// we are short
			
		else
			OrderReliablePrint("EnsureValidStop: error, passed in price == sl, cannot adjust"); 
			
		sl = NormalizeDouble(sl, int(MarketInfo(symbol, MODE_DIGITS))); 
	}
}


//=============================================================================
//
//						 OrderReliable_SleepRandomTime()
//
//	This sleeps a random amount of time defined by an exponential 
//	probability distribution. The mean time, in Seconds is given 
//	in 'mean_time'.
//
//	This is the back-off strategy used by Ethernet.  This will 
//	quantize in tenths of seconds, so don't call this with a too 
//	small a number.  This returns immediately if we are backtesting
//	and does not sleep.
//
//	Matt Kennel mbkennel@gmail.com.
//
//=============================================================================
void OrderReliable_SleepRandomTime(double mean_time, double max_time) 
{
	if (IsTesting()) 
		return; 	// return immediately if backtesting.

	double tenths = MathCeil(mean_time / 0.1);
	if (tenths <= 0) 
		return; 
	 
	int maxtenths = int(MathRound(max_time/0.1)); 
	double p = 1.0 - 1.0 / tenths; 
	  
	Sleep(1000); 	// one tenth of a second
	
	for(int i=0; i < maxtenths; i++)  
	{
		if (MathRand() > p*32768) 
			break; 
			
		// MathRand() returns in 0..32767
		Sleep(1000); 
	}
}  


//=============================================================================
//							 OrderReSendReliable()
//
//	This is intended to be a drop-in replacement for OrderSend() which, 
//	one hopes, is more resistant to various forms of errors prevalent 
//	with MetaTrader.
//			  
//	RETURN VALUE: 
//
//	Ticket number or -1 under some error conditions. 
//
//
//	FEATURES:
//
//		 * Re-trying under some error conditions, sleeping a random 
//		   time defined by an exponential probability distribution.
//
//		 * Automatic normalization of Digits
//
//		 * Automatically makes sure that stop levels are more than
//		   the minimum stop distance, as given by the server. If they
//		   are too close, they are adjusted.
//
//		 * Automatically converts limit orders to market orders 
//		   when the limit orders are rejected by the server for 
//		   being to close to market.
//
//		 * Displays various error messages on the log for debugging.
//
//
//	Matt Kennel, mbkennel@gmail.com  	2006-05-28
//
//=============================================================================
int OrderReSendReliable(string symbol, int cmd, double volume, double price,
					  int slippage, double stoploss, double takeprofit,
					  string comment, int _magic, datetime expiration = 0, 
					  color arrow_color = CLR_NONE) 
{
  double servers_min_stop;

	// ------------------------------------------------
	// Check basic conditions see if trade is possible. 
	// ------------------------------------------------
	OrderReliable_Fname = "OrderReSendReliable";
	OrderReliablePrint(" attempted " + OrderReliable_CommandString(cmd) + " " + string(volume) + 
						" lots @" + string(price) + " sl:" + string(stoploss) + " tp:" + string(takeprofit)); 

/*	if (!IsConnected())
	{
		OrderReliablePrint("error: IsConnected() == false");
		_OR_err = ERR_NO_CONNECTION;
		return(-1);
	}
*/	
	if (IsStopped()) 
	{
		OrderReliablePrint("error: IsStopped() == true");
		_OR_err = ERR_COMMON_ERROR; 
		return(-1);
	}
	
	int cnt = 0;
	while(!IsTradeAllowed() && cnt < retry_attempts) 
	{
		OrderReliable_SleepRandomTime(5*sleep_time, 12*sleep_maximum); 
		cnt++;
	}
	
	if (!IsTradeAllowed()) 
	{
		OrderReliablePrint("error: no operation possible because IsTradeAllowed()==false, even after retries.");
		_OR_err = ERR_TRADE_CONTEXT_BUSY; 

		return(-1);  
	}

	// Normalize all price / stoploss / takeprofit to the proper # of digits.
	int digits = int(MarketInfo(symbol, MODE_DIGITS));
	if (digits > 0) 
	{
		price = NormalizeDouble(price, digits);
		stoploss = NormalizeDouble(stoploss, digits);
		takeprofit = NormalizeDouble(takeprofit, digits); 
	}
	
	if (stoploss != 0) 
		OrderReliable_EnsureValidStop(cmd,symbol, price, stoploss); 

	int err = GetLastError(); // clear the global variable.  
	err = 0; 
	_OR_err = 0; 
	bool exit_loop = false;
	bool limit_to_market = false; 
	
	// limit/stop order. 
	int ticket=-1;

	if ((cmd == OP_BUYSTOP) || (cmd == OP_SELLSTOP) || (cmd == OP_BUYLIMIT) || (cmd == OP_SELLLIMIT)) 
	{
		cnt = 0;
		while (!exit_loop) 
		{
			if (IsTradeAllowed()) 
			{
				ticket = OrderSend(symbol, cmd, volume, price, slippage, stoploss, 
									takeprofit, comment, _magic, expiration, arrow_color);
				err = GetLastError();
				_OR_err = err; 
			} 
			else 
			{
				cnt++;
			} 
			
			switch (err) 
			{
				case ERR_NO_ERROR:
					exit_loop = true;
					break;
				
				// retryable errors
				case ERR_SERVER_BUSY:
				case ERR_NO_CONNECTION:
				case ERR_INVALID_PRICE:
				case ERR_OFF_QUOTES:
				case ERR_BROKER_BUSY:
				case ERR_TRADE_CONTEXT_BUSY: 
					cnt++; 
					break;
					
				case ERR_PRICE_CHANGED:
				case ERR_REQUOTE:
					RefreshRates();
					continue;	// we can apparently retry immediately according to MT docs.
					
				case ERR_INVALID_STOPS:
					servers_min_stop = MarketInfo(symbol, MODE_STOPLEVEL) * MarketInfo(symbol, MODE_POINT); 
					if (cmd == OP_BUYSTOP) 
					{
						// If we are too close to put in a limit/stop order so go to market.
						if (MathAbs(Ask - price) <= servers_min_stop)	
							limit_to_market = true; 
							
					} 
					else if (cmd == OP_SELLSTOP) 
					{
						// If we are too close to put in a limit/stop order so go to market.
						if (MathAbs(Bid - price) <= servers_min_stop)
							limit_to_market = true; 
					}
					exit_loop = true; 
					break; 
					
				default:
					// an apparently serious error.
					exit_loop = true;
					break; 
					
			}  // end switch 

			if (cnt > retry_attempts) 
				exit_loop = true; 
			 	
			if (exit_loop) 
			{
				if (err != ERR_NO_ERROR) 
				{
					OrderReliablePrint("non-retryable error: " + OrderReliableErrTxt(err)); 
				}
				if (cnt > retry_attempts) 
				{
					OrderReliablePrint("retry attempts maxed at " + string(retry_attempts)); 
				}
			}
			 
			if (!exit_loop) 
			{
				OrderReliablePrint("retryable error (" + string(cnt) + "/" + string(retry_attempts) + 
									"): " + OrderReliableErrTxt(err)); 
				OrderReliable_SleepRandomTime(sleep_time, sleep_maximum); 
				RefreshRates(); 
			}
		}
		 
		// We have now exited from loop. 
		if (err == ERR_NO_ERROR) 
		{
			//OrderReliablePrint("apparently successful OP_BUYSTOP or OP_SELLSTOP order placed, details follow.");
			//OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES); 
			//OrderPrint(); 
			return(ticket); // SUCCESS! 
		} 
		if (!limit_to_market) 
		{
			OrderReliablePrint("failed to execute stop or limit order after " + string(cnt) + " retries");
			OrderReliablePrint("failed trade: " + OrderReliable_CommandString(cmd) + " " + symbol + 
								"@" + string(price) + " tp@" + string(takeprofit) + " sl@" + string(stoploss)); 
			OrderReliablePrint("last error: " + OrderReliableErrTxt(err)); 
			return(-1); 
		}
	}  // end	  
  
	if (limit_to_market) 
	{
		OrderReliablePrint("going from limit order to market order because market is too close.");
		if ((cmd == OP_BUYSTOP) || (cmd == OP_BUYLIMIT)) 
		{
			cmd = OP_BUY;
			price = Ask;
		} 
		else if ((cmd == OP_SELLSTOP) || (cmd == OP_SELLLIMIT)) 
		{
			cmd = OP_SELL;
			price = Bid;
		}	
	}
	
	// we now have a market order.
	err = GetLastError(); // so we clear the global variable.  
	err = 0; 
	_OR_err = 0; 
	ticket = -1;

	if ((cmd == OP_BUY) || (cmd == OP_SELL)) 
	{
		cnt = 0;
		while (!exit_loop) 
		{
			if (IsTradeAllowed()) 
			{
					RefreshRates();
      		if (cmd == OP_BUY)
		         {
      			price = Ask;
               }
      		else if (cmd == OP_SELL)
         		{
      			price = Bid;
		         }
            ticket = OrderSend(symbol, cmd, volume, price, slippage, 
									0, 0, comment, _magic, 
									expiration, arrow_color);
            err = GetLastError();
   			_OR_err = err;
			} 
			else 
			{
				cnt++;
			} 
			switch (err) 
			{
				case ERR_NO_ERROR:
					exit_loop = true;
					break;
					
				case ERR_SERVER_BUSY:
				case ERR_NO_CONNECTION:
				case ERR_INVALID_PRICE:
				case ERR_OFF_QUOTES:
				case ERR_BROKER_BUSY:
				case ERR_TRADE_CONTEXT_BUSY: 
					cnt++; // a retryable error
					break;
					
				case ERR_PRICE_CHANGED:
				case ERR_REQUOTE:
					RefreshRates();
      		if (cmd == OP_BUY)
		         {
      			price = Ask;
               }
      		else if (cmd == OP_SELL)
         		{
      			price = Bid;
		         }
					continue; // we can apparently retry immediately according to MT docs.
					
				default:
					// an apparently serious, unretryable error.
					exit_loop = true;
					break; 
					
			}  // end switch 

			if (cnt > retry_attempts) 
			 	exit_loop = true; 
			 	
			if (!exit_loop) 
			{
			RefreshRates();
				OrderReliablePrint("retryable error (" + string(cnt) + "/" + 
									string(retry_attempts) + "): " + OrderReliableErrTxt(err)+ " (price = "+ string(price) + ", Ask = "+ string(Ask) +", and Bid = "+ string(Bid) +")"); 
				OrderReliable_SleepRandomTime(sleep_time,sleep_maximum); 
				RefreshRates();
      		if (cmd == OP_BUY)
		         {
      			price = Ask;
               }
      		else if (cmd == OP_SELL)
         		{
      			price = Bid;
		         }
			}
			
			if (exit_loop) 
			{
				if (err != ERR_NO_ERROR) 
				{
					OrderReliablePrint("non-retryable error: " + OrderReliableErrTxt(err)); 
				}
				if (cnt > retry_attempts) 
				{
					OrderReliablePrint("retry attempts maxed at " + string(retry_attempts)); 
				}
			}
		}
		
		// we have now exited from loop. 
		if (err == ERR_NO_ERROR) 
		{
			//OrderReliablePrint("apparently successful OP_BUY or OP_SELL order placed, details follow.");
			//OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES); 
			//OrderPrint(); 
			return(ticket); // SUCCESS! 
		} 
		OrderReliablePrint("failed to execute OP_BUY/OP_SELL, after " + string(cnt) + " retries");
		OrderReliablePrint("failed trade: " + OrderReliable_CommandString(cmd) + " " + symbol + 
							"@" + string(price) + " tp@" + string(takeprofit) + " sl@" + string(stoploss));
      OrderReliablePrint("failed to execute OP_BUY/OP_SELL, after " + string(cnt) + " retries");
		OrderReliablePrint("last error: " + OrderReliableErrTxt(err)+ " (price = "+ string(price) + ", Ask = "+ string(Ask) +", and Bid = "+ string(Bid) +")"); 
		return(-1); 
	}
  return(-1);   // smz
}
	

