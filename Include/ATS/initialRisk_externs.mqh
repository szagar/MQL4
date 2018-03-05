enum Enum_INITIAL_RISK { IR_PATI_Pips, IR_DayATR,IR_ATR,IR_PrevHL};

extern string commentString_IR_1 = ""; //---------------------------------------------
//extern string commentString_IR_2 = ""; //--------- Initial Risk (1R) settings 
//extern string commentString_IR_3 = ""; //---------------------------------------------
extern Enum_INITIAL_RISK OneRmodel = IR_DayATR;  //1R model
extern int IR_BarCount = 3;                      //>> BarCount   5-60,5
extern int IR_AtrTF = 0;                         //>> ATR TimeFrame       
extern double IR_ATRfactor = 2.7;                //>> ATR multiplier  0.6-3.5, 0.1
