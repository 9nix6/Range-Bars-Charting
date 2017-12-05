//+------------------------------------------------------------------+
//|                                         RangeBars.mqh ver:2.03.0 |
//|                                        Copyright 2017, AZ-iNVEST |
//|                                          http://www.az-invest.eu |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, AZ-iNVEST"
#property link      "http://www.az-invest.eu"

#define RANGEBAR_INDICATOR_NAME "Market\\Range Bars Charting" 
//#define RANGEBAR_INDICATOR_NAME "RangeBars\\RangeBarsOverlay203"

#define RANGEBAR_OPEN            00
#define RANGEBAR_HIGH            01
#define RANGEBAR_LOW             02
#define RANGEBAR_CLOSE           03 
#define RANGEBAR_BAR_COLOR       04
#define RANGEBAR_MA1             05
#define RANGEBAR_MA2             06
#define RANGEBAR_MA3             07
#define RANGEBAR_CHANNEL_HIGH    08
#define RANGEBAR_CHANNEL_MID     09
#define RANGEBAR_CHANNEL_LOW     10
#define RANGEBAR_BAR_OPEN_TIME   11
#define RANGEBAR_TICK_VOLUME     12
#define RANGEBAR_REAL_VOLUME     13
#define RANGEBAR_BUY_VOLUME      14
#define RANGEBAR_SELL_VOLUME     15
#define RANGEBAR_BUYSELL_VOLUME  16

#include <AZ-INVEST/SDK/RangeBarSettings.mqh>

class RangeBars
{
   private:
   
      RangeBarSettings * rangeBarSettings;

      //
      //  Median renko indicator handle
      //
      
      int rangeBarsHandle;
      string rangeBarsSymbol;
   
   public:
      
      RangeBars();   
      RangeBars(string symbol);
      ~RangeBars(void);
      
      int Init();
      void Deinit();
      bool Reload();
      
      int GetHandle(void) { return rangeBarsHandle; };
      bool GetMqlRates(MqlRates &ratesInfoArray[], int start, int count);
      bool GetBuySellVolumeBreakdown(double &buy[], double &sell[], double &buySell[], int start, int count);      
      bool GetMA1(double &MA[], int start, int count);
      bool GetMA2(double &MA[], int start, int count);
      bool GetMA3(double &MA[], int start, int count);
      bool GetDonchian(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count);
      bool GetBollingerBands(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count);
      bool GetSuperTrend(double &SuperTrendHighArray[], double &SuperTrendArray[], double &SuperTrendLowArray[], int start, int count); 
      
      bool IsNewBar();
      
   private:

      bool GetChannel(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count);
   
};

RangeBars::RangeBars(void)
{
#define CONSTRUCTOR1
   rangeBarSettings = new RangeBarSettings();
   rangeBarsHandle = INVALID_HANDLE;
   rangeBarsSymbol = _Symbol;
}

RangeBars::RangeBars(string symbol)
{
#define CONSTRUCTOR2
   rangeBarSettings = new RangeBarSettings();
   rangeBarsHandle = INVALID_HANDLE;
   rangeBarsSymbol = symbol;
}

RangeBars::~RangeBars(void)
{
   if(rangeBarSettings != NULL)
      delete rangeBarSettings;
}

//
//  Function for initializing the median renko indicator handle
//

int RangeBars::Init()
{
   if(!MQLInfoInteger((int)MQL5_TESTING))
   {
      if(!rangeBarSettings.Load())
      {
         if(rangeBarsHandle != INVALID_HANDLE)
         {
            // could not read new settings - keep old settings
            
            return rangeBarsHandle;
         }
         else
         {
            Print("Failed to load indicator settings - RangeBar indicator not on chart");
            return INVALID_HANDLE;
         }
      }   
      
      if(rangeBarsHandle != INVALID_HANDLE)
         Deinit();

   }
   else
   {
      #ifdef SHOW_INDICATOR_INPUTS
         //
         //  Load settings from EA inputs
         //
         rangeBarSettings.Load();
      #else
         //
         //  Save indicator inputs for use by EA attached to same chart.
         //
         rangeBarSettings.Save();
      #endif
   }   

   RANGEBAR_SETTINGS s = rangeBarSettings.GetRangeBarSettings();         
   CHART_INDICATOR_SETTINGS cis = rangeBarSettings.GetChartIndicatorSettings(); 

   //RangeBarSettings.Debug();
   
   rangeBarsHandle = iCustom(this.rangeBarsSymbol,_Period,RANGEBAR_INDICATOR_NAME, 
                                       s.barSizeInTicks,
                                       s.atrEnabled,
                                       //s.atrTimeFrame,
                                       s.atrPeriod,
                                       s.atrPercentage,
                                       s.showNumberOfDays,
                                       s.resetOpenOnNewTradingDay,
                                       TopBottomPaddingPercentage,
                                       showPivots,
                                       pivotPointCalculationType,
                                       RColor,
                                       PColor,
                                       SColor,
                                       PDHColor,
                                       PDLColor,
                                       PDCColor,   
                                       showNextBarLevels,
                                       HighThresholdIndicatorColor,
                                       LowThresholdIndicatorColor,
                                       showCurrentBarOpenTime,
                                       InfoTextColor,
                                       UseSoundSignalOnNewBar,
                                       OnlySignalReversalBars,
                                       UseAlertWindow,
                                       SendPushNotifications,
                                       SoundFileBull,
                                       SoundFileBear,
                                       cis.MA1on, 
                                       cis.MA1period,
                                       cis.MA1method,
                                       cis.MA1applyTo,
                                       cis.MA1shift,
                                       cis.MA2on,
                                       cis.MA2period,
                                       cis.MA2method,
                                       cis.MA2applyTo,
                                       cis.MA2shift,
                                       cis.MA3on,
                                       cis.MA3period,
                                       cis.MA3method,
                                       cis.MA3applyTo,
                                       cis.MA3shift,
                                       cis.ShowChannel,
                                       "",
                                       cis.DonchianPeriod,
                                       cis.BBapplyTo,
                                       cis.BollingerBandsPeriod,
                                       cis.BollingerBandsDeviations,
                                       cis.SuperTrendPeriod,
                                       cis.SuperTrendMultiplier,
                                       "",
                                       DisplayAsBarChart,
                                       UsedInEA);

      
    if(rangeBarsHandle == INVALID_HANDLE)
    {
      Print("RangeBar indicator init failed on error ",GetLastError());
    }
    else
    {
      Print("RangeBar indicator init OK");
    }
     
    return rangeBarsHandle;
}

//
// Function for reloading the Median Renko indicator if needed
//

bool RangeBars::Reload()
{
   if(rangeBarSettings.Changed())
   {
      if(Init() == INVALID_HANDLE)
         return false;
      
      return true;
   }
   
   return false;
}

//
// Function for releasing the Median Renko indicator hanlde - free resources
//

void RangeBars::Deinit()
{
   if(rangeBarsHandle == INVALID_HANDLE)
      return;
      
   if(IndicatorRelease(rangeBarsHandle))
      Print("RangeBar indicator handle released");
   else 
      Print("Failed to release RangeBar indicator handle");
}

//
// Function for detecting a new Renko bar
//

bool RangeBars::IsNewBar()
{
   MqlRates currentBar[1];
   static datetime prevBarTime;
   
   GetMqlRates(currentBar,0,1);
   
   if(currentBar[0].time == 0)
      return false;
   
   if(prevBarTime < currentBar[0].time)
   {
      prevBarTime = currentBar[0].time;
      return true;
   }

   return false;}

//
// Get "count" Renko MqlRates into "ratesInfoArray[]" array starting from "start" bar  
//

bool RangeBars::GetMqlRates(MqlRates &ratesInfoArray[], int start, int count)
{
   double o[],l[],h[],c[],barColor[],time[],tick_volume[],real_volume[];

   if(ArrayResize(o,count) == -1)
      return false;
   if(ArrayResize(l,count) == -1)
      return false;
   if(ArrayResize(h,count) == -1)
      return false;
   if(ArrayResize(c,count) == -1)
      return false;
   if(ArrayResize(barColor,count) == -1)
      return false;
   if(ArrayResize(time,count) == -1)
      return false;
   if(ArrayResize(tick_volume,count) == -1)
      return false;
   if(ArrayResize(real_volume,count) == -1)
      return false;

  
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_OPEN,start,count,o) == -1)
      return false;
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_LOW,start,count,l) == -1)
      return false;
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_HIGH,start,count,h) == -1)
      return false;
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_CLOSE,start,count,c) == -1)
      return false;
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_BAR_OPEN_TIME,start,count,time) == -1)
      return false;
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_BAR_COLOR,start,count,barColor) == -1)
      return false;
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_TICK_VOLUME,start,count,tick_volume) == -1)
      return false;
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_REAL_VOLUME,start,count,real_volume) == -1)
      return false;

   if(ArrayResize(ratesInfoArray,count) == -1)
      return false; 

   int tempOffset = count-1;
   for(int i=0; i<count; i++)
   {
      ratesInfoArray[tempOffset-i].open = o[i];
      ratesInfoArray[tempOffset-i].low = l[i];
      ratesInfoArray[tempOffset-i].high = h[i];
      ratesInfoArray[tempOffset-i].close = c[i];
      ratesInfoArray[tempOffset-i].time = (datetime)time[i];
      ratesInfoArray[tempOffset-i].tick_volume = (long)tick_volume[i];
      ratesInfoArray[tempOffset-i].real_volume = (long)real_volume[i];
      ratesInfoArray[tempOffset-i].spread = (int)barColor[i];
   }
   
   ArrayFree(o);
   ArrayFree(l);
   ArrayFree(h);
   ArrayFree(c);
   ArrayFree(barColor);
   ArrayFree(time);
   ArrayFree(tick_volume);   
   ArrayFree(real_volume);  
   
   return true;
}
bool RangeBars::GetBuySellVolumeBreakdown(double &buy[], double &sell[], double &buySell[], int start, int count)
{
   double b[],s[],bs[];
   
   if(ArrayResize(b,count) == -1)
      return false;
   if(ArrayResize(s,count) == -1)
      return false;
   if(ArrayResize(bs,count) == -1)
      return false;

#ifdef P_RANGEBAR_BR
   #ifdef P_RANGEBAR_BR_PRO
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_BUY_VOLUME,start,count,b) == -1)
      return false;
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_SELL_VOLUME,start,count,s) == -1)
      return false;
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_BUYSELL_VOLUME,start,count,bs) == -1)
      return false;
   #endif
#else
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_BUY_VOLUME,start,count,b) == -1)
      return false;
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_SELL_VOLUME,start,count,s) == -1)
      return false;
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_BUYSELL_VOLUME,start,count,bs) == -1)
      return false;
#endif

   if(ArrayResize(buy,count) == -1)
      return false; 
   if(ArrayResize(sell,count) == -1)
      return false; 
   if(ArrayResize(buySell,count) == -1)
      return false; 

   int tempOffset = count-1;
   for(int i=0; i<count; i++)
   {
      buy[tempOffset-i] = b[i];
      sell[tempOffset-i] = s[i];
      buySell[tempOffset-i] = bs[i];
   }
   
   ArrayFree(b);
   ArrayFree(s);
   ArrayFree(bs);
   
   return true;


}

//
// Get "count" MovingAverage1 values into "MA[]" array starting from "start" bar  
//

bool RangeBars::GetMA1(double &MA[], int start, int count)
{
   double tempMA[];
   if(ArrayResize(tempMA,count) == -1)
      return false;

   if(ArrayResize(MA,count) == -1)
      return false;
   
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_MA1,start,count,tempMA) == -1)
      return false;

   for(int i=0; i<count; i++)
   {
      MA[count-1-i] = tempMA[i];
   }

   ArrayFree(tempMA);      
   return true;
}

//
// Get "count" MovingAverage2 values into "MA[]" starting from "start" bar  
//

bool RangeBars::GetMA2(double &MA[], int start, int count)
{
   double tempMA[];
   if(ArrayResize(tempMA,count) == -1)
      return false;

   if(ArrayResize(MA,count) == -1)
      return false;
   
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_MA2,start,count,tempMA) == -1)
      return false;
   
   for(int i=0; i<count; i++)
   {
      MA[count-1-i] = tempMA[i];
   }
   
   ArrayFree(tempMA);   
   return true;
}

//
// Get "count" MovingAverage3 values into "MA[]" starting from "start" bar  
//

bool RangeBars::GetMA3(double &MA[], int start, int count)
{
   double tempMA[];
   if(ArrayResize(tempMA,count) == -1)
      return false;

   if(ArrayResize(MA,count) == -1)
      return false;
   
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_MA3,start,count,tempMA) == -1)
      return false;
   
   for(int i=0; i<count; i++)
   {
      MA[count-1-i] = tempMA[i];
   }
   
   ArrayFree(tempMA);   
   return true;
}

//
// Get "count" Renko Donchian channel values into "HighArray[]", "MidArray[]", and "LowArray[]" arrays starting from "start" bar  
//

bool RangeBars::GetDonchian(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count)
{
   return GetChannel(HighArray,MidArray,LowArray,start,count);
}

//
// Get "count" Bollinger band values into "HighArray[]", "MidArray[]", and "LowArray[]" arrays starting from "start" bar  
//

bool RangeBars::GetBollingerBands(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count)
{
   return GetChannel(HighArray,MidArray,LowArray,start,count);
}

//
// Get "count" SuperTrend values into "HighArray[]", "MidArray[]", and "LowArray[]" arrays starting from "start" bar  
//

bool RangeBars::GetSuperTrend(double &SuperTrendHighArray[], double &SuperTrendArray[], double &SuperTrendLowArray[], int start, int count)
{
   return GetChannel(SuperTrendHighArray,SuperTrendArray,SuperTrendLowArray,start,count);
}


//
// Private function used by GetRenkoDonchian and GetRenkoBollingerBands functions to get data
//

bool RangeBars::GetChannel(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count)
{
   double tempH[], tempM[], tempL[];

#ifdef P_RANGEBAR_BR
   return false;
#else
   if(ArrayResize(tempH,count) == -1)
      return false;
   if(ArrayResize(tempM,count) == -1)
      return false;
   if(ArrayResize(tempL,count) == -1)
      return false;

   if(ArrayResize(HighArray,count) == -1)
      return false;
   if(ArrayResize(MidArray,count) == -1)
      return false;
   if(ArrayResize(LowArray,count) == -1)
      return false;
   
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_CHANNEL_HIGH,start,count,tempH) == -1)
      return false;
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_CHANNEL_MID,start,count,tempM) == -1)
      return false;
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_CHANNEL_LOW,start,count,tempL) == -1)
      return false;
   
   int tempOffset = count-1;
   for(int i=0; i<count; i++)
   {
      HighArray[tempOffset-i] = tempH[i];
      MidArray[tempOffset-i] = tempM[i];
      LowArray[tempOffset-i] = tempL[i];
   }   
   
   ArrayFree(tempH);
   ArrayFree(tempM);
   ArrayFree(tempL);
   
   return true;
#endif
}

