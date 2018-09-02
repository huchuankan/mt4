//+------------------------------------------------------------------+
//|                                      �����������GMTʱ��ƽ��.mq4 |
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
��    ��
���������
���������
��    ��:
*/
double iGMTDifference()
  {
    int GMT=StrToDouble(iWorldTime(0,0)); //��ø�������ʱ��
    int ServerTime=StrToDouble(TimeToStr(TimeCurrent(),TIME_MINUTES)); //���MT4������ʱ��
    iDisplayInfo("Author", "����:���� 520FX",1,10,15,8,"Times New Roman",SlateGray);
    iDisplayInfo("wing",CharToStr(175),1,20,25,30,"Wingdings", Gold);
    Alert("��ʷ��������ƽ��ʱ��Ϊ: "+(ServerTime-GMT));
  }
/*
��    �������㵱��ʱ��
���������int myTimeZone ����ʱ�� string myLocalSummerTime ����ʱ
���������ָ��ʱ��ʱ�䣬��ʽ��hh:mm:ss
��    ������ȡ���ؼ����ʱ�䣬����ʱ�䣬����GMTʱ��
          ��������ʱ����
*/
string iWorldTime(int myTimeZone, string myLocalSummerTime)
   {
      string myTime; //�������ز���
      //��������ʱ��ֹ
      int mySummerStartTime = StrToTime(StringSubstr(myLocalSummerTime, 0, 16));
      int mySummerEndTime = StrToTime(StringSubstr(myLocalSummerTime, 17, 16));
      //
      string myHH,myMM,mySS;
      int GMT = TimeHour(Time[0])-2; //����GMTʱ��
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
��    ��������Ļ����ʾ���ֱ�ǩ
�����������ǩ���� �ı����� �ı���ʾ�� ��ǩXλ������ ��ǩYλ������ �ı��ֺ� �ı����� �ı���ɫ
���������
��    ����
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