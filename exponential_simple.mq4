#property strict

string botName = "Ichimoku scalper";

int Magic = 1234;
int maxTrades = 1;
int MaxCloseSpreadPips = 8;
double lotSize = 0.10;

int stopLoss = -10;
int takeProfit = 5;
int absolute_takeprofit = 50;
int absolute_stoploss = -50;

bool shift = false;

bool goLong = false;
bool goShort = false;

//Initialize the bot
int OnInit(){ 
ChartOpen("EURUSD", PERIOD_H4);

return(INIT_SUCCEEDED); 

}


//When bot is stopped
void OnDeinit(const int reason){  }

//tick loop
void OnTick()
{   
   //tenkan_sen determines buy or se
   double tenkan_sen = iIchimoku(Symbol(),0,9,26,52,MODE_TENKANSEN,0);
   double kijun_sen = iIchimoku(Symbol(),0,9,26,52,MODE_KIJUNSEN,0);
   
   double span_a = iIchimoku(Symbol(),0,9,26,52,MODE_SENKOUSPANA,0);
   double span_b = iIchimoku(Symbol(),0,9,26,52,MODE_SENKOUSPANB,0);

   //for current bar
   double current_low = iLow(Symbol(), 0, 0);
   double current_high = iHigh(Symbol(), 0, 0);
   
   //for last bar
   double last_low = iLow(Symbol(),0,3);
   double last_high = iHigh(Symbol(),0,3);
   double last_close = iClose(Symbol(), 0, 3);
      
   if ( getTotalOpenTrades() < maxTrades) {
      
      goLong = false;
      goShort = false;
      
      if (span_a > span_b) {
         if ((last_close < span_a && current_low > span_a) && tenkan_sen > kijun_sen && Ask > span_a && checkLastTen(true, false)) {
            //buy signal
            int orderResult = OrderSend(Symbol(), OP_BUY, lotSize, Ask, 10, 0, 0, "BUY Order", Magic, 0, clrRed); 
            goLong = true;
            
         }
         if ((last_close > span_b && current_high < span_b) && tenkan_sen < kijun_sen && Bid < span_b && checkLastTen(false, true)) {
            //sell signal
            int orderResult = OrderSend(Symbol(), OP_SELL, lotSize, Bid, 10, 0, 0, "SELL Order", Magic, 0, clrGreen); 
            goShort = true;
         
         }
      }
      
      if (span_a < span_b) {
         if ((last_close < span_b && current_low > span_b) && tenkan_sen > kijun_sen && Ask > span_b && checkLastTen(true, false)) {
            //buy signal
            int orderResult = OrderSend(Symbol(), OP_BUY, lotSize, Ask, 10, 0, 0, "BUY Order", Magic, 0, clrRed); 
            goLong = true;
              
         }
         if ((last_close > span_a && current_high < span_a) && tenkan_sen < kijun_sen && Bid < span_a && checkLastTen(false, true)) {
            //sell signal
            int orderResult = OrderSend(Symbol(), OP_SELL, lotSize, Bid, 10, 0, 0, "SELL Order", Magic, 0, clrGreen); 
            goShort = true;
            
         }
      }
      
      /*
      
      if (span_a > span_b && tenkan_sen > kijun_sen && Ask > span_a) {
      //sell signal
         int orderResult = OrderSend(Symbol(), OP_BUY, lotSize, Ask, 10, 0, 0, "BUY Order", Magic, 0, clrRed); 
         goLong = true;
      }
      
      if (span_a < span_b && tenkan_sen < kijun_sen && Bid < span_a) {
      //buy
         int orderResult = OrderSend(Symbol(), OP_SELL, lotSize, Ask, 10, 0, 0, "SELL Order", Magic, 0, clrGreen); 
         goShort = true; 
      }
      */
   }
   
   if (getTotalProfits() < absolute_stoploss || getTotalProfits() > absolute_takeprofit) {
      closeAllTrades();
   }
   
   if (goLong == true ) {
      if (getTotalProfits() > takeProfit && tenkan_sen < kijun_sen) {
         closeAllTrades();
      }
      
      if (getTotalProfits() < stopLoss) {
         if (tenkan_sen < kijun_sen) {
            closeAllTrades();
         }
         else if (span_a > span_b) {
            if (Bid < span_a) {
               closeAllTrades();
            }
         }
         else if (span_a < span_b) {
            if (Bid < span_b) {
               closeAllTrades();
            }
         }
      }
   }
   
   if (goShort == true) {
      if (getTotalProfits() > takeProfit && tenkan_sen > kijun_sen) {
         closeAllTrades();
      }
      
      if (getTotalProfits() < stopLoss) {
         if (tenkan_sen > kijun_sen) {
            closeAllTrades();
         }
         else if (span_a > span_b) {
            if (Ask > span_b) {
               closeAllTrades();
            }
         }
         else if (span_a < span_b) {
            if (Ask > span_a) {
               closeAllTrades();
            }
         }
      }
   }     
}

// Helper functions 

bool checkLastTen(bool isLong, bool isShort) {
   for (int i = 0; i < 10; i ++) {
      double span_a = iIchimoku(Symbol(),0,9,26,52,MODE_SENKOUSPANA,i);
      double span_b = iIchimoku(Symbol(),0,9,26,52,MODE_SENKOUSPANB,i);
      
      if (span_a > span_b) {
         if (isLong == true) {
            if (Ask < span_a) {
               return false;
            } 
         }
         else if (isShort == true) {
            if (Bid > span_a) {
               return false;
            }
         }
      }
      if (span_a < span_b) {
         if (isLong == true) {
            if (Ask < span_b) { 
               return false;
            }
         }
         else if (isShort == true) {
            if (Bid > span_a) {
               return false;
            }
         }
      }
   }
   
   return true;
}

int getTotalOpenTrades() {
   int totalTrades = 0;
   
   for(int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         
         if (OrderSymbol() != Symbol()) continue;
         if (OrderMagicNumber() != Magic) continue;
         if (OrderCloseTime() != 0) continue;
         
         totalTrades++;  
      }
   }
   
   return totalTrades;
}

void closeAllTrades () {
   int closeResult = 0;
   
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() != Magic) continue;
         if (OrderSymbol() != Symbol()) continue; 
         if (OrderType() == OP_BUY) closeResult = OrderClose(OrderTicket(), OrderLots(), Bid, MaxCloseSpreadPips, clrRed); 
         if (OrderType() == OP_SELL) closeResult = OrderClose(OrderTicket(), OrderLots(), Ask, MaxCloseSpreadPips, clrGreen); 
         i--;   
      }
   }
}

double getTotalProfits() {
   double totalProfits = 0;
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() != Magic) continue;
         if (OrderSymbol() != Symbol()) continue; 
         if (OrderCloseTime() != 0) continue;
         
         totalProfits += OrderProfit();  
      }
   }
   
   return totalProfits;
}

