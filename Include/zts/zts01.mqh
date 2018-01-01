//+------------------------------------------------------------------+
//|                                                        zts01.mqh |
//+------------------------------------------------------------------+
#property strict

class RoboZTS01 {
private:
public:
  RoboZTS01();
  ~RoboZTS01();
  
  int OnInit();
  void OnDeinit();
  void OnTick();
  
  void setExitStrategy(int);
  void addSetup(int);
  void cleanUpEOD();
  void startOfDay();
};

  RoboZTS01::RoboZTS01() {
  }
  
  RoboZTS01::~RoboZTS01() {
  }

  int RoboZTS01::OnInit() {return(0);}
  void RoboZTS01::OnDeinit() { }
  void RoboZTS01::OnTick() { }
  
  void RoboZTS01::setExitStrategy(int strategyIndex) { };
  void RoboZTS01::addSetup(int) { }
  void RoboZTS01::cleanUpEOD() { }
  void RoboZTS01::startOfDay() { }
