//+------------------------------------------------------------------+
//|                                                          ROC.mq5 |
//|                   Copyright 2009-2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009-2017, MetaQuotes Software Corp."
#property link        "http://www.mql5.com"
#property description "Rate of Change"
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  LightSeaGreen
//--- input parameters
input int InpRocPeriod=12; // Period
//--- indicator buffers
double    ExtRocBuffer[];
//--- global variable
int       ExtRocPeriod;

//
//
//

#include <AZ-INVEST/SDK/RangeBarIndicator.mqh>
RangeBarIndicator customChartIndicator;

//
//
//

//+------------------------------------------------------------------+
//| Rate of Change initialization function                           |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- check for input
   if(InpRocPeriod<1)
     {
      ExtRocPeriod=12;
      Print("Incorrect value for input variable InpRocPeriod =",InpRocPeriod,
            "Indicator will use value =",ExtRocPeriod,"for calculations.");
     }
   else ExtRocPeriod=InpRocPeriod;
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtRocBuffer,INDICATOR_DATA);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"ROC("+string(ExtRocPeriod)+")");
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ExtRocPeriod);
//--- initialization done

   //
   //  Indicator uses Price[] array for calculations so we need to set this in the MedianRenkoIndicator class
   //
  
   customChartIndicator.SetUseAppliedPriceFlag(PRICE_CLOSE);
   
   //
   //
   //

  }
//+------------------------------------------------------------------+
//| Rate of Change                                                   |
//+------------------------------------------------------------------+
//int OnCalculate(const int rates_total,const int prev_calculated,const int begin,const double &price[])
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])

  {
   //
   
   if(!customChartIndicator.OnCalculate(rates_total,prev_calculated,Time,Close))
      return(0);
   
   if(!customChartIndicator.BufferSynchronizationCheck(Close))
      return(0);
   
   int _prev_calculated = customChartIndicator.GetPrevCalculated();
   
   //
   //
   //   
  
//--- check for rates count
   if(rates_total<ExtRocPeriod)
      return(0);
//--- preliminary calculations
   int pos=_prev_calculated-1; // set calc position
   if(pos<ExtRocPeriod)
      pos=ExtRocPeriod;
//--- the main loop of calculations
   for(int i=pos;i<rates_total && !IsStopped();i++)
     {
      if(customChartIndicator.Price[i]==0.0)
         ExtRocBuffer[i]=0.0;
      else
         ExtRocBuffer[i]=(customChartIndicator.Price[i]-customChartIndicator.Price[i-ExtRocPeriod])/customChartIndicator.Price[i]*100;
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
