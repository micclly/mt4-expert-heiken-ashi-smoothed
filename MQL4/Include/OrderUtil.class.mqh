/*
 * This is licensed under GNU General Public License Version 3.
 * See a LICENSE file distributed with this software.
 */
#property copyright "Copyright 2014, micclly."
#property link      "https://github.com/micclly"
#property strict

class OrderUtil
{
public:
    static double getAsk();
    static double pipToPrice(int pip);
    static int priceToPip(double price);
    static bool selectTicket(int ticket);
    static bool getTickets(int magicNumber, int& tickets[]);
    static bool calcLimits(int orderType, int tpPip, int slPip, double& tp, double& sl);
    static bool calcLimitsForModify(int ticket, int tpPip, int slPip, double& tp, double& sl);
};


static double OrderUtil::pipToPrice(int pip)
{
    return pip * Point;
}

static int OrderUtil::priceToPip(double price)
{
    return (int)NormalizeDouble(price / Point, 0);
}

static bool OrderUtil::selectTicket(int ticket)
{
    if (!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) {
        Alert("ERROR: Cannot select ticket " + IntegerToString(ticket));
        return false;
    }
    
    return true;
}

static bool OrderUtil::getTickets(int magicNumber, int& tickets[])
{
    int total = OrdersTotal();
    if (total == 0) {
        return false;
    }

    int buf[100];
    int ticketCount = 0;
    for (int i = total - 1; i >= 0; i--) {
        if (!OrderSelect(i, SELECT_BY_POS)) {
            continue;
        }
        else if (OrderMagicNumber() != magicNumber) {
            continue;
        }

        ticketCount += 1;
        if (ArraySize(buf) == ticketCount) {
            if (ArrayResize(buf, ticketCount) < 0) {
                return false;
            }
        }

        buf[ticketCount - 1] = OrderTicket();
    }

    ArrayResize(tickets, ticketCount);
    ArrayCopy(tickets, buf, 0, 0, ticketCount);
    
    return true;
}

static bool OrderUtil::calcLimits(int orderType, int tpPip, int slPip, double& tp, double& sl)
{
    if (orderType == OP_BUY) {
        double ask = Ask;
        if (tpPip > 0) {
            tp = NormalizeDouble(ask + pipToPrice(tpPip), Digits);
        }

        if (slPip > 0) {
            sl = NormalizeDouble(ask - pipToPrice(slPip), Digits);
        }

    }
    else if (orderType == OP_SELL) {
        double bid = Bid;
        if (tpPip > 0) {
            tp = NormalizeDouble(bid - pipToPrice(tpPip), Digits);
        }

        if (slPip > 0) {
            sl = NormalizeDouble(bid + pipToPrice(slPip), Digits);
        }
    }
    else {
        return false;
    }

    
    return true;
}

static bool OrderUtil::calcLimitsForModify(int ticket, int tpPip, int slPip, double& tp, double& sl)
{
    if (!selectTicket(ticket)) {
        return false;
    }

    if (OrderType() == OP_BUY) {
        double ask = Ask;
        if (tpPip > 0) {
            tp = NormalizeDouble(ask + pipToPrice(tpPip), Digits);
        }

        if (slPip > 0) {
            sl = NormalizeDouble(ask - pipToPrice(slPip), Digits);
        }

    }
    else if (OrderType() == OP_SELL) {
        double bid = Bid;
        if (tpPip > 0) {
            tp = NormalizeDouble(bid - pipToPrice(tpPip), Digits);
        }

        if (slPip > 0) {
            sl = NormalizeDouble(bid + pipToPrice(slPip), Digits);
        }
    }
    else {
        return false;
    }

    
    return true;
}

