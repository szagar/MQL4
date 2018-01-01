//+------------------------------------------------------------------+
//|                                                 price_levels.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

double GetNextLevel(double currentLevel, int direction) {
  //  direction:  1 = UP, -1 = down 
  //double currentBaseLevel;
  string baseString;
  double isolatedLevel;
  double nextLevel;
  if (currentLevel > 50) { // Are we dealing with Yen's or other pairs?
    baseString = DoubleToStr(currentLevel, 3);
    baseString = StringSubstr(baseString, 0, StringLen(baseString) - 3);
    isolatedLevel = currentLevel -  StrToDouble(baseString) ;
  }
  else {
    baseString  = DoubleToStr(currentLevel, 5);
    baseString = StringSubstr(baseString,0, StringLen(baseString) - 3);
    isolatedLevel = (currentLevel - StrToDouble(baseString)) * 100;
  }
  if (direction > 0) {
    if (isolatedLevel >= .7999)
      nextLevel = 1.00;
    else if (isolatedLevel >= .4999)
      nextLevel = .80;
    else if (isolatedLevel >= .1999)
      nextLevel = .50;
    else nextLevel = .20;   
  }
  else {
    if (isolatedLevel >.79999)
         nextLevel = .80;
    else if (isolatedLevel > .49999)
         nextLevel = .50;
    else if (isolatedLevel > .19999)
         nextLevel = .20;
    else nextLevel = .00;
  }
  if (currentLevel > 50) {
    return StrToDouble(baseString) + nextLevel;
  }
  else
    return (StrToDouble(baseString) + nextLevel/100);    
}
