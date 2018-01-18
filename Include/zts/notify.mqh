#property strict


extern string commentString_28 = ""; //*****************************************
extern string commentString_29 = ""; //Notifications Settings
extern bool Mail_Alert = false;
extern bool PopUp_Alert = false;
extern bool Sound_Alert = false;
extern bool SmartPhone_Notifications=false;
extern string commentString_30 = ""; //*****************************************

void SendAlert(string Message)
{
   if(Mail_Alert) SendMail("New Finch Alert",Message);
   if(PopUp_Alert) Alert(Message);
   if(Sound_Alert) PlaySound("alert.wav");
   if(SmartPhone_Notifications) SendNotification(Message);
   return;
}


/**
4250  ERR_NOTIFICATION_SEND_FAILED,
4251  ERR_NOTIFICATION_WRONG_PARAMETER,
4252  ERR_NOTIFICATION_WRONG_SETTINGS,
4253  ERR_NOTIFICATION_TOO_FREQUENT.
**/
