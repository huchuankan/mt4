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
     // yidong(orderComment,orderMagic);
     // Alert( Time[1]+""+Symbol()+""+Period());
   //Print("---" + Time[0]);
   //  test();
   //testVariance();
   Comment("3432");
  }
  
  void testBtn()
  {
    ObjectDelete("myLabel");
    ObjectDelete("myInput");
    ObjectDelete("myButton");
    addLabel("myLabel","下单量",20,20,clrWhite);
    addInput("myInput",80,20);
    addButton("myButton",150,20,"测试按钮");
    
    WindowRedraw();
    
  }
  
  
  void test()
  {
    int      FastEMA=12;
    int      SlowEMA=26;
    int      SignalSMA=9;
     int      MA1 = 7;
   int      MA2 = 17;
   int      MA3 = 34;

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
     
     double ma7Arr[3] ;//= {ma7_0,ma7_1,ma7_2,ma7_3};
     ma7Arr[0] = ma7_0;ma7Arr[1] = ma7_1;ma7Arr[2] = ma7_2;//ma7Arr[3] = ma7_3;
     double ma17Arr[3];// = {ma17_0,ma17_1,ma17_2}; 
     ma17Arr[0] = ma17_0;ma17Arr[1] = ma17_1;ma17Arr[2] = ma17_2;
     
     double aa[3]={1.1,2,2.5};
     
  bool flag =  arrOrderCheck(ma7Arr,true);
  Alert(flag);
  
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

/*
* 设置文本内容，name参数为唯一的值，比如时间
*/
void text(string name,string neirong,int x,int y,int daxiao,color yanse,double angle)
  {
    string objName = name +""+Symbol()+""+Period();
    if (ObjectFind(objName)<0) {
        ObjectCreate(objName,OBJ_LABEL,0,0,0);
        ObjectSetText(objName,neirong,daxiao,"宋体",yanse);
        ObjectSet(objName,OBJPROP_XDISTANCE,x);
        ObjectSet(objName,OBJPROP_YDISTANCE,y);
        ObjectSet(objName,OBJPROP_CORNER,0);
        ObjectSet(objName,OBJPROP_ANGLE,90);
     }
    else {
        ObjectSetText(objName,neirong,daxiao,"宋体",yanse);
        WindowRedraw();
     }
  }
  
    
void testVariance()
{
   //Alert(variance("ma",20,0,7,0,0));
   for (int i = 0; i<20; i++) {
       Print("=======计算方差====="+variance("ma",10,i,34,0,0));
   }
}
  
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
    int myDigit = 2;//精度
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
    int myDigit = 2;            //精度
    int n = ArraySize(array); //样本总数
    double total = 0.0;       //样本总和
    double totalVar = 0.0;  
    string txt = "";
    
    for (int i = 0; i < n; i++) {
        txt=txt+array[i]+",";
        total += array[i];
    }
   // Print(txt);
    double e = NormalizeDouble(total/n,myDigit);
     
    for (int i = 0; i < n; i++) {
       totalVar += (e-array[i]) * (e-array[i]);
    }
    o = NormalizeDouble(MathSqrt(totalVar/n),myDigit);
    //Print("标准差="+DoubleToString(o,1));
    return o;
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