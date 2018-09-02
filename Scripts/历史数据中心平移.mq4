//+------------------------------------------------------------------+
//|                                      计算服务器和GMT时间平移.mq4 |
//|                                  Copyright 2013 By Xiyu QQ:19646 |
//|                                                    www.520FX.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013 By Xiyu QQ:19646"
#property link      "www.520FX.com"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
   iGMTDifference();
   return(0);
  }
//+------------------------------------------------------------------+
/*
函    数
输出参量：
输出参数：
算    法:
*/
double iGMTDifference()
  {
    int GMT=StrToDouble(iWorldTime(0,0)); //获得格林威治时间
    int ServerTime=StrToDouble(TimeToStr(TimeCurrent(),TIME_MINUTES)); //获得MT4服务器时间
    iDisplayInfo("Author", "作者:熙羽 520FX",1,10,15,8,"Times New Roman",SlateGray);
    iDisplayInfo("wing",CharToStr(175),1,20,25,30,"Wingdings", Gold);
    Alert("历史数据中心平移时差为: "+(ServerTime-GMT));
  }
/*
函    数：计算当地时间
输入参数：int myTimeZone 本地时区 string myLocalSummerTime 夏令时
输出参数：指定时区时间，格式：hh:mm:ss
算    法：获取本地计算机时间，北京时间，计算GMT时间
          根据夏令时调整
*/
string iWorldTime(int myTimeZone, string myLocalSummerTime)
   {
      string myTime; //函数返回参数
      //计算夏令时起止
      int mySummerStartTime = StrToTime(StringSubstr(myLocalSummerTime, 0, 16));
      int mySummerEndTime = StrToTime(StringSubstr(myLocalSummerTime, 17, 16));
      //
      string myHH,myMM,mySS;
      int GMT = TimeHour(Time[0])-2; //计算GMT时间
      int myLocalTime = GMT+myTimeZone;
      if (myLocalTime < 0) myLocalTime = myLocalTime+24;
      if (myLocalTime >= 24) myLocalTime = myLocalTime-24;
      myHH = DoubleToStr(myLocalTime,0);
      if (StringLen(myHH) == 1) myHH = "0"+myHH;
      myMM = DoubleToStr(TimeMinute(TimeLocal()),0);
      if (StringLen(myMM) == 1) myMM = "0"+myMM;
      mySS = DoubleToStr(TimeSeconds(TimeLocal()),0);
      if (StringLen(mySS) == 1) mySS = "0"+mySS;
      myTime = myHH+":"+myMM;
      if (StrToTime(myTime) > mySummerStartTime && StrToTime(myTime) < mySummerEndTime)
         {
            myHH = DoubleToStr(StrToDouble(myHH)+1,0);
            if (StringLen(myHH) == 1) myHH = "0"+myHH;
            myTime = myHH+":"+myMM+"*";
         }
      return (myTime);
   }
 
 /*
函    数：在屏幕上显示文字标签
输入参数：标签名称 文本内容 文本显示角 标签X位置坐标 标签Y位置坐标 文本字号 文本字体 文本颜色
输出参数：
算    法：
*/
void iDisplayInfo(string LableName,string LableDoc,int Corner,int LableX,int LableY,int DocSize,string DocStyle,color DocColor)
   {
      if (Corner == -1) return(0);
      ObjectCreate(LableName, OBJ_LABEL, 0, 0, 0);
      ObjectSetText(LableName, LableDoc, DocSize, DocStyle,DocColor);
      ObjectSet(LableName, OBJPROP_CORNER, Corner);
      ObjectSet(LableName, OBJPROP_XDISTANCE, LableX);
      ObjectSet(LableName, OBJPROP_YDISTANCE, LableY);
   }