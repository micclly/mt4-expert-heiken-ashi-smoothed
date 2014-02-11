#property copyright "Copyright 2014, micclly."
#property link      "https://github.com/micclly"
#property version   "1.00"
#property strict

#include <ParabolicExpert.class.mqh>

input bool inputDebug = true;
input double inputPrabolicSarStep = 0.02;
input double inputParabolicSarMax = 0.2;


ParabolicExpert g_expert(inputPrabolicSarStep, inputParabolicSarMax);

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
