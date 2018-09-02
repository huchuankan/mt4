//+------------------------------------------------------------------+
#property show_inputs
extern string 开始时间 = "2010.02.23";
extern string 结束时间 = "2010.03.05";
//+------------------------------------------------------------------+
int start()
  {
Alert("账户:"+AccountNumber()+"\n在本段时间内"+开始时间
   +"____"+结束时间+"的\n已平仓的交易量总计："+DoubleToStr(CountOrdersLots(),2)+"手");
   return(0);
  }
double CountOrdersLots()
  {
   int orders=OrdersHistoryTotal();
   double LotsSum;
   for(int i=orders-1;i>=0;i--)
      {
       OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
       if(OrderType()==OP_BUY || OrderType()==OP_SELL)
         {
          if(StrToTime(开始时间)<=OrderOpenTime() && StrToTime(结束时间)+86400>=OrderOpenTime())
             LotsSum+=OrderLots();
         }
      }
    return(LotsSum);
  }
//+------------------------------------------------------------------+

