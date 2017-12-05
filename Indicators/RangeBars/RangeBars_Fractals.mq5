//+------------------------------------------------------------------+
//|                                                     Fractals.mq5 |
//|                        Copyright 2009, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_ARROW
#property indicator_type2   DRAW_ARROW
#property indicator_color1  Gray
#property indicator_color2  Gray
#property indicator_label1  "Fractal Up"
#property indicator_label2  "Fractal Down"
//---- indicator buffers
double ExtUpperBuffer[];
double ExtLowerBuffer[];
//--- 10 pixels upper from high price
int    ExtArrowShift=-10;

//
//
//

#include <AZ-INVEST/SDK/RangeBarIndicator.mqh>
RangeBarIndicator rangeBarsIndicator;

//
//
//

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtUpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLowerBuffer,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_ARROW,217);
   PlotIndexSetInteger(1,PLOT_ARROW,218);
//---- arrow shifts when drawing
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,ExtArrowShift);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-ExtArrowShift);
//---- sets drawing line empty value--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- initialization done
  }
//+------------------------------------------------------------------+
//|  Accelerator/Decelerator Oscillator                              |
//+------------------------------------------------------------------+
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
   // Process data through MedianRenko indicator
   //
   
   if(!rangeBarsIndicator.OnCalculate(rates_total,prev_calculated,Time))
      return(0);
   
   //
   // Make the following modifications in the code below:
   //
   // rangeBarsIndicator.GetPrevCalculated() should be used instead of prev_calculated
   //
   // rangeBarsIndicator.Open[] should be used instead of open[]
   // rangeBarsIndicator.Low[] should be used instead of low[]
   // rangeBarsIndicator.High[] should be used instead of high[]
   // rangeBarsIndicator.Close[] should be used instead of close[]
   //
   // rangeBarsIndicator.IsNewBar (true/false) informs you if a renko brick completed
   //
   // rangeBarsIndicator.Time[] shold be used instead of Time[] for checking the renko bar time.
   // (!) rangeBarsIndicator.SetGetTimeFlag() must be called in OnInit() for rangeBarsIndicator.Time[] to be used
   //
   // rangeBarsIndicator.Tick_volume[] should be used instead of TickVolume[]
   // rangeBarsIndicator.Real_volume[] should be used instead of Volume[]
   // (!) rangeBarsIndicator.SetGetVolumesFlag() must be called in OnInit() for Tick_volume[] & Real_volume[] to be used
   //
   // rangeBarsIndicator.Price[] should be used instead of Price[]
   // (!) rangeBarsIndicator.SetUseAppliedPriceFlag(ENUM_APPLIED_PRICE _applied_price) must be called in OnInit() for rangeBarsIndicator.Price[] to be used
   //
   
   int _prev_calculated = rangeBarsIndicator.GetPrevCalculated();
   
   //
   //
   //     
  
   int i,limit;
//---
   if(rates_total<5)
      return(0);
//---
   if(_prev_calculated<7)
     {
      limit=2;
      //--- clean up arrays
      ArrayInitialize(ExtUpperBuffer,EMPTY_VALUE);
      ArrayInitialize(ExtLowerBuffer,EMPTY_VALUE);
     }
   else limit=rates_total-5;

   for(i=limit; i<rates_total-3 && !IsStopped();i++)
     {
      //---- Upper Fractal
      if(rangeBarsIndicator.High[i]>rangeBarsIndicator.High[i+1] && rangeBarsIndicator.High[i]>rangeBarsIndicator.High[i+2] && rangeBarsIndicator.High[i]>=rangeBarsIndicator.High[i-1] && rangeBarsIndicator.High[i]>=rangeBarsIndicator.High[i-2])
         ExtUpperBuffer[i]=rangeBarsIndicator.High[i];
      else ExtUpperBuffer[i]=EMPTY_VALUE;

      //---- Lower Fractal
      if(rangeBarsIndicator.Low[i]<rangeBarsIndicator.Low[i+1] && rangeBarsIndicator.Low[i]<rangeBarsIndicator.Low[i+2] && rangeBarsIndicator.Low[i]<=rangeBarsIndicator.Low[i-1] && rangeBarsIndicator.Low[i]<=rangeBarsIndicator.Low[i-2])
         ExtLowerBuffer[i]=rangeBarsIndicator.Low[i];
      else ExtLowerBuffer[i]=EMPTY_VALUE;
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }

//+------------------------------------------------------------------+
