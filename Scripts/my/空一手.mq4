//+------------------------------------------------------------------+
//|                                                          空一手.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//--- input parameters
 int orderMagic = 000000;
int openSlip = 20;//开仓滑点数
int closeSlip = 5;//平仓滑点数
string orderComment = "自己空";
//下单的止损止盈点数
int      orderStopLost = 200;
int      orderTakeProfit = 0; 
int lots = 1.0;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
    sell(lots,orderStopLost,orderTakeProfit,orderComment,orderMagic);
  }
//+------------------------------------------------------------------+

/*
 * 开空单
 * params:手数,止损,止盈,注释,魔术编号
 * desciprtion:如果没有用EA下过空单,则开单(无论手工是否下过单子,都不影响开单)
               默认选择当前图表货币对,止损止盈和滑移的点数,按照小数点后5位来处理
 *
 * return:下单结果,-1表示失败,
*/
int sell(double orderLots,double sl,double tp,string com,int sellMagic)
{ 
   int result = -1;
   if (sl != 0) {
     sl = Bid + sl * Point; //Ask + sl * Point; //多一个点差止损
   }
   if (tp != 0) {
     tp = Bid - tp * Point;
   }
   result=OrderSend(Symbol(),OP_SELL,orderLots,Bid,openSlip,sl,tp,com,sellMagic,0,Blue);  
   if (result==-1) {
      Print("=======开空单失败,错误码====="+GetLastError());
   }     
   return(result);
} 
