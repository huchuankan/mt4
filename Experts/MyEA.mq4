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

//均线参数
input int      MA1 = 7;
input int      MA2 = 17;
input int      MA3 = 34;

//+------------------------------------------------------------------+
string orderComment;
int openSlip;//开仓滑点数
int closeSlip;//平仓滑点数
double lots;//下单量

//记录下单时间
datetime buytime = 0;
datetime selltime = 0;

datetime alerttime = 0;

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
    //checkAlert();
    //runEA_macd();
    //runEA_macd_0();
    runEA_ma_cross();

    yidong(orderComment,orderMagic);
}

/*
 *macd交叉通知
 *
 */
 void checkAlert() 
 {
    int h = TimeHour(TimeCurrent());
    if (h < 10 || h > 19) {  //晚上10点后，别吵啦
       return;
    }
    int shift = 1;
    double up = iCustom(NULL,0,"myMACD",FastEMA,SlowEMA,SignalSMA,3,shift);;
    double down = iCustom(NULL,0,"myMACD",FastEMA,SlowEMA,SignalSMA,4,shift);
    
    if (MathAbs(up) < 1) {//不存在的值可能是很大或很小的一个int
      if (alerttime != Time[0]) {
         alerttime = Time[0];
         Alert("金叉");
      }
    }
    else if (MathAbs(down) < 1) {
      if (alerttime != Time[0]) {
         alerttime = Time[0];
         Alert("死叉");
      }
    }
 }

/*
* ma7 和 ma17 互穿下单
*/
 void runEA_ma_cross()
 {
     double ma7_1 = iMA(NULL,0,MA1,0,MODE_SMA,PRICE_CLOSE,1);
     double ma7_2 = iMA(NULL,0,MA1,0,MODE_SMA,PRICE_CLOSE,2);
     
     double ma17_1 = iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,1);
     double ma17_2 = iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,2);
     
     if ( ma7_1 > ma17_1 && ma7_2 < ma17_2) {
         closeAll(OP_SELL,orderComment,orderMagic);
         //buy
         if (buytime != Time[0]) {
            if (buy(lots,orderStopLost,orderTakeProfit,orderComment,orderMagic)>0) {
                buytime = Time[0];
            }
         }
     
     }
     
     if ( ma7_1 < ma17_1 && ma7_2 > ma17_2) {
         closeAll(OP_BUY,orderComment,orderMagic);
         //sell
         if (selltime != Time[0]) {
            if (sell(lots,orderStopLost,orderTakeProfit,orderComment,orderMagic)>0) {
                selltime = Time[0];
            }
         }
     
     }
     
 }


/*
 *macd 柱线（快速）上穿0线，k线在7日均线上，多
 *反之空
 */
 void runEA_macd_0() 
 {
     double fast0 = iCustom(NULL,0,"myMACD",FastEMA,SlowEMA,SignalSMA,0,0);
     double slow0 = iCustom(NULL,0,"myMACD",FastEMA,SlowEMA,SignalSMA,1,0);
     
     double fast1 = iCustom(NULL,0,"myMACD",FastEMA,SlowEMA,SignalSMA,0,1);
     double slow1 = iCustom(NULL,0,"myMACD",FastEMA,SlowEMA,SignalSMA,1,1);
     
     double fast2 = iCustom(NULL,0,"myMACD",FastEMA,SlowEMA,SignalSMA,0,2);
     double slow2 = iCustom(NULL,0,"myMACD",FastEMA,SlowEMA,SignalSMA,1,2);
     
     double fast3 = iCustom(NULL,0,"myMACD",FastEMA,SlowEMA,SignalSMA,0,3);
     double slow3 = iCustom(NULL,0,"myMACD",FastEMA,SlowEMA,SignalSMA,1,3);
     
     double fast4 = iCustom(NULL,0,"myMACD",FastEMA,SlowEMA,SignalSMA,0,4);
     double slow4 = iCustom(NULL,0,"myMACD",FastEMA,SlowEMA,SignalSMA,1,4);
     
     double fastArr[6] ;//= {fast0,fast1,0,fast2,fast3,fast4}; 
     fastArr[0] = fast0;fastArr[1] = fast1;fastArr[2] = 0;fastArr[3] = fast2;fastArr[4] = fast3;fastArr[5] = fast4;
     
     double slowArr[5] ;//= {slow0,slow1,slow2,slow3,slow4}; 
     slowArr[0] = slow0;slowArr[1] = slow1;slowArr[2] = slow2;slowArr[3] = slow3;slowArr[4] = slow4;
     
     double ma7_0 = iMA(NULL,0,MA1,0,MODE_SMA,PRICE_CLOSE,0);
     double ma7_1 = iMA(NULL,0,MA1,0,MODE_SMA,PRICE_CLOSE,1);
     double ma7_2 = iMA(NULL,0,MA1,0,MODE_SMA,PRICE_CLOSE,2);
     double ma7_3 = iMA(NULL,0,MA1,0,MODE_SMA,PRICE_CLOSE,3);
     
     double ma17_0 = iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,0);    
     double ma17_1 = iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,1);
     double ma17_2 = iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,2);
     double ma17_3 = iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,3);   
     
     double ma7Arr[4] ;//= {ma7_0,ma7_1,ma7_2,ma7_3};
     ma7Arr[0] = ma7_0;ma7Arr[1] = ma7_1;ma7Arr[2] = ma7_2;ma7Arr[3] = ma7_3;
     double ma17Arr[3];// = {ma17_0,ma17_1,ma17_2}; 
     ma17Arr[0] = ma17_0;ma17Arr[1] = ma17_1;ma17Arr[2] = ma17_2;
     
//buy 入口  第一个判断可以关掉
  //if (hasOrder(OP_BUY,orderComment,orderMagic) == false) {
     if (arrOrderCheck(fastArr,true) && arrOrderCheck(slowArr,true) && fast0>slow0 && fast1>slow1 && fast2>slow2 && fast3>slow3 && fast4>slow4) {
        if (arrOrderCheck(ma7Arr,true) && arrOrderCheck(ma17Arr,true) && ma7_0>ma17_0 && ma7_1>ma17_1) {
           if (Close[1]>ma7_1 && Open[1]>ma17_1) {
              if (buytime != Time[0]) {
                 if (buy(lots,orderStopLost,orderTakeProfit,orderComment,orderMagic)>0) {
                    buytime = Time[0];
                 }
              }
           }
        }
     }
   //}
    
//sell入口 第一个判断可以关掉
  //if (hasOrder(OP_SELL,orderComment,orderMagic) == false) {
     if (arrOrderCheck(fastArr,false) && arrOrderCheck(slowArr,false) && fast0<slow0 && fast1<slow1 && fast2<slow2 && fast3<slow3 && fast4<slow4) {
        if (arrOrderCheck(ma7Arr,false) && arrOrderCheck(ma17Arr,false) && ma7_0<ma17_0 && ma7_1<ma17_1) {
           if (Close[1]<ma7_1 && Open[1]<ma17_1) {
              if (selltime != Time[0]) {
                 if (sell(lots,orderStopLost,orderTakeProfit,orderComment,orderMagic)>0) {
                     selltime = Time[0];
                 }
              }
           }
        }
     }
   //}
   
 }

/*
 *macd交叉开单,但是且三线单边排列 （概率太低）
 *
 */
 void runEA_macd() 
 {
    int shift = 1;
    double up = iCustom(NULL,0,"myMACD",FastEMA,SlowEMA,SignalSMA,3,shift);;
    double down = iCustom(NULL,0,"myMACD",FastEMA,SlowEMA,SignalSMA,4,shift);
    double fast = iCustom(NULL,0,"myMACD",FastEMA,SlowEMA,SignalSMA,0,shift);
    double slow = iCustom(NULL,0,"myMACD",FastEMA,SlowEMA,SignalSMA,1,shift);
    
    if (MathAbs(up) < 1) {//不存在的值可能是很大或很小的一个int
       double ma7 = iMA(NULL,0,MA1,0,MODE_SMA,PRICE_CLOSE,1);
       double ma17 = iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,1);
       double ma34 = iMA(NULL,0,MA3,0,MODE_SMA,PRICE_CLOSE,1);
        if (ma34 < ma17 && ma34< ma7) {
           //buy
           if (buytime != Time[0]) {
              if (buy(lots,orderStopLost,orderTakeProfit,orderComment,orderMagic)>0) {
                  buytime = Time[0];
              }
           }
        }
    
    }
    else if (MathAbs(down) < 1) {
       double ma7 = iMA(NULL,0,MA1,0,MODE_SMA,PRICE_CLOSE,1);
       double ma17 = iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,1);
       double ma34 = iMA(NULL,0,MA3,0,MODE_SMA,PRICE_CLOSE,1);
       if (ma34 > ma17 && ma34> ma7) {
          //sell
          if (selltime != Time[0]) {
             if (sell(lots,orderStopLost,orderTakeProfit,orderComment,orderMagic)>0) {
                 selltime = Time[0];
             }
          }
       }
        
    }
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
   bool hasOrder = hasOrder(OP_BUY,com,buyMagic);

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
   bool hasOrder = hasOrder(OP_SELL,com,sellMagic);

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

/*
 * 判断是不是有下过单
 * type:开单类型 OP_BUY  OP_SELL
 * comment 订单描述
 * magit 开单魔术编号
 */
bool hasOrder(int type,string comment,int magit) 
{
  bool hasOrder = false;
  int t = OrdersTotal();
  for (int i = 0;i < OrdersTotal();i++) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true) {
          if(OrderSymbol() == Symbol() && OrderComment() == comment && OrderMagicNumber() == magit) { //&& OrderType() == type
              hasOrder = true;
              break;
          }
      }
   }
   return hasOrder;
}

/*
 * 判断数组是不是按照升序或是降序排列的
 */
bool arrOrderCheck(double& arr[],bool isJiang)
{
   int length = ArraySize(arr);
   if (length <= 0) {
      return false;
   }
   for (int i=0;i<length-1;i++) {
      if (isJiang) { //从大到小
         if (arr[i] < arr[i+1]) {
            return false;
         }
      } else { //从小到大
         if (arr[i] > arr[i+1]) {
            return false;
         }
      }
   }
   return true;
}

/*
 * 将所有指定方向的单子进行平仓 byeType:OP_BUY / OP_SELL
 * desciprtion:平掉所有多单,或平掉所有空单,不影响挂单 
 */ 
void closeAll(int byeType, string com, int magic)
{
  while (orderTradeCount(byeType,com,magic) > 0) {
    int t=OrdersTotal();
    for (int i = t - 1;i >= 0;i--) {
        if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true) {
           if (OrderSymbol() == Symbol() && OrderType() == byeType && OrderComment() == com &&  OrderMagicNumber() == magic) {
              if(OrderType() <= 1) {
                OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),closeSlip,Green);
              }
            }
        }
    }
    //Print("=======已经全部平掉"+byeType+"方向的单子,错误码====="+GetLastError());
  }
}
  
/* 获取指定方向的下单数量
 * desciprtion:所有已成交的多单数量 或者空单数量
 */
int orderTradeCount(int byeType, string com, int magic)
{
  int count=0;
  for (int i = 0;i < OrdersTotal();i++) {
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true) {
         if (OrderSymbol() == Symbol() && OrderType() == byeType && OrderComment() == com &&  OrderMagicNumber() == magic) {
            count++;
         }
      }
  }
  //Alert("orderCount="+count);
  return(count);
}