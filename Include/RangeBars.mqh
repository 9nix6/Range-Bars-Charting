//+------------------------------------------------------------------+
//|                                         RangeBars.mqh ver:1.47.0 |
//|                                        Copyright 2017, AZ-iNVEST |
//|                                          http://www.az-invest.eu |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, AZ-iNVEST"
#property link      "http://www.az-invest.eu"

#define RANGEBAR_INDICATOR_NAME "Market\\Range Bars Charting" 

#define RANGEBAR_MA1 0
#define RANGEBAR_MA2 1
#define RANGEBAR_CHANNEL_HIGH 2
#define RANGEBAR_CHANNEL_MID 3
#define RANGEBAR_CHANNEL_LOW 4
#define RANGEBAR_OPEN 5
#define RANGEBAR_HIGH 6
#define RANGEBAR_LOW 7
#define RANGEBAR_CLOSE 8
#define RANGEBAR_COLOR_CODE 9
#define RANGEBAR_BAR_OPEN_TIME 10
#define RANGEBAR_TICK_VOLUME 11

#include <RangeBarSettings.mqh>

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
      int GetOLHCForIndicatorCalc(double &o[],double &l[],double &h[],double &c[], int start, int count);
      int GetOLHCAndApplPriceForIndicatorCalc(double &o[],double &l[],double &h[],double &c[],double &price[],ENUM_APPLIED_PRICE applied_price, int start, int count);
      double CalcAppliedPrice(const MqlRates &_rates, ENUM_APPLIED_PRICE applied_price);
      double CalcAppliedPrice(const double &o,const double &l,const double &h,const double &c,ENUM_APPLIED_PRICE applied_price);
      bool GetMA1(double &MA[], int start, int count);
      bool GetMA2(double &MA[], int start, int count);
      bool GetDonchian(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count);
      bool GetBollingerBands(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count);
      bool GetSuperTrend(double &SuperTrendHighArray[], double &SuperTrendArray[], double &SuperTrendLowArray[], int start, int count); 
      bool IsNewBar();
      
   private:

      bool GetChannel(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count);
   
};

RangeBars::RangeBars(void)
{
   rangeBarSettings = new RangeBarSettings();
   rangeBarsHandle = INVALID_HANDLE;
   rangeBarsSymbol = _Symbol;
}

RangeBars::RangeBars(string symbol)
{
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
            Print("Failed to load indicator settings.");
            Alert("You need to put the Median Renko indicator on your chart first!");
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

   RANGEBAR_SETTINGS s = rangeBarSettings.Get();         

   //RangeBarSettings.Debug();
   
   rangeBarsHandle = iCustom(this.rangeBarsSymbol,PERIOD_M1,RANGEBAR_INDICATOR_NAME, 
                                       s.barSizeInTicks,
                                       s._startFromDateTime,
                                       s.resetOpenOnNewTradingDay,
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
                                       s.MA1on, 
                                       s.MA1period,
                                       s.MA1method,
                                       s.MA1applyTo,
                                       s.MA1shift,
                                       s.MA2on,
                                       s.MA2period,
                                       s.MA2method,
                                       s.MA2applyTo,
                                       s.MA2shift,
                                       s.ShowChannel,
                                       "",
                                       s.DonchianPeriod,
                                       s.BBapplyTo,
                                       s.BollingerBandsPeriod,
                                       s.BollingerBandsDeviations,
                                       s.SuperTrendPeriod,
                                       s.SuperTrendMultiplier,
                                       "",
                                       UsedInEA);
      
    if(rangeBarsHandle == INVALID_HANDLE)
    {
      Print("RangeBars indicator init failed on error ",GetLastError());
    }
    else
    {
      Print("RangeBars indicator init OK");
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
      Print("RangeBars indicator handle released");
   else 
      Print("Failed to release RangeBars indicator handle");
}

//
// Function for detecting a new Renko bar
//

bool RangeBars::IsNewBar()
{
   MqlRates currentRenko[1];
   static MqlRates prevRenko;
   
   GetMqlRates(currentRenko,1,1);
   
   if((prevRenko.open != currentRenko[0].open) ||
      (prevRenko.high != currentRenko[0].high) ||
      (prevRenko.low != currentRenko[0].low) ||
      (prevRenko.close != currentRenko[0].close))
   {
      prevRenko.open = currentRenko[0].open;
      prevRenko.high = currentRenko[0].high;
      prevRenko.low = currentRenko[0].low;
      prevRenko.close = currentRenko[0].close;
      return true;
   }
   
   return false;
}

//
// Get "count" Renko MqlRates into "ratesInfoArray[]" array starting from "start" bar  
//

bool RangeBars::GetMqlRates(MqlRates &ratesInfoArray[], int start, int count)
{
   double o[],l[],h[],c[],time[],tick_volume[];

   if(ArrayResize(o,count) == -1)
      return false;
   if(ArrayResize(l,count) == -1)
      return false;
   if(ArrayResize(h,count) == -1)
      return false;
   if(ArrayResize(c,count) == -1)
      return false;
   if(ArrayResize(time,count) == -1)
      return false;
   if(ArrayResize(tick_volume,count) == -1)
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
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_TICK_VOLUME,start,count,tick_volume) == -1)
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
   }
   
   ArrayFree(o);
   ArrayFree(l);
   ArrayFree(h);
   ArrayFree(c);
   ArrayFree(time);
   ArrayFree(tick_volume);   
   
   return true;
}

//
// Get "count" Renko MqlRates into "ratesInfoArray[]" array starting from "start" bar  
//

int RangeBars::GetOLHCForIndicatorCalc(double &o[],double &l[],double &h[],double &c[], int start, int count)
{
   if(ArrayResize(o,count) == -1)
      return false;

   int _count = CopyBuffer(rangeBarsHandle,RANGEBAR_OPEN,start,count,o);
   if(_count == -1)
      return _count;


   if(ArrayResize(o,_count) == -1)
      return -1;
   if(ArrayResize(l,_count) == -1)
      return -1;
   if(ArrayResize(h,_count) == -1)
      return -1;
   if(ArrayResize(c,_count) == -1)
      return -1;
  
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_OPEN,start,_count,o) == -1)
      return -1;
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_LOW,start,_count,l) == -1)
      return -1;
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_HIGH,start,_count,h) == -1)
      return -1;
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_CLOSE,start,_count,c) == -1)
      return -1;
   
   return _count;
}

//
// Get "count" Renko MqlRates into "ratesInfoArray[]" array starting from "start" bar  
//

int RangeBars::GetOLHCAndApplPriceForIndicatorCalc(double &o[],double &l[],double &h[],double &c[],double &price[],ENUM_APPLIED_PRICE applied_price, int start, int count)
{
   if(ArrayResize(o,count) == -1)
      return false;

   int _count = CopyBuffer(rangeBarsHandle,RANGEBAR_OPEN,start,count,o);
   if(_count == -1)
      return _count;


   if(ArrayResize(o,_count) == -1)
      return -1;
   if(ArrayResize(l,_count) == -1)
      return -1;
   if(ArrayResize(h,_count) == -1)
      return -1;
   if(ArrayResize(c,_count) == -1)
      return -1;
   if(ArrayResize(price,_count) == -1)
      return -1;
  
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_OPEN,start,_count,o) == -1)
      return -1;
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_LOW,start,_count,l) == -1)
      return -1;
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_HIGH,start,_count,h) == -1)
      return -1;
   if(CopyBuffer(rangeBarsHandle,RANGEBAR_CLOSE,start,_count,c) == -1)
      return -1;
   
   if(applied_price == PRICE_CLOSE) 
   {
      if(CopyBuffer(rangeBarsHandle,RANGEBAR_CLOSE,start,_count,price) == -1)
         return -1;
   }
   else if(applied_price == PRICE_OPEN) 
   {
      if(CopyBuffer(rangeBarsHandle,RANGEBAR_OPEN,start,_count,price) == -1)
         return -1;
   }
   else if(applied_price == PRICE_HIGH) 
   {
      if(CopyBuffer(rangeBarsHandle,RANGEBAR_HIGH,start,_count,price) == -1)
         return -1;
   }
   else if(applied_price == PRICE_LOW) 
   {
      if(CopyBuffer(rangeBarsHandle,RANGEBAR_LOW,start,_count,price) == -1)
         return -1;
   }
   else
   {       
      for(int i=0; i<_count; i++)
      {
         price[i] = CalcAppliedPrice(o[i],l[i],h[i],c[i],applied_price);
      }
   }
   
   
   return _count;
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
}

//
//  Function used for calculating the Apllied Price based on Renko OLHC values
//

double RangeBars::CalcAppliedPrice(const MqlRates &_rates, ENUM_APPLIED_PRICE applied_price)
{
      if(applied_price == PRICE_CLOSE)
         return _rates.close;
      else if (applied_price == PRICE_OPEN)
         return _rates.open;
      else if (applied_price == PRICE_HIGH)
         return _rates.high;
      else if (applied_price == PRICE_LOW)
         return _rates.low;
      else if (applied_price == PRICE_MEDIAN)
         return (_rates.high + _rates.low) / 2;
      else if (applied_price == PRICE_TYPICAL)
         return (_rates.high + _rates.low + _rates.close) / 3;
      else if (applied_price == PRICE_WEIGHTED)
         return (_rates.high + _rates.low + _rates.close + _rates.close) / 4;
         
      return 0.0;
}

double RangeBars::CalcAppliedPrice(const double &o,const double &l,const double &h,const double &c, ENUM_APPLIED_PRICE applied_price)
{
      if(applied_price == PRICE_CLOSE)
         return c;
      else if (applied_price == PRICE_OPEN)
         return o;
      else if (applied_price == PRICE_HIGH)
         return h;
      else if (applied_price == PRICE_LOW)
         return l;
      else if (applied_price == PRICE_MEDIAN)
         return (h + l) / 2;
      else if (applied_price == PRICE_TYPICAL)
         return (h + l + c) / 3;
      else if (applied_price == PRICE_WEIGHTED)
         return (h + l + c +c) / 4;
      
      return 0.0;
}
