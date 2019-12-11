//+------------------------------------------------------------------+
//|                                                       ZigZag.mq4 |
//|                   Copyright 2006-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "2006-2014, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property strict

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  Red
//---- indicator parameters
input int InpDepth=12;     // Depth
input int InpDeviation=5;  // Deviation
input int InpBackstep=3;   // Backstep
extern int  CCI_period=12;
//---- indicator buffers
double ExtZigzagBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double cci[];
//--- globals
int    ExtLevel=3; // recounting's depth of extremums
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpBackstep>=InpDepth)
     {
      Print("Backstep cannot be greater or equal to Depth");
      return(INIT_FAILED);
     }
//--- 2 additional buffers
   IndicatorBuffers(4);
//---- drawing settings
   SetIndexStyle(0,DRAW_SECTION);
//---- indicator buffers
   SetIndexBuffer(0,ExtZigzagBuffer);
   SetIndexBuffer(1,ExtHighBuffer);
   SetIndexBuffer(2,ExtLowBuffer);
   SetIndexStyle(3,DRAW_LINE,EMPTY,1,clrLightSlateGray);
   SetIndexBuffer(3,cci);
   SetIndexEmptyValue(0,0.0);
//---- indicator short name
   IndicatorShortName("CCI_ZigZag("+string(InpDepth)+","+string(InpDeviation)+","+string(InpBackstep)+")");
//---- initialization done
   return(INIT_SUCCEEDED);
  }
double ccilow(int bars,int shift)
  {
    double min=10000;
    for(int i=shift;i<(bars+shift);i++)
      {
        if(min>ccixian(i))
          {
            min=ccixian(i);
          }
      }
    return(min);
  }
double ccihigh(int bars,int shift)
  {
    double max=-10000;
    for(int i=shift;i<(bars+shift);i++)
      {
        if(max<ccixian(i))
          {
            max=ccixian(i);
          }
      }
    return(max);
  }
double ccixian(int shift)
  {
    return(iCCI(NULL,0,CCI_period,PRICE_CLOSE,shift));
  }
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   int    i,limit,counterZ,whatlookfor=0;
   int    back,pos,lasthighpos=0,lastlowpos=0;
   double extremum;
   double curlow=0.0,curhigh=0.0,lasthigh=0.0,lastlow=0.0;
//--- check for history and inputs
   if(rates_total<InpDepth || InpBackstep>=InpDepth)
      return(0);
//--- first calculations
   if(prev_calculated==0)
      limit=InitializeAll();
   else 
     {
      //--- find first extremum in the depth ExtLevel or 100 last bars
      i=counterZ=0;
      while(counterZ<ExtLevel && i<100)
        {
         if(ExtZigzagBuffer[i]!=0.0)
            counterZ++;
         i++;
        }
      //--- no extremum found - recounting all from begin
      if(counterZ==0)
         limit=InitializeAll();
      else
        {
         //--- set start position to found extremum position
         limit=i-1;
         //--- what kind of extremum?
         if(ExtLowBuffer[i]!=0.0) 
           {
            //--- low extremum
            curlow=ExtLowBuffer[i];
            //--- will look for the next high extremum
            whatlookfor=1;
           }
         else
           {
            //--- high extremum
            curhigh=ExtHighBuffer[i];
            //--- will look for the next low extremum
            whatlookfor=-1;
           }
         //--- clear the rest data
         for(i=limit-1; i>=0; i--)  
           {
            ExtZigzagBuffer[i]=0.0;  
            ExtLowBuffer[i]=0.0;
            ExtHighBuffer[i]=0.0;
           }
        }
     }
//--- main loop      
   for(i=limit; i>=0; i--)
     {
      //--- find lowest low in depth of bars
      extremum=ccilow(InpDepth,i);//low[iLowest(NULL,0,MODE_LOW,InpDepth,i)];
      //--- this lowest has been found previously
      if(extremum==lastlow)
         extremum=0.0;
      else 
        { 
         //--- new last low
         lastlow=extremum; 
         //--- discard extremum if current low is too high
         if(ccixian(i)-extremum>InpDeviation*Point)
            extremum=0.0;
         else
           {
            //--- clear previous extremums in backstep bars
            for(back=1; back<=InpBackstep; back++)
              {
               pos=i+back;
               if(ExtLowBuffer[pos]!=0 && ExtLowBuffer[pos]>extremum)
                  ExtLowBuffer[pos]=0.0; 
              }
           }
        } 
      //--- found extremum is current low
      if(ccixian(i)==extremum)
         ExtLowBuffer[i]=extremum;
      else
         ExtLowBuffer[i]=0.0;
      //--- find highest high in depth of bars
      extremum=ccihigh(InpDepth,i);//high[iHighest(NULL,0,MODE_HIGH,InpDepth,i)];
      //--- this highest has been found previously
      if(extremum==lasthigh)
         extremum=0.0;
      else 
        {
         //--- new last high
         lasthigh=extremum;
         //--- discard extremum if current high is too low
         if(extremum-ccixian(i)>InpDeviation*Point)
            extremum=0.0;
         else
           {
            //--- clear previous extremums in backstep bars
            for(back=1; back<=InpBackstep; back++)
              {
               pos=i+back;
               if(ExtHighBuffer[pos]!=0 && ExtHighBuffer[pos]<extremum)
                  ExtHighBuffer[pos]=0.0; 
              } 
           }
        }
      //--- found extremum is current high
      if(ccixian(i)==extremum)
         ExtHighBuffer[i]=extremum;
      else
         ExtHighBuffer[i]=0.0;
     }
//--- final cutting 
   if(whatlookfor==0)
     {
      lastlow=0.0;
      lasthigh=0.0;  
     }
   else
     {
      lastlow=curlow;
      lasthigh=curhigh;
     }
   for(i=limit; i>=0; i--)
     {
      cci[i]=ccixian(i);
      switch(whatlookfor)
        {
         case 0: // look for peak or lawn 
            if(lastlow==0.0 && lasthigh==0.0)
              {
               if(ExtHighBuffer[i]!=0.0)
                 {
                  lasthigh=ccixian(i);
                  lasthighpos=i;
                  whatlookfor=-1;
                  ExtZigzagBuffer[i]=lasthigh;
                 }
               if(ExtLowBuffer[i]!=0.0)
                 {
                  lastlow=ccixian(i);
                  lastlowpos=i;
                  whatlookfor=1;
                  ExtZigzagBuffer[i]=lastlow;
                 }
              }
             break;  
         case 1: // look for peak
            if(ExtLowBuffer[i]!=0.0 && ExtLowBuffer[i]<lastlow && ExtHighBuffer[i]==0.0)
              {
               ExtZigzagBuffer[lastlowpos]=0.0;
               lastlowpos=i;
               lastlow=ExtLowBuffer[i];
               ExtZigzagBuffer[i]=lastlow;
              }
            if(ExtHighBuffer[i]!=0.0 && ExtLowBuffer[i]==0.0)
              {
               lasthigh=ExtHighBuffer[i];
               lasthighpos=i;
               ExtZigzagBuffer[i]=lasthigh;
               whatlookfor=-1;
              }   
            break;               
         case -1: // look for lawn
            if(ExtHighBuffer[i]!=0.0 && ExtHighBuffer[i]>lasthigh && ExtLowBuffer[i]==0.0)
              {
               ExtZigzagBuffer[lasthighpos]=0.0;
               lasthighpos=i;
               lasthigh=ExtHighBuffer[i];
               ExtZigzagBuffer[i]=lasthigh;
              }
            if(ExtLowBuffer[i]!=0.0 && ExtHighBuffer[i]==0.0)
              {
               lastlow=ExtLowBuffer[i];
               lastlowpos=i;
               ExtZigzagBuffer[i]=lastlow;
               whatlookfor=1;
              }   
            break;               
        }
     }
//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int InitializeAll()
  {
   ArrayInitialize(ExtZigzagBuffer,0.0);
   ArrayInitialize(ExtHighBuffer,0.0);
   ArrayInitialize(ExtLowBuffer,0.0);
//--- first counting position
   return(Bars-InpDepth);
  }
//+------------------------------------------------------------------+