//+------------------------------------------------------------------+
//|                                                  setTemplate.mq4 |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict
#property show_inputs

enum Templates {Default,asianBox,PatiBarSize50sma,PATI_look,ADX,BollingerBands};

extern Templates NewTemplate=Default;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   long thischart=ChartID();
   long firstchart = ChartFirst();
   while(firstchart>0)
   {
   if(firstchart==thischart)
   {
   firstchart=ChartNext(firstchart);
   continue;
   }
   ChartApplyTemplate(firstchart,EnumToString(NewTemplate));
   firstchart=ChartNext(firstchart);
   }
   ChartApplyTemplate(thischart,EnumToString(NewTemplate));   
  }
//+------------------------------------------------------------------+
