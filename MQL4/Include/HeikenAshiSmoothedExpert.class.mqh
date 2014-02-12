#property copyright "Copyright 2014, micclly."
#property link      "https://github.com/micclly"
#property strict

#include <OrderUtil.class.mqh>

enum HeikenTrend
{
    HT_UP,
    HT_FLAT,
    HT_DOWN,
    HT_UNKNOWN,
};

struct OpenCloseValue
{
    double open;
    double close;
};

class ParabolicExpert
{
public:
    ParabolicExpert(ENUM_MA_METHOD maMethod, int maPeriod, ENUM_MA_METHOD maMethod2, int maPeriod2, double lots, int tpPip, int slPip, int slipPip);

    void setDebugLevel(int level);
    void onTick();
    
private:
    static const int MAGIC_NUMBER;
    static const int MAX_HISTORY_COUNT;

    int m_debugLevel;
    const ENUM_MA_METHOD m_maMethod;
    const int m_maPeriod;
    const ENUM_MA_METHOD m_maMethod2;
    const int m_maPeriod2;
    const double m_lots;
    const int m_tpPip;
    const int m_slPip;
    const int m_slipPip;

    int m_prevBars;
    OpenCloseValue m_heikenHistory[];
    int m_heikenHistoryCount;

    bool isDebug(int level);
    void updateHistory();
    bool isHeikenTrendChanged();
    HeikenTrend getHeikenTrend(int shift);
    bool buy();
    bool sell();
    bool processTickets();
};


static const int ParabolicExpert::MAGIC_NUMBER = 868001;
static const int ParabolicExpert::MAX_HISTORY_COUNT = 200;


ParabolicExpert::ParabolicExpert(ENUM_MA_METHOD maMethod, int maPeriod, ENUM_MA_METHOD maMethod2, int maPeriod2, double lots, int tpPip, int slPip, int slipPip)
: m_debugLevel(0), m_maMethod(maMethod), m_maPeriod(maPeriod), m_heikenHistoryCount(0),
  m_maMethod2(maMethod2), m_maPeriod2(maPeriod2),
  m_lots(lots), m_tpPip(tpPip), m_slPip(slPip), m_slipPip(slipPip), m_prevBars(0)
{
    ArraySetAsSeries(m_heikenHistory, true);
    ArrayResize(m_heikenHistory, MAX_HISTORY_COUNT);
}

void ParabolicExpert::setDebugLevel(int level)
{
    PrintFormat("Debug mode enabled: level=%d", level);
    m_debugLevel = level;
}

void ParabolicExpert::onTick()
{
    bool barsChanged = false;
    if (m_prevBars != Bars) {
        barsChanged = true;
    }

    m_prevBars = Bars;

    if (barsChanged) {
        updateHistory();
    }

    if (!processTickets()) {
        return;
    }

    if (barsChanged && isHeikenTrendChanged()) {
        if (isDebug(2)) {
            PrintFormat("m_heikenHistory[0].open=%s, m_heikenHistory[0].close=%s, m_heikenHistory[1].open=%s, m_heikenHistory[1].close",
                DoubleToString(m_heikenHistory[0].open, Digits),
                DoubleToString(m_heikenHistory[0].close, Digits),
                DoubleToString(m_heikenHistory[1].open, Digits),
                DoubleToString(m_heikenHistory[1].close, Digits));
        }

        HeikenTrend trend = getHeikenTrend(0);
        if (isDebug(1)) {
            PrintFormat("Heiken trend is changed to: %s", EnumToString(trend));
        }
        
        if (trend == HT_UP) {
            buy();
        }
        else if (trend == HT_DOWN) {
            sell();
        }
        else {
            Alert("Unexpected trend type: " + EnumToString(trend));
        }
    }
}

bool ParabolicExpert::isDebug(int level)
{
    return m_debugLevel >= level;
}

void ParabolicExpert::updateHistory()
{
    if (m_heikenHistoryCount > 0 ) {
        for (int i = m_heikenHistoryCount - 1; i > 0; i--) {
            m_heikenHistory[i] = m_heikenHistory[i -1];
        }
    }

    double haOpen = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", m_maMethod, m_maPeriod, m_maMethod2, m_maPeriod2, 2, 1);
    double haClose = iCustom(NULL, 0, "Heiken_Ashi_Smoothed", m_maMethod, m_maPeriod, m_maMethod2, m_maPeriod2, 3, 1);

    if (isDebug(2)) {
        PrintFormat("haOpen=%s, haClose=%s, at %s",
            DoubleToString(haOpen, Digits), DoubleToString(haClose, Digits),
            TimeToString(Time[1]));
    }

    
    m_heikenHistory[0].open = NormalizeDouble(haOpen, Digits);
    m_heikenHistory[0].close = NormalizeDouble(haClose, Digits);

    if (m_heikenHistoryCount < MAX_HISTORY_COUNT) {
        m_heikenHistoryCount += 1;
    }
}

bool ParabolicExpert::isHeikenTrendChanged()
{
    if (m_heikenHistoryCount < 2) {
        return false;
    }
    else if (m_prevBars <= 10) {
        return false;
    }

    HeikenTrend latest = getHeikenTrend(0);
    if (latest == HT_FLAT) {
        return false;
    }

    for (int i = 1; i < m_heikenHistoryCount; i++) {
        HeikenTrend t = getHeikenTrend(i);
        if (t != HT_FLAT) {
            return t != latest;
        }
    }

    return false;
}

HeikenTrend ParabolicExpert::getHeikenTrend(int shift)
{
    if (m_heikenHistoryCount < shift) {
        return HT_UNKNOWN;
    }

    if (m_heikenHistory[shift].open < m_heikenHistory[shift].close) {
        return HT_UP;
    }
    else if (m_heikenHistory[shift].open == m_heikenHistory[shift].close) {
        return HT_FLAT;
    }
    else {
        return HT_DOWN;
    }
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
    
    HeikenTrend trend = getHeikenTrend(0);
    for (int i = 0; i < ArraySize(tickets); i++) {
        if (!OrderUtil::selectTicket(tickets[i])) {
            Alert("Cannot select ticket #" + IntegerToString(tickets[i]));
            ExpertRemove();
            return false;
        }

        if (OrderType() == OP_BUY) {
            if (trend == HT_DOWN) {
                if (!OrderClose(tickets[i], OrderLots(), Bid, m_slipPip, clrGreen)) {
                    Alert("Cannot close ticket #" + IntegerToString(tickets[i]));
                }
            }
        }
        else if (OrderType() == OP_SELL) {
            if (trend == HT_UP) {
                if (!OrderClose(tickets[i], OrderLots(), Ask, m_slipPip, clrYellow)) {
                    Alert("Cannot close ticket #" + IntegerToString(tickets[i]));
                }
            }
        }
    }

    return true;
}