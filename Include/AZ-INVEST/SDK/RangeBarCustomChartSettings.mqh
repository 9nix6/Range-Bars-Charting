#include <AZ-INVEST/SDK/CommonSettings.mqh>

#ifdef DEVELOPER_VERSION
   #define CUSTOM_CHART_NAME "RangeBars_TEST"
#else
   #define CUSTOM_CHART_NAME "Range Bars"
#endif

//
// Tick chart specific settings
//
#ifdef SHOW_INDICATOR_INPUTS
   #ifdef MQL5_MARKET_DEMO // hardcoded values
   
      double                  InpBarSize = 180;                               // Range bar size
      ENUM_BAR_SIZE_CALC_MODE InpBarSizeCalcMode = BAR_SIZE_ABSOLUTE_TICKS;   // Bar size calculation
      int                     InpShowNumberOfDays = 7;                        // Show history for number of days
      datetime                InpShowFromDate = 0;                            // Show history starting from
      ENUM_TIMEFRAMES         InpAtrTimeFrame = PERIOD_D1;                    // ATR timeframe setting
      int                     InpAtrPeriod = 14;                              // ATR period setting
      ENUM_BOOL               InpResetOpenOnNewTradingDay = true;             // Synchronize first bar's open on new day
   
   #else // user defined settings
      
      input double                  InpBarSize = 100;                            // Range bar size
      input ENUM_BAR_SIZE_CALC_MODE InpBarSizeCalcMode = BAR_SIZE_ABSOLUTE_TICKS;// Bar size calculation
      input int                     InpShowNumberOfDays = 5;                     // Show history for number of days
      input datetime                InpShowFromDate = 0;                         // Show history starting from
      input group                   "### ATR bar size calculation settings"
      input ENUM_TIMEFRAMES         InpAtrTimeFrame = PERIOD_D1;                 // ATR timeframe setting
      input int                     InpAtrPeriod = 14;                           // ATR period setting   
      input group                   "### Chart synchronization"
      input ENUM_BOOL               InpResetOpenOnNewTradingDay = true;          // Synchronize first bar's open on new day
   
   #endif
#else // don't SHOW_INDICATOR_INPUTS 
      double                  InpBarSize = 180;                            // Range bar size 
      ENUM_BAR_SIZE_CALC_MODE InpBarSizeCalcMode = BAR_SIZE_ABSOLUTE_TICKS;// Bar size calculation
      int                     InpShowNumberOfDays = 7;                     // Show history for number of days
      datetime                InpShowFromDate = 0;                         // Show history starting from
      ENUM_TIMEFRAMES         InpAtrTimeFrame = PERIOD_D1;                 // ATR timeframe setting
      int                     InpAtrPeriod = 14;                           // ATR period setting
      ENUM_BOOL               InpResetOpenOnNewTradingDay = true;          // Synchronize first bar's open on new day
#endif

//
// Remaining settings are located in the include file below.
// These are common for all custom charts
//
#include <az-invest/sdk/CustomChartSettingsBase.mqh>

#define SETNAME_BAR_SIZE_CALC_MODE  "barSizeCalcMode"
#define SETNAME_ATR_TIMEFRAME       "atrTimeFrame"
#define SETNAME_ATR_PERIOD          "atrPeriod"

struct RANGEBAR_SETTINGS
{
   double                  barSize;
   ENUM_BAR_SIZE_CALC_MODE barSizeCalcMode;
   ENUM_TIMEFRAMES         atrTimeFrame;
   int                     atrPeriod;
   int                     showNumberOfDays;
   datetime                showFromDate;
   ENUM_BOOL               resetOpenOnNewTradingDay;  
};


class CRangeBarCustomChartSettigns : public CCustomChartSettingsBase
{
   protected:
      
   RANGEBAR_SETTINGS settings;

   public:
   
   CRangeBarCustomChartSettigns();
   ~CRangeBarCustomChartSettigns();

   RANGEBAR_SETTINGS GetCustomChartSettings() { return this.settings; };   
   
   virtual void SetCustomChartSettings();
   virtual string GetSettingsFileName();
   virtual uint CustomChartSettingsToFile(int handle);
   virtual uint CustomChartSettingsFromFile(int handle);
};

void CRangeBarCustomChartSettigns::CRangeBarCustomChartSettigns()
{
   settingsFileName = GetSettingsFileName();
}

void CRangeBarCustomChartSettigns::~CRangeBarCustomChartSettigns()
{
}

string CRangeBarCustomChartSettigns::GetSettingsFileName()
{
   return CUSTOM_CHART_NAME+(string)ChartID()+".set";  
}

uint CRangeBarCustomChartSettigns::CustomChartSettingsToFile(int file_handle)
{
   return FileWriteStruct(file_handle,this.settings);
}

uint CRangeBarCustomChartSettigns::CustomChartSettingsFromFile(int file_handle)
{
   return FileReadStruct(file_handle,this.settings);
}

void CRangeBarCustomChartSettigns::SetCustomChartSettings()
{
   settings.barSize = InpBarSize;   
   settings.barSizeCalcMode = InpBarSizeCalcMode;
   settings.showNumberOfDays = InpShowNumberOfDays;
   settings.showFromDate = InpShowFromDate;
   settings.atrTimeFrame = InpAtrTimeFrame;
   settings.atrPeriod = InpAtrPeriod;
   settings.resetOpenOnNewTradingDay = InpResetOpenOnNewTradingDay;
}
