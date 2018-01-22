//+------------------------------------------------------------------+
//|                                                  buystopline.mq4 |
//|                                Copyright jimdandymql4courses.com |
//|                               http://www.jimdandymql4courses.com |
//+------------------------------------------------------------------+
#property copyright "Copyright jimdandymql4courses.com"
#property link      "http://www.jimdandymql4courses.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart(){ObjectCreate(0,"buystopline",OBJ_HLINE,0,0,WindowPriceOnDropped());}
//+------------------------------------------------------------------+
