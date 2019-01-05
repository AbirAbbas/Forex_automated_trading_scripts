#property strict

string botName = "Ichimoku scalper";

int Magic = 1234;
int maxTrades = 1;
int MaxCloseSpreadPips = 8;
double lotSize = 0.10;

int stopLoss = -50;
int takeProfit = 30;
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
   //data 
   double tenkan_sen = iIchimoku(Symbol(),0,9,26,52,MODE_TENKANSEN,0);
   double kijun_sen = iIchimoku(Symbol(),0,9,26,52,MODE_KIJUNSEN,0);
   
   double tenkan_sen1 = iIchimoku(Symbol(),0,9,26,52,MODE_TENKANSEN,1);
   double kijun_sen1 = iIchimoku(Symbol(),0,9,26,52,MODE_KIJUNSEN,1);
   
   double tenkan_sen2 = iIchimoku(Symbol(),0,9,26,52,MODE_TENKANSEN,2);
   double kijun_sen2 = iIchimoku(Symbol(),0,9,26,52,MODE_KIJUNSEN,2);   
   
   double span_a = iIchimoku(Symbol(),0,9,26,52,MODE_SENKOUSPANA,0);
   double span_b = iIchimoku(Symbol(),0,9,26,52,MODE_SENKOUSPANB,0);
   
   double span_a1 = iIchimoku(Symbol(),0,9,26,52,MODE_SENKOUSPANA,3);
   double span_b1 = iIchimoku(Symbol(),0,9,26,52,MODE_SENKOUSPANB,3);
   
   double current_low = iLow(Symbol(), 0, 0);
   double current_high = iHigh(Symbol(), 0, 0);
   double last_low = iLow(Symbol(),0,1);
   double last_high = iHigh(Symbol(),0,1);
   double last_close = iClose(Symbol(), 0, 1);
      
   if ( getTotalOpenTrades() < maxTrades) {
      goLong = false;
      goShort = false;
          
      if (tenkan_sen > kijun_sen && tenkan_sen1 > kijun_sen1 && tenkan_sen2 > kijun_sen2) {
         int orderResult = OrderSend(Symbol(), OP_BUY, lotSize, Ask, 10, 0, 0, "BUY Order", Magic, 0, clrRed); 
         goLong = true;
      }
      
      if (tenkan_sen < kijun_sen && tenkan_sen1 < kijun_sen1 && tenkan_sen2 < kijun_sen2) {
         int orderResult = OrderSend(Symbol(), OP_SELL, lotSize, Bid, 10, 0, 0, "SELL Order", Magic, 0, clrGreen); 
         goShort = true;
      }
   } 
   
   if (goLong && tenkan_sen < kijun_sen && tenkan_sen1 < kijun_sen1 && tenkan_sen2 < kijun_sen2) {
      closeAllTrades();
   }
   else if (goShort && tenkan_sen > kijun_sen && tenkan_sen1 > kijun_sen1 && tenkan_sen2 > kijun_sen2) {
      closeAllTrades();
   }
   
   

}

// Helper functions

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

