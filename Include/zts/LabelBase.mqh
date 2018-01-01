//+------------------------------------------------------------------+
//|                                                    LabelBase.mqh |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property version   "1.00"
#property strict
#include <zts\common.mqh>

class LabelBase {
private:
  string LabelName;
  long ChartId;
  int xloc, yloc;

  bool objectExists();
  bool labelCreate(const long              chart_ID,               // chart's ID
                   const string            name,             // label name
                   const int               x=0,                      // X coordinate
                   const int               y=0,                      // Y coordinate
                   const int               sub_window=0,             // subwindow index
                   const ENUM_BASE_CORNER  corner=CORNER_RIGHT_UPPER, // chart corner for anchoring
                   const string            text="Label",             // text
                   const string            font="Arial",             // font
                   const int               font_size=10,             // font size
                   const color             clr=clrRed,               // color
                   const double            angle=0.0,                // text slope
                   const ENUM_ANCHOR_POINT anchor=ANCHOR_RIGHT_UPPER, // anchor type
                   const bool              back=false,               // in the background
                   const bool              selection=false,          // highlight to move
                   const bool              hidden=false,              // hidden in the object list
                   const long              z_order=0);                // priority for mouse click

public:
  LabelBase(string name, int x=0, int y=0);
  ~LabelBase();

  string labelText;

  void setXYcoord(int x, int y) { xloc = x; yloc = y; }
  void appendToText(string text);
  void setText(string text);
  string getText();
  void clearText();
};

LabelBase::LabelBase(string name, int x=0, int y=0) {
  LabelName = name;
  xloc = x;
  yloc = y;
}

LabelBase::~LabelBase() {
}

bool LabelBase::objectExists() {
  Print(__FUNCTION__,": check if ",LabelName," exists");
  int id = ObjectFind(LabelName);
  Print(__FUNCTION__,": id = ", id);
  return((id<0) ? false : true);
}

void LabelBase::setText(string text) {
  if(!objectExists()) {
    if(!labelCreate(ChartId,LabelName,xloc,yloc)) {
      Print(__FUNCTION__,": Could not create label object!");
      return;
    }
  }
  else {
    Print(__FUNCTION__,": LabelBase object ",LabelName," exists");
  }
  if(!ObjectSetString(ChartId,LabelName,OBJPROP_TEXT,text)) 
    Print(__FUNCTION__,": failed to change text! Error code = ",GetLastError());
  else
    labelText = text;
}

string LabelBase::getText() {
  if(!objectExists()) return("NA");
  string txt = ObjectGetString(ChartId,LabelName,OBJPROP_TEXT);  
  int error=GetLastError();
  if (error==4202) {
    Alert(__FUNCTION__+": Error in getting Label text");
    txt = "NA";
  }
  return(txt);
}

void LabelBase::clearText() {
  ResetLastError();
  if(!ObjectDelete(ChartId,LabelName)) {
    Print(__FUNCTION__,": failed to delete \"Text\" object! Error code =", GetLastError());
  }
}

bool LabelBase::labelCreate(const long   chart_ID,               // chart's ID
                 const string            name,             // label name
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const int               sub_window=0,             // subwindow index
                 const ENUM_BASE_CORNER  corner=CORNER_RIGHT_UPPER, // chart corner for anchoring
                 const string            text="Label",             // text
                 const string            font="Arial",             // font
                 const int               font_size=10,             // font size
                 const color             clr=clrRed,               // color
                 const double            angle=0.0,                // text slope
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_RIGHT_UPPER, // anchor type
                 const bool              back=false,               // in the background
                 const bool              selection=false,          // highlight to move
                 const bool              hidden=false,              // hidden in the object list
                 const long              z_order=0) {                // priority for mouse click
//--- reset the error value
   ResetLastError();
//--- create a text label
   Print(__FUNCTION__,": create label, chart_id=",chart_ID,"  name=",name);
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0)) {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
