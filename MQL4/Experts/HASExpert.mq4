/*
 * This is licensed under GNU General Public License Version 3.
 * See a LICENSE file distributed with this software.
 */
#property copyright "Copyright 2014, micclly."
#property link      "https://github.com/micclly"
#property strict

#include <HeikenAshiSmoothedExpert.class.mqh>

input int inputDebugLevel = 1;
input ENUM_MA_METHOD inputMaMethod = MODE_SMMA;
input int inputMaPeriod = 200;
input ENUM_MA_METHOD inputMaMethod2 = MODE_SMMA;
input int inputMaPeriod2 = 200;
input double inputLots = 0.1;
input int inputTakeProfitPip = 750;
input int inputStopLossPip = 250;
input int inputSlippage = 5;


HeikenAshiSmoothedExpert g_expert(
    inputMaMethod,
    inputMaPeriod,
    inputMaMethod2,
    inputMaPeriod2,
    inputLots,
    inputTakeProfitPip,
    inputStopLossPip,
    inputSlippage);

int OnInit()
{
    g_expert.setDebugLevel(inputDebugLevel);


    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
    g_expert.onTick();
}
