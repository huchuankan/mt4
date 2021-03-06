//+------------------------------------------------------------------+
//|                                                    TradeTime.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window


//均线周期
input int      start = 8;
input int      end = 19;
input bool     show = true;
//--- indicator buffers

string drawStartTime = "";
string drawEndTime = "";
//--- right input parameters flag
bool      extParameters = false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

   //--- check for input parameters
   if (start<0 || end>=24 || start>=24 || end<0) {
      Alert("Wrong input parameters");
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
   if (!extParameters || Period() >= 60 || !show){
     ObjectsDeleteAll(0,OBJ_VLINE);
     return(0);
   }
   int i = 0;
   int limit;
   limit = rates_total - prev_calculated;
   if (prev_calculated > 0) {
      limit++;
   }

   //limit = 500;
   for (i=limit-1;i>=0;i--) { 
   
      int h=TimeHour(time[i]);
      int m = TimeMinute(time[i]);
      
      if (h == start && m == 0){
         string timeStr = getTimeStr(time[i]);
         if (drawStartTime != timeStr) {
            ObjectCreate(timeStr,OBJ_VLINE,0,time[i],open[i]);
            ObjectSet(timeStr,OBJPROP_COLOR,clrLime);
            ObjectSet(timeStr,OBJPROP_WIDTH,2);
            drawStartTime = timeStr;
            Print("交易开始时间");
         }
      }
      if (h == end && m == 0){
         string timeStr = getTimeStr(time[i]);
         if (drawEndTime != timeStr) { 
            ObjectCreate(timeStr,OBJ_VLINE,0,time[i],open[i]);
            ObjectSet(timeStr,OBJPROP_COLOR,clrRed);
            ObjectSet(timeStr,OBJPROP_WIDTH,2);
            drawEndTime = timeStr;
            Print("交易结束时间");
         }
      }
    }
   return(rates_total);
  }
//+------------------------------------------------------------------+

string getTimeStr(datetime time)
{
   string year = IntegerToString(TimeYear(time));
   string month = TimeMonth(time) > 9 ? IntegerToString(TimeMonth(time)) : "0" + IntegerToString(TimeMonth(time));
   string day = TimeDay(time) > 9 ? IntegerToString(TimeDay(time)) : "0" + IntegerToString(TimeDay(time));
   string hour = TimeHour(time) > 9 ? IntegerToString(TimeHour(time)) : "0" + IntegerToString(TimeHour(time));
   return year+month+day+hour;
}
