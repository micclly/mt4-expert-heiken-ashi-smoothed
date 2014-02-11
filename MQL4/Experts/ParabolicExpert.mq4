#property copyright "Copyright 2014, micclly."
#property link      "https://github.com/micclly"
#property strict

#include <ParabolicExpert.class.mqh>

input bool inputDebug = true;
input double inputPrabolicSarStep = 0.02;
input double inputParabolicSarMax = 0.2;
input double inputLots = 0.1;
input int inputTakeProfitPip = 75;
input int inputStopLossPip = 25;


ParabolicExpert g_expert(
    inputPrabolicSarStep,
    inputParabolicSarMax,
    inputLots,
    inputTakeProfitPip,
    inputStopLossPip);

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
