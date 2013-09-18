//////////////////////////////////////////////////////////////////////  FUNCTION TO HANDLE ALERTS

UIATarget.onAlert = function onAlert(alert) {

  		var title = alert.name();	
	
  		 UIALogger.logWarning("Alert with title '" + title + "' encountered.");
   			if (title == "Are you sure?") {
    			   	alert.buttons()["Reset"].tap();
   			     	return true;  //alert handled, so bypass the default handler
 	  												 }
 		   // return false to use the default handler
  				  return false;
													}
//////// END Handling the Alert
