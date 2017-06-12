#property copyright "Copyright 2017, AZ-iNVEST"
#property link      "http://www.az-invest.eu"
#property version   "2.03"
#property description "Example EA showing the way to use the RangeBars class defined in RangeBars.mqh" 

//
// SHOW_INDICATOR_INPUTS *NEEDS* to be defined, if the EA needs to be *tested in MT5's backtester*
// -------------------------------------------------------------------------------------------------
// Using '#define SHOW_INDICATOR_INPUTS' will show the RangeBars indicator's inputs 
// NOT using the '#define SHOW_INDICATOR_INPUTS' statement will read the settigns a chart with 
// the RangeBars indicator attached.
//

#define SHOW_INDICATOR_INPUTS

//
// You need to include the rangeBars.mqh header file
//

#include <RangeBars.mqh>

//
//  To use the RangeBars indicator in your EA you need do instantiate the indicator class (RangeBars)
//  and call the Init() method in your EA's OnInit() function.
//  Don't forget to release the indicator when you're done by calling the Deinit() method.
//  Example shown in OnInit & OnDeinit functions below:
//

RangeBars * rangeBars;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   rangeBars = new RangeBars(); 
   if(rangeBars == NULL)
      return(INIT_FAILED);
   
   rangeBars.Init();
   if(rangeBars.GetHandle() == INVALID_HANDLE)
      return(INIT_FAILED);
   
   //
   //  your custom code goes here...
   //
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(rangeBars != NULL)
   {
      rangeBars.Deinit();
      delete rangeBars;
   }
   
   //
   //  your custom code goes here...
   //
}

//
//  At this point you may use the rangebars data fetching methods in your EA.
//  Brief demonstration presented below in the OnTick() function:
//

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   //
   // It is considered good trading & EA coding practice to perform calculations
   // when a new bar is fully formed. 
   // The IsNewBar() method is used for checking if a new range bar has formed 
   //
   
   if(rangeBars.IsNewBar())
   {
      //
      //  There are two methods for getting the Moving Average values.
      //  The example below gets the moving average values for 3 latest bars
      //  counting to the left from the most current (uncompleted) bar.
      //
      
      int startAtBar = 0;   // get value starting from the most current (uncompleted) bar.
      int numberOfBars = 3; // gat a total of 3 MA values (for the 3 latest bars)
      
      //
      // Values will be stored in 2 arrays defined below
      //
      
      double MA1[]; // array to be filled by values of the first moving average
      double MA2[]; // array to be filled by values of the second moving average
      
      if(rangeBars.GetMA1(MA1,startAtBar,numberOfBars) && rangeBars.GetMA1(MA2,startAtBar,numberOfBars))
      {
         //
         // Values are stored in the MA1 and MA2 arrays and are now ready for use
         //
         // MA1[0] contains the 1st moving average value for the latest (uncompleted) bar
         // MA1[1] contains the 1st moving average value for the 1st bar to the left from the latest (uncompleted) bar
         // MA1[2] contains the 1st moving average value for the 2nd bar to the left from the latest (uncompleted) bar
         // MA1[3]..MA1[n] do not exist since we retrieved the values for 3 bars (defined by "numnberOfBars")
         //
         // The values for the 2nd moving average are stored in MA2[] and are accessed identically to values of MA1[] (shown above)
      }
      
      //
      // Getting the MqlRates info for range bars is done using the
      // GetMqlRates(MqlRates &ratesInfoArray[], int start, int count) 
      // method. Example below:
      //
      
      MqlRates RangeBarRatesInfoArray[];  // This array will store the MqlRates data for range bars
      startAtBar = 1;                     // get values starting from the last completed bar.
      numberOfBars = 2;                   // gat a total of 2 MqlRates values (for 2 bars starting from bar 1 (last completed))
      
      if(rangeBars.GetMqlRates(RangeBarRatesInfoArray,startAtBar,numberOfBars))
      {
         //
         //  Check if a range bars reversal bar has formed
         //
         
         if((RangeBarRatesInfoArray[0].open < RangeBarRatesInfoArray[0].close) &&
            (RangeBarRatesInfoArray[1].open > RangeBarRatesInfoArray[1].close))
         {
            // bullish reversal
         }
         else if((RangeBarRatesInfoArray[0].open > RangeBarRatesInfoArray[0].close) &&
            (RangeBarRatesInfoArray[1].open < RangeBarRatesInfoArray[1].close))
         {
            // bearish reversal
         }
      }
      
      //
      // Getting Donchain channel values is done using the
      // GetDonchian(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count) 
      // method. Example below:
      //
      
      double HighArray[];  // This array will store the values of the high band
      double MidArray[];   // This array will store the values of the middle band
      double LowArray[];   // This array will store the values of the low band
      startAtBar = 1;      // get values starting from the last completed bar.
      numberOfBars = 20;   // gat a total of 20 values (for 20 bars starting from bar 1 (last completed))
      
      if(rangeBars.GetDonchian(HighArray,MidArray,LowArray,startAtBar,numberOfBars))
      {
         //
         // Apply your Donchian channel logic here...
         //
      }
      
      //
      // Getting Bollinger Bands values is done using the
      // GetBollingerBands(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count) 
      // method. Example below:
      //
      
      // HighArray[] array will store the values of the high band
      // MidArray[] array will store the values of the middle band
      // LowArray[] array will store the values of the low band
      
      startAtBar = 1;      // get values starting from the last completed bar.
      numberOfBars = 10;   // gat a total of 10 values (for 10 bars starting from bar 1 (last completed))     
      
      if(rangeBars.GetBollingerBands(HighArray,MidArray,LowArray,startAtBar,numberOfBars))
      {
         //
         // Apply your Bollinger Bands logic here...
         //
      } 

      //
      // Getting SuperTrend values is done using the
      // GetSuperTrend(double &SuperTrendHighArray[], double &SuperTrendArray[], double &SuperTrendLowArray[], int start, int count) 
      // method. Example below:
      //
      
      // HighArray[] array will store the values of the high SuperTrend line
      // MidArray[] array will store the values of the SuperTrend value
      // LowArray[] array will store the values of the low SuperTrend line
      
      startAtBar = 1;      // get values starting from the last completed bar.
      numberOfBars = 3;   // gat a total of 3 values (for 3 bars starting from bar 1 (last completed))     
      
      if(rangeBars.GetSuperTrend(HighArray,MidArray,LowArray,startAtBar,numberOfBars))
      {
         //
         // Apply your SuperTrend logic here...
         //
      } 
      
   } 
}
