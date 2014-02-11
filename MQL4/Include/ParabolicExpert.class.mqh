#property copyright "Copyright 2014, micclly."
#property link      "https://github.com/micclly"
#property version   "1.00"
#property strict

enum ParabolicTrend
{
    UP,
    DOWN,
    UNKNOWN,
};

class ParabolicExpert
{
public:
    ParabolicExpert(double sarStep, double sarMax);

    void enableDebug();
    void onTick();
    
private:
    static const int MAX_HISTORY_COUNT;
    bool m_debug;
    const double m_sarStep;
    const double m_sarMax;
    double m_parabolicHistory[];
    int m_parabolicHistoryCount;

    bool isDebug();
    void addHistory(double parabolic);
    bool isParabolicTrendChanged();
    ParabolicTrend getParabolicTrend();
};

static const int ParabolicExpert::MAX_HISTORY_COUNT = 2;


ParabolicExpert::ParabolicExpert(double sarStep, double sarMax)
: m_debug(false), m_sarStep(sarStep), m_sarMax(sarMax), m_parabolicHistoryCount(0)
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
    double p = iCustom(NULL, 0, "Parabolic", 0.02, 0.2, 0, 0);
    addHistory(p);

    if (isParabolicTrendChanged()) {
        if (isDebug()) {
            PrintFormat("parabolic[0]=%s, parabolic[1]=%s", DoubleToString(m_parabolicHistory[0], 4), DoubleToString(m_parabolicHistory[1], 4));
            PrintFormat("Parabolic trend changed, at %s", TimeToString(Time[1]));
        }

        ParabolicTrend trend = getParabolicTrend();
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

    if ((m_parabolicHistory[1] < High[2]) && (m_parabolicHistory[0] > High[2])) {
        return true;
    }
    else if ((m_parabolicHistory[1] > Low[2]) && (m_parabolicHistory[0] < Low[2])) {
        return true;
    }

    return false;
}

ParabolicTrend ParabolicExpert::getParabolicTrend()
{
    if (m_parabolicHistoryCount < 2) {
        return UNKNOWN;
    }

    if (m_parabolicHistory[0] > High[2]) {
        return DOWN;
    }
    else if (m_parabolicHistory[0] < Low[2]) {
        return UP;
    }

    return UNKNOWN;
}