#property copyright "Copyright ?2009,Í¨Ó®Íâ»ã"
#property link      "http://www.fx3721.cn"

extern string comment = "TDS";
extern int magic = 1234;
extern string moneymanagement = "Money Management";
extern double lots = 0.01;
extern bool lotsoptimized = TRUE;
extern double risk = 1.0;
extern double minlot = 0.01;
extern double maxlot = 10.0;
extern double lotdigits = 2.0;
extern bool basketpercent = FALSE;
extern double profit = 10.0;
extern double loss = 30.0;
extern string ordersmanagement = "Order Management";
extern bool oppositeclose = TRUE;
extern bool reversesignals = FALSE;
extern int maxtrades = 100;
extern int tradesperbar = 1;
extern bool hidestop = FALSE;
extern bool hidetarget = TRUE;
extern int buystop = 0;
extern int buytarget = 11;
extern int sellstop = 0;
extern int selltarget = 11;
extern int trailingstart = 0;
extern int trailingstop = 0;
extern int trailingstep = 1;
extern int breakevengain = 0;
extern int breakeven = 0;
extern int slippage = 5;
extern string entrylogics = "Entry Logics";
extern int shift = 1;
extern bool timeframe1 = TRUE;
extern int timeframe1period = 3;
extern bool timeframe5 = FALSE;
extern int timeframe5period = 12;
extern bool timeframe15 = FALSE;
extern int timeframe15period = 12;
extern bool timeframe30 = FALSE;
extern int timeframe30period = 12;
extern bool timeframe60 = FALSE;
extern int timeframe60period = 12;
extern bool timeframe240 = TRUE;
extern int timeframe240period = 12;
extern bool timeframe1440 = TRUE;
extern int timeframe1440period = 10;
extern bool timeframe10080 = FALSE;
extern int timeframe10080period = 12;
extern string timefilter = "Time Filter";
extern int gmtshift = 1;
extern bool tradesunday = FALSE;
extern bool mondayfilter = TRUE;
extern int mondaystart = 14;
extern bool fridayfilter = FALSE;
extern int fridayend = 24;
extern string volatilityfilters = "Volatility Filter";
extern bool timeframe1vfilter = FALSE;
extern bool timeframe5vfilter = FALSE;
extern bool timeframe15vfilter = FALSE;
extern bool timeframe30vfilter = FALSE;
extern bool timeframe60vfilter = FALSE;
extern bool timeframe240vfilter = TRUE;
extern bool timeframe1440vfilter = TRUE;
extern bool timeframe10080vfilter = FALSE;
extern string otherfilters = "Other Filters";
extern bool pricefilter = TRUE;
extern bool patternsfilter = TRUE;
datetime gt_unused_396;
datetime gt_unused_400;
int g_datetime_404;
int g_datetime_408;
double gd_412 = 0.0;
double g_ord_open_price_420 = 0.0;
double g_ord_open_price_428 = 0.0;
double g_price_436;
double g_price_444;
double gd_452;
double gd_460;
double gd_484;
double gd_492;
int g_pos_500;
int g_pos_504;
int g_pos_508;
int g_pos_512;
int g_digits_516;
int g_bars_520 = -1;
int g_count_524 = 0;
int g_ord_total_528;
int g_ticket_532;
int gi_536 = 0;
int gi_540 = 0;
int gi_544 = 0;
int gi_unused_548 = 0;
int gi_unused_552 = 0;
int g_pos_556 = 0;

int init() {
   gt_unused_396 = Time[0];
   gt_unused_400 = Time[0];
   g_digits_516 = Digits;
   if (g_digits_516 == 3 || g_digits_516 == 5) {
      gd_452 = 10.0 * Point;
      gd_460 = 10;
   } else {
      gd_452 = Point;
      gd_460 = 1;
   }
   return (0);
}

int start() {
   double ld_8;
   double ld_16;
   Comment("\n  THE DONCHIAN SCALPER", 
   "\n   BY WWW.TRADINGSYSTEMFOREX.COM");
   g_ord_total_528 = OrdersTotal();
   if (breakevengain > 0) {
      for (int l_pos_0 = 0; l_pos_0 < g_ord_total_528; l_pos_0++) {
         OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_BUY) {
               if (NormalizeDouble(Bid - OrderOpenPrice(), g_digits_516) < NormalizeDouble(breakevengain * gd_452, g_digits_516)) continue;
               if (NormalizeDouble(OrderStopLoss() - OrderOpenPrice(), g_digits_516) >= NormalizeDouble(breakeven * gd_452, g_digits_516)) continue;
               OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(OrderOpenPrice() + breakeven * gd_452, g_digits_516), OrderTakeProfit(), 0, Blue);
               return (0);
            }
            if (NormalizeDouble(OrderOpenPrice() - Ask, g_digits_516) >= NormalizeDouble(breakevengain * gd_452, g_digits_516)) {
               if (NormalizeDouble(OrderOpenPrice() - OrderStopLoss(), g_digits_516) < NormalizeDouble(breakeven * gd_452, g_digits_516)) {
                  OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(OrderOpenPrice() - breakeven * gd_452, g_digits_516), OrderTakeProfit(), 0, Red);
                  return (0);
               }
            }
         }
      }
   }
   if (trailingstop > 0) {
      for (int l_pos_4 = 0; l_pos_4 < g_ord_total_528; l_pos_4++) {
         OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_BUY) {
               if (!(NormalizeDouble(Ask, g_digits_516) > NormalizeDouble(OrderOpenPrice() + trailingstart * gd_452, g_digits_516) && NormalizeDouble(OrderStopLoss(), g_digits_516) < NormalizeDouble(Bid - (trailingstop +
                  trailingstep) * gd_452, g_digits_516) || OrderStopLoss() == 0.0)) continue;
               OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Bid - trailingstop * gd_452, g_digits_516), OrderTakeProfit(), 0, Blue);
               return (0);
            }
            if (NormalizeDouble(Bid, g_digits_516) < NormalizeDouble(OrderOpenPrice() - trailingstart * gd_452, g_digits_516) && NormalizeDouble(OrderStopLoss(), g_digits_516) > NormalizeDouble(Ask +
               (trailingstop + trailingstep) * gd_452, g_digits_516) || OrderStopLoss() == 0.0) {
               OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Ask + trailingstop * gd_452, g_digits_516), OrderTakeProfit(), 0, Red);
               return (0);
            }
         }
      }
   }
   if (basketpercent) {
      ld_8 = profit * (AccountBalance() / 100.0);
      ld_16 = loss * (AccountBalance() / 100.0);
      gd_412 = AccountEquity() - AccountBalance();
      if (gd_412 > gd_484) gd_484 = gd_412;
      if (gd_412 < gd_492) gd_492 = gd_412;
      if (gd_412 >= ld_8 || gd_412 <= (-1.0 * ld_16)) {
         for (g_pos_500 = g_ord_total_528 - 1; g_pos_500 >= 0; g_pos_500--) {
            OrderSelect(g_pos_500, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slippage * gd_452);
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slippage * gd_452);
         }
         return (0);
      }
   }
   for (g_pos_556 = 0; g_pos_556 < OrdersTotal(); g_pos_556++) {
      OrderSelect(g_pos_556, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderCloseTime() == 0) {
         gi_544++;
         if (OrderType() == OP_BUY) {
            gi_536++;
            g_ord_open_price_420 = OrderOpenPrice();
            gi_unused_548 = OrderProfit();
            g_datetime_404 = OrderOpenTime();
         }
         if (OrderType() == OP_SELL) {
            gi_540++;
            g_ord_open_price_428 = OrderOpenPrice();
            gi_unused_552 = OrderProfit();
            g_datetime_408 = OrderOpenTime();
         }
      }
   }
   double l_ihigh_24 = iHigh(Symbol(), PERIOD_M1, iHighest(Symbol(), PERIOD_M1, MODE_HIGH, timeframe1period, shift + 1));
   double l_ilow_32 = iLow(Symbol(), PERIOD_M1, iLowest(Symbol(), PERIOD_M1, MODE_LOW, timeframe1period, shift + 1));
   double l_ihigh_40 = iHigh(Symbol(), PERIOD_M1, iHighest(Symbol(), PERIOD_M1, MODE_HIGH, timeframe1period, shift));
   double l_ilow_48 = iLow(Symbol(), PERIOD_M1, iLowest(Symbol(), PERIOD_M1, MODE_LOW, timeframe1period, shift));
   double l_ihigh_56 = iHigh(Symbol(), PERIOD_M5, iHighest(Symbol(), PERIOD_M5, MODE_HIGH, timeframe5period, shift + 1));
   double l_ilow_64 = iLow(Symbol(), PERIOD_M5, iLowest(Symbol(), PERIOD_M5, MODE_LOW, timeframe5period, shift + 1));
   double l_ihigh_72 = iHigh(Symbol(), PERIOD_M5, iHighest(Symbol(), PERIOD_M5, MODE_HIGH, timeframe5period, shift));
   double l_ilow_80 = iLow(Symbol(), PERIOD_M5, iLowest(Symbol(), PERIOD_M5, MODE_LOW, timeframe5period, shift));
   double l_ihigh_88 = iHigh(Symbol(), PERIOD_M15, iHighest(Symbol(), PERIOD_M15, MODE_HIGH, timeframe15period, shift + 1));
   double l_ilow_96 = iLow(Symbol(), PERIOD_M15, iLowest(Symbol(), PERIOD_M15, MODE_LOW, timeframe15period, shift + 1));
   double l_ihigh_104 = iHigh(Symbol(), PERIOD_M15, iHighest(Symbol(), PERIOD_M15, MODE_HIGH, timeframe15period, shift));
   double l_ilow_112 = iLow(Symbol(), PERIOD_M15, iLowest(Symbol(), PERIOD_M15, MODE_LOW, timeframe15period, shift));
   double l_ihigh_120 = iHigh(Symbol(), PERIOD_M30, iHighest(Symbol(), PERIOD_M30, MODE_HIGH, timeframe30period, shift + 1));
   double l_ilow_128 = iLow(Symbol(), PERIOD_M30, iLowest(Symbol(), PERIOD_M30, MODE_LOW, timeframe30period, shift + 1));
   double l_ihigh_136 = iHigh(Symbol(), PERIOD_M30, iHighest(Symbol(), PERIOD_M30, MODE_HIGH, timeframe30period, shift));
   double l_ilow_144 = iLow(Symbol(), PERIOD_M30, iLowest(Symbol(), PERIOD_M30, MODE_LOW, timeframe30period, shift));
   double l_ihigh_152 = iHigh(Symbol(), PERIOD_H1, iHighest(Symbol(), PERIOD_H1, MODE_HIGH, timeframe60period, shift + 1));
   double l_ilow_160 = iLow(Symbol(), PERIOD_H1, iLowest(Symbol(), PERIOD_H1, MODE_LOW, timeframe60period, shift + 1));
   double l_ihigh_168 = iHigh(Symbol(), PERIOD_H1, iHighest(Symbol(), PERIOD_H1, MODE_HIGH, timeframe60period, shift));
   double l_ilow_176 = iLow(Symbol(), PERIOD_H1, iLowest(Symbol(), PERIOD_H1, MODE_LOW, timeframe60period, shift));
   double l_ihigh_184 = iHigh(Symbol(), PERIOD_H4, iHighest(Symbol(), PERIOD_H4, MODE_HIGH, timeframe240period, shift + 1));
   double l_ilow_192 = iLow(Symbol(), PERIOD_H4, iLowest(Symbol(), PERIOD_H4, MODE_LOW, timeframe240period, shift + 1));
   double l_ihigh_200 = iHigh(Symbol(), PERIOD_H4, iHighest(Symbol(), PERIOD_H4, MODE_HIGH, timeframe240period, shift));
   double l_ilow_208 = iLow(Symbol(), PERIOD_H4, iLowest(Symbol(), PERIOD_H4, MODE_LOW, timeframe240period, shift));
   double l_ihigh_216 = iHigh(Symbol(), PERIOD_D1, iHighest(Symbol(), PERIOD_D1, MODE_HIGH, timeframe1440period, shift + 1));
   double l_ilow_224 = iLow(Symbol(), PERIOD_D1, iLowest(Symbol(), PERIOD_D1, MODE_LOW, timeframe1440period, shift + 1));
   double l_ihigh_232 = iHigh(Symbol(), PERIOD_D1, iHighest(Symbol(), PERIOD_D1, MODE_HIGH, timeframe1440period, shift));
   double l_ilow_240 = iLow(Symbol(), PERIOD_D1, iLowest(Symbol(), PERIOD_D1, MODE_LOW, timeframe1440period, shift));
   double l_ihigh_248 = iHigh(Symbol(), PERIOD_W1, iHighest(Symbol(), PERIOD_W1, MODE_HIGH, timeframe10080period, shift + 1));
   double l_ilow_256 = iLow(Symbol(), PERIOD_W1, iLowest(Symbol(), PERIOD_W1, MODE_LOW, timeframe10080period, shift + 1));
   double l_ihigh_264 = iHigh(Symbol(), PERIOD_W1, iHighest(Symbol(), PERIOD_W1, MODE_HIGH, timeframe10080period, shift));
   double l_ilow_272 = iLow(Symbol(), PERIOD_W1, iLowest(Symbol(), PERIOD_W1, MODE_LOW, timeframe10080period, shift));
   bool li_280 = TRUE;
   bool li_284 = TRUE;
   bool li_288 = FALSE;
   bool li_292 = FALSE;
   if ((timeframe1vfilter && iBands(NULL, PERIOD_M1, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, shift) > iBands(NULL, PERIOD_M1, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, shift + 1) &&
      iBands(NULL, PERIOD_M1, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, shift) < iBands(NULL, PERIOD_M1, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, shift + 1)) || (timeframe5vfilter && iBands(NULL, PERIOD_M5, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, shift) > iBands(NULL, PERIOD_M5, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, shift +
      1) && iBands(NULL, PERIOD_M5, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, shift) < iBands(NULL, PERIOD_M5, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, shift + 1)) || (timeframe15vfilter &&
      iBands(NULL, PERIOD_M15, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, shift) > iBands(NULL, PERIOD_M15, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, shift + 1) && iBands(NULL, PERIOD_M15, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, shift) < iBands(NULL, PERIOD_M15, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, shift +
      1)) || (timeframe30vfilter && iBands(NULL, PERIOD_M30, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, shift) > iBands(NULL, PERIOD_M30, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, shift + 1) &&
      iBands(NULL, PERIOD_M30, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, shift) < iBands(NULL, PERIOD_M30, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, shift + 1)) || (timeframe60vfilter && iBands(NULL, PERIOD_H1, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, shift) > iBands(NULL, PERIOD_H1, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, shift +
      1) && iBands(NULL, PERIOD_H1, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, shift) < iBands(NULL, PERIOD_M15, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, shift + 1)) || (timeframe240vfilter &&
      iBands(NULL, PERIOD_H4, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, shift) > iBands(NULL, PERIOD_H4, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, shift + 1) && iBands(NULL, PERIOD_H4, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, shift) < iBands(NULL, PERIOD_H4, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, shift +
      1)) || (timeframe1440vfilter && iBands(NULL, PERIOD_D1, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, shift) > iBands(NULL, PERIOD_D1, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, shift + 1) &&
      iBands(NULL, PERIOD_D1, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, shift) < iBands(NULL, PERIOD_D1, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, shift + 1)) || (timeframe10080vfilter && iBands(NULL, PERIOD_W1, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, shift) > iBands(NULL, PERIOD_W1, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, shift +
      1) && iBands(NULL, PERIOD_W1, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, shift) < iBands(NULL, PERIOD_W1, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, shift + 1))) {
      li_280 = FALSE;
      li_284 = FALSE;
   }
   double ld_296 = Close[1];
   double ld_304 = 5.0 * gd_452;
   double ld_312 = 10.0 * gd_452;
   double ld_320 = 50.0 * gd_452;
   double ld_328 = 110.0 * gd_452;
   double l_iclose_336 = iClose(NULL, PERIOD_H1, 1);
   double l_iclose_344 = iClose(NULL, PERIOD_H1, 2);
   double l_iclose_352 = iClose(NULL, PERIOD_H1, 3);
   double l_iclose_360 = iClose(NULL, PERIOD_H1, 4);
   double l_iclose_368 = iClose(NULL, PERIOD_H1, 5);
   double l_iclose_376 = iClose(NULL, PERIOD_H1, 6);
   double l_iclose_384 = iClose(NULL, PERIOD_H1, 7);
   double l_iclose_392 = iClose(NULL, PERIOD_H1, 8);
   double l_iclose_400 = iClose(NULL, PERIOD_H1, 9);
   double l_iclose_408 = iClose(NULL, PERIOD_H1, 10);
   double l_iclose_416 = iClose(NULL, PERIOD_H1, 11);
   double l_iclose_424 = iClose(NULL, PERIOD_H1, 12);
   double l_iclose_432 = iClose(NULL, PERIOD_H1, 13);
   double l_iopen_440 = iOpen(NULL, PERIOD_H1, 1);
   double l_iopen_448 = iOpen(NULL, PERIOD_H1, 2);
   double l_iopen_456 = iOpen(NULL, PERIOD_H1, 3);
   double l_iopen_464 = iOpen(NULL, PERIOD_H1, 4);
   double l_iopen_472 = iOpen(NULL, PERIOD_H1, 5);
   double l_iopen_480 = iOpen(NULL, PERIOD_H1, 6);
   double l_iopen_488 = iOpen(NULL, PERIOD_H1, 7);
   double l_iopen_496 = iOpen(NULL, PERIOD_H1, 8);
   double l_iopen_504 = iOpen(NULL, PERIOD_H1, 9);
   double l_iopen_512 = iOpen(NULL, PERIOD_H1, 10);
   double l_iopen_520 = iOpen(NULL, PERIOD_H1, 11);
   double l_iopen_528 = iOpen(NULL, PERIOD_H1, 12);
   double l_iopen_536 = iOpen(NULL, PERIOD_H1, 13);
   double l_ihigh_544 = iHigh(NULL, PERIOD_H1, 1);
   double l_ihigh_552 = iHigh(NULL, PERIOD_H1, 2);
   double l_ihigh_560 = iHigh(NULL, PERIOD_H1, 3);
   double l_ihigh_568 = iHigh(NULL, PERIOD_H1, 4);
   double l_ihigh_576 = iHigh(NULL, PERIOD_H1, 5);
   double l_ihigh_584 = iHigh(NULL, PERIOD_H1, 6);
   double l_ihigh_592 = iHigh(NULL, PERIOD_H1, 7);
   double l_ihigh_600 = iHigh(NULL, PERIOD_H1, 8);
   double l_ihigh_608 = iHigh(NULL, PERIOD_H1, 9);
   double l_ihigh_616 = iHigh(NULL, PERIOD_H1, 10);
   double l_ihigh_624 = iHigh(NULL, PERIOD_H1, 11);
   double l_ihigh_632 = iHigh(NULL, PERIOD_H1, 12);
   double l_ihigh_640 = iHigh(NULL, PERIOD_H1, 13);
   double l_ilow_648 = iLow(NULL, PERIOD_H1, 1);
   double l_ilow_656 = iLow(NULL, PERIOD_H1, 2);
   double l_ilow_664 = iLow(NULL, PERIOD_H1, 3);
   double l_ilow_672 = iLow(NULL, PERIOD_H1, 4);
   double l_ilow_680 = iLow(NULL, PERIOD_H1, 5);
   double l_ilow_688 = iLow(NULL, PERIOD_H1, 6);
   double l_ilow_696 = iLow(NULL, PERIOD_H1, 7);
   double l_ilow_704 = iLow(NULL, PERIOD_H1, 8);
   double l_ilow_712 = iLow(NULL, PERIOD_H1, 9);
   double l_ilow_720 = iLow(NULL, PERIOD_H1, 10);
   double l_ilow_728 = iLow(NULL, PERIOD_H1, 11);
   double l_ilow_736 = iLow(NULL, PERIOD_H1, 12);
   double l_ilow_744 = iLow(NULL, PERIOD_H1, 13);
   if ((pricefilter && ld_296 > l_iclose_376 + 110.0 * gd_452) || (patternsfilter && (l_iclose_336 >= l_iclose_344 && l_iclose_336 >= l_iclose_352 && l_iopen_464 > l_iclose_360 &&
      l_iclose_368 > l_iopen_472 && l_iopen_464 - l_iclose_360 >= 50.0 * gd_452 && l_iopen_472 - l_ilow_680 <= 5.0 * gd_452 && l_ihigh_568 - l_iopen_464 <= 5.0 * gd_452) ||
      (l_iclose_376 > l_iopen_480 && l_iclose_368 > l_iopen_472 && l_iclose_360 > l_iopen_464 && l_iclose_352 > l_iopen_456 && l_iclose_344 > l_iopen_448 && l_iclose_336 > l_iopen_440 &&
      l_iclose_376 - l_iopen_480 < l_iclose_368 - l_iopen_472 && l_iclose_368 - l_iopen_472 < l_iclose_360 - l_iopen_464 && l_iclose_360 - l_iopen_464 > l_iclose_352 - l_iopen_456 &&
      l_iclose_352 - l_iopen_456 < l_iclose_344 - l_iopen_448 && l_iclose_344 - l_iopen_448 < l_iclose_336 - l_iopen_440 && l_iclose_352 - l_iopen_456 < 4.0 * (l_ihigh_560 - l_iclose_352) && l_iclose_344 - l_iopen_448 < 2.0 * (l_ihigh_552 - l_iclose_344) && l_ihigh_544 < l_ihigh_552) ||
      (l_iclose_368 > l_iopen_472 && l_iclose_360 > l_iopen_464 && l_iclose_352 > l_iopen_456 && l_iclose_344 > l_iopen_448 && l_iclose_336 > l_iopen_440 && l_iclose_368 - l_iopen_472 < l_iclose_360 - l_iopen_464 &&
      l_iclose_360 - l_iopen_464 < l_iclose_352 - l_iopen_456 && l_iclose_352 - l_iopen_456 > l_iclose_344 - l_iopen_448 && l_iclose_344 - l_iopen_448 < l_iclose_336 - l_iopen_440 &&
      l_iclose_344 - l_iopen_448 < 10.0 * (l_ihigh_552 - l_iclose_344) && l_iclose_336 - l_iopen_440 < 2.0 * (l_ihigh_544 - l_iclose_336)) || (l_iclose_368 > l_iopen_472 && l_iclose_360 > l_iopen_464 && l_iclose_352 > l_iopen_456 && l_iclose_344 > l_iopen_448 && l_iclose_336 < l_iopen_440 && l_iclose_368 - l_iopen_472 > 110.0 * gd_452 && l_iclose_368 - l_iopen_472 > l_iclose_360 - l_iopen_464 && l_iclose_360 - l_iopen_464 >= l_iclose_352 - l_iopen_456 && l_iclose_352 - l_iopen_456 < l_iclose_344 - l_iopen_448 && l_ihigh_576 > l_ihigh_568 && l_ihigh_576 > l_ihigh_560 && l_ihigh_576 > l_ihigh_552 && l_ihigh_576 > l_ihigh_544 && l_ihigh_552 > l_ihigh_544 && l_ilow_680 < l_ihigh_568 && l_ilow_672 < l_ihigh_560 && l_ilow_664 < l_ihigh_552 && l_ilow_648 < l_ihigh_552) ||
      (l_iclose_352 > l_iopen_456 && l_iclose_344 > l_iopen_448 && l_iclose_336 > l_iopen_440 && l_iclose_352 - l_iopen_456 <= 10.0 * gd_452 && l_iclose_344 - l_iopen_448 >= 50.0 * gd_452 &&
      l_ihigh_560 < l_ihigh_552 && l_ihigh_552 < l_ihigh_544 && l_iopen_456 - l_ilow_664 <= 5.0 * gd_452 && l_iopen_448 - l_ilow_656 <= 5.0 * gd_452 && l_iopen_440 - l_ilow_648 <= 5.0 * gd_452) ||
      (l_iclose_360 > l_iopen_464 && l_iclose_352 > l_iopen_456 && l_iclose_344 > l_iopen_448 && l_iclose_360 - l_iopen_464 <= 10.0 * gd_452 && l_iclose_352 - l_iopen_456 >= 50.0 * gd_452 &&
      l_ihigh_568 < l_ihigh_560 && l_ihigh_560 < l_ihigh_552 && l_iopen_464 - l_ilow_672 <= 5.0 * gd_452 && l_iopen_456 - l_ilow_664 <= 5.0 * gd_452 && l_iopen_448 - l_ilow_656 <= 5.0 * gd_452 &&
      l_ihigh_544 < l_ihigh_552) || (l_iclose_368 > l_iopen_472 && l_iclose_360 > l_iopen_464 && l_iclose_352 > l_iopen_456 && l_iclose_368 - l_iopen_472 <= 10.0 * gd_452 && l_iclose_360 - l_iopen_464 >= 50.0 * gd_452 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_iopen_472 - l_ilow_680 <= 5.0 * gd_452 && l_iopen_464 - l_ilow_672 <= 5.0 * gd_452 && l_iopen_456 - l_ilow_664 <= 5.0 * gd_452 && l_ihigh_552 < l_ihigh_560 && l_ihigh_544 < l_ihigh_552) ||
      (l_iclose_376 > l_iopen_480 && l_iclose_368 > l_iopen_472 && l_iclose_360 > l_iopen_464 && l_iclose_376 - l_iopen_480 <= 10.0 * gd_452 && l_iclose_368 - l_iopen_472 >= 50.0 * gd_452 &&
      l_ihigh_584 < l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_iopen_480 - l_ilow_688 <= 5.0 * gd_452 && l_iopen_472 - l_ilow_680 <= 5.0 * gd_452 && l_iopen_464 - l_ilow_672 <= 5.0 * gd_452 &&
      l_ihigh_560 < l_ihigh_568 && l_ihigh_552 < l_ihigh_560 && l_ihigh_544 < l_ihigh_552) || (l_iclose_384 > l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 > l_iopen_472 && l_iclose_384 - l_iopen_488 <= 10.0 * gd_452 && l_iclose_376 - l_iopen_480 >= 50.0 * gd_452 && l_ihigh_592 < l_ihigh_584 && l_ihigh_584 < l_ihigh_576 && l_iopen_488 - l_ilow_696 <= 5.0 * gd_452 && l_iopen_480 - l_ilow_688 <= 5.0 * gd_452 && l_iopen_472 - l_ilow_680 <= 5.0 * gd_452 && l_ihigh_568 < l_ihigh_576 && l_ihigh_560 < l_ihigh_568 && l_ihigh_552 < l_ihigh_560 && l_ihigh_544 < l_ihigh_552) ||
      (l_iclose_392 > l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 < l_iopen_472 && l_iclose_360 > l_iopen_464 && l_iclose_352 > l_iopen_456 &&
      l_iclose_344 >= l_iopen_448 && l_iclose_336 < l_iopen_440 && l_ilow_704 < l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 < l_ilow_672 &&
      l_ilow_672 < l_ilow_664 && l_ilow_664 < l_ilow_656 && l_ilow_656 > l_ilow_648 && l_ihigh_600 <= l_ihigh_592 && l_ihigh_592 < l_ihigh_584 && l_ihigh_584 > l_ihigh_576 &&
      l_ihigh_576 < l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ihigh_560 < l_ihigh_552 && l_ihigh_552 > l_ihigh_544) || (l_iclose_384 > l_iopen_488 && l_iclose_376 < l_iopen_480 && l_iclose_368 > l_iopen_472 && l_iclose_360 < l_iopen_464 && l_iclose_352 > l_iopen_456 && l_iclose_344 > l_iopen_448 && l_iclose_336 < l_iopen_440 && l_ihigh_592 > l_ihigh_584 && l_ihigh_584 < l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ihigh_560 < l_ihigh_552 && l_ihigh_552 > l_ihigh_544 && l_ilow_696 > l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 > l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 < l_ilow_656 && l_ilow_656 < l_ilow_648) ||
      (l_iclose_392 > l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 < l_iopen_472 && l_iclose_360 > l_iopen_464 && l_iclose_352 > l_iopen_456 &&
      l_iclose_344 < l_iopen_448 && l_ihigh_600 > l_ihigh_592 && l_ihigh_592 < l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 < l_ihigh_560 &&
      l_ihigh_560 > l_ihigh_552 && l_ilow_704 > l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 < l_ilow_664 &&
      l_ilow_664 < l_ilow_656) || (l_iclose_400 > l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 > l_iopen_488 && l_iclose_376 < l_iopen_480 && l_iclose_368 > l_iopen_472 && l_iclose_360 > l_iopen_464 && l_iclose_352 < l_iopen_456 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 < l_ihigh_592 && l_ihigh_592 > l_ihigh_584 && l_ihigh_584 < l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ilow_712 > l_ilow_704 && l_ilow_704 < l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 < l_ilow_664) ||
      (l_iclose_408 > l_iopen_512 && l_iclose_400 < l_iopen_504 && l_iclose_392 > l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 > l_iopen_472 &&
      l_iclose_360 < l_iopen_464 && l_ihigh_616 > l_ihigh_608 && l_ihigh_608 < l_ihigh_600 && l_ihigh_600 > l_ihigh_592 && l_ihigh_592 < l_ihigh_584 && l_ihigh_584 < l_ihigh_576 &&
      l_ihigh_576 > l_ihigh_568 && l_ilow_720 > l_ilow_712 && l_ilow_712 < l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 < l_ilow_680 &&
      l_ilow_680 < l_ilow_672) || (l_iclose_384 < l_iopen_488 && l_iclose_376 < l_iopen_480 && l_iclose_368 > l_iopen_472 && l_iclose_360 > l_iopen_464 && l_iopen_456 > l_iclose_352 && l_iopen_448 > l_iclose_344 && l_iclose_336 > l_iopen_440 && l_ihigh_592 < l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ihigh_552 >= l_ihigh_544 && l_ilow_696 > l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 > l_ilow_664 && l_ilow_664 > l_ilow_656 && l_ilow_656 < l_ilow_648 && l_iclose_384 - l_ilow_696 <= 5.0 * gd_452 && l_iclose_376 - l_ilow_688 <= 5.0 * gd_452 && l_ihigh_560 - l_iopen_456 <= 5.0 * gd_452 && l_ihigh_552 - l_iopen_448 <= 5.0 * gd_452 && l_ihigh_544 - l_iclose_336 <= 5.0 * gd_452) ||
      (l_iclose_392 < l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 > l_iopen_472 && l_iopen_464 > l_iclose_360 && l_iopen_456 > l_iclose_352 &&
      l_iclose_344 > l_iopen_448 && l_ihigh_600 < l_ihigh_592 && l_ihigh_592 > l_ihigh_584 && l_ihigh_584 < l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 > l_ihigh_560 &&
      l_ihigh_560 >= l_ihigh_552 && l_ilow_704 > l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 > l_ilow_672 && l_ilow_672 > l_ilow_664 &&
      l_ilow_664 < l_ilow_656 && l_iclose_392 - l_ilow_704 <= 5.0 * gd_452 && l_iclose_384 - l_ilow_696 <= 5.0 * gd_452 && l_ihigh_568 - l_iopen_464 <= 5.0 * gd_452 && l_ihigh_560 - l_iopen_456 <= 5.0 * gd_452 &&
      l_ihigh_552 - l_iclose_344 <= 5.0 * gd_452) || (l_iclose_400 < l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 > l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iopen_472 > l_iclose_368 && l_iopen_464 > l_iclose_360 && l_iclose_352 > l_iopen_456 && l_ihigh_608 < l_ihigh_600 && l_ihigh_600 > l_ihigh_592 && l_ihigh_592 < l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 >= l_ihigh_560 && l_ilow_712 > l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 > l_ilow_672 && l_ilow_672 < l_ilow_664 && l_iclose_400 - l_ilow_712 <= 5.0 * gd_452 && l_iclose_392 - l_ilow_704 <= 5.0 * gd_452 && l_ihigh_576 - l_iopen_472 <= 5.0 * gd_452 && l_ihigh_568 - l_iopen_464 <= 5.0 * gd_452 && l_ihigh_560 - l_iclose_352 <= 5.0 * gd_452) ||
      (l_iclose_408 < l_iopen_512 && l_iclose_400 < l_iopen_504 && l_iclose_392 > l_iopen_496 && l_iclose_384 > l_iopen_488 && l_iopen_480 > l_iclose_376 && l_iopen_472 > l_iclose_368 &&
      l_iclose_360 > l_iopen_464 && l_ihigh_616 < l_ihigh_608 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 < l_ihigh_592 && l_ihigh_592 > l_ihigh_584 && l_ihigh_584 > l_ihigh_576 &&
      l_ihigh_576 >= l_ihigh_568 && l_ilow_720 > l_ilow_712 && l_ilow_712 > l_ilow_704 && l_ilow_704 < l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 > l_ilow_680 &&
      l_ilow_680 < l_ilow_672 && l_iclose_408 - l_ilow_720 <= 5.0 * gd_452 && l_iclose_400 - l_ilow_712 <= 5.0 * gd_452 && l_ihigh_584 - l_iopen_480 <= 5.0 * gd_452 && l_ihigh_576 - l_iopen_472 <= 5.0 * gd_452 &&
      l_ihigh_568 - l_iclose_360 <= 5.0 * gd_452) || (l_iclose_408 > l_iopen_512 && l_iopen_504 > l_iclose_400 && l_iclose_392 > l_iopen_496 && l_iclose_384 > l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 > l_iopen_472 && l_iclose_360 > l_iopen_464 && l_iclose_352 < l_iopen_456 && l_iclose_344 > l_iopen_448 && l_iclose_336 > l_iopen_440 && l_ihigh_616 < l_ihigh_608 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 < l_ihigh_592 && l_ihigh_592 < l_ihigh_584 && l_ihigh_584 < l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ihigh_560 < l_ihigh_552 && l_ihigh_552 < l_ihigh_544 && l_ilow_720 > l_ilow_712 && l_ilow_712 < l_ilow_704 && l_ilow_704 < l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 > l_ilow_656 && l_ilow_656 < l_ilow_648) ||
      (l_iclose_400 < l_iopen_504 && l_iclose_392 >= l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 > l_iopen_472 && l_iclose_360 > l_iopen_464 &&
      l_iclose_352 < l_iopen_456 && l_iclose_344 > l_iopen_448 && l_iclose_336 > l_iopen_440 && l_ihigh_608 < l_ihigh_600 && l_ihigh_600 < l_ihigh_592 && l_ihigh_592 < l_ihigh_584 &&
      l_ihigh_584 < l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ihigh_552 < l_ihigh_544 && l_ilow_712 < l_ilow_704 &&
      l_ilow_704 > l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 <= l_ilow_656 && l_ilow_656 < l_ilow_648) ||
      (l_iclose_408 < l_iopen_512 && l_iclose_400 >= l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 > l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 > l_iopen_472 &&
      l_iclose_360 < l_iopen_464 && l_iclose_352 > l_iopen_456 && l_iclose_344 > l_iopen_448 && l_ihigh_616 < l_ihigh_608 && l_ihigh_608 < l_ihigh_600 && l_ihigh_600 < l_ihigh_592 &&
      l_ihigh_592 < l_ihigh_584 && l_ihigh_584 < l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 < l_ihigh_552 && l_ilow_720 < l_ilow_712 &&
      l_ilow_712 > l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 <= l_ilow_664 && l_ilow_664 < l_ilow_656) ||
      (l_iclose_408 > l_iopen_512 && l_iclose_400 > l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 > l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 > l_iopen_472 &&
      l_iclose_360 > l_iopen_464 && l_iclose_352 > l_iopen_456 && l_iclose_344 < l_iopen_448 && l_iclose_336 < l_iopen_440 && l_ihigh_616 < l_ihigh_608 && l_ihigh_608 > l_ihigh_600 &&
      l_ihigh_600 > l_ihigh_592 && l_ihigh_592 < l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ihigh_560 > l_ihigh_552 &&
      l_ihigh_552 > l_ihigh_544 && l_ilow_720 < l_ilow_712 && l_ilow_712 > l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 < l_ilow_680 &&
      l_ilow_680 < l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 > l_ilow_656 && l_ilow_656 > l_ilow_648) || (l_iclose_400 >= l_iclose_400 && l_iclose_392 < l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 < l_iopen_480 && l_iclose_368 < l_iopen_472 && l_iclose_360 > l_iopen_464 && l_iclose_352 > l_iopen_456 && l_iclose_344 < l_iopen_448 && l_iclose_336 > l_iopen_440 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 >= l_ihigh_592 && l_ihigh_592 > l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ihigh_552 < l_ihigh_544 && l_ilow_712 > l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 < l_ilow_656 && l_ilow_656 < l_ilow_648) ||
      (l_iclose_408 >= l_iclose_408 && l_iclose_400 < l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 < l_iopen_480 && l_iclose_368 > l_iopen_472 &&
      l_iclose_360 > l_iopen_464 && l_iclose_352 < l_iopen_456 && l_iclose_344 > l_iopen_448 && l_ihigh_616 > l_ihigh_608 && l_ihigh_608 >= l_ihigh_600 && l_ihigh_600 > l_ihigh_592 &&
      l_ihigh_592 > l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 < l_ihigh_552 && l_ilow_720 > l_ilow_712 &&
      l_ilow_712 > l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 < l_ilow_656) ||
      (l_iclose_400 > l_iopen_504 && l_iclose_392 >= l_iopen_496 && l_iclose_384 > l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 > l_iopen_472 && l_iclose_360 > l_iopen_464 &&
      l_iclose_352 < l_iopen_456 && l_iclose_344 < l_iopen_448 && l_iclose_336 > l_iopen_440 && l_ihigh_608 >= l_ihigh_600 && l_ihigh_600 < l_ihigh_592 && l_ihigh_592 > l_ihigh_584 &&
      l_ihigh_584 < l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ihigh_552 >= l_ihigh_544 && l_ilow_712 < l_ilow_704 &&
      l_ilow_704 <= l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 <= l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 > l_ilow_656 &&
      l_ilow_656 < l_ilow_648) || (l_iclose_408 > l_iopen_512 && l_iclose_400 >= l_iopen_504 && l_iclose_392 > l_iopen_496 && l_iclose_384 > l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 > l_iopen_472 && l_iclose_360 < l_iopen_464 && l_iclose_352 < l_iopen_456 && l_iclose_344 > l_iopen_448 && l_ihigh_616 >= l_ihigh_608 && l_ihigh_608 < l_ihigh_600 && l_ihigh_600 > l_ihigh_592 && l_ihigh_592 < l_ihigh_584 && l_ihigh_584 < l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 >= l_ihigh_552 && l_ilow_720 < l_ilow_712 && l_ilow_712 <= l_ilow_704 && l_ilow_704 < l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 <= l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 > l_ilow_664 && l_ilow_664 < l_ilow_656) ||
      (l_iclose_400 > l_iopen_504 && l_iclose_392 > l_iopen_496 && l_iclose_384 > l_iopen_488 && l_iclose_376 < l_iopen_480 && l_iclose_368 > l_iopen_472 && l_iclose_360 > l_iopen_464 &&
      l_iclose_352 < l_iopen_456 && l_iclose_344 > l_iopen_448 && l_iclose_336 > l_iopen_440 && l_ihigh_608 < l_ihigh_600 && l_ihigh_600 < l_ihigh_592 && l_ihigh_592 > l_ihigh_584 &&
      l_ihigh_584 > l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ihigh_552 < l_ihigh_544 && l_ilow_712 < l_ilow_704 &&
      l_ilow_704 < l_ilow_696 && l_ilow_696 <= l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 > l_ilow_656 && l_ilow_656 < l_ilow_648) ||
      (l_iclose_408 > l_iopen_512 && l_iclose_400 > l_iopen_504 && l_iclose_392 > l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 > l_iopen_472 &&
      l_iclose_360 < l_iopen_464 && l_iclose_352 > l_iopen_456 && l_iclose_344 > l_iopen_448 && l_ihigh_616 < l_ihigh_608 && l_ihigh_608 < l_ihigh_600 && l_ihigh_600 > l_ihigh_592 &&
      l_ihigh_592 > l_ihigh_584 && l_ihigh_584 < l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 < l_ihigh_552 && l_ilow_720 < l_ilow_712 &&
      l_ilow_712 < l_ilow_704 && l_ilow_704 <= l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 > l_ilow_664 && l_ilow_664 < l_ilow_656) ||
      (l_iclose_400 > l_iopen_504 && l_iclose_392 > l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 > l_iopen_472 && l_iclose_360 > l_iopen_464 &&
      l_iclose_352 < l_iopen_456 && l_iclose_344 > l_iopen_448 && l_iclose_336 > l_iopen_440 && l_ihigh_608 < l_ihigh_600 && l_ihigh_600 > l_ihigh_592 && l_ihigh_592 > l_ihigh_584 &&
      l_ihigh_584 < l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 < l_ihigh_552 && l_ihigh_552 > l_ihigh_544 && l_ilow_712 < l_ilow_704 &&
      l_ilow_704 > l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 < l_ilow_656 && l_ilow_656 < l_ilow_648) ||
      (l_iclose_408 > l_iopen_512 && l_iclose_400 > l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 > l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 > l_iopen_472 &&
      l_iclose_360 < l_iopen_464 && l_iclose_352 > l_iopen_456 && l_iclose_344 > l_iopen_448 && l_ihigh_616 < l_ihigh_608 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 > l_ihigh_592 &&
      l_ihigh_592 < l_ihigh_584 && l_ihigh_584 < l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ilow_720 < l_ilow_712 &&
      l_ilow_712 > l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 < l_ilow_656) ||
      (l_iclose_400 > l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 < l_iopen_472 && l_iclose_360 < l_iopen_464 &&
      l_iclose_352 > l_iopen_456 && l_iclose_344 > l_iopen_448 && l_iclose_336 < l_iopen_440 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 > l_ihigh_592 && l_ihigh_592 >= l_ihigh_584 &&
      l_ihigh_584 >= l_ihigh_576 && l_ihigh_576 >= l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ihigh_560 < l_ihigh_552 && l_ihigh_552 > l_ihigh_544 && l_ilow_712 < l_ilow_704 &&
      l_ilow_704 > l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 > l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 < l_ilow_656 && l_ilow_656 > l_ilow_648) ||
      (l_iclose_400 < l_iopen_504 && l_iclose_392 > l_iopen_496 && l_iclose_384 > l_iopen_488 && l_iclose_376 >= l_iopen_480 && l_iclose_368 > l_iopen_472 && l_iclose_360 > l_iopen_464 &&
      l_iclose_352 < l_iopen_456 && l_iclose_344 > l_iopen_448 && l_iclose_336 > l_iopen_440 && l_ihigh_608 < l_ihigh_600 && l_ihigh_600 < l_ihigh_592 && l_ihigh_592 < l_ihigh_584 &&
      l_ihigh_584 <= l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ihigh_552 < l_ihigh_544 && l_ilow_712 < l_ilow_704 &&
      l_ilow_704 < l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 > l_ilow_656 && l_ilow_656 < l_ilow_648))) li_280 = FALSE;
   if ((pricefilter && ld_296 < l_iclose_376 - 110.0 * gd_452) || (patternsfilter && (l_iclose_368 > l_iopen_472 && l_iclose_360 > l_iopen_464 && l_iclose_352 > l_iopen_456 &&
      l_iclose_344 < l_iopen_448 && l_iclose_336 > l_iopen_440 && l_iclose_368 - l_iopen_472 > l_iclose_360 - l_iopen_464 && l_iclose_360 - l_iopen_464 > l_iclose_352 - l_iopen_456 &&
      l_iclose_352 - l_iopen_456 > l_iopen_448 - l_iclose_344 && l_iopen_448 - l_iclose_344 < l_iclose_336 - l_iopen_440) || (l_iclose_376 > l_iopen_480 && l_iclose_368 > l_iopen_472 && l_iclose_360 > l_iopen_464 && l_iclose_352 < l_iopen_456 && l_iclose_344 > l_iopen_448 && l_iclose_336 > l_iopen_440 && l_iclose_376 - l_iopen_480 > l_iclose_368 - l_iopen_472 && l_iclose_368 - l_iopen_472 > l_iclose_360 - l_iopen_464 && l_iclose_360 - l_iopen_464 > l_iopen_456 - l_iclose_352 && l_iopen_456 - l_iclose_352 < l_iclose_344 - l_iopen_448 && l_iclose_344 - l_iopen_448 <= l_iclose_336 - l_iopen_440) ||
      (l_iclose_400 < l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 > l_iopen_488 && l_iclose_376 <= l_iopen_480 && l_iclose_368 < l_iopen_472 && l_iclose_360 < l_iopen_464 &&
      l_iclose_352 > l_iopen_456 && l_iclose_344 < l_iopen_448 && l_iclose_336 < l_iopen_440 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 < l_ihigh_592 && l_ihigh_592 > l_ihigh_584 &&
      l_ihigh_584 > l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 < l_ihigh_552 && l_ihigh_552 > l_ihigh_544 && l_ilow_712 > l_ilow_704 &&
      l_ilow_704 < l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 <= l_ilow_680 && l_ilow_680 > l_ilow_672 && l_ilow_672 > l_ilow_664 && l_ilow_664 < l_ilow_656 && l_ilow_656 > l_ilow_648) ||
      (l_iclose_408 < l_iopen_512 && l_iclose_400 < l_iopen_504 && l_iclose_392 > l_iopen_496 && l_iclose_384 <= l_iopen_488 && l_iclose_376 < l_iopen_480 && l_iclose_368 < l_iopen_472 &&
      l_iclose_360 > l_iopen_464 && l_iclose_352 < l_iopen_456 && l_iclose_344 < l_iopen_448 && l_ihigh_616 > l_ihigh_608 && l_ihigh_608 < l_ihigh_600 && l_ihigh_600 > l_ihigh_592 &&
      l_ihigh_592 > l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ilow_720 > l_ilow_712 &&
      l_ilow_712 < l_ilow_704 && l_ilow_704 < l_ilow_696 && l_ilow_696 <= l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 > l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 > l_ilow_656) ||
      (l_iclose_416 < l_iopen_520 && l_iclose_408 < l_iopen_512 && l_iclose_400 > l_iopen_504 && l_iclose_392 <= l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 < l_iopen_480 &&
      l_iclose_368 > l_iopen_472 && l_iclose_360 < l_iopen_464 && l_iclose_352 < l_iopen_456 && l_ihigh_624 > l_ihigh_616 && l_ihigh_616 < l_ihigh_608 && l_ihigh_608 > l_ihigh_600 &&
      l_ihigh_600 > l_ihigh_592 && l_ihigh_592 > l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ilow_728 > l_ilow_720 &&
      l_ilow_720 < l_ilow_712 && l_ilow_712 < l_ilow_704 && l_ilow_704 <= l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 > l_ilow_664) ||
      (l_iclose_424 < l_iopen_528 && l_iclose_416 < l_iopen_520 && l_iclose_408 > l_iopen_512 && l_iclose_400 <= l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 < l_iopen_488 &&
      l_iclose_376 > l_iopen_480 && l_iclose_368 < l_iopen_472 && l_iclose_360 < l_iopen_464 && l_ihigh_632 > l_ihigh_624 && l_ihigh_624 < l_ihigh_616 && l_ihigh_616 > l_ihigh_608 &&
      l_ihigh_608 > l_ihigh_600 && l_ihigh_600 > l_ihigh_592 && l_ihigh_592 > l_ihigh_584 && l_ihigh_584 < l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ilow_736 > l_ilow_728 &&
      l_ilow_728 < l_ilow_720 && l_ilow_720 < l_ilow_712 && l_ilow_712 <= l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 > l_ilow_672) ||
      (l_iclose_432 < l_iopen_536 && l_iclose_424 < l_iopen_528 && l_iclose_416 > l_iopen_520 && l_iclose_408 <= l_iopen_512 && l_iclose_400 < l_iopen_504 && l_iclose_392 < l_iopen_496 &&
      l_iclose_384 > l_iopen_488 && l_iclose_376 < l_iopen_480 && l_iclose_368 < l_iopen_472 && l_ihigh_640 > l_ihigh_632 && l_ihigh_632 < l_ihigh_624 && l_ihigh_624 > l_ihigh_616 &&
      l_ihigh_616 > l_ihigh_608 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 > l_ihigh_592 && l_ihigh_592 < l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ilow_744 > l_ilow_736 &&
      l_ilow_736 < l_ilow_728 && l_ilow_728 < l_ilow_720 && l_ilow_720 <= l_ilow_712 && l_ilow_712 > l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 > l_ilow_680) ||
      (l_iclose_400 > l_iopen_504 && l_iclose_392 > l_iopen_496 && l_iclose_384 <= l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 < l_iopen_472 && l_iclose_360 > l_iopen_464 &&
      l_iclose_352 >= l_iopen_456 && l_iclose_344 < l_iopen_448 && l_iclose_336 < l_iopen_440 && l_ihigh_608 >= l_ihigh_600 && l_ihigh_600 <= l_ihigh_592 && l_ihigh_592 < l_ihigh_584 &&
      l_ihigh_584 > l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ihigh_552 > l_ihigh_544 && l_ilow_712 <= l_ilow_704 &&
      l_ilow_704 > l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 <= l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 > l_ilow_656 && l_ilow_656 <= l_ilow_648) ||
      (l_iclose_400 >= l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 < l_iopen_480 && l_iclose_368 < l_iopen_472 && l_iclose_360 > l_iopen_464 &&
      l_iclose_352 > l_iopen_456 && l_iclose_344 < l_iopen_448 && l_iclose_336 > l_iopen_440 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 >= l_ihigh_592 && l_ihigh_592 > l_ihigh_584 &&
      l_ihigh_584 > l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ihigh_552 < l_ihigh_544 && l_ilow_712 > l_ilow_704 &&
      l_ilow_704 > l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 < l_ilow_656 && l_ilow_656 < l_ilow_648) ||
      (l_iclose_408 >= l_iopen_512 && l_iclose_400 < l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 < l_iopen_480 && l_iclose_368 > l_iopen_472 &&
      l_iclose_360 > l_iopen_464 && l_iclose_352 < l_iopen_456 && l_iclose_344 > l_iopen_448 && l_ihigh_616 > l_ihigh_608 && l_ihigh_608 >= l_ihigh_600 && l_ihigh_600 > l_ihigh_592 &&
      l_ihigh_592 > l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 < l_ihigh_552 && l_ilow_720 > l_ilow_712 &&
      l_ilow_712 > l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 < l_ilow_656) ||
      (l_iclose_400 < l_iopen_504 && l_iclose_392 > l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 < l_iopen_480 && l_iclose_368 > l_iopen_472 && l_iclose_360 < l_iopen_464 &&
      l_iclose_352 < l_iopen_456 && l_iclose_344 < l_iopen_448 && l_iclose_336 < l_iopen_440 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 < l_ihigh_592 && l_ihigh_592 > l_ihigh_584 &&
      l_ihigh_584 < l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ihigh_552 > l_ihigh_544 && l_ilow_712 < l_ilow_704 &&
      l_ilow_704 < l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 > l_ilow_664 && l_ilow_664 > l_ilow_656 && l_ilow_656 > l_ilow_648) ||
      (l_iclose_408 < l_iopen_512 && l_iclose_400 > l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 < l_iopen_472 &&
      l_iclose_360 < l_iopen_464 && l_iclose_352 < l_iopen_456 && l_iclose_344 < l_iopen_448 && l_ihigh_616 > l_ihigh_608 && l_ihigh_608 < l_ihigh_600 && l_ihigh_600 > l_ihigh_592 &&
      l_ihigh_592 < l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ilow_720 < l_ilow_712 &&
      l_ilow_712 < l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 > l_ilow_672 && l_ilow_672 > l_ilow_664 && l_ilow_664 > l_ilow_656) ||
      (l_iclose_400 > l_iopen_504 && l_iclose_392 < l_iopen_504 && l_iclose_384 < l_iopen_488 && l_iclose_376 < l_iopen_480 && l_iclose_368 < l_iopen_472 && l_iclose_360 > l_iopen_464 &&
      l_iclose_352 > l_iopen_456 && l_iclose_344 < l_iopen_448 && l_iclose_336 >= l_iopen_440 && l_ihigh_616 > l_ihigh_608 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 > l_ihigh_592 &&
      l_ihigh_592 > l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ihigh_560 < l_ihigh_552 && l_ihigh_552 < l_ihigh_544 &&
      l_ilow_712 < l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 >= l_ilow_672 && l_ilow_672 >= l_ilow_664 &&
      l_ilow_664 < l_ilow_656 && l_ilow_656 <= l_ilow_648) || (l_iclose_400 > l_iopen_504 && l_iclose_392 > l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 >= l_iopen_480 && l_iclose_368 > l_iopen_472 && l_iclose_360 < l_iopen_464 && l_iclose_352 > l_iopen_456 && l_iclose_344 < l_iopen_448 && l_iclose_336 > l_iopen_440 && l_ihigh_608 < l_ihigh_600 && l_ihigh_600 < l_ihigh_592 && l_ihigh_592 < l_ihigh_584 && l_ihigh_584 < l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 < l_ihigh_552 && l_ihigh_552 > l_ihigh_544 && l_ilow_712 <= l_ilow_704 && l_ilow_704 < l_ilow_696 && l_ilow_696 <= l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 > l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 > l_ilow_656 && l_ilow_656 > l_ilow_648) ||
      (l_iclose_408 > l_iopen_512 && l_iclose_400 > l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 >= l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 < l_iopen_472 &&
      l_iclose_360 > l_iopen_464 && l_iclose_352 < l_iopen_456 && l_iclose_344 > l_iopen_448 && l_ihigh_616 < l_ihigh_608 && l_ihigh_608 < l_ihigh_600 && l_ihigh_600 < l_ihigh_592 &&
      l_ihigh_592 < l_ihigh_584 && l_ihigh_584 < l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ilow_720 <= l_ilow_712 &&
      l_ilow_712 < l_ilow_704 && l_ilow_704 <= l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 > l_ilow_664 && l_ilow_664 > l_ilow_656) ||
      (l_iclose_416 > l_iopen_520 && l_iclose_408 > l_iopen_512 && l_iclose_400 < l_iopen_504 && l_iclose_392 >= l_iopen_496 && l_iclose_384 > l_iopen_488 && l_iclose_376 < l_iopen_480 &&
      l_iclose_368 > l_iopen_472 && l_iclose_360 < l_iopen_464 && l_iclose_352 > l_iopen_456 && l_ihigh_624 < l_ihigh_616 && l_ihigh_616 < l_ihigh_608 && l_ihigh_608 < l_ihigh_600 &&
      l_ihigh_600 < l_ihigh_592 && l_ihigh_592 < l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ilow_728 <= l_ilow_720 &&
      l_ilow_720 < l_ilow_712 && l_ilow_712 <= l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 > l_ilow_672 && l_ilow_672 > l_ilow_664) ||
      (l_iclose_424 > l_iopen_528 && l_iclose_416 > l_iopen_520 && l_iclose_408 < l_iopen_512 && l_iclose_400 >= l_iopen_504 && l_iclose_392 > l_iopen_496 && l_iclose_384 < l_iopen_488 &&
      l_iclose_376 > l_iopen_480 && l_iclose_368 < l_iopen_472 && l_iclose_360 > l_iopen_464 && l_ihigh_632 < l_ihigh_624 && l_ihigh_624 < l_ihigh_616 && l_ihigh_616 < l_ihigh_608 &&
      l_ihigh_608 < l_ihigh_600 && l_ihigh_600 < l_ihigh_592 && l_ihigh_592 > l_ihigh_584 && l_ihigh_584 < l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ilow_736 <= l_ilow_728 &&
      l_ilow_728 < l_ilow_720 && l_ilow_720 <= l_ilow_712 && l_ilow_712 > l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 > l_ilow_672) ||
      (l_iclose_400 < l_iopen_504 && l_iclose_392 > l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 >= l_iopen_480 && l_iclose_368 < l_iopen_472 && l_iclose_360 > l_iopen_464 &&
      l_iclose_352 < l_iopen_456 && l_iclose_344 < l_iopen_448 && l_iclose_336 > l_iopen_440 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 > l_ihigh_592 && l_ihigh_592 > l_ihigh_584 &&
      l_ihigh_584 < l_ihigh_576 && l_ihigh_576 <= l_ihigh_568 && l_ihigh_568 <= l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ihigh_552 > l_ihigh_544 && l_ilow_712 < l_ilow_704 &&
      l_ilow_704 < l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 > l_ilow_664 && l_ilow_664 > l_ilow_656 && l_ilow_656 < l_ilow_648) ||
      (l_iclose_400 < l_iopen_504 && l_iclose_392 >= l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 < l_iopen_472 && l_iclose_360 < l_iopen_464 &&
      l_iclose_352 > l_iopen_456 && l_iclose_344 > l_iopen_448 && l_iclose_336 > l_iopen_440 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 < l_ihigh_592 && l_ihigh_592 <= l_ihigh_584 &&
      l_ihigh_584 <= l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 < l_ihigh_552 && l_ihigh_552 < l_ihigh_544 && l_ilow_712 >= l_ilow_704 &&
      l_ilow_704 >= l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 > l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 < l_ilow_656 && l_ilow_656 < l_ilow_648) ||
      (l_iclose_408 < l_iopen_512 && l_iclose_400 >= l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 > l_iopen_488 && l_iclose_376 < l_iopen_480 && l_iclose_368 < l_iopen_472 &&
      l_iclose_360 > l_iopen_464 && l_iclose_352 > l_iopen_456 && l_iclose_344 > l_iopen_448 && l_ihigh_616 > l_ihigh_608 && l_ihigh_608 < l_ihigh_600 && l_ihigh_600 <= l_ihigh_592 &&
      l_ihigh_592 <= l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ihigh_560 < l_ihigh_552 && l_ilow_720 >= l_ilow_712 &&
      l_ilow_712 >= l_ilow_704 && l_ilow_704 < l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 < l_ilow_656) ||
      (l_iclose_400 > l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 > l_iopen_488 && l_iclose_376 < l_iopen_480 && l_iclose_368 >= l_iopen_472 && l_iclose_360 < l_iopen_464 &&
      l_iclose_352 < l_iopen_456 && l_iclose_344 < l_iopen_448 && l_iclose_336 > l_iopen_440 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 > l_ihigh_592 && l_ihigh_592 > l_ihigh_584 &&
      l_ihigh_584 > l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ihigh_552 > l_ihigh_544 && l_ilow_712 > l_ilow_704 &&
      l_ilow_704 <= l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 > l_ilow_672 && l_ilow_672 > l_ilow_664 && l_ilow_664 > l_ilow_656 && l_ilow_656 < l_ilow_648) ||
      (l_iclose_408 > l_iopen_512 && l_iclose_400 < l_iopen_504 && l_iclose_392 > l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 >= l_iopen_480 && l_iclose_368 < l_iopen_472 &&
      l_iclose_360 < l_iopen_464 && l_iclose_352 < l_iopen_456 && l_iclose_344 > l_iopen_448 && l_ihigh_616 > l_ihigh_608 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 > l_ihigh_592 &&
      l_ihigh_592 > l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ilow_720 > l_ilow_712 &&
      l_ilow_712 <= l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 > l_ilow_672 && l_ilow_672 > l_ilow_664 && l_ilow_664 < l_ilow_656) ||
      (l_iclose_416 > l_iopen_520 && l_iclose_408 < l_iopen_512 && l_iclose_400 > l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 >= l_iopen_488 && l_iclose_376 < l_iopen_480 &&
      l_iclose_368 < l_iopen_472 && l_iclose_360 < l_iopen_464 && l_iclose_352 > l_iopen_456 && l_ihigh_624 > l_ihigh_616 && l_ihigh_616 > l_ihigh_608 && l_ihigh_608 > l_ihigh_600 &&
      l_ihigh_600 > l_ihigh_592 && l_ihigh_592 > l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ilow_728 > l_ilow_720 &&
      l_ilow_720 <= l_ilow_712 && l_ilow_712 > l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 > l_ilow_672 && l_ilow_672 < l_ilow_664) ||
      (l_iclose_424 > l_iopen_528 && l_iclose_416 < l_iopen_520 && l_iclose_408 > l_iopen_512 && l_iclose_400 < l_iopen_504 && l_iclose_392 >= l_iopen_496 && l_iclose_384 < l_iopen_488 &&
      l_iclose_376 < l_iopen_480 && l_iclose_368 < l_iopen_472 && l_iclose_360 > l_iopen_464 && l_ihigh_632 > l_ihigh_624 && l_ihigh_624 > l_ihigh_616 && l_ihigh_616 > l_ihigh_608 &&
      l_ihigh_608 > l_ihigh_600 && l_ihigh_600 > l_ihigh_592 && l_ihigh_592 > l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ilow_736 > l_ilow_728 &&
      l_ilow_728 <= l_ilow_720 && l_ilow_720 > l_ilow_712 && l_ilow_712 > l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 < l_ilow_672) ||
      (l_iclose_400 > l_iopen_504 && l_iclose_392 > l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 > l_iopen_472 && l_iclose_360 <= l_iopen_464 &&
      l_iclose_352 < l_iopen_456 && l_iclose_344 < l_iopen_448 && l_iclose_336 > l_iopen_440 && l_ihigh_608 < l_ihigh_600 && l_ihigh_600 <= l_ihigh_592 && l_ihigh_584 < l_ihigh_576 &&
      l_ihigh_576 < l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ihigh_552 > l_ihigh_544 && l_ilow_712 < l_ilow_704 && l_ilow_704 > l_ilow_696 &&
      l_ilow_696 < l_ilow_688 && l_ilow_688 <= l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 > l_ilow_664 && l_ilow_664 > l_ilow_656 && l_ilow_656 < l_ilow_648) ||
      (l_iclose_400 > l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 > l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 > l_iopen_472 && l_iclose_360 < l_iopen_464 &&
      l_iclose_352 < l_iopen_456 && l_iclose_344 < l_iopen_448 && l_iclose_336 > l_iopen_440 && l_ihigh_608 < l_ihigh_600 && l_ihigh_600 > l_ihigh_592 && l_ihigh_592 < l_ihigh_584 &&
      l_ihigh_584 < l_ihigh_576 && l_ihigh_576 >= l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ihigh_552 > l_ihigh_544 && l_ilow_712 < l_ilow_704 &&
      l_ilow_704 > l_ilow_696 && l_ilow_696 <= l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 > l_ilow_672 && l_ilow_672 > l_ilow_664 && l_ilow_664 >= l_ilow_656 &&
      l_ilow_656 > l_ilow_648) || (l_iclose_408 > l_iopen_512 && l_iclose_400 < l_iopen_504 && l_iclose_392 > l_iopen_496 && l_iclose_384 > l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 < l_iopen_472 && l_iclose_360 < l_iopen_464 && l_iclose_352 < l_iopen_456 && l_iclose_344 > l_iopen_448 && l_ihigh_616 < l_ihigh_608 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 < l_ihigh_592 && l_ihigh_592 < l_ihigh_584 && l_ihigh_584 >= l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ilow_720 < l_ilow_712 && l_ilow_712 > l_ilow_704 && l_ilow_704 <= l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 > l_ilow_672 && l_ilow_672 >= l_ilow_664 && l_ilow_664 > l_ilow_656) ||
      (l_iclose_416 > l_iopen_520 && l_iclose_408 < l_iopen_512 && l_iclose_400 > l_iopen_504 && l_iclose_392 > l_iopen_496 && l_iclose_384 > l_iopen_488 && l_iclose_376 < l_iopen_480 &&
      l_iclose_368 < l_iopen_472 && l_iclose_360 < l_iopen_464 && l_iclose_352 > l_iopen_456 && l_ihigh_624 < l_ihigh_616 && l_ihigh_616 > l_ihigh_608 && l_ihigh_608 < l_ihigh_600 &&
      l_ihigh_600 < l_ihigh_592 && l_ihigh_592 >= l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ilow_728 < l_ilow_720 &&
      l_ilow_720 > l_ilow_712 && l_ilow_712 <= l_ilow_704 && l_ilow_704 < l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 >= l_ilow_672 &&
      l_ilow_672 > l_ilow_664) || (l_iclose_424 > l_iopen_528 && l_iclose_416 < l_iopen_520 && l_iclose_408 > l_iopen_512 && l_iclose_400 > l_iopen_504 && l_iclose_392 > l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 < l_iopen_480 && l_iclose_368 < l_iopen_472 && l_iclose_360 > l_iopen_464 && l_ihigh_632 < l_ihigh_624 && l_ihigh_624 > l_ihigh_616 && l_ihigh_616 < l_ihigh_608 && l_ihigh_608 < l_ihigh_600 && l_ihigh_600 >= l_ihigh_592 && l_ihigh_592 > l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ilow_736 < l_ilow_728 && l_ilow_728 > l_ilow_720 && l_ilow_720 <= l_ilow_712 && l_ilow_712 < l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 >= l_ilow_680 && l_ilow_680 > l_ilow_672) ||
      (l_iclose_400 > l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 >= l_iopen_488 && l_iclose_376 < l_iopen_480 && l_iclose_368 < l_iopen_472 && l_iclose_360 >= l_iopen_464 &&
      l_iclose_352 > l_iopen_456 && l_iclose_344 < l_iopen_448 && l_iclose_336 < l_iopen_440 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 >= l_ihigh_592 && l_ihigh_592 >= l_ihigh_584 &&
      l_ihigh_584 > l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ihigh_552 > l_ihigh_544 && l_ilow_712 > l_ilow_704 &&
      l_ilow_704 < l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 > l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 < l_ilow_656 && l_ilow_656 > l_ilow_648) ||
      (l_iclose_408 > l_iopen_512 && l_iclose_400 < l_iopen_504 && l_iclose_392 >= l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 < l_iopen_480 && l_iclose_368 >= l_iopen_472 &&
      l_iclose_360 > l_iopen_464 && l_iclose_352 < l_iopen_456 && l_iclose_344 < l_iopen_448 && l_ihigh_616 > l_ihigh_608 && l_ihigh_608 >= l_ihigh_600 && l_ihigh_600 >= l_ihigh_592 &&
      l_ihigh_592 > l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ilow_720 > l_ilow_712 &&
      l_ilow_712 < l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 > l_ilow_656) ||
      (l_iclose_400 < l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 < l_iopen_472 && l_iclose_360 < l_iopen_464 &&
      l_iclose_352 > l_iopen_456 && l_iclose_344 > l_iopen_448 && l_iclose_336 < l_iopen_440 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 > l_ihigh_592 && l_ihigh_592 >= l_ihigh_584 &&
      l_ihigh_584 < l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 >= l_ihigh_552 && l_ihigh_552 > l_ihigh_544 && l_ilow_712 > l_ilow_704 &&
      l_ilow_704 > l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 > l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 > l_ilow_656 && l_ilow_656 > l_ilow_648) ||
      (l_iclose_400 < l_iopen_504 && l_iclose_392 > l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 > l_iopen_480 && l_iclose_368 < l_iopen_472 && l_iclose_360 < l_iopen_464 &&
      l_iclose_352 > l_iopen_456 && l_iclose_344 > l_iopen_448 && l_iclose_336 < l_iopen_440 && l_ihigh_608 < l_ihigh_600 && l_ihigh_600 > l_ihigh_592 && l_ihigh_592 > l_ihigh_584 &&
      l_ihigh_584 < l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ihigh_560 < l_ihigh_552 && l_ihigh_552 > l_ihigh_544 && l_ilow_712 < l_ilow_704 &&
      l_ilow_704 > l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 > l_ilow_672 && l_ilow_672 > l_ilow_664 && l_ilow_664 < l_ilow_656 && l_ilow_656 > l_ilow_648) ||
      (l_iclose_400 > l_iopen_504 && l_iclose_392 > l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 < l_iopen_480 && l_iclose_368 < l_iopen_472 && l_iclose_360 > l_iopen_464 &&
      l_iclose_352 > l_iopen_456 && l_iclose_344 > l_iopen_448 && l_iclose_336 <= l_iopen_440 && l_ihigh_608 < l_ihigh_600 && l_ihigh_600 < l_ihigh_592 && l_ihigh_592 < l_ihigh_584 &&
      l_ihigh_584 > l_ihigh_576 && l_ihigh_576 >= l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ihigh_560 < l_ihigh_552 && l_ihigh_552 > l_ihigh_544 && l_ilow_712 < l_ilow_704 &&
      l_ilow_704 < l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 > l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 < l_ilow_656 && l_ilow_656 > l_ilow_648) ||
      (l_iclose_400 > l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 < l_iopen_488 && l_iclose_376 < l_iopen_480 && l_iclose_368 < l_iopen_472 && l_iclose_360 > l_iopen_464 &&
      l_iclose_352 > l_iopen_456 && l_iclose_344 < l_iopen_448 && l_iclose_336 >= l_iopen_440 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 > l_ihigh_592 && l_ihigh_592 > l_ihigh_584 &&
      l_ihigh_584 > l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ihigh_560 < l_ihigh_552 && l_ihigh_552 < l_ihigh_544 && l_ilow_712 < l_ilow_704 &&
      l_ilow_704 > l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 >= l_ilow_672 && l_ilow_672 >= l_ilow_664 && l_ilow_664 < l_ilow_656 &&
      l_ilow_656 <= l_ilow_648) || (l_iclose_400 < l_iopen_504 && l_iclose_392 < l_iopen_496 && l_iclose_384 <= l_iopen_488 && l_iclose_376 <= l_iopen_480 && l_iclose_368 >= l_iopen_472 && l_iclose_360 > l_iopen_464 && l_iclose_352 > l_iopen_456 && l_iclose_344 < l_iopen_448 && l_iclose_336 > l_iopen_440 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 > l_ihigh_592 && l_ihigh_592 < l_ihigh_584 && l_ihigh_584 > l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ihigh_560 > l_ihigh_552 && l_ihigh_552 < l_ihigh_544 && l_ilow_712 > l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 > l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 < l_ilow_664 && l_ilow_664 > l_ilow_656 && l_ilow_656 < l_ilow_648) ||
      (l_iclose_408 < l_iopen_512 && l_iclose_400 < l_iopen_504 && l_iclose_392 <= l_iopen_496 && l_iclose_384 <= l_iopen_488 && l_iclose_376 >= l_iopen_480 && l_iclose_368 > l_iopen_472 &&
      l_iclose_360 > l_iopen_464 && l_iclose_352 < l_iopen_456 && l_iclose_344 > l_iopen_448 && l_ihigh_616 > l_ihigh_608 && l_ihigh_608 > l_ihigh_600 && l_ihigh_600 < l_ihigh_592 &&
      l_ihigh_592 > l_ihigh_584 && l_ihigh_584 < l_ihigh_576 && l_ihigh_576 < l_ihigh_568 && l_ihigh_568 > l_ihigh_560 && l_ihigh_560 < l_ihigh_552 && l_ilow_720 > l_ilow_712 &&
      l_ilow_712 > l_ilow_704 && l_ilow_704 < l_ilow_696 && l_ilow_696 > l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 < l_ilow_672 && l_ilow_672 > l_ilow_664 && l_ilow_664 < l_ilow_656) ||
      (l_iclose_416 < l_iopen_520 && l_iclose_408 < l_iopen_512 && l_iclose_400 <= l_iopen_504 && l_iclose_392 <= l_iopen_496 && l_iclose_384 >= l_iopen_488 && l_iclose_376 > l_iopen_480 &&
      l_iclose_368 > l_iopen_472 && l_iclose_360 < l_iopen_464 && l_iclose_352 > l_iopen_456 && l_ihigh_624 > l_ihigh_616 && l_ihigh_616 > l_ihigh_608 && l_ihigh_608 < l_ihigh_600 &&
      l_ihigh_600 > l_ihigh_592 && l_ihigh_592 < l_ihigh_584 && l_ihigh_584 < l_ihigh_576 && l_ihigh_576 > l_ihigh_568 && l_ihigh_568 < l_ihigh_560 && l_ilow_728 > l_ilow_720 &&
      l_ilow_720 > l_ilow_712 && l_ilow_712 < l_ilow_704 && l_ilow_704 > l_ilow_696 && l_ilow_696 < l_ilow_688 && l_ilow_688 < l_ilow_680 && l_ilow_680 > l_ilow_672 && l_ilow_672 < l_ilow_664))) li_284 = FALSE;
   if (lotsoptimized) lots = NormalizeDouble(AccountBalance() / 1000.0 * minlot * risk, lotdigits);
   if (lots < minlot) lots = minlot;
   if (lots > maxlot) lots = maxlot;
   if (tradesperbar == 1 && TimeCurrent() - g_datetime_404 < Period() || TimeCurrent() - g_datetime_408 < Period()) g_count_524 = 1;
   bool li_752 = FALSE;
   bool li_756 = FALSE;
   if (timeframe1 == FALSE || (timeframe1 && l_ihigh_40 > l_ihigh_24) && timeframe5 == FALSE || (timeframe5 && l_ihigh_72 > l_ihigh_56) && timeframe15 == FALSE || (timeframe15 &&
      l_ihigh_104 > l_ihigh_88) && timeframe30 == FALSE || (timeframe30 && l_ihigh_136 > l_ihigh_120) && timeframe60 == FALSE || (timeframe60 && l_ihigh_168 > l_ihigh_152) &&
      timeframe240 == FALSE || (timeframe240 && l_ihigh_200 > l_ihigh_184) && timeframe1440 == FALSE || (timeframe1440 && l_ihigh_232 > l_ihigh_216) && timeframe10080 == FALSE ||
      (timeframe10080 && l_ihigh_264 > l_ihigh_248) && li_280) {
      if (reversesignals) li_756 = TRUE;
      else li_752 = TRUE;
   }
   if (timeframe1 == FALSE || (timeframe1 && l_ilow_48 < l_ilow_32) && timeframe5 == FALSE || (timeframe5 && l_ilow_80 < l_ilow_64) && timeframe15 == FALSE || (timeframe15 &&
      l_ilow_112 < l_ilow_96) && timeframe30 == FALSE || (timeframe30 && l_ilow_144 < l_ilow_128) && timeframe60 == FALSE || (timeframe60 && l_ilow_176 < l_ilow_160) && timeframe240 == FALSE ||
      (timeframe240 && l_ilow_208 < l_ilow_192) && timeframe1440 == FALSE || (timeframe1440 && l_ilow_240 < l_ilow_224) && timeframe10080 == FALSE || (timeframe10080 && l_ilow_272 < l_ilow_256) && li_284) {
      if (reversesignals) li_752 = TRUE;
      else li_756 = TRUE;
   }
   if (g_bars_520 != Bars) {
      g_count_524 = 0;
      g_bars_520 = Bars;
   }
   if ((oppositeclose && li_756) || li_288) {
      for (g_pos_500 = g_ord_total_528 - 1; g_pos_500 >= 0; g_pos_500--) {
         OrderSelect(g_pos_500, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slippage * gd_452);
      }
   }
   if ((oppositeclose && li_752) || li_292) {
      for (g_pos_504 = g_ord_total_528 - 1; g_pos_504 >= 0; g_pos_504--) {
         OrderSelect(g_pos_504, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slippage * gd_452);
      }
   }
   if (hidestop) {
      for (g_pos_508 = g_ord_total_528 - 1; g_pos_508 >= 0; g_pos_508--) {
         OrderSelect(g_pos_508, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_BUY && buystop > 0 && Bid < OrderOpenPrice() - buystop * gd_452) OrderClose(OrderTicket(), OrderLots(), Bid, slippage * gd_452);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_SELL && sellstop > 0 && Ask > OrderOpenPrice() + sellstop * gd_452) OrderClose(OrderTicket(), OrderLots(), Ask, slippage * gd_452);
      }
   }
   if (hidetarget) {
      for (g_pos_512 = g_ord_total_528 - 1; g_pos_512 >= 0; g_pos_512--) {
         OrderSelect(g_pos_512, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_BUY && buytarget > 0 && Bid > OrderOpenPrice() + buytarget * gd_452) OrderClose(OrderTicket(), OrderLots(), Bid, slippage * gd_452);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_SELL && selltarget > 0 && Ask < OrderOpenPrice() - selltarget * gd_452) OrderClose(OrderTicket(), OrderLots(), Ask, slippage * gd_452);
      }
   }
   if ((tradesunday == FALSE && DayOfWeek() == 0) || (mondayfilter && DayOfWeek() == 1 && (!(Hour() >= mondaystart + gmtshift))) || (fridayfilter && DayOfWeek() == 5 &&
      (!(Hour() < fridayend + gmtshift)))) return (0);
   if (count(OP_BUY, magic) + count(OP_SELL, magic) < maxtrades) {
      if (li_752 && g_count_524 < tradesperbar && IsTradeAllowed()) {
         while (IsTradeContextBusy()) Sleep(3000);
         if (hidestop == FALSE && buystop > 0) g_price_436 = Ask - buystop * gd_452;
         else g_price_436 = 0;
         if (hidetarget == FALSE && buytarget > 0) g_price_444 = Ask + buytarget * gd_452;
         else g_price_444 = 0;
         RefreshRates();
         g_ticket_532 = OrderSend(Symbol(), OP_BUY, lots, Ask, slippage * gd_460, g_price_436, g_price_444, comment + ". Magic: " + DoubleToStr(magic, 0), magic, 0, Blue);
         if (g_ticket_532 <= 0) Print("Error Occured : " + errordescription(GetLastError()));
         else {
            g_count_524++;
            Print("Order opened : " + Symbol() + " Buy @ " + Ask + " SL @ " + g_price_436 + " TP @" + g_price_444 + " ticket =" + g_ticket_532);
         }
      }
      if (li_756 && g_count_524 < tradesperbar && IsTradeAllowed()) {
         while (IsTradeContextBusy()) Sleep(3000);
         if (hidestop == FALSE && sellstop > 0) g_price_436 = Bid + sellstop * gd_452;
         else g_price_436 = 0;
         if (hidetarget == FALSE && selltarget > 0) g_price_444 = Bid - selltarget * gd_452;
         else g_price_444 = 0;
         RefreshRates();
         g_ticket_532 = OrderSend(Symbol(), OP_SELL, lots, Bid, slippage * gd_460, g_price_436, g_price_444, comment + ". Magic: " + DoubleToStr(magic, 0), magic, 0, Red);
         if (g_ticket_532 <= 0) Print("Error Occured : " + errordescription(GetLastError()));
         else {
            g_count_524++;
            Print("Order opened : " + Symbol() + " Sell @ " + Ask + " SL @ " + g_price_436 + " TP @" + g_price_444 + " ticket =" + g_ticket_532);
         }
      }
   }
   return (0);
}

int count(int a_cmd_0, int a_magic_4) {
   int l_count_8 = 0;
   for (int l_pos_12 = 0; l_pos_12 < OrdersTotal(); l_pos_12++) {
      OrderSelect(l_pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderType() == a_cmd_0 && OrderMagicNumber() == a_magic_4 || a_magic_4 == 0) l_count_8++;
   }
   return (l_count_8);
}

string errordescription(int ai_0) {
   string ls_ret_4;
   switch (ai_0) {
   case 0:
   case 1:
      ls_ret_4 = "no error";
      break;
   case 2:
      ls_ret_4 = "common error";
      break;
   case 3:
      ls_ret_4 = "invalid trade parameters";
      break;
   case 4:
      ls_ret_4 = "trade server is busy";
      break;
   case 5:
      ls_ret_4 = "old version of the client terminal";
      break;
   case 6:
      ls_ret_4 = "no connection with trade server";
      break;
   case 7:
      ls_ret_4 = "not enough rights";
      break;
   case 8:
      ls_ret_4 = "too frequent requests";
      break;
   case 9:
      ls_ret_4 = "malfunctional trade operation";
      break;
   case 64:
      ls_ret_4 = "account disabled";
      break;
   case 65:
      ls_ret_4 = "invalid account";
      break;
   case 128:
      ls_ret_4 = "trade timeout";
      break;
   case 129:
      ls_ret_4 = "invalid price";
      break;
   case 130:
      ls_ret_4 = "invalid stops";
      break;
   case 131:
      ls_ret_4 = "invalid trade volume";
      break;
   case 132:
      ls_ret_4 = "market is closed";
      break;
   case 133:
      ls_ret_4 = "trade is disabled";
      break;
   case 134:
      ls_ret_4 = "not enough money";
      break;
   case 135:
      ls_ret_4 = "price changed";
      break;
   case 136:
      ls_ret_4 = "off quotes";
      break;
   case 137:
      ls_ret_4 = "broker is busy";
      break;
   case 138:
      ls_ret_4 = "requote";
      break;
   case 139:
      ls_ret_4 = "order is locked";
      break;
   case 140:
      ls_ret_4 = "long positions only allowed";
      break;
   case 141:
      ls_ret_4 = "too many requests";
      break;
   case 145:
      ls_ret_4 = "modification denied because order too close to market";
      break;
   case 146:
      ls_ret_4 = "trade context is busy";
      break;
   case 4000:
      ls_ret_4 = "no error";
      break;
   case 4001:
      ls_ret_4 = "wrong function pointer";
      break;
   case 4002:
      ls_ret_4 = "array index is out of range";
      break;
   case 4003:
      ls_ret_4 = "no memory for function call stack";
      break;
   case 4004:
      ls_ret_4 = "recursive stack overflow";
      break;
   case 4005:
      ls_ret_4 = "not enough stack for parameter";
      break;
   case 4006:
      ls_ret_4 = "no memory for parameter string";
      break;
   case 4007:
      ls_ret_4 = "no memory for temp string";
      break;
   case 4008:
      ls_ret_4 = "not initialized string";
      break;
   case 4009:
      ls_ret_4 = "not initialized string in array";
      break;
   case 4010:
      ls_ret_4 = "no memory for array\' string";
      break;
   case 4011:
      ls_ret_4 = "too long string";
      break;
   case 4012:
      ls_ret_4 = "remainder from zero divide";
      break;
   case 4013:
      ls_ret_4 = "zero divide";
      break;
   case 4014:
      ls_ret_4 = "unknown command";
      break;
   case 4015:
      ls_ret_4 = "wrong jump (never generated error)";
      break;
   case 4016:
      ls_ret_4 = "not initialized array";
      break;
   case 4017:
      ls_ret_4 = "dll calls are not allowed";
      break;
   case 4018:
      ls_ret_4 = "cannot load library";
      break;
   case 4019:
      ls_ret_4 = "cannot call function";
      break;
   case 4020:
      ls_ret_4 = "expert function calls are not allowed";
      break;
   case 4021:
      ls_ret_4 = "not enough memory for temp string returned from function";
      break;
   case 4022:
      ls_ret_4 = "system is busy (never generated error)";
      break;
   case 4050:
      ls_ret_4 = "invalid function parameters count";
      break;
   case 4051:
      ls_ret_4 = "invalid function parameter value";
      break;
   case 4052:
      ls_ret_4 = "string function internal error";
      break;
   case 4053:
      ls_ret_4 = "some array error";
      break;
   case 4054:
      ls_ret_4 = "incorrect series array using";
      break;
   case 4055:
      ls_ret_4 = "custom indicator error";
      break;
   case 4056:
      ls_ret_4 = "arrays are incompatible";
      break;
   case 4057:
      ls_ret_4 = "global variables processing error";
      break;
   case 4058:
      ls_ret_4 = "global variable not found";
      break;
   case 4059:
      ls_ret_4 = "function is not allowed in testing mode";
      break;
   case 4060:
      ls_ret_4 = "function is not confirmed";
      break;
   case 4061:
      ls_ret_4 = "send mail error";
      break;
   case 4062:
      ls_ret_4 = "string parameter expected";
      break;
   case 4063:
      ls_ret_4 = "integer parameter expected";
      break;
   case 4064:
      ls_ret_4 = "double parameter expected";
      break;
   case 4065:
      ls_ret_4 = "array as parameter expected";
      break;
   case 4066:
      ls_ret_4 = "requested history data in update state";
      break;
   case 4099:
      ls_ret_4 = "end of file";
      break;
   case 4100:
      ls_ret_4 = "some file error";
      break;
   case 4101:
      ls_ret_4 = "wrong file name";
      break;
   case 4102:
      ls_ret_4 = "too many opened files";
      break;
   case 4103:
      ls_ret_4 = "cannot open file";
      break;
   case 4104:
      ls_ret_4 = "incompatible access to a file";
      break;
   case 4105:
      ls_ret_4 = "no order selected";
      break;
   case 4106:
      ls_ret_4 = "unknown symbol";
      break;
   case 4107:
      ls_ret_4 = "invalid price parameter for trade function";
      break;
   case 4108:
      ls_ret_4 = "invalid ticket";
      break;
   case 4109:
      ls_ret_4 = "trade is not allowed";
      break;
   case 4110:
      ls_ret_4 = "longs are not allowed";
      break;
   case 4111:
      ls_ret_4 = "shorts are not allowed";
      break;
   case 4200:
      ls_ret_4 = "object is already exist";
      break;
   case 4201:
      ls_ret_4 = "unknown object property";
      break;
   case 4202:
      ls_ret_4 = "object is not exist";
      break;
   case 4203:
      ls_ret_4 = "unknown object type";
      break;
   case 4204:
      ls_ret_4 = "no object name";
      break;
   case 4205:
      ls_ret_4 = "object coordinates error";
      break;
   case 4206:
      ls_ret_4 = "no specified subwindow";
      break;
   default:
      ls_ret_4 = "unknown error";
   }
   return (ls_ret_4);
}