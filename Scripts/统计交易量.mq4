//+------------------------------------------------------------------+
#property show_inputs
extern string ��ʼʱ�� = "2010.02.23";
extern string ����ʱ�� = "2010.03.05";
//+------------------------------------------------------------------+
int start()
  {
Alert("�˻�:"+AccountNumber()+"\n�ڱ���ʱ����"+��ʼʱ��
   +"____"+����ʱ��+"��\n��ƽ�ֵĽ������ܼƣ�"+DoubleToStr(CountOrdersLots(),2)+"��");
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
          if(StrToTime(��ʼʱ��)<=OrderOpenTime() && StrToTime(����ʱ��)+86400>=OrderOpenTime())
             LotsSum+=OrderLots();
         }
      }
    return(LotsSum);
  }
//+------------------------------------------------------------------+

