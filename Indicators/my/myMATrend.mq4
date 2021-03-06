//+------------------------------------------------------------------+
//|                                                    myMATrend.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   6

//--- MA短周期
#property indicator_label1  "line1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- plot 常规
#property indicator_label2  "line2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrWhite
#property indicator_style2  STYLE_SOLID
#property indicator_width2 2
//--- plot 空头
#property indicator_label3  "line3"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLime
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot 盘整
#property indicator_label4  "line4"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrWhite
#property indicator_style4  STYLE_SOLID
#property indicator_width3  2

//--- plot 多头
#property indicator_label5  "line5"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrRed
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2

//--- MA长周期
#property indicator_label6  "line6"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrDarkViolet
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1


//均线周期
input int      MA1 = 7;
input int      MA2 = 17;
input int      MA3 = 34;
//判断趋势的变化量
input int      step = 5; 
//MA2的彩色线，
input bool     MA2NeedColor = true;
input bool     MA1Show = true;
input bool     MA3Show = true;

//--- indicator buffers
double         line1Buffer[];
double         line2Buffer[];
double         line3Buffer[];
double         line4Buffer[];
double         line5Buffer[];
double         line6Buffer[];
//--- right input parameters flag
bool      extParameters = false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,line1Buffer);
   SetIndexBuffer(1,line2Buffer);
   SetIndexBuffer(2,line3Buffer);
   SetIndexBuffer(3,line4Buffer);
   SetIndexBuffer(4,line5Buffer);
   SetIndexBuffer(5,line6Buffer);
 
   
//--- set levels 指标值的精度   
   IndicatorSetInteger(INDICATOR_DIGITS,5);
     
   //SetIndexStyle(1,DRAW_LINE,EMPTY,EMPTY,MA2DefaultColor);
   SetIndexLabel(0,"MA("+IntegerToString(MA1)+")");
   SetIndexLabel(1,"MA("+IntegerToString(MA2)+")");
   SetIndexLabel(2,"MA("+IntegerToString(MA2)+")空头");
   SetIndexLabel(3,"MA("+IntegerToString(MA2)+")盘整");
   SetIndexLabel(4,"MA("+IntegerToString(MA2)+")多头");
   SetIndexLabel(5,"MA("+IntegerToString(MA3)+")");
   

   //--- check for input parameters
   if (MA1<=0 || step<=0 || MA1>=MA2 || MA1>=MA3 || MA2>=MA3) {
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
   //limit = 500;
   for (i=0;i<limit;i++) { 
      if (MA1Show) {
         line1Buffer[i] = iMA(NULL,0,MA1,0,MODE_SMA,PRICE_CLOSE,i);
      }
      if (MA3Show){
         line6Buffer[i] = iMA(NULL,0,MA3,0,MODE_SMA,PRICE_CLOSE,i);
      }

      double ma_i = iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,i);
      line2Buffer[i] = ma_i;
      
      if (MA2NeedColor) {
         double ma_i_pre =  iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,i+1);
        
         //double diff = StringToDouble(DoubleToStr((ma_i - ma_i_pre) / Point,1));
         double diff = MathRound((ma_i - ma_i_pre) / Point);
         double diffAbs = MathAbs(diff);
         //Print(diff);
         if (diffAbs < step) {
            line4Buffer[i] = ma_i;
            line3Buffer[i] = EMPTY_VALUE;
            line5Buffer[i] = EMPTY_VALUE;
         } else if (diffAbs == step) {
         //Print("相等---"+i);
            line4Buffer[i] = ma_i;
            line3Buffer[i] = EMPTY_VALUE;
            line5Buffer[i] = EMPTY_VALUE;
         } else {
            if (diff > 0){
               line5Buffer[i] = ma_i;
               line3Buffer[i] = EMPTY_VALUE;
               line4Buffer[i] = EMPTY_VALUE;
            } else {
               line3Buffer[i] = ma_i;
               line4Buffer[i] = EMPTY_VALUE;
               line5Buffer[i] = EMPTY_VALUE;
            }
         }
      }
    
    
    }
   return(rates_total);
  }
//+------------------------------------------------------------------+

