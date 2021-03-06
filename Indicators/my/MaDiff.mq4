//+------------------------------------------------------------------+
//|                                                    MaDiff.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//| 描述MA1与MA2  MA2与MA3 之间的差值
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot fast
#property indicator_label1  "fast"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot slow
#property indicator_label2  "slow"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrWhite
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot up
#property indicator_label3  "up"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot down
#property indicator_label4  "down"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrAqua
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

//--- input parameters
input int      MA1 = 7;
input int      MA2 = 17;
input int      MA3 = 34;
//--- indicator buffers
double         fastBuffer[];
double         slowBuffer[];
double         upBuffer[];
double         downBuffer[];

//--- right input parameters flag
bool      extParameters = false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,fastBuffer);
   SetIndexBuffer(1,slowBuffer);
   SetIndexBuffer(2,upBuffer);
   SetIndexBuffer(3,downBuffer);

   
//--- set levels 指标值的进度   
   IndicatorSetInteger(INDICATOR_DIGITS,0); 
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   SetIndexArrow(2,225);
   SetIndexArrow(3,226);
   
   SetIndexLabel(0,"MA("+IntegerToString(MA1)+")-MA("+IntegerToString(MA2)+")");
   SetIndexLabel(1,"MA("+IntegerToString(MA2)+")-MA("+IntegerToString(MA3)+")");
   SetIndexLabel(2,"死叉");
   SetIndexLabel(3,"金叉");
   //--- check for input parameters
   if (MA1>=MA2 || MA1>=MA3 || MA2>=MA3) {
      Print("Wrong input parameters");
      extParameters = false;
      return(INIT_FAILED);
   } else { 
      extParameters = true;
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
   if (rates_total <= MA3 || !extParameters){
     return(0);
   }
   int i = 0;
   int limit;
   limit = rates_total - prev_calculated;
   if (prev_calculated > 0) {
      limit++;
   }
   for (i=0;i<limit;i++) {
     double ma1 = iMA(NULL,0,MA1,0,MODE_SMA,PRICE_CLOSE,i);
     double ma2 = iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,i);
     double ma3 = iMA(NULL,0,MA3,0,MODE_SMA,PRICE_CLOSE,i);
     fastBuffer[i] = DoubleToString(((ma1-ma2)/Point));
     slowBuffer[i] = DoubleToString(((ma2-ma3)/Point));
   }
    
   for(i=0;i<limit-1;i++) {
     int h = TimeHour(time[i]);
     bool inTime = h > 8 && h < 20;
     if (Period()>15) {
         inTime = true;
     }
   
     if (fastBuffer[i+1] > slowBuffer[i+1] && fastBuffer[i+2] < slowBuffer[i+2] && inTime) {
        if (slowBuffer[i+1] > 0) {
           upBuffer[i+1] = -10;
        } else {
           upBuffer[i+1] = slowBuffer[i+1] - 10;
        }
     }
     if (fastBuffer[i+1] < slowBuffer[i+1] && fastBuffer[i+2] > slowBuffer[i+2] && inTime) {
        if (slowBuffer[i+1] < 0) {
           downBuffer[i+1] =  10;
        } else {
           downBuffer[i+1] = slowBuffer[i+1] + 10;
        } 
     }
   } 
   
   return(rates_total);
  }
//+------------------------------------------------------------------+

