//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property indicator_chart_window
extern color textcolor=clrGreen;//Font Color
extern int fontsize=8;//Font Size
extern color linecolor=clrGreen;//Line Color
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init()
  {

  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit()
  {
   ObjectsDeleteAll(0,"KKPL");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int dig;
   (Digits==2 || Digits==4)?dig=10:dig=1;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY)
           {

            int value=OrderOpenPrice()/Point;
            value=value-value%(1000/dig);

            double theval=value*Point;

            //double upper = DoubleToStr(theval+(400*Point),Digits);
            double lower=DoubleToStr(theval,Digits);
            double lower2=DoubleToStr(theval+(200*Point),Digits);
            double lower5=DoubleToStr(theval+(500*Point),Digits);
            double lower8=DoubleToStr(theval+(800*Point),Digits);

            if(lower<OrderOpenPrice())
               lower+=(1000*Point);
            if(lower2<OrderOpenPrice())
               lower2+=(1000*Point);
            if(lower5<OrderOpenPrice())
               lower5+=(1000*Point);
            if(lower8<OrderOpenPrice())
               lower8+=(1000*Point);

            ObjectCreate(0,"KKPLU000+"+OrderTicket(),OBJ_TREND,0,iTime(Symbol(),0,0)+Period()*60,lower,iTime(Symbol(),0,0)+((Period()*60)*2),lower);
            ObjectSet("KKPLU000+"+OrderTicket(),OBJPROP_COLOR,linecolor);
            ObjectSet("KKPLU000+"+OrderTicket(),OBJPROP_RAY,false);
            ObjectCreate(0,"KKPLU000TEXT+"+OrderTicket(),OBJ_TEXT,0,iTime(Symbol(),0,0)+((Period()*60)*2),lower);//,iTime(Symbol(),0,0)+((Period()*60)*2),lower);
            ObjectSetText("KKPLU000TEXT+"+OrderTicket(),DoubleToStr(lower,Digits-1),fontsize,NULL,textcolor);
            ObjectSet("KKPLU000TEXT+"+OrderTicket(),OBJPROP_ANCHOR,ANCHOR_LEFT);

            ObjectCreate(0,"KKPLU200+"+OrderTicket(),OBJ_TREND,0,iTime(Symbol(),0,0)+Period()*60,lower2,iTime(Symbol(),0,0)+((Period()*60)*2),lower2);
            ObjectSet("KKPLU200+"+OrderTicket(),OBJPROP_COLOR,linecolor);
            ObjectSet("KKPLU200+"+OrderTicket(),OBJPROP_RAY,false);
            ObjectCreate(0,"KKPLU200TEXT+"+OrderTicket(),OBJ_TEXT,0,iTime(Symbol(),0,0)+((Period()*60)*2),lower2);//,iTime(Symbol(),0,0)+((Period()*60)*2),lower);
            ObjectSetText("KKPLU200TEXT+"+OrderTicket(),DoubleToStr(lower2,Digits-1),fontsize,NULL,textcolor);
            ObjectSet("KKPLU200TEXT+"+OrderTicket(),OBJPROP_ANCHOR,ANCHOR_LEFT);

            ObjectCreate(0,"KKPLU500+"+OrderTicket(),OBJ_TREND,0,iTime(Symbol(),0,0)+Period()*60,lower5,iTime(Symbol(),0,0)+((Period()*60)*2),lower5);
            ObjectSet("KKPLU500+"+OrderTicket(),OBJPROP_COLOR,linecolor);
            ObjectSet("KKPLU500+"+OrderTicket(),OBJPROP_RAY,false);
            ObjectCreate(0,"KKPLU500TEXT+"+OrderTicket(),OBJ_TEXT,0,iTime(Symbol(),0,0)+((Period()*60)*2),lower5);//,iTime(Symbol(),0,0)+((Period()*60)*2),lower);
            ObjectSetText("KKPLU500TEXT+"+OrderTicket(),DoubleToStr(lower5,Digits-1),fontsize,NULL,textcolor);
            ObjectSet("KKPLU500TEXT+"+OrderTicket(),OBJPROP_ANCHOR,ANCHOR_LEFT);

            ObjectCreate(0,"KKPLU800+"+OrderTicket(),OBJ_TREND,0,iTime(Symbol(),0,0)+Period()*60,lower8,iTime(Symbol(),0,0)+((Period()*60)*2),lower8);
            ObjectSet("KKPLU800+"+OrderTicket(),OBJPROP_COLOR,linecolor);
            ObjectSet("KKPLU800+"+OrderTicket(),OBJPROP_RAY,false);
            ObjectCreate(0,"KKPLU800TEXT+"+OrderTicket(),OBJ_TEXT,0,iTime(Symbol(),0,0)+((Period()*60)*2),lower8);//,iTime(Symbol(),0,0)+((Period()*60)*2),lower);
            ObjectSetText("KKPLU800TEXT+"+OrderTicket(),DoubleToStr(lower8,Digits-1),fontsize,NULL,textcolor);
            ObjectSet("KKPLU800TEXT+"+OrderTicket(),OBJPROP_ANCHOR,ANCHOR_LEFT);
           }
         if(OrderType()==OP_SELL)
           {
            int valued=OrderOpenPrice()/Point;
            valued=valued-valued%(1000/dig);

            double thevald=valued*Point;

            //double upper = DoubleToStr(theval+(400*Point),Digits);
            double lowerd=DoubleToStr(thevald,Digits);
            double lower2d=DoubleToStr(thevald+(200*Point),Digits);
            double lower5d=DoubleToStr(thevald+(500*Point),Digits);
            double lower8d=DoubleToStr(thevald+(800*Point),Digits);

            if(lowerd>OrderOpenPrice())
               lowerd-=(1000*Point);
            if(lower2d>OrderOpenPrice())
               lower2d-=(1000*Point);
            if(lower5d>OrderOpenPrice())
               lower5d-=(1000*Point);
            if(lower8d>OrderOpenPrice())
               lower8d-=(1000*Point);

            ObjectCreate(0,"KKPLD000+"+OrderTicket(),OBJ_TREND,0,iTime(Symbol(),0,0)+Period()*60,lowerd,iTime(Symbol(),0,0)+((Period()*60)*2),lowerd);
            ObjectSet("KKPLD000+"+OrderTicket(),OBJPROP_COLOR,linecolor);
            ObjectSet("KKPLD000+"+OrderTicket(),OBJPROP_RAY,false);
            ObjectCreate(0,"KKPLD000TEXT+"+OrderTicket(),OBJ_TEXT,0,iTime(Symbol(),0,0)+((Period()*60)*2),lowerd);//,iTime(Symbol(),0,0)+((Period()*60)*2),lower);
            ObjectSetText("KKPLD000TEXT+"+OrderTicket(),DoubleToStr(lowerd,Digits-1),fontsize,NULL,textcolor);
            ObjectSet("KKPLD000TEXT+"+OrderTicket(),OBJPROP_ANCHOR,ANCHOR_LEFT);

            ObjectCreate(0,"KKPLD200+"+OrderTicket(),OBJ_TREND,0,iTime(Symbol(),0,0)+Period()*60,lower2d,iTime(Symbol(),0,0)+((Period()*60)*2),lower2d);
            ObjectSet("KKPLD200+"+OrderTicket(),OBJPROP_COLOR,linecolor);
            ObjectSet("KKPLD200+"+OrderTicket(),OBJPROP_RAY,false);
            ObjectCreate(0,"KKPLD200TEXT+"+OrderTicket(),OBJ_TEXT,0,iTime(Symbol(),0,0)+((Period()*60)*2),lower2d);//,iTime(Symbol(),0,0)+((Period()*60)*2),lower);
            ObjectSetText("KKPLD200TEXT+"+OrderTicket(),DoubleToStr(lower2d,Digits-1),fontsize,NULL,textcolor);
            ObjectSet("KKPLD200TEXT+"+OrderTicket(),OBJPROP_ANCHOR,ANCHOR_LEFT);

            ObjectCreate(0,"KKPLD500+"+OrderTicket(),OBJ_TREND,0,iTime(Symbol(),0,0)+Period()*60,lower5d,iTime(Symbol(),0,0)+((Period()*60)*2),lower5d);
            ObjectSet("KKPLD500+"+OrderTicket(),OBJPROP_COLOR,linecolor);
            ObjectSet("KKPLD500+"+OrderTicket(),OBJPROP_RAY,false);
            ObjectCreate(0,"KKPLD500TEXT+"+OrderTicket(),OBJ_TEXT,0,iTime(Symbol(),0,0)+((Period()*60)*2),lower5d);//,iTime(Symbol(),0,0)+((Period()*60)*2),lower);
            ObjectSetText("KKPLD500TEXT+"+OrderTicket(),DoubleToStr(lower5d,Digits-1),fontsize,NULL,textcolor);
            ObjectSet("KKPLD500TEXT+"+OrderTicket(),OBJPROP_ANCHOR,ANCHOR_LEFT);

            ObjectCreate(0,"KKPLD800+"+OrderTicket(),OBJ_TREND,0,iTime(Symbol(),0,0)+Period()*60,lower8d,iTime(Symbol(),0,0)+((Period()*60)*2),lower8d);
            ObjectSet("KKPLD800+"+OrderTicket(),OBJPROP_COLOR,linecolor);
            ObjectSet("KKPLD800+"+OrderTicket(),OBJPROP_RAY,false);
            ObjectCreate(0,"KKPLD800TEXT+"+OrderTicket(),OBJ_TEXT,0,iTime(Symbol(),0,0)+((Period()*60)*2),lower8d);//,iTime(Symbol(),0,0)+((Period()*60)*2),lower);
            ObjectSetText("KKPLD800TEXT+"+OrderTicket(),DoubleToStr(lower8d,Digits-1),fontsize,NULL,textcolor);
            ObjectSet("KKPLD800TEXT+"+OrderTicket(),OBJPROP_ANCHOR,ANCHOR_LEFT);
           }
        }
     }
   for(int j=ObjectsTotal()-1;j>=0;j--)
     {
      if(StringFind(ObjectName(j),"KKPL",0)>=0)
        {
         string result[];
         ushort sep=StringGetChar("+"+OrderTicket(),0);
         StringSplit(ObjectName(j),sep,result);

         bool deleteobj=true;
         for(int o=OrdersTotal()-1;o>=0;o--)
           {
            if(!OrderSelect(o,SELECT_BY_POS,MODE_TRADES))
               continue;
            if(OrderTicket()==result[1])
              {
               deleteobj=false;
               break;
              }
           }
         if(deleteobj)
           {
            ObjectDelete(0,ObjectName(j));
            continue;
           }
         if(StringFind(ObjectName(j),"TEXT",0)<0)
           {
            ObjectSet(ObjectName(j),OBJPROP_TIME1,iTime(Symbol(),0,0)+Period()*60);
           }
         else
           {
            ObjectSet(ObjectName(j),OBJPROP_TIME1,iTime(Symbol(),0,0)+((Period()*60)*2));
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
