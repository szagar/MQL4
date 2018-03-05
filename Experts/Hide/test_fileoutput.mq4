//+------------------------------------------------------------------+
//|                                              test_fileoutput.mq4 |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   int      CREATE   = FILE_WRITE|FILE_TXT|FILE_ANSI;
   int      APPEND   = FILE_READ|CREATE;
   string   fileName = WindowExpertName() + ".RES";
   string   SEP      = "\t";  // TAB
   string   header   = OnTester_core( true, SEP)   + SEP + "Symbol"  + SEP
                     + "Period"                    + SEP + "Eprofit" + SEP
                     + "Eprofit2"                  + SEP + "nTrades";
   string   format   =  OnTester_core(false, SEP)  + SEP + _Symbol   + SEP
                     + "%s"                        + SEP + "%.2f"    + SEP
                     + "%g"                        + SEP + "%i";
   HANDLE   handle   = FileOpen(fileName, APPEND);
   if(handle == INVALID_HANDLE){
      Alert(StringFormat("%s: FileOpen(%s): %i", fileName, _LastError) ); 
      return 0;
   }
   if(FileSize(handle) == 0)  FileWrite(handle, header);
   else                       FileSeek(handle, 0, SEEK_END);
   FileWrite(handle, StringFormat(format, as_string(tf), perTF[tf].sum(),
                                             perTF[tf].sum2(), nTrades) );
   FileClose(handle);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
