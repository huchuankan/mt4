//+------------------------------------------------------------------+
//|                                                        myKDJ.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot K
#property indicator_label1  "K"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot D
#property indicator_label2  "D"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot J
#property indicator_label3  "J"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint     InpPeriod      =  9;          // Period
input double   InpFactor1     =  0.666666;   // KFactor
input double   InpFactor2     =  0.333333;   // DFactor
input double   InpThreshold   =  50.0;       // Threshold
//--- indicator buffers
double         BufferK[];
double         BufferD[];
double         BufferJ[];
//--- global variables
double         factor1;
double         factor2;
double         threshold;
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=(int)InpPeriod;
   factor1=(InpFactor1<0.01 ? 0.01 : InpFactor1);
   factor2=(InpFactor2<0.01 ? 0.01 : InpFactor2);
   threshold=(InpThreshold<0 ? 0 : InpThreshold>100 ? 100 : InpThreshold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferK);
   SetIndexBuffer(1,BufferD);
   SetIndexBuffer(2,BufferJ);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"KDJ ("+(string)period+","+DoubleToString(factor1,6)+","+DoubleToString(factor2,6)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,threshold);
//--- setting plot buffer parameters
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//---
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
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
