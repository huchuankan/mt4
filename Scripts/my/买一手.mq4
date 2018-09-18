//+------------------------------------------------------------------+
//|                                                          买一手.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//--- input parameters
 int orderMagic = 000000;
int openSlip = 20;//开仓滑点数
int closeSlip = 5;//平仓滑点数
string orderComment = "自己买";
//下单的止损止盈点数
int      orderStopLost = 200;
int      orderTakeProfit = 0; 
int lots = 1.0;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
    buy(lots,orderStopLost,orderTakeProfit,orderComment,orderMagic)>0;
  }
//+------------------------------------------------------------------+


  
/*
 * 开多单
 * params:手数,止损,止盈,注释,魔术编号
 * desciprtion:如果没有用EA下过多单,则开单(无论手工是否下过单子,都不影响开单)
               默认选择当前图表货币对,止损止盈和滑移的点数,按照小数点后5位来处理
 *
 * return:下单结果,-1表示失败,
 */
int buy(double orderLots,double sl,double tp,string com,int buyMagic) 
{
   int result = -1;
   if (sl != 0) {
     sl = Ask - sl * Point;  //Bid - sl * Point; //多一个点差止损
   }
   if (tp != 0) {
     tp = Ask + tp * Point;
   }
   result=OrderSend(Symbol(),OP_BUY,orderLots,Ask,openSlip,sl,tp,com,buyMagic,0,White); 
   if (result==-1) {
      Print("=======开多单失败,错误码====="+GetLastError());
   }      
   return(result);
}