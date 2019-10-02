//+------------------------------------------------------------------+
//|                                         ArbitrageReverse_1.1.mq4 |
//|                               Copyright © 2007, Yury V. Reshetov |
//|                                          http://reshetov.xnet.uz |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Yury V. Reshetov"
#property link      "http://reshetov.xnet.uz"
//---- input parameters
extern double experts = 1;
extern double beginPrice = 1.8014;
static int    FactorLots = 5000; //100=0.01 lots, 50=0.02 lots, 20=0.05 lots, ...
extern int    magicnumber = 777;
static int    prevtime = 0;
static double bl = 1000;
double dig;
extern bool CloseTimeFilter=true;
extern int CloseHour=23;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
   if((CloseTimeFilter&&Hour()>=CloseHour)&&AccountEquity()>AccountBalance())
   {
      CloseBuyOrders(magicnumber);
      CloseSellOrders(magicnumber);
      return(0);
   }
   double minLot = MarketInfo(Symbol(),MODE_MINLOT);
   if (minLot==0.01){dig=2;}
   if (minLot==0.1){dig=1;}
   if(Time[0] == prevtime) 
       return(0);
   prevtime = Time[0];
   if(!IsTradeAllowed()) 
     {
       prevtime = Time[1];
       return(0);
     }
//----
   int total = OrdersHistoryTotal();
   double money = bl * beginPrice;
   int i = 0;
   for (i = 0; i < total; i++) 
     {
       OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
       if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicnumber) 
         {
           if(OrderType() == OP_BUY) 
             {
               money = money + (OrderClosePrice() - 
                       OrderOpenPrice()) * 10 * OrderLots();
             } 
           else 
             {
               money = money - (OrderClosePrice() - 
                       OrderOpenPrice()) * 10 * OrderLots();
             }
         }
     }
   total = OrdersTotal();   
   double com =  bl;
   int tickbuy = -1;
   double buyprofit = 0;
   double buyvolume = 0;
   int ticksell = -1;
   double sellprofit = 0;
   double sellvolume = 0;
   for(i = 0; i < total; i++) 
     {
       OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
       if(OrderMagicNumber() == magicnumber) 
         {
           if(OrderType() == OP_BUY) 
             {
               if(OrderSymbol() == Symbol()) 
                 {
                   buyvolume = OrderLots();
                   money = money - 10 * buyvolume * OrderOpenPrice();
                   tickbuy = OrderTicket();
                   buyprofit = OrderProfit();
                 }
               com = com + 10 * OrderLots(); 
             } 
           else 
             {
               if(OrderSymbol() == Symbol()) 
                 {
                   sellvolume = OrderLots();
                   money = money + 10 * sellvolume * OrderOpenPrice();
                   ticksell = OrderTicket();
                   sellprofit = OrderProfit();
                 }
               com = com - 10 * OrderLots(); 
             }
         }
     }
   if(! IsTradeAllowed()) 
     {
       prevtime = Time[1];
       return(0);
     }
   closeby(ticksell, tickbuy);
   if(!IsTradeAllowed()) 
     {
       prevtime = Time[1];
       return(0);
     }
   double lots = 0;
   double price = 0;
   double dt = (money / Ask - com) * experts / (experts + 1);
   if(dt < 0) 
     {
       if(buyprofit < 0) 
           return(0);
       if(sellprofit > 0.01) 
           return(0);
       dt = (com - money / Bid) * experts / (experts + 1);
       if(dt < 1) 
         {
           closeby(tickbuy, ticksell);
           return(0);
         }
       if(dt > 10) 
           dt = 10;
       lots = MathFloor(dt) / 10;
       if(tickbuy >= 0) 
         {
           if(buyvolume > lots) 
             {
               OrderClose(tickbuy, lots, Bid, 3, Blue);
               Sleep(30000);
             } 
           else 
             {
               OrderClose(tickbuy, buyvolume, Bid, 3, Blue);
               tickbuy = -1;
               Sleep(30000);
             }
         } 
       else 
         {
           lots = getLots(lots);
           if(lots > 0) 
             {
               ticksell = OrderSend(Symbol(), OP_SELL, NormalizeDouble(lots/FactorLots,dig), Bid, 3, 
                          0, 0, "ArbitrageReverse", magicnumber, 0, Red);
               Sleep(30000);
             }
         }
     } 
   else 
     {
       if(sellprofit < 0) 
           return(0);
       if(buyprofit > 0.001) 
           return(0);
       if(dt < 1) 
         {
           closeby(ticksell, tickbuy);
           return(0);
         }
       if(dt > 10) 
           dt = 10;
       lots = MathFloor(dt) / 10;
       if(ticksell >= 0) 
         {
           if(sellvolume > lots) 
             {
               OrderClose(ticksell, lots, Ask, 3, Red);
               Sleep(30000);
             } 
           else 
             {
               OrderClose(ticksell, sellvolume, Ask, 3, Red);
               ticksell = -1;
               Sleep(30000);
             }
         } 
       else 
         {
           lots = getLots(lots);
           if(lots > 0) 
             {
               tickbuy = OrderSend(Symbol(), OP_BUY, NormalizeDouble(lots/FactorLots,dig), Ask, 3, 0, 
                         0, "ArbitrageReverse",  magicnumber, 0, Blue);
               Sleep(30000);
             }
         }
     }
//----
   if(!IsTradeAllowed()) 
     {
       prevtime = Time[1];
       return(0);
     }
   closeby(tickbuy, ticksell);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeby(int sell, int buy) 
  {
   if(sell >= 0 && buy >= 0) 
     {
       OrderCloseBy(buy, sell, Green);
       Sleep(30000);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getLots(double lt) 
  {
   double marginrequired = MarketInfo(Symbol(), MODE_MARGINREQUIRED);
   double freemargin = AccountFreeMargin();
   if(freemargin > (marginrequired * lt)) 
     {
       return(lt);
     } 
   double result = freemargin / marginrequired;
   result = MathFloor(result * 10) / 10;
   return(result);
  }
//+------------------------------------------------------------------+

//|---------close buy orders

int CloseBuyOrders(int Magic)
{
  int result,total=OrdersTotal();

  for (int cnt=total-1;cnt>=0;cnt--)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if(OrderMagicNumber()==Magic&&OrderSymbol()==Symbol())
    {
      if(OrderType()==OP_BUY)
      {
        OrderClose(OrderTicket(),OrderLots(),Bid,3);
        switch(OrderType())
        {
          case OP_BUYLIMIT:
          case OP_BUYSTOP:
          result=OrderDelete(OrderTicket());
        }
      }
    }
  }
  return(0);
}

//|---------close sell orders

int CloseSellOrders(int Magic)
{
  int result,total=OrdersTotal();

  for(int cnt=total-1;cnt>=0;cnt--)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if(OrderMagicNumber()==Magic&&OrderSymbol()==Symbol())
    {
      if(OrderType()==OP_SELL)
      {
        OrderClose(OrderTicket(),OrderLots(),Ask,3);
        switch(OrderType())
        {
          case OP_SELLLIMIT:
          case OP_SELLSTOP:
          result=OrderDelete(OrderTicket());
        }
      }
    }
  }
  return(0);
}