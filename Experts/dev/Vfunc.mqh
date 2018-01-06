//+------------------------------------------------------------------+
//|                                                        Vfunc.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// base virtual class
class VbaseClass {
private:
  string name;
  
public:
  VbaseClass();
  ~VbaseClass();
  
  virtual void OnTick();
};

VbaseClass::VbaseClass() {
  name = "VbaseClass";
}

VbaseClass::~VbaseClass() {
}

VbaseClass::OnTick() {
  Print(__FUNCTION__+"("+IntegerToString(__LINE__)+")");
}

// setup 1
class Setup1 : public VbaseClass {
private:

public:
  string name;
  Setup1();
  ~Setup1();
  
  virtual void OnTick();
};

Setup1::Setup1() {
  name = "Setup1";
}

Setup1::~Setup1() {
}

Setup1::OnTick() {
  Print(__FUNCTION__+"("+IntegerToString(__LINE__)+")");
}


// setup 2
class Setup2 : public VbaseClass {
private:

public:
  string name;
  Setup2();
  ~Setup2();
  
  virtual void OnTick();
};

Setup2::Setup2() {
  name = "Setup2";
}

Setup2::~Setup2() {
}

Setup2::OnTick() {
  Print(__FUNCTION__+"("+IntegerToString(__LINE__)+")");
}





class TestRobo {
private:
  string name;
  VbaseClass *s1;
  VbaseClass *s2;
  VbaseClass *s3;
  VbaseClass *setups[3];
public:
  TestRobo();
  ~TestRobo();
  
  void OnTick();
};

TestRobo::TestRobo() {
  name = "TestRobo";
  s1 = new VbaseClass();
  s2 = new Setup1();
  s3 = new Setup2();
  setups[0] = new VbaseClass();
  setups[1] = new Setup1();
  setups[2] = new Setup2();  
}

TestRobo::~TestRobo() {
}

TestRobo::OnTick() {
  //Print(__FUNCTION__+"("+IntegerToString(__LINE__)+")");
  Print("scalars:");
  s1.OnTick();
  s2.OnTick();
  s3.OnTick();
  VbaseClass *setup;
  Print("arrays:");
  for(int i=0;i<3;i++) {
    setup = setups[i];
    setup.OnTick();
  }
}

