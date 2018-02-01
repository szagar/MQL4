#property strict


extern string commentString_not_0 = ""; //---------------------------------------------
extern string commentString_not_1 = ""; //*** Nofication settings:
extern bool Mail_Alert = false;             //- Mail Alert?
extern bool PopUp_Alert = false;            //- Popup Alert?
extern bool Sound_Alert = false;            //- Sound Alert?
extern bool SmartPhone_Notifications=false; //- SmartPhone Notification?

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
