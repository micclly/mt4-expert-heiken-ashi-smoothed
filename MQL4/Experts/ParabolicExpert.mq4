#property copyright "Copyright 2014, micclly."
#property link      "https://github.com/micclly"
#property strict

#include <ParabolicExpert.class.mqh>

input bool inputDebug = true;
input double inputPrabolicSarStep = 0.02;
input double inputParabolicSarMax = 0.2;
input ENUM_MA_METHOD inputMaMethod = MODE_SMMA;
input int inputMaPeriod = 200;
input double inputLots = 0.1;
input int inputTakeProfitPip = 750;
input int inputStopLossPip = 250;
input int inputSlippage = 10;


ParabolicExpert g_expert(
    inputPrabolicSarStep,
    inputParabolicSarMax,
    inputMaMethod,
    inputMaPeriod,
    inputLots,
    inputTakeProfitPip,
    inputStopLossPip,
    inputSlippage);

int OnInit()
{
    if (inputDebug) {
        g_expert.enableDebug();
    }

    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
    g_expert.onTick();
}
