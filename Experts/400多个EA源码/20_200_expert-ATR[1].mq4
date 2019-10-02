//+------------------------------------------------------------------+
//|                                               20/200 expert.mq4  |
//|                                                    1H   EUR/USD  |
//|                                                    xybare        |
//|                                                 www.eafan.net    |
//+------------------------------------------------------------------+

#property copyright "Smirnov Pavel"
#property link      "www.autoforex.ru"

extern int TakeProfit = 200; // 止盈
//extern int StopLoss = 2000; // 止损
extern int ATR_PERIOD=14;
extern double ATRSL=2;
extern int TradeTime=18;
extern int t1=7;
extern int t2=2;
extern int delta=10;
extern double lot = 0.1;
double StopLoss;
int ticket;
bool cantrade=true;
double atr;
int OpenLong(double volume=0.1)
{
  int slippage=10;
  string comment="20/200 expert (Long)";
  color arrow_color=Red;
  int magic=0;

  ticket=OrderSend(Symbol(),OP_BUY,volume,Ask,slippage,Ask-StopLoss,
                      Ask+TakeProfit*Point,comment,magic,0,arrow_color);
  if(ticket>0)
  {
    if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
    {
      Print("Buy order opened : ",OrderOpenPrice());
      return(0);
    }  
  }
  else 
  {
    Print("Error opening Buy order : ",GetLastError()); 
    return(-1);
  }
}
  
int OpenShort(double volume=0.1)
{
  int slippage=10;
  string comment="20/200 expert (Short)";
  color arrow_color=Red;
  int magic=0;  
  
  ticket=OrderSend(Symbol(),OP_SELL,volume,Bid,slippage,Bid+StopLoss,
                      Bid-TakeProfit*Point,comment,magic,0,arrow_color);
  if(ticket>0)
  {
    if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
      {
        Print("Sell order opened : ",OrderOpenPrice());
        return(0);
      }  
  }
  else 
  {
    Print("Error opening Sell order : ",GetLastError()); 
    return(-1);
  }
}

int init()
{MathSrand(TimeLocal());

  return(0);
}

int deinit()
{   
  return(0);
}

int start()
{
  atr=iATR(Symbol(),PERIOD_D1,ATR_PERIOD,1);
  StopLoss=ATRSL*atr;
  if((TimeHour(TimeCurrent())>TradeTime)) cantrade=true;  
  // 如果到指定交易时间开仓指示为真
  if(OrdersTotal()<1)
  {
   
    if((TimeHour(TimeCurrent())==TradeTime)&&(TimeMinute(TimeCurrent())>=0)&&(cantrade))
    {
      // 是否可以开仓
      if ((Open[t1]-Open[t2])>delta*Point) //如果最近的价格比以前的价格低，说明下跌，卖
            {
       
        if(AccountFreeMarginCheck(Symbol(),OP_SELL,lot)<=0 || GetLastError()==134)
        {
          Print("Not enough money");
          return(0);
        }
       OpenShort(lot);
     
        cantrade=false; 
        return(0);
      }
      if ((Open[t2]-Open[t1])>delta*Point) //如果最近的价格比以前的价格高，说明涨，我买
            {
     
        if(AccountFreeMarginCheck(Symbol(),OP_BUY,lot)<=0 || GetLastError()==134)
        {
          Print("Not enough money");
          return(0);
        }
        OpenLong(lot);
   
        cantrade=false;
        return(0);
      }
    }
  }   
  return(0);
}