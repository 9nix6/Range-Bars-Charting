//+------------------------------------------------------------------+
//|                                                   SuperTrend.mq5 |
//|                                           Copyright 2011, FxGeek |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, FxGeek"
#property link      " http://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots 2

#property indicator_label1  "Filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrBisque, clrPaleGreen

#property indicator_label2  "SuperTrend"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrGreen, clrRed

#include <AZ-INVEST/CustomBarConfig.mqh>
#include <IncOnRingBuffer\CATROnRingBuffer.mqh>

input int    Periode=10;
input double Multiplier=3;
input bool   Show_Filling=true; // Show as DRAW_FILLING
input int    lookback         = 3000;         // Maximum lookback period

double Filled_a[];
double Filled_b[];
double SuperTrend[];
double ColorBuffer[];
double Atr[];
double Up[];
double Down[];
double Middle[];
double trend[];

CATROnRingBuffer atr;
//int atrHandle;
int changeOfTrend;
int flag;
int flagh;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,Filled_a,INDICATOR_DATA);
   SetIndexBuffer(1,Filled_b,INDICATOR_DATA);
   SetIndexBuffer(2,SuperTrend,INDICATOR_DATA);
   SetIndexBuffer(3,ColorBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,Atr,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,Up,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,Down,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,Middle,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,trend,INDICATOR_CALCULATIONS);

   //atrHandle=iATR(_Symbol,_Period,Periode);
   if(!atr.Init(Periode,MODE_SMA,lookback))
      return(INIT_FAILED);
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   if(!customChartIndicator.OnCalculate(rates_total,prev_calculated,time,close))
      return(0);

   if(!customChartIndicator.BufferSynchronizationCheck(close))
      return(0);

   int _prev_calculated = customChartIndicator.GetPrevCalculated();
   int _rates_total = ArraySize(customChartIndicator.Close);


   int to_copy;
   if(_prev_calculated>_rates_total || _prev_calculated<0)
      to_copy=_rates_total;
   else
     {
      to_copy=_rates_total-_prev_calculated;
      if(_prev_calculated>0)
         to_copy++;
     }

   if(IsStopped())
      return(0); //Checking for stop flag
   //if(CopyBuffer(atrHandle,0,0,to_copy,Atr)<=0)
   //  {
   //   Print("Getting Atr is failed! Error",GetLastError());
   //   return(0);
   //  }
   
   atr.MainOnArray(_rates_total,_prev_calculated,customChartIndicator.High,customChartIndicator.Low,customChartIndicator.Close);

   int first;
   if(_prev_calculated>_rates_total || _prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=Periode; // starting index for calculation of all bars
     }
   else
     {
      first=_prev_calculated-1; // starting number for calculation of new bars
     }

   for(int i=first; i<_rates_total && !IsStopped(); i++)
     {
      Atr[i] = atr[(_rates_total-1)-i];
      Middle[i]=(customChartIndicator.High[i]+customChartIndicator.Low[i])/2;
      Up[i]  = Middle[i] +(Multiplier*Atr[i]);
      Down[i]= Middle[i] -(Multiplier*Atr[i]);

      if(customChartIndicator.Close[i]>Up[i-1])
        {
         trend[i]=1;
         if(trend[i-1]==-1)
            changeOfTrend=1;

        }
      else
         if(customChartIndicator.Close[i]<Down[i-1])
           {
            trend[i]=-1;
            if(trend[i-1]==1)
               changeOfTrend=1;
           }
         else
            if(trend[i-1]==1)
              {
               trend[i]=1;
               changeOfTrend=0;
              }
            else
               if(trend[i-1]==-1)
                 {
                  trend[i]=-1;
                  changeOfTrend=0;
                 }

      if(trend[i]<0 && trend[i-1]>0)
        {
         flag=1;
        }
      else
        {
         flag=0;
        }

      if(trend[i]>0 && trend[i-1]<0)
        {
         flagh=1;
        }
      else
        {
         flagh=0;
        }

      if(trend[i]>0 && Down[i]<Down[i-1])
         Down[i]=Down[i-1];

      if(trend[i]<0 && Up[i]>Up[i-1])
         Up[i]=Up[i-1];

      if(flag==1)
         Up[i]=Middle[i]+(Multiplier*Atr[i]);

      if(flagh==1)
         Down[i]=Middle[i]-(Multiplier*Atr[i]);

      //-- Draw the indicator
      if(trend[i]==1)
        {
         SuperTrend[i]=Down[i];
         if(changeOfTrend==1)
           {
            SuperTrend[i-1]=SuperTrend[i-2];
            changeOfTrend=0;
           }
         ColorBuffer[i]=0.0;
        }
      else
         if(trend[i]==-1)
           {
            SuperTrend[i]=Up[i];
            if(changeOfTrend==1)
              {
               SuperTrend[i-1]= SuperTrend[i-2];
               changeOfTrend = 0;
              }
            ColorBuffer[i]=1.0;
           }

      if(Show_Filling)
        {
         Filled_a[i]= SuperTrend[i];
         Filled_b[i]= customChartIndicator.Close[i];
        }
      else
        {
         Filled_a[i]= EMPTY_VALUE;
         Filled_b[i]= EMPTY_VALUE;
        }
     }


//--- return value of _prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

