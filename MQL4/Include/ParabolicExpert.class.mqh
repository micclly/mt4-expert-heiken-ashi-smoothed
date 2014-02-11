#property copyright "Copyright 2014, micclly."
#property link      "https://github.com/micclly"
#property strict

#include <OrderUtil.class.mqh>

enum ParabolicTrend
{
    UP,
    DOWN,
    UNKNOWN,
};

class ParabolicExpert
{
public:
    ParabolicExpert(double sarStep, double sarMax, double lots, int tpPip, int slPip);

    void enableDebug();
    void onTick();
    
private:
    static const int MAGIC_NUMBER;
    static const int MAX_HISTORY_COUNT;

    bool m_debug;
    const double m_sarStep;
    const double m_sarMax;
    const double m_lots;
    const int m_tpPip;
    const int m_slPip;

    int g_prevBars;
    double m_parabolicHistory[];
    int m_parabolicHistoryCount;

    bool isDebug();
    void addHistory(double parabolic);
    bool isParabolicTrendChanged();
    ParabolicTrend getParabolicTrend(int shift);
    bool buy();
    bool sell();
    bool close();
};


static const int ParabolicExpert::MAGIC_NUMBER = 868001;
static const int ParabolicExpert::MAX_HISTORY_COUNT = 2;


ParabolicExpert::ParabolicExpert(double sarStep, double sarMax, double lots, int tpPip, int slPip)
: m_debug(false), m_sarStep(sarStep), m_sarMax(sarMax), m_parabolicHistoryCount(0),
  m_lots(lots), m_tpPip(tpPip), m_slPip(slPip), g_prevBars(0)
{
    ArraySetAsSeries(m_parabolicHistory, true);
    ArrayResize(m_parabolicHistory, MAX_HISTORY_COUNT);
}

void ParabolicExpert::enableDebug()
{
    Print("Debug mode enabled");
    m_debug = true;
}

void ParabolicExpert::onTick()
{
    if (g_prevBars == Bars) {
        return;
    }

    g_prevBars = Bars;

    double p = iCustom(NULL, 0, "Parabolic", 0.02, 0.2, 0, 0);
    addHistory(p);

    int tickets[];
    if (!OrderUtil::getTickets(MAGIC_NUMBER, tickets)) {
        Alert("Cannot get tickets");
        ExpertRemove();
        return;
    }
    
    for (int i = 0; i < ArraySize(tickets); i++) {
        //
    }

    if (isParabolicTrendChanged()) {
        if (isDebug()) {
            PrintFormat("parabolic[0]=%s, parabolic[1]=%s", DoubleToString(m_parabolicHistory[0], 4), DoubleToString(m_parabolicHistory[1], 4));
            PrintFormat("Parabolic trend changed, at %s", TimeToString(Time[1]));
        }

        ParabolicTrend trend = getParabolicTrend(0);
        if (isDebug()) {
            PrintFormat("Parabolic trend is: %s", EnumToString(trend));
        }
        
        switch (trend) {
        case UP:
            break;
        case DOWN:
            break;
        default:
            break;
        }
    }
}

bool ParabolicExpert::isDebug()
{
    return m_debug;
}

void ParabolicExpert::addHistory(double parabolic)
{
    if (m_parabolicHistoryCount > 0 ) {
        for (int i = m_parabolicHistoryCount - 1; i > 0; i--) {
            m_parabolicHistory[i] = m_parabolicHistory[i-1];
        }
    }

    m_parabolicHistory[0] = parabolic;
    if (m_parabolicHistoryCount < MAX_HISTORY_COUNT) {
        m_parabolicHistoryCount += 1;
    }
}

bool ParabolicExpert::isParabolicTrendChanged()
{
    if (m_parabolicHistoryCount < 2) {
        return false;
    }

    ParabolicTrend t0 = getParabolicTrend(0);
    ParabolicTrend t1 = getParabolicTrend(1);

    if (t0 != UNKNOWN && t1 != UNKNOWN) {
        return t0 != t1;
    }

    return false;
}

ParabolicTrend ParabolicExpert::getParabolicTrend(int shift)
{
    if (m_parabolicHistoryCount < shift) {
        return UNKNOWN;
    }

    int shiftIndex = shift + 2;
    if (m_parabolicHistory[shift] > High[shiftIndex]) {
        return DOWN;
    }
    else if (m_parabolicHistory[shift] < Low[shiftIndex]) {
        return UP;
    }

    return UNKNOWN;
}

bool ParabolicExpert::buy()
{
    return false;
}

bool ParabolicExpert::sell()
{
    return false;
}

bool ParabolicExpert::close()
{
    return false;
}