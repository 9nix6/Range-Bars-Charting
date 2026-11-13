# Range Bars Charting — MetaTrader 5 SDK

[![MQL Build](https://github.com/9nix6/Range-Bars-Charting/actions/workflows/mql-build.yml/badge.svg?branch=master)](https://github.com/9nix6/Range-Bars-Charting/actions/workflows/mql-build.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

The open-source companion SDK to the **Range Bars Charting** indicator for MetaTrader 5.

It provides what is needed to build Expert Advisors and indicators that run **directly on a
range bar chart**: a client library that reads the indicator's buffers, a shim that ports ordinary MT5
indicators onto the custom chart's OHLC values, 64 already-ported indicators, and four working EAs.

An EA built with this SDK **inherits the settings of the chart it is attached to** — there is no
need to duplicate the indicator's configuration in the EA's own inputs.

> **The bar-building engine itself is not in this repository.** It ships as a compiled indicator,
> purchased separately — see [Getting the indicator](#getting-the-indicator). What lives here is
> the source for everything that *consumes* the bars it produces.

## Requirements

| | |
|---|---|
| Platform | MetaTrader 5 |
| Compiler | MetaEditor (bundled with MT5, Windows only) |
| Indicator | Range Bars Charting (MQL5 Market) or RangeBars for MetaTrader 5 (az-invest.eu) — see [Selecting your edition](#selecting-your-edition) |

## Installation

Download the archive from the [latest release](https://github.com/9nix6/Range-Bars-Charting/releases/latest). Copy the `Include`,
`Indicators` and `Experts` folders into the **`MQL5`** sub-folder of your MetaTrader data folder
(*File → Open Data Folder* in the terminal), merging them with what is already there, then restart
MetaTrader.

Cloning the repository instead gives you the sources without binaries; compile them in MetaEditor
(**F7**) after copying.

## Selecting your edition

The same engine is sold in two editions, and each is installed under a different indicator name.
The SDK calls it by that name through `iCustom()`, so **the edition has to be selected at compile
time** — in `Include/AZ-INVEST/CustomBarConfig.mqh`.

**This repository ships configured for the MQL5 Market edition:**

```c
#define MQL5_MARKET_VERSION
```

If you bought the indicator **from az-invest.eu**, comment that line out:

```c
//#define MQL5_MARKET_VERSION
```

then recompile (**F7**). The mapping:

| You bought | `CustomBarConfig.mqh` | Indicator it looks for |
|---|---|---|
| Range Bars Charting (MQL5 Market) | `MQL5_MARKET_VERSION` defined — the default | `Market\Range Bars Charting` |
| RangeBars for MetaTrader 5 (az-invest.eu) | `MQL5_MARKET_VERSION` commented out | `RangeBars` |

> **If the EA or a ported indicator loads but shows nothing**, this is the first thing to check.
> A mismatch here means `iCustom()` is asking for an indicator you do not have installed, which
> produces an empty chart rather than an error message.

`CustomBarConfig.mqh` and the two ready-to-trade EAs are shared with the other AZ-INVEST custom
chart SDKs, so they also carry `#define`s for those products (Renko, Tick & Volume Chart, Seconds Chart, Line Break).
Leave them as they are: this repository contains the headers for Range Bars only, and the
`RANGEBAR_LICENSE` / `EA_ON_RANGE_BARS` defines are already selected.

## Repository layout

| Path | Contents |
|---|---|
| `Include/AZ-INVEST/SDK/` | Client library and helper classes |
| `Include/AZ-INVEST/CustomBarConfig.mqh` | Product and edition selection (`#define` ladder) |
| `Indicators/RangeBars/` | 64 indicators ported to the custom chart |
| `Experts/` | Four EAs — two examples, two ready to trade |

Each directory mirrors its counterpart under `MQL5/`, which is why the install step is a straight
copy.

## Core library

| Header | Purpose |
|---|---|
| `RangeBars.mqh` | The `RangeBars` class — handle acquisition and buffer access for the indicator. This is the one to include in an EA. |
| `RangeBarIndicator.mqh` | The `RangeBarIndicator` class — patches an ordinary MT5 indicator to calculate on the custom chart's OHLC values. |
| `CommonSettings.mqh`, `RangeBarCustomChartSettings.mqh` | Read the settings in use on the chart, so an EA adopts them automatically. |

The remaining headers — settings base classes, trade functions, trading checks, trade manager,
time control — are **the same files** as in the
[Median & Turbo Renko SDK](https://github.com/9nix6/Median-and-Turbo-Renko-indicator-bundle), which is where they are maintained.

## Expert Advisors

### Examples

| EA | Demonstrates |
|---|---|
| `RangeBars_ExampleEA.mq5` | A minimal skeleton showing the `RangeBars` class methods. |
| `RangeBars_ExampleEA2.mq5` | Trading decisions driven by the SuperTrend indicator on range bars. |

### Ready to trade

| EA | Strategy |
|---|---|
| `2MA_Cross.mq5` | Two–moving-average cross, with fixed stop loss, take profit and trading hours. |
| `PriceMA_Cross.mq5` | Price/MA cross, with the same risk and session controls. |

Both read moving-average values **from the indicator's buffers**. If MA1/MA2 are not enabled on the
indicator, these EAs receive no data and will not trade.

To run an EA in the Strategy Tester, uncomment `#define SHOW_INDICATOR_INPUTS` in its source and
recompile: in the tester there is no chart to inherit settings from, so the EA has to expose the
indicator's inputs itself.

## Porting a standard MT5 indicator

The indicators in `Indicators/RangeBars/` all follow one pattern, applied consistently, and the
same pattern applies to any standard MT5 indicator. `RSI.mq5` is the reference implementation and
carries the steps as comments.

## Building

MetaEditor compiles the sources: press **F7**, or run `metaeditor64.exe /compile:<path>` headless.
There is no macOS or Linux MQL5 compiler.

Check [Selecting your edition](#selecting-your-edition) before your first build.

**This repository contains sources only.** Compiled `.ex5` files are not committed — continuous
integration compiles every source in `Experts/` and `Indicators/RangeBars/` on each push and pull
request, once per edition, failing on any error or warning, and attaches the binaries to each
[release](https://github.com/9nix6/Range-Bars-Charting/releases). A release archive's binaries are therefore always built from exactly
the sources beside them.

## Getting the indicator

| Platform | Product | Where |
|---|---|---|
| MetaTrader 5 | Range Bars Charting | MQL5 Market |
| MetaTrader 5 | [RangeBars for MetaTrader 5](https://www.az-invest.eu/rangebars-for-metatrader-5) | az-invest.eu |
| MetaTrader 4 | [RangeBars plug-in](https://www.az-invest.eu/rangebars-plug-in-for-metatrader4) | az-invest.eu |

Both MT5 editions are the same engine and both work with this SDK — they differ only in the
indicator name, which is what [Selecting your edition](#selecting-your-edition) is about.

## License

Released under the [GNU General Public License v3](LICENSE). Individual indicators under
`Indicators/RangeBars/` are third-party sources carrying their own licences — check a file's own
header before redistributing or relicensing it.

## Disclaimer

The EAs and indicators in this repository are provided for educational and informational purposes
only, and are not advice or an invitation to trade. Applying the techniques, ideas and suggestions
in these files is done at the user's sole discretion and risk.
