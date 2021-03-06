//+------------------------------------------------------------------+
//|                                                    myMAColor.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//| 彩色均线指标,均线之间间隔用颜色表示
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   9
//--- plot line1
#property indicator_label1  "line1"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrFuchsia
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot line2
#property indicator_label2  "line2"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrYellow
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot line3
#property indicator_label3  "line3"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrWhite
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
//--- plot up end
#property indicator_label6  "upEnd"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot down end
#property indicator_label7  "downEnd"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrAqua
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1

//--- histogram line1
#property indicator_label8  "histogram1"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrFuchsia
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- plot line2
#property indicator_label9  "histogram2"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrYellow
#property indicator_style9  STYLE_SOLID
#property indicator_width9  1

//--- input parameters
input int      MA1 = 7;
input int      MA2 = 17;
input int      MA3 = 34;
//--- indicator buffers
double         line1Buffer[];
double         line2Buffer[];
double         line3Buffer[];
double         upBuffer[];
double         downBuffer[];
double         upEndBuffer[];
double         downEndBuffer[];
double         histogram1Buffer[];
double         histogram2Buffer[];


//--- right input parameters flag
bool      extParameters = false;

//标记单边条件下的箭头是否显示，防止同一单边条件下显示多个箭头
bool      showUpArrow = false;
bool      showDownArrow = false;

//记录当前k线时间，同一k线上对于前面的箭头计算就只计算1回，防止在一条k线上，每次价格波动都去计算箭头
datetime calculateTime = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,line1Buffer);
   SetIndexBuffer(1,line2Buffer);
   SetIndexBuffer(2,line3Buffer);
   SetIndexBuffer(3,upBuffer);
   SetIndexBuffer(4,downBuffer);
   SetIndexBuffer(5,upEndBuffer);
   SetIndexBuffer(6,downEndBuffer);
   SetIndexBuffer(7,histogram1Buffer);
   SetIndexBuffer(8,histogram2Buffer);
   
//--- set levels 指标值的进度   
   IndicatorSetInteger(INDICATOR_DIGITS,5); 
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   SetIndexArrow(3,225);
   SetIndexArrow(4,226);
   SetIndexArrow(5,74);
   SetIndexArrow(6,74);
   
   SetIndexLabel(0,"MA("+IntegerToString(MA1)+")");
   SetIndexLabel(1,"MA("+IntegerToString(MA2)+")");
   SetIndexLabel(2,"MA("+IntegerToString(MA3)+")");
   SetIndexLabel(7,"上柱");
   SetIndexLabel(8,"下柱");
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
     //
      int h=TimeHour(time[i]);
      bool inTime = h>8 && h<20;
      if (Period()>15) {
         inTime = true;
      }
      if ( inTime) {
         line1Buffer[i] = iMA(NULL,0,MA1,0,MODE_SMA,PRICE_CLOSE,i);
         line2Buffer[i] = iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,i);
         
      }
      
      line3Buffer[i] = iMA(NULL,0,MA3,0,MODE_SMA,PRICE_CLOSE,i);
      histogram1Buffer[i] = iMA(NULL,0,MA1,0,MODE_SMA,PRICE_CLOSE,i);
      histogram2Buffer[i] = iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,i);
   } 
   //Print("time[0]===----"+time[0]+"当前"+calculateTime ); //2018.08.21 16:52:00

   if (calculateTime == time[0]) {
      return (rates_total);
   }
   
   for (i=0;i<limit-1;i++) {
      int h=TimeHour(time[i]);
      bool inTime = h>8 && h<20;
      if (Period()>15) {
         inTime = true;
      }
        
      if (line1Buffer[i+1] > line2Buffer[i+1] && line1Buffer[i+2] < line2Buffer[i+2] && inTime) {
         upBuffer[i+1] = line2Buffer[i+1] - 200*Point;
      }
      if (line1Buffer[i+1] < line2Buffer[i+1] && line1Buffer[i+2] > line2Buffer[i+2] && inTime) {
         downBuffer[i+1] = line2Buffer[i+1] + 200*Point;
      } 
      double m1 = iMA(NULL,0,MA1,0,MODE_SMA,PRICE_CLOSE,i+1);
      double m2 = iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,i+1);
      string neirong =  DoubleToString(  ((m1-m2)/Point));
      //text(time[i+1],neirong,time[i+1],high[i+1],10,clrWhite,90);
      
   } 
   
    
   //确保上面的箭头能计算一遍
   calculateTime = time[0];
   //Print("时间同步----");
   return(rates_total);
  }
//+------------------------------------------------------------------+

