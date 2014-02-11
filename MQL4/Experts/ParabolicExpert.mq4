#property copyright "Copyright 2014, micclly."
#property link      "https://github.com/micclly"
#property version   "1.00"
#property strict

class ParabolicExpert
{
public:
    ParabolicExpert(double sarStep, double sarMax);
    void onTick();
    
private:
    static const int MAX_HISTORY_COUNT;
    const double m_sarStep;
    const double m_sarMax;
    double m_parabolicHistory[];
    int m_parabolicHistoryCount;

    void addHistory(double parabolic);
    bool isParabolicTrendChanged();
};

static const int ParabolicExpert::MAX_HISTORY_COUNT = 2;


ParabolicExpert::ParabolicExpert(double sarStep, double sarMax)
: m_sarStep(sarStep), m_sarMax(sarMax), m_parabolicHistoryCount(0)
{
    ArraySetAsSeries(m_parabolicHistory, true);
    ArrayResize(m_parabolicHistory, MAX_HISTORY_COUNT);
}

ParabolicExpert::onTick()
{
    double p = iCustom(NULL, 0, "Parabolic", 0.02, 0.2, 0, 0);
    PrintFormat("Adding parabolic %.3f to history, at %s, high %.3f low %.3f", p, TimeToString(Time[1]), High[1], Low[1]);
    addHistory(p);

    if (isParabolicTrendChanged()) {
        PrintFormat("parabolic[0]=%s, parabolic[1]=%s", DoubleToString(m_parabolicHistory[0], 4), DoubleToString(m_parabolicHistory[1], 4));
        PrintFormat("Parabolic trend changed, at %s", TimeToString(Time[1]));
    }
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
    if (m_parabolicHistoryCount < MAX_HISTORY_COUNT) {
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

input double parabolicSarStep = 0.02;
input double parabolicSarMax = 0.2;

ParabolicExpert expert(parabolicSarStep, parabolicSarMax);

int OnInit()
{
    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
    expert.onTick();
}
