//+------------------------------------------------------------------+
//|                                                          OBV.mq5 |
//|                   Copyright 2009-2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009-2017, MetaQuotes Software Corp."
#property link        "http://www.mql5.com"
#property description "On Balance Volume"
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue
#property indicator_label1  "OBV"
//--- input parametrs
input ENUM_APPLIED_VOLUME InpVolumeType=VOLUME_TICK; // Volumes
//---- indicator buffer
double                    ExtOBVBuffer[];

//
// Initialize RangeBar indicator for data processing 
// according to settings of the RangeBar indicator already on chart
//

#include <AZ-INVEST/SDK/RangeBarIndicator.mqh>
RangeBarIndicator customIndicator;

//
//
//


//+------------------------------------------------------------------+
//| On Balance Volume initialization function                        |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- define indicator buffer
   SetIndexBuffer(0,ExtOBVBuffer);
//--- set indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- OnInit done

   customIndicator.SetGetVolumesFlag();
   
  }
//+------------------------------------------------------------------+
//| On Balance Volume                                                |
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
   //
   // Process data through RangeBar indicator
   //
   
   if(!customIndicator.OnCalculate(rates_total,prev_calculated,time))
      return(0);
      
   int _prev_calculated = customIndicator.GetPrevCalculated();

   //
   //
   // 

//--- variables
   int    pos;
//--- check for bars count
   if(rates_total<2)
      return(0);
//--- starting calculation
   pos=_prev_calculated-1;
//--- correct position, when it's first iteration
   if(pos<1)
     {
      pos=1;
      if(InpVolumeType==VOLUME_TICK)
         ExtOBVBuffer[0]=(double)customIndicator.Tick_volume[0];
      else ExtOBVBuffer[0]=(double)customIndicator.Real_volume[0];
     }
//--- main cycle
   if(InpVolumeType==VOLUME_TICK)
      CalculateOBV(pos,rates_total,customIndicator.Close,customIndicator.Tick_volume);
   else
      CalculateOBV(pos,rates_total,customIndicator.Close,customIndicator.Real_volume);
//---- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Calculate OBV by volume argument                                 |
//+------------------------------------------------------------------+
void CalculateOBV(int StartPosition,
                  int RatesCount,
                  const double &ClBuffer[],
                  const long &VolBuffer[])
  {
   for(int i=StartPosition;i<RatesCount && !IsStopped();i++)
     {
      //--- get some data
      double Volume=(double)VolBuffer[i];
      double PrevClose=ClBuffer[i-1];
      double CurrClose=ClBuffer[i];
      //--- fill ExtOBVBuffer
      if(CurrClose<PrevClose) ExtOBVBuffer[i]=ExtOBVBuffer[i-1]-Volume;
      else
        {
         if(CurrClose>PrevClose) ExtOBVBuffer[i]=ExtOBVBuffer[i-1]+Volume;
         else                    ExtOBVBuffer[i]=ExtOBVBuffer[i-1];
        }
     }
  }
//+------------------------------------------------------------------+