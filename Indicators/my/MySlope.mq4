//+------------------------------------------------------------------+
//|                                                      MySlope.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//| 计算指标之间的斜率，可计算间隔k之间斜率
//+------------------------------------------------------------------+

#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot line1
#property indicator_label1  "line1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrFuchsia
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot line2
#property indicator_label2  "line2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrYellow
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2


//--- input parameters
input string   指标名称 = "name=MA/MACD/ADX等";
input string   name1 = "MA";//指标名称  
input int      period1 = 20; //指标适用周期
input int      step1 = 1; //k线间隔
input string   name2 = "MA";//指标名称
input int      period2 = 20; //指标适用周期
input int      step2 = 10; //k线间隔
//--- indicator buffers
double         line1Buffer[]; 
double         line2Buffer[];

//--- right input parameters flag
bool      extParameters = false;
int       myDigit = 6;//精度
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,line1Buffer);
   SetIndexBuffer(1,line2Buffer);
//--- set levels 指标值的精度   
   IndicatorSetInteger(INDICATOR_DIGITS,myDigit); 

   
   SetIndexLabel(0,"MA("+IntegerToString(MA1)+")");
   SetIndexLabel(1,"MA("+IntegerToString(MA2)+")");
   SetIndexLabel(2,"MA("+IntegerToString(MA3)+")");
   //--- check for input parameters
   if (MA1>=MA2 || MA1>=MA3 || MA2>=MA3 || period1<=0 || period2<=0 || period3<=0) {
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
   if (rates_total <= MA3 || rates_total < period1 || rates_total < period2 || rates_total < period3 || !extParameters){
     return(0);
   }
   int i = 0;
   int limit;
   limit = rates_total - prev_calculated;
   if (prev_calculated > 0) {
      limit++;
   }
   for (i=0;i<limit;i++) {
      line1Buffer[i] = variance("ma",period1,i,MA1,0,0);
      line2Buffer[i] = variance("ma",period2,i,MA2,0,0);
      line3Buffer[i] = variance("ma",period3,i,MA3,0,0);
   } 
   
   return(rates_total);
  }
//+------------------------------------------------------------------+

 /*
 * 获取指定周期内的数组方差
 */
 double variance(string libName,int period,int shift,int p1,int p2,int p3)
 {
    double result = 0.0;
    if (period < 1) {
       Print("=======计算方差错误,样本数量不足=====");
       return -1;
    }
    double array[];
    ArrayResize(array,period);
    if (libName == "ma") {
      for (int i = 0; i<period; i++) {
         array[i] = NormalizeDouble(iMA(NULL,0,p1,0,MODE_SMA,PRICE_CLOSE,i+shift)/Point,myDigit);
      }
      result = culVariance(array);
    }
    
    return result;
 }
 
 /*
 * 具体计算方差
 */
 double culVariance(double& array[])
 {
    double o = 0.0;           //标准差
    int n = ArraySize(array); //样本总数
    double total = 0.0;       //样本总和
    double totalVar = 0.0;  
    
    for (int i = 0; i < n; i++) {
        total += array[i];
    }
    double e = NormalizeDouble(total/n,myDigit);
     
    for (int i = 0; i < n; i++) {
       totalVar += (e-array[i]) * (e-array[i]);
    }
    o = NormalizeDouble(MathSqrt(totalVar/n),myDigit);
    //Print("标准差="+DoubleToString(o,1));
    return o;
 }