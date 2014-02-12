#property copyright "Copyright 2014, micclly."
#property link      "https://github.com/micclly"
#property strict

#include <ParabolicExpert.class.mqh>

input int inputDebugLevel = 1;
input double inputPrabolicSarStep = 0.02;
input double inputParabolicSarMax = 0.2;
input ENUM_MA_METHOD inputMaMethod = MODE_SMMA;
input int inputMaPeriod = 200;
input ENUM_MA_METHOD inputMaMethod2 = MODE_SMMA;
input int inputMaPeriod2 = 200;
input double inputLots = 0.1;
input int inputTakeProfitPip = 750;
input int inputStopLossPip = 250;
input int inputSlippage = 5;


ParabolicExpert g_expert(
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
