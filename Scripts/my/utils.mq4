//+------------------------------------------------------------------+
//|                                                        utils.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//--- input parameters
input int orderMagic = 123456;
input int moveStopLost = 100; //移动止损点数
input int startMoveStopLost = 0; //开始移动止损的盈利点数
input int startSaveProfit = 100; //盈利多少点开始保本（止损到1点盈利）

//-;-- my parameters
string orderComment;
int openSlip;//开仓滑点数
int closeSlip;//平仓滑点数

void OnStart()
  {   
   orderComment = Symbol();
   openSlip = 20;
   closeSlip = 5;
   
   //int a=  buy(0.1,0,0,orderComment,orderMagic);
   //Sleep(500);
   //int b = sell(0.2,0,0,orderComment,orderMagic);
    //OrderSend(Symbol(),OP_BUY,0.1,Ask,50,Ask-200*Point,Ask+300*Point,"",0,0,White);
    //OrderSend(Symbol(),OP_BUY,0.2,Ask,50,Ask-200*Point,Ask+300*Point,"",0,0,White);
    //closeAll();
    //closeAll(OP_SELL,orderComment,orderMagic);
    //modify(1000,1000);
    //Alert(DoubleToStr(Point,5));
    //closeallprofit();
      yidong(orderComment,orderMagic);
  }
/*
 * 修改已开仓的订单的止盈止损
 * params :止盈和止损的点数
 * desciprtion:仅仅操作EA创建的订单,不影响其他手工订单,止盈和止损的点数,按照小数点后5位来处理,如果为0,则保留原样
 */
void modify(int slpoint,int tppoint)
{
  int t = OrdersTotal();
  for (int i = t - 1;i >= 0;i--) {
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true) {
         string comment = OrderComment();
         int magic = OrderMagicNumber();
         if(OrderSymbol() == Symbol() && OrderType() <=1 && comment == orderComment && magic == orderMagic) {
            double mysl = 0;
            double mytp = 0;
            double p=MarketInfo(OrderSymbol(),MODE_POINT);
            if (OrderType() == OP_BUY) {
                if (slpoint != 0) {
                   mysl = OrderOpenPrice() - slpoint * p;
                }else {
                   mysl = OrderStopLoss();
                }
                if (tppoint != 0) {
                   mytp = OrderOpenPrice() + tppoint * p;
                }else {
                   mytp = OrderTakeProfit(); 
                }
                OrderModify(OrderTicket(),OrderOpenPrice(),mysl,mytp,CLR_NONE);
            }
            else if (OrderType() == OP_SELL) {
                if (slpoint != 0) {
                   mysl = OrderOpenPrice() + slpoint * p;
                }else {
                   mysl = OrderStopLoss(); 
                }
                if (tppoint != 0) {
                    mytp = OrderOpenPrice() - tppoint * p;
                }else {
                    mytp = OrderTakeProfit(); 
                }
                OrderModify(OrderTicket(),OrderOpenPrice(),mysl,mytp,CLR_NONE);
            }          
         }
      }
  }
}

/*
 * 关闭所有本EA下的单(开单和挂单)
 * desciprtion:仅仅操作EA创建的订单,不影响其他手工订单
 */ 
void closeAll()
{
  while (orderTradeCount() > 0) {
    int t=OrdersTotal();
    for (int i = t - 1;i >= 0;i--) {
        if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true) {
           string comment = OrderComment();
           int magic = OrderMagicNumber();
           if (OrderSymbol() == Symbol() && comment == orderComment && magic == orderMagic) {
              if(OrderType() <= 1) {
                OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),closeSlip,Green);
              }
              else {
                OrderDelete(OrderTicket());
              }
            }
        }
    }
    Print("=======已关闭所有EA的订单,错误码====="+GetLastError());
  }
}
  
 /* 获取单子的数量(包括开单和挂单)
 *  desciprtion:仅仅获取EA创建的订单的数量,不计算其他手工订单
 */
int orderTradeCount()
{
  int count=0;
  for (int i = 0;i < OrdersTotal();i++) {
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true) {
         string comment = OrderComment();
         int magic = OrderMagicNumber();
         if (OrderSymbol() == Symbol() && comment == orderComment && magic == orderMagic) {
            count++;
         }
      }
  }
  return(count);
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
    Print("=======已经全部平掉"+byeType+"方向的单子,错误码====="+GetLastError());
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
  Alert("orderCount="+count);
  return(count);
}

  
/*
 * 开多单
 * params:手数,止损,止盈,注释,魔术编号
 * desciprtion:如果没有用EA下过多单,则开单(无论手工是否下过单子,都不影响开单)
               默认选择当前图表货币对,止损止盈和滑移的点数,按照小数点后5位来处理
 *
 * return:下单结果,-1表示失败,
 */
int buy(double lots,double sl,double tp,string com,int buyMagic) 
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
        sl = Ask - sl * Point; //Bid - sl * Point; //多一个点差止损
      }
      if (tp != 0) {
        tp = Ask + tp * Point;
      }
      result=OrderSend(Symbol(),OP_BUY,lots,Ask,openSlip,sl,tp,com,buyMagic,0,White); 
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
int sell(double lots,double sl,double tp,string com,int sellMagic)
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
        sl = Bid + sl * Point;//Ask + sl * Point; //多一个点差止损
      }
      if (tp != 0) {
        tp = Bid - tp * Point;
      }
      result=OrderSend(Symbol(),OP_SELL,lots,Bid,openSlip,sl,tp,com,sellMagic,0,Blue);  
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