# Range-Bars-Charting
MQL5 header files for 'Range Bars Charting' indicator available for MT5 via MQL5 Market. The files lets you easily create a RangeBars based EA in MT5.
The created EA will automatically acquire the settings used on the RangeBars chart it is applied to, so it is not required to clone the indicator's settings 
used on the chart to the RangeBars settings that should be used in the EA.

## The files
**RangeBars.mqh** - The header file for including in the EA code. It contains the definition and implementation of the RangeBars class

**CommonSettings.mqh** & **RangeBarSettings.mqh** - These header files are used by the **RangeBars** class to automatically read the EA settings used on the Renko chart where the EA should be attached.

**RangeBarIndicator.mqh** - This helper header file includes a **RangeBarIndicator** class which is used to patch MQL5 indicators to work directly on the RangeBars charts and use the RangeBar's OLHC values for calculation.

**ExampleEA.mq5** - An example EA skeleton showing the use of methods included in the RangeBars class library

**ExampleEA2.mq5** - An example EA utilizing the Super Trend indicator on RangeBars to make trading decisions also showing the use of methods included in the RangeBars class library.

## Installation

All folders (Experts, Include & Indicators) & sub-folders should be placed in the **MQL5** sub-folder of your Metatrader's Data Folder.

## Resources
The RangeBars indicator for MT5 can be downloaded from https://www.mql5.com/en/market/product/16762

A version for MT4 is available from https://www.az-invest.eu/rangebars-plug-in-for-metatrader4
