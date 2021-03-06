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
input int      orderTakeProfit = 300; 
//盈利多少点开始保本（止损到1点盈利）
input int startSaveProfit = 100; 

//均线参数
input int      MA1 = 7;
input int      MA2 = 17;
input int      MA3 = 34;

//其他参数
input color    labelColor = clrWhite;
//下单和平仓是自动还是手动,手动会通知
input bool     autoTrade = true;


//+------------------------------------------------------------------+
string orderComment;
int openSlip;//开仓滑点数
int closeSlip;//平仓滑点数
double lots;//下单量
int adxPeriod;//adx指标的周期

//记录下单时间
datetime buytime = 0;
datetime selltime = 0;
datetime buyNotiTime = 0;
datetime sellNotiTime = 0;
datetime closeAllNotiTime = 0;

datetime oneSideTime = 0;//单边计算时间,涉及到单边不离场
datetime hadOrderTime = 0;//有单子K线时间，防止同一K线连续做单

datetime alerttime = 0;

const int ORDER_NONE = -1;//没有下过单的状态 通OP_BUY OP_SELL
double SIMILAR_DELTA = 0; //判断相似的时候的差值范围

const int COMPARE_LARGE = 1;//数值比较，前者比后者大
const int COMPARE_EQUAL = 0;//数值比较，前者和后者在指定范围内相似
const int COMPARE_SMALL = -1;//数值比较，前者比后者小

int OnInit()
  {
   orderComment = Symbol();
   openSlip = 20;
   closeSlip = 5;
   lots = 0.01;
   SIMILAR_DELTA = 10 * Point;
   adxPeriod = 10;
   initButton();
   return(INIT_SUCCEEDED);
  }
  
void initButton()
{
   addLabel("autoLabel",autoTrade ? "自动" : "手动",20,20,labelColor);
   addLabel("lotLabel","下单量",60,20,labelColor);
   addInput("lotInput",120,20);
   ObjectSetString(0,"lotInput",OBJPROP_TEXT,DoubleToString(lots,2));
   addButton("buyButton",190,20,"多单");
   addButton("sellButton",245,20,"空单");
   addButton("closeAllButton",300,20,"全部平仓");
   addButton("resetNotiButton",390,20,"刷新通知");
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
    if (id == CHARTEVENT_OBJECT_CLICK) {
      string lotsString = ObjectGetString(0,"lotInput",OBJPROP_TEXT);
      double lotsNum = StringToDouble(lotsString);
      if (sparam == "buyButton") {
         buy(lotsNum,orderStopLost,orderTakeProfit,orderComment,orderMagic,false);
      } else if(sparam == "sellButton") {
         sell(lotsNum,orderStopLost,orderTakeProfit,orderComment,orderMagic,false);
      } else if(sparam == "closeAllButton") {
         closeAll(OP_BUY,orderComment,orderMagic,false);
         closeAll(OP_SELL,orderComment,orderMagic,false);
      } else if(sparam == "resetNotiButton") {
         buyNotiTime = 0;
         sellNotiTime = 0;
         closeAllNotiTime = 0;
      }
    }
  }

void OnDeinit(const int reason)
  { 
   ObjectDelete("autoLabel");
   ObjectDelete("lotLabel");
   ObjectDelete("lotInput");
   ObjectDelete("buyButton");
   ObjectDelete("sellButton");
   ObjectDelete("closeAllButton");
   ObjectDelete("resetNotiButton");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    int h = TimeHour(TimeCurrent());
    if ((h < 9 || h > 19) && !hasOrder(ORDER_NONE,orderComment,orderMagic)) {
       return;
    } 
    //checkAlert();
    //runEA_macd();
    //runEA_macd_0();
    //runEA_ma_cross();
    runEA_ma_adx();

    yidong(orderComment,orderMagic);
}

/*
 *macd交叉通知
 *
 */
 void checkAlert() 
 {
    int h = TimeHour(TimeCurrent());
    if (h < 9 || h > 19) {  //晚上10点后，别吵啦
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
 * ma单边排列，adx结合
 **/
 void runEA_ma_adx()
 {
    if (oneSideTime != Time[0]) {
     checkOneSide();
    }
  
    bool hasBuyOrder  = hasOrder(OP_BUY,orderComment,orderMagic);
    bool hasSellOrder = hasOrder(OP_SELL,orderComment,orderMagic);
    bool hasOrder = hasBuyOrder || hasSellOrder;
    if (hasOrder) {
        if (hadOrderTime != Time[0]) {
            hadOrderTime = Time[0];
        }
  
        double ma7_0 = iMA(NULL,0,MA1,0,MODE_SMA,PRICE_CLOSE,0);
        double ma7_1 = iMA(NULL,0,MA1,0,MODE_SMA,PRICE_CLOSE,1);
        double ma7_2 = iMA(NULL,0,MA1,0,MODE_SMA,PRICE_CLOSE,2);
        double ma17_0 = iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,0);
        double ma17_1 = iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,1);
        double ma17_2 = iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,2);

        double adx_0 = iADX(NULL,0,adxPeriod,PRICE_CLOSE,MODE_MAIN,0);
        double adx_1 = iADX(NULL,0,adxPeriod,PRICE_CLOSE,MODE_MAIN,1);
        double adx_2 = iADX(NULL,0,adxPeriod,PRICE_CLOSE,MODE_MAIN,2);
     
        double plus_di_0 = iADX(NULL,0,adxPeriod,PRICE_CLOSE,MODE_PLUSDI,0);
        double plus_di_1 = iADX(NULL,0,adxPeriod,PRICE_CLOSE,MODE_PLUSDI,1);
        double minus_di_0 = iADX(NULL,0,adxPeriod,PRICE_CLOSE,MODE_MINUSDI,0);
        double minus_di_1 = iADX(NULL,0,adxPeriod,PRICE_CLOSE,MODE_MINUSDI,1);
        
        if (hasBuyOrder) {
           // 平仓条件:(buy)------------------------
           // 收盘价1低于7日均线且adx0,1,2下跌    adx0<25  DI-,DI+交叉  收盘价1低于17均线
           if ((compare(Close[1],ma7_1) == COMPARE_SMALL && adx_0 < adx_1 && adx_1 < adx_2) || adx_0 < 25 || plus_di_0 < minus_di_0 || Close[1] < ma17_1) {
              closeAll(OP_BUY,orderComment,orderMagic);
           }
        }
        if (hasSellOrder) {
           if ((compare(Close[1],ma7_1) == COMPARE_LARGE && adx_0 < adx_1 && adx_1 < adx_2) || adx_0 < 25 || plus_di_0 > minus_di_0 || Close[1] > ma17_1) {
              closeAll(OP_SELL,orderComment,orderMagic);
           }
        }
    } else {
        if (hadOrderTime == Time[0]) { //防止同k线，平仓后又瞬间开仓做单
            return;
        }
        double ma7_0 = iMA(NULL,0,MA1,0,MODE_SMA,PRICE_CLOSE,0);
        double ma7_1 = iMA(NULL,0,MA1,0,MODE_SMA,PRICE_CLOSE,1);
        double ma7_2 = iMA(NULL,0,MA1,0,MODE_SMA,PRICE_CLOSE,2);
        double ma17_0 = iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,0);
        double ma17_1 = iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,1);
        double ma17_2 = iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,2);
        double ma34_1 = iMA(NULL,0,MA3,0,MODE_SMA,PRICE_CLOSE,1);

        double adx_0 = iADX(NULL,0,adxPeriod,PRICE_CLOSE,MODE_MAIN,0);
        double adx_1 = iADX(NULL,0,adxPeriod,PRICE_CLOSE,MODE_MAIN,1);
        double adx_2 = iADX(NULL,0,adxPeriod,PRICE_CLOSE,MODE_MAIN,2);
     
        double plus_di_0 = iADX(NULL,0,adxPeriod,PRICE_CLOSE,MODE_PLUSDI,0);
        double plus_di_1 = iADX(NULL,0,adxPeriod,PRICE_CLOSE,MODE_PLUSDI,1);
        double plus_di_2 = iADX(NULL,0,adxPeriod,PRICE_CLOSE,MODE_PLUSDI,2);
        double minus_di_0 = iADX(NULL,0,adxPeriod,PRICE_CLOSE,MODE_MINUSDI,0);
        double minus_di_1 = iADX(NULL,0,adxPeriod,PRICE_CLOSE,MODE_MINUSDI,1);
        double minus_di_2 = iADX(NULL,0,adxPeriod,PRICE_CLOSE,MODE_MINUSDI,2);
        
        
        //开仓条件1:(buy)-------------------------------------
        //k线实体在7日均线上 && 多头排列
        //7日1,17日均线的0,1,2都上升趋势
        //adx线0,1大于25 && 0,1,2值递增
        //DI+的0,1 分别大于DI-的0,1
        //开仓条件2:(buy)------------------------------------
        //1号k线阳线 && k线实体在7日均线上 && 多头排列
        //7日1,17日均线的0,1,2都上升
        //DI+,DI-交叉后,DI+0,1,2递增,DI-0,1,2递减 && adx>20 && adx夹在两线中间
        if (compare(Close[1],ma7_1) >= COMPARE_EQUAL && compare(Open[1],ma7_1) >= COMPARE_EQUAL && ma7_1 > ma17_1) {
            if (ma7_0 > ma7_1 && ma7_1 > ma7_2 && compare(ma17_1,ma17_2) >= COMPARE_EQUAL && compare(ma17_0,ma17_1) >= COMPARE_EQUAL) {
            
               if (adx_0 > 25 && adx_1 > 25 && adx_0 > adx_1 && adx_1 > adx_2) {
                  if (plus_di_0 > minus_di_0 && plus_di_1 > minus_di_1) {
                     //buy
                     if (buytime != Time[0]) {
                        if (buy(lots,orderStopLost,orderTakeProfit,orderComment,orderMagic)>0) {
                            buytime = Time[0];
                        }
                     }
                  }
               }
               if (plus_di_0 > adx_0 && adx_0 > minus_di_0 && adx_0 > 20 ) {
                  if (plus_di_1 < minus_di_1 || plus_di_2 < minus_di_2) {
                     if (plus_di_0 > plus_di_1 && plus_di_1 > plus_di_2 && minus_di_0 < minus_di_1 && minus_di_1 < minus_di_2) {
                        //buy
                        if (buytime != Time[0]) {
                           if (buy(lots,orderStopLost,orderTakeProfit,orderComment,orderMagic)>0) {
                               buytime = Time[0];
                           }
                        }
                     }
                  }
               }
               
            }
        }
        if (compare(Close[1],ma7_1) <= COMPARE_EQUAL && compare(Open[1],ma7_1) <= COMPARE_EQUAL && ma7_1 < ma17_1) {
            if (ma7_0 < ma7_1 && ma7_1 < ma7_2 && compare(ma17_1,ma17_2) <= COMPARE_EQUAL && compare(ma17_0,ma17_1) <= COMPARE_EQUAL) {
            
               if (adx_0 > 25 && adx_1 > 25 && adx_0 > adx_1 && adx_1 > adx_2) {
                  if (plus_di_0 < minus_di_0 && plus_di_1 < minus_di_1) {
                     //sell
                     if (selltime != Time[0]) {
                        if (sell(lots,orderStopLost,orderTakeProfit,orderComment,orderMagic)>0) {
                            selltime = Time[0];
                        }
                     }
                  }
               }
               if (plus_di_0 < adx_0 && adx_0 < minus_di_0 && adx_0 > 20 ) {
                  if (plus_di_1 > minus_di_1 || plus_di_2 > minus_di_2) {
                     if (plus_di_0 < plus_di_1 && plus_di_1 < plus_di_2 && minus_di_0 > minus_di_1 && minus_di_1 > minus_di_2) {
                        //buy
                        if (selltime != Time[0]) {
                           if (sell(lots,orderStopLost,orderTakeProfit,orderComment,orderMagic)>0) {
                               selltime = Time[0];
                           }
                        }
                     }
                  }
               }
               
            }
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
int buy(double orderLots,double sl,double tp,string com,int buyMagic, bool fromAuto=true) 
{
   int result = -1;
   bool hasOrder = hasOrder(ORDER_NONE,com,buyMagic);
   
   if(hasOrder == false) {
      if (autoTrade || !fromAuto) 
         {if (sl != 0) {
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
      //发通知
      if (buyNotiTime != Time[0]) { 
         buyNotiTime = Time[0];  
         sentMyNotification(Symbol() + ":在" + Ask + "开多单啦"+ Time[0]); 
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
int sell(double orderLots,double sl,double tp,string com,int sellMagic, bool fromAuto=true)
{ 
   int result = -1;
   bool hasOrder = hasOrder(ORDER_NONE,com,sellMagic);

   if(hasOrder == false) {
      if (autoTrade || !fromAuto) {
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
      if (sellNotiTime != Time[0]) { 
         sellNotiTime = Time[0];  
         sentMyNotification(Symbol() + ":在" + Bid + "开空单啦"+ Time[0]); 
      }
   }
   return(result);
} 

/*
 * 将所有指定方向的单子进行平仓 byeType:OP_BUY / OP_SELL
 * fromAuto:平仓指令来自于自动程序,还是来自于手动点击按钮
 * desciprtion:平掉所有多单,或平掉所有空单,不影响挂单 
 */ 
void closeAll(int byeType, string com, int magic, bool fromAuto=true)
{ 
   if (autoTrade || !fromAuto) {
      while (orderTradeCount(byeType,com,magic) > 0) {
         int t = OrdersTotal();
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
   if(closeAllNotiTime != Time[0]) { 
      closeAllNotiTime = Time[0];  
      sentMyNotification(Symbol() + ":要平仓啦" + Time[0]);
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
  return(count);
}


/*
 * 发通知
 */
 void sentMyNotification(string text)
 {
  
  SendNotification(text);
  Alert(text);
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
 * type:开单类型 OP_BUY  OP_SELL ORDER_NONE表示所有单
 * comment 订单描述
 * magit 开单魔术编号
 */
bool hasOrder(int type,string comment,int magit) 
{
  bool hasOrder = false;
  int t = OrdersTotal();
  for (int i = 0;i < OrdersTotal();i++) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true) {
          if(OrderSymbol() == Symbol() && OrderComment() == comment && OrderMagicNumber() == magit) {
            if (type == ORDER_NONE ||  OrderType() == type) {
                hasOrder = true;
                break;
            }
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
 *  判断前值比后值小,或者相似
 */
bool smallOrSimilar(double smallVlaue, double bigValue)
{
  return smallVlaue <= bigValue + SIMILAR_DELTA;
}

/*
 *  判断前值与后值大小
 */
int compare(double value1, double value2)
{
   if (value1 > value2 + SIMILAR_DELTA) {
      return COMPARE_LARGE;
   } else if (value1 + SIMILAR_DELTA < value2) {
      return COMPARE_SMALL;
   } else {
      return COMPARE_EQUAL;
   }
}

/*
 *  判断K线的单边属性
 */
void checkOneSide ()
{


}








 
 
 /*
 * 添加一个按钮
 */
 void addButton(string name,int x,int y,string text,int width=0)
 {
   if (ObjectFind(name) >= 0) {
     ObjectDelete(name);
   }

   ObjectCreate(0,name,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrBlue);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrDarkGray);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   if (width <= 0) {
      int as = StringLen(text);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,as * 17 + 10);
    } else {
      ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
    }
   ObjectSetInteger(0,name,OBJPROP_YSIZE,20);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
   //ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,clrOrange);
   //ObjectSetInteger(0,name,OBJPROP_CORNER,0);//四个角落哪个角落为原点
 }
 
 /*
 * 添加一个输入框
 */
 void addInput(string name,int x,int y)
 {
  if (ObjectFind(name) >= 0) {
     ObjectDelete(name);
  } 
 
   ObjectCreate(0,name,OBJ_EDIT,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
//--- set object size
   ObjectSetInteger(0,name,OBJPROP_XSIZE,60);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,20);

   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
//--- set the type of text alignment in the object
   ObjectSetInteger(0,name,OBJPROP_ALIGN,ALIGN_LEFT);
//--- enable (true) or cancel (false) read-only mode
   ObjectSetInteger(0,name,OBJPROP_READONLY,false);
   //ObjectSetInteger(0,name,OBJPROP_CORNER,0);
//--- set text color
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrBlack);
   //--- set background color
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrAliceBlue);
//--- set border color
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,clrBlue);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetString(0,name,OBJPROP_TEXT,"0.01");
}
 
 /*
 * 添加一个标签
 */
void addLabel(string name,string text,int x,int y,color fontColor)
{
   int fontSize = 13;
   string font = "宋体";
   if (ObjectFind(name) < 0) {
      ObjectCreate(name,OBJ_LABEL,0,0,0);
      ObjectSetText(name,text,fontSize,font,fontColor);
      ObjectSet(name,OBJPROP_XDISTANCE,x);
      ObjectSet(name,OBJPROP_YDISTANCE,y);
      ObjectSet(name,OBJPROP_CORNER,0);
   } else {
      ObjectSetText(name,text,fontSize,font,fontColor);
      WindowRedraw();
   }
}