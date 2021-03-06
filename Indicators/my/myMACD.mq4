//+------------------------------------------------------------------+
//|                                                       myMACD.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   7
//--- plot fast
#property indicator_label1  "fast"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrWhite
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot slow
#property indicator_label2  "slow"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrYellow
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Label3
#property indicator_label3  "period"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrForestGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot up

#property indicator_label4  "up"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot down
#property indicator_label5  "down"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrAqua
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot up bad
#property indicator_label6  "up-bad"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot down bad
#property indicator_label7  "down-bad"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrAqua
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1

//--- input parameters
input int      FastEMA=12;
input int      SlowEMA=26;
input int      SignalSMA=9;
//--- indicator buffers
double         fastBuffer[];
double         slowBuffer[];
double         periodBuffer[];
double         upBuffer[];
double         downBuffer[];
double         upBadBuffer[];
double         downBadBuffer[];
//--- right input parameters flag
bool      ExtParameters=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,fastBuffer);
   SetIndexBuffer(1,slowBuffer);
   SetIndexBuffer(2,periodBuffer);
   SetIndexBuffer(3,upBuffer);
   SetIndexBuffer(4,downBuffer);
   SetIndexBuffer(5,upBadBuffer);
   SetIndexBuffer(6,downBadBuffer);
   
//--- set levels 指标值的进度   
   IndicatorSetInteger(INDICATOR_DIGITS,6); 
   
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   SetIndexArrow(3,225);
   SetIndexArrow(4,226);
   SetIndexArrow(5,76);
   SetIndexArrow(6,76);
   
   //--- name for DataWindow and indicator subwindow label
   IndicatorShortName("MyMACD("+IntegerToString(FastEMA)+","+IntegerToString(SlowEMA)+","+IntegerToString(SignalSMA)+")");
   SetIndexLabel(2,"柱");
   //--- check for input parameters
   if(FastEMA<=1 || SlowEMA<=1 || SignalSMA<=1 || FastEMA>=SlowEMA) {
      Print("Wrong input parameters");
      ExtParameters=false;
      return(INIT_FAILED);
   } else { 
      ExtParameters=true;
   }
   //--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if (rates_total <= SignalSMA || !ExtParameters){
     return(0);
   }
   int i=0;
   int limit;
   limit = rates_total - prev_calculated;
   if (prev_calculated > 0) {
      limit++;
   }
   for (i=0;i<limit;i++) {
     //
     periodBuffer[i] = iMACD(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,i);
     slowBuffer[i] = iMACD(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,i);
     fastBuffer[i] = periodBuffer[i];  
   } 
   /*
    for(i=0;i<limit-1;i++) {
     int h=TimeHour(time[i]);
     bool inTime = h>8 && h<20;
     if (Period()>15) {
        inTime = true;
     }
   
     if (fastBuffer[i+1] > slowBuffer[i+1] && fastBuffer[i+2] < slowBuffer[i+2] && inTime) {
        if (slowBuffer[i+1] > 0) {
           upBadBuffer[i+1] = -0.0001;
        } else {
         // if(MathAbs(slowBuffer[i+1])<0.0001){
             upBuffer[i+1] = slowBuffer[i+1] - 0.0001;
          // } 
          // else {
          //   upBadBuffer[i+1] = slowBuffer[i+1] - 0.0001;
         //  }
        }
          //upBuffer[i+1] = slowBuffer[i+1] - 0.0001;
      } 
     if (fastBuffer[i+1] < slowBuffer[i+1] && fastBuffer[i+2] > slowBuffer[i+2] && inTime) {
        if (slowBuffer[i+1] < 0) {
           downBadBuffer[i+1] =  0.0001;
        } else {
         //  if (MathAbs(slowBuffer[i+1])<0.0001){
             downBuffer[i+1] = slowBuffer[i+1] + 0.0001;
         //  } 
          // else {
         //    downBuffer[i+1] = slowBuffer[i+1] + 0.0001;
         //  }
        } 
        // downBuffer[i+1] = slowBuffer[i+1] + 0.0001;
     }
    
   } 
   */




   return(rates_total);
  }
//+------------------------------------------------------------------+
