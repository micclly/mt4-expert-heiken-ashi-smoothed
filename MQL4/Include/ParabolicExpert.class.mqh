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
    ParabolicExpert(double sarStep, double sarMax, ENUM_MA_METHOD maMethod, int maPeriod, double lots, int tpPip, int slPip, int slipPip);

    void enableDebug();
    void onTick();
    
private:
    static const int MAGIC_NUMBER;
    static const int MAX_HISTORY_COUNT;

    bool m_debug;
    const double m_sarStep;
    const double m_sarMax;
    const ENUM_MA_METHOD m_maMethod;
    const int m_maPeriod;
    const double m_lots;
    const int m_tpPip;
    const int m_slPip;
    const int m_slipPip;

    int g_prevBars;
    double m_parabolicHistory[];
    int m_parabolicHistoryCount;

    bool isDebug();
    void addHistory(double parabolic);
    bool isParabolicTrendChanged();
    ParabolicTrend getParabolicTrend(int shift);
    bool buy();
    bool sell();
    bool processTickets();
};


static const int ParabolicExpert::MAGIC_NUMBER = 868001;
static const int ParabolicExpert::MAX_HISTORY_COUNT = 2;


ParabolicExpert::ParabolicExpert(double sarStep, double sarMax, ENUM_MA_METHOD maMethod, int maPeriod, double lots, int tpPip, int slPip, int slipPip)
: m_debug(false), m_sarStep(sarStep), m_sarMax(sarMax), m_maMethod(maMethod), m_maPeriod(maPeriod), m_parabolicHistoryCount(0),
  m_lots(lots), m_tpPip(tpPip), m_slPip(slPip), m_slipPip(slipPip), g_prevBars(0)
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
    bool barsChanged = false;
    if (g_prevBars != Bars) {
        barsChanged = true;
    }

    g_prevBars = Bars;

    if (barsChanged) {
        double p = iCustom(NULL, 0, "Parabolic", 0.02, 0.2, 0, 0);
        addHistory(p);
    }

    if (!processTickets()) {
        return;
    }

    if (barsChanged && isParabolicTrendChanged()) {
        if (isDebug()) {
            PrintFormat("parabolic[0]=%s, parabolic[1]=%s", DoubleToString(m_parabolicHistory[0], 4), DoubleToString(m_parabolicHistory[1], 4));
            PrintFormat("Parabolic trend changed, at %s", TimeToString(Time[1]));
        }

        ParabolicTrend trend = getParabolicTrend(0);
        if (isDebug()) {
            PrintFormat("Parabolic trend is: %s", EnumToString(trend));
        }
        
        if (trend == UP) {
            buy();
        }
        else if (trend == DOWN) {
            sell();
        }
        else {
            Alert("Unknown trend type: " + EnumToString(trend));
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
    double ma = iMA(Symbol(), 0, m_maPeriod, 0, m_maMethod, PRICE_CLOSE, shift);
    if (m_parabolicHistory[shift] >= ma) {
        return DOWN;
    }
    else if (m_parabolicHistory[shift] <= ma) {
        return UP;
    }

    return UNKNOWN;
}

bool ParabolicExpert::buy()
{
    double tp, sl;
    if (!OrderUtil::calcLimits(OP_BUY, m_tpPip, m_slPip, tp, sl)) {
        Alert("Limit calculation failed");
        return false;
    }

    if (!OrderSend(Symbol(), OP_BUY, m_lots, Bid, m_slipPip, sl, tp, NULL, MAGIC_NUMBER, 0, clrRed)) {
        Alert("OrderSend to buy failed");
        return false;
    }

    return true;
}

bool ParabolicExpert::sell()
{
    double tp, sl;
    if (!OrderUtil::calcLimits(OP_SELL, m_tpPip, m_slPip, tp, sl)) {
        Alert("Limit calculation failed");
        return false;
    }

    if (!OrderSend(Symbol(), OP_SELL, m_lots, Ask, m_slipPip, sl, tp, NULL, MAGIC_NUMBER, 0, clrRed)) {
        Alert("OrderSend to sell failed");
        return false;
    }

    return true;
}

bool ParabolicExpert::processTickets()
{
    int tickets[];
    if (!OrderUtil::getTickets(MAGIC_NUMBER, tickets)) {
        return true;
    }
    
    ParabolicTrend trend = getParabolicTrend(0);
    for (int i = 0; i < ArraySize(tickets); i++) {
        if (!OrderUtil::selectTicket(tickets[i])) {
            Alert("Cannot select ticket #" + IntegerToString(tickets[i]));
            ExpertRemove();
            return false;
        }

        if (OrderType() == OP_BUY) {
            if (trend == DOWN) {
                if (Bid - OrderOpenPrice()  <= 0) {
                    if (!OrderClose(tickets[i], OrderLots(), Bid, m_slipPip, clrGreen)) {
                        Alert("Cannot close ticket #" + IntegerToString(tickets[i]));
                    }
                }
            }
        }
        else if (OrderType() == OP_SELL) {
            if (trend == UP) {
                if (OrderOpenPrice() - Ask <= 0) {
                    if (!OrderClose(tickets[i], OrderLots(), Ask, m_slipPip, clrYellow)) {
                        Alert("Cannot close ticket #" + IntegerToString(tickets[i]));
                    }
                }
            }
        }
    }

    return true;
}