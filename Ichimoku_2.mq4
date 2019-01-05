#property strict

string botName = "Ichimoku scalper";

int Magic = 1234;
int maxTrades = 1;
int slowTerm = 20;
int fastTerm = 10;
int MaxCloseSpreadPips = 8;

double lotSize = 0.10;

double stopLoss = -25;
double takeProfit = 5;

bool goLong = false;
bool goShort = false;

int longCounter = 0;
int shortCounter = 0;


//Initialize the bot
int OnInit(){ return(INIT_SUCCEEDED); }

//When bot is stopped
void OnDeinit(const int reason){  }

//tick loop
void OnTick()
{   

   double tenkan_sen = iIchimoku(NULL,0,9,26,52,MODE_TENKANSEN,0);
   double kijun_sen = iIchimoku(NULL,0,9,26,52,MODE_KIJUNSEN,0);
   
   double span_a = iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,0);
   double span_b = iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,0);
     
   if ( getTotalOpenTrades() < maxTrades) {
   
      goLong = false;
      goShort = false;
           
      double span_a_1 = iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,1);
      double span_b_1 = iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,1);
      
      double span_a_2 = iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,2);
      double span_b_2 = iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,2);
      
      double span_a_3 = iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,3);
      double span_b_3 = iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,3);
      
      double closing_price_1 = iClose(Symbol(), 0, 1);
      double closing_price_2 = iClose(Symbol(), 0, 2);
      double closing_price_3 = iClose(Symbol(), 0, 3);
            
      
      if (span_a > span_b) {
         if (Ask > span_a * 1.005) {
            if (span_a_1 < span_b_1 && span_a_2 < span_b_2 && span_a_3 < span_b_3) {
               
               int orderResult = OrderSend(Symbol(), OP_BUY, lotSize, Ask, 10, 0, 0, "Buy Order", Magic, 0, clrGreen); 
               goLong = true; 
            } 
         }
         if (Bid < span_b * 0.995) {
            if (span_a_1 > span_b_1 && span_a_2 > span_b_2 && span_a_3 < span_b_3) {
               int orderResult = OrderSend(Symbol(), OP_SELL, lotSize, Ask, 10, 0, 0, "Sell Order", Magic, 0, clrRed); 
               goShort = true;
            }
         }
      }
      
      if (span_b > span_a) {
         if (Ask > span_b * 1.005) {
            if (span_a_1 < span_b_1 && span_a_2 < span_b_2 && span_a_3 < span_b_3) {
               int orderResult = OrderSend(Symbol(), OP_BUY, lotSize, Ask, 10, 0, 0, "Buy Order", Magic, 0, clrGreen); 
               goLong = true; 
            } 
         }
         if (Bid < span_a * 0.995) {
            if (span_a_1 > span_b_1 && span_a_2 > span_b_2 && span_a_3 < span_b_3) {
               int orderResult = OrderSend(Symbol(), OP_SELL, lotSize, Ask, 10, 0, 0, "Sell Order", Magic, 0, clrRed); 
               goShort = true;
            }
         }
      }
   }
   if (getTotalProfits() > takeProfit) {
      closeAllTrades();
      lotSize = AccountFreeMargin()/10000;
   }
   if (goLong == true) {
      if (Bid < span_a) {
         closeAllTrades();
         lotSize = AccountFreeMargin()/10000;
      }
   }
   
   if (goShort == true) {
      if (Ask > span_b) {
         closeAllTrades();
         lotSize = AccountFreeMargin()/10000;
      }
   }
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

