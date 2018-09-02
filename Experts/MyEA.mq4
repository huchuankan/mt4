//+------------------------------------------------------------------+
//|                                                         MyEA.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- input parameters
input int      FastEMA=12;
input int      SlowEMA=26;
input int      SignalSMA=9;
input int      orderMagic = 123456;
input int      moveStopLost = 200; 
//开始移动止损的盈利点数
input int      startMoveStopLost = 100;
//下单的止损止盈点数
input int      orderStopLost = 200;
input int      orderTakeProfit = 0; 
//盈利多少点开始保本（止损到1点盈利）
input int startSaveProfit = 100; 
//+------------------------------------------------------------------+
string orderComment;
int openSlip;//开仓滑点数
int closeSlip;//平仓滑点数
double lots;//下单量

//记录下单时间
datetime buytime = 0;
datetime selltime = 0;

int OnInit()
  {
   orderComment = Symbol();
   openSlip = 20;
   closeSlip = 5;
   lots = 1.0;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  { 
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    int h = TimeHour(TimeCurrent());
    if (h < 10 || h > 19) {
       if(OrdersTotal() > 0) {
          yidong(orderComment,orderMagic);
       }
       return;
    }
   
    int shift = 1;
    double up = iCustom(NULL,0,"myMACD",FastEMA,SlowEMA,SignalSMA,3,shift);;
    double down = iCustom(NULL,0,"myMACD",FastEMA,SlowEMA,SignalSMA,4,shift);
    double fast = iCustom(NULL,0,"myMACD",FastEMA,SlowEMA,SignalSMA,0,shift);
    double slow = iCustom(NULL,0,"myMACD",FastEMA,SlowEMA,SignalSMA,1,shift);
    
    if (MathAbs(up) < 1) {
        //buy
        if (buytime != Time[0]) {
           if (buy(lots,orderStopLost,orderTakeProfit,orderComment,orderMagic)>0) {
               buytime = Time[0];
           }
        }
    
    }
    else if (MathAbs(down) < 1) {
        //sell
        if (selltime != Time[0]) {
           if (sell(lots,orderStopLost,orderTakeProfit,orderComment,orderMagic)>0) {
               selltime = Time[0];
           }
        }
    }
    yidong(orderComment,orderMagic);
}

  
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
  bool hasOrder = false;
  int t = OrdersTotal();
  for (int i = 0;i < OrdersTotal();i++) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true) {
          if(OrderSymbol() == Symbol() && OrderType() == OP_BUY && OrderComment() == com && OrderMagicNumber() == buyMagic) {
              hasOrder = true;
              break;
          }
      }
   }

   if(hasOrder == false) {
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
   }
   return(result);
}

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
  bool hasOrder = false;
  int t = OrdersTotal();
  for (int i = 0;i < OrdersTotal();i++) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true) {
          if(OrderSymbol() == Symbol() && OrderType() == OP_SELL && OrderComment() == com && OrderMagicNumber() == sellMagic) {
              hasOrder = true;
              break;
          }
      }
   }

   if(hasOrder == false) {
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
   }
   return(result);
} 

/*
 * 移动止损
 * params:注释,魔术编号
 * desciprtion:代码会自动检测buy和sell单并对其移动止损
 */
void yidong(string com,int magic)
{
   for (int i=0;i<OrdersTotal();i++) {
        if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true) {
            int tikit = OrderTicket();
            if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderComment() == com && OrderMagicNumber()==magic) {
           
                if (((Bid - OrderOpenPrice()) >= Point * startMoveStopLost) || ((Bid - OrderOpenPrice()) >= Point * startSaveProfit)) {
                    double stopLostPoint = Bid - Point * moveStopLost;
                    double saveProfitPoint = OrderOpenPrice() + Point * 10; //利益保护1个点盈利
                    if (startSaveProfit > 0 && (Bid - OrderOpenPrice() >= Point * startSaveProfit)) {
                       if (stopLostPoint < saveProfitPoint) {
                          stopLostPoint = saveProfitPoint;
                       }
                    }
                    if (OrderStopLoss() < stopLostPoint || OrderStopLoss()==0) {
                           //double a= 12.0
                       
                        bool result = OrderModify(OrderTicket(),OrderOpenPrice(),stopLostPoint,OrderTakeProfit(),0,Green);
                        if(!result){
                           Print("==========移动止损多单失败=====",GetLastError());
                        }
                    }
                }    
            }
            if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderComment() == com && OrderMagicNumber() == magic) {
               if (((OrderOpenPrice() - Ask) >= Point * startMoveStopLost) || ((OrderOpenPrice() - Ask) >= Point * startSaveProfit)) {
                   double stopLostPoint = Ask + Point * moveStopLost;
                   double saveProfitPoint = OrderOpenPrice() - Point * 10; //利益保护1个点盈利
                   if (startSaveProfit > 0 && (OrderOpenPrice() - Ask >= Point * startSaveProfit)) {
                      if (stopLostPoint > saveProfitPoint) {
                         stopLostPoint = saveProfitPoint;
                      }
                   }
                   if ((OrderStopLoss() > stopLostPoint) || (OrderStopLoss() == 0)) {
                      bool result = OrderModify(OrderTicket(),OrderOpenPrice(),stopLostPoint,OrderTakeProfit(),0,Green);
                      if(!result){
                         Print("===========移动止损空单失败=====",GetLastError());
                      }
                   }
               }
            }
         }
    }
}