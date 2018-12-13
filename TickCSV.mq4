//+------------------------------------------------------------------+
//|                                                      TickCSV.mq4 |
//|                                  Copyright 2018, Rednut Software |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Rednut Software"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int fp = INVALID_HANDLE;
int fday = -1;
int g_fmin = -1;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if (fp != INVALID_HANDLE)
   {
      FileClose(fp);
      fday = -1;
      g_fmin = -1;
   }
  }

void OpenTickCsv(MqlDateTime &dt)
  {
   string fname;
   
   if (fp != INVALID_HANDLE)
   {
      FileClose(fp);
      fday = -1;
   }
   
   fname = StringFormat("TickCsv_%s_%04d%02d%02d%02d%02d%02d.csv",
                        Symbol(),
                        dt.year, dt.mon, dt.day,
                        dt.hour, dt.min, dt.sec);
   
   fp = FileOpen(fname, FILE_READ | FILE_WRITE | FILE_SHARE_READ | FILE_ANSI);
   if (fp == INVALID_HANDLE)
   {
      PrintFormat("failed to FileOpen(%s)", fname);
   }
   else
   {
      fday = dt.day;
   }
   g_fmin = -1;
  }

void WriteTickCsv(MqlDateTime &sv_dt, MqlDateTime &lc_dt)
  {
   string str;
   if (g_fmin != sv_dt.min)
   {
      /* flush every minute */
      FileFlush(fp);
      g_fmin = sv_dt.min;
   }
   str = StringFormat(
               "%04d/%02d/%02d %02d:%02d:%02d,"
               "%04d/%02d/%02d %02d:%02d:%02d,"
               "%f,%f"
               "\n",
               lc_dt.year,lc_dt.mon,lc_dt.day,lc_dt.hour,lc_dt.min,lc_dt.sec,
               sv_dt.year,sv_dt.mon,sv_dt.day,sv_dt.hour,sv_dt.min,sv_dt.sec,
               Bid,Ask);
   FileWriteString(fp,str);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   MqlDateTime sv_dt;
   MqlDateTime lc_dt;
   
   TimeCurrent(sv_dt);
   TimeLocal(lc_dt);
   
   if (fday != sv_dt.day)
   {
      OpenTickCsv(sv_dt);
      if (fday != sv_dt.day)
      {
         ExpertRemove();
      }
   }
   
   WriteTickCsv(sv_dt, lc_dt);
  }
//+------------------------------------------------------------------+
