/// This JS script tests the UI Elements and Accessibility tags for the ARIS game "Game-Tester"

/////Variables
var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();
target.logElementTree();

var username = "aris-test";
var password = "aris";
var gameName = "ARIS-Tester";

////////////////////////////////////////////////////////////////////// RESET USER IF ALREADY LOGGED IN

var resetUser = function()
{

	var resetUser = "Resetting the User if already logged in.";
	UIALogger.logStart(resetUser);
	
		if (app.navigationBar().buttons()["idcard"].checkIsValid() )
		{
			app.navigationBar().buttons()["idcard"].tap();
			
window.staticTexts()["Logout"].tap();
			
			
		}
	
	UIALogger.logPass(resetUser);	
}


////////////////////////////////////////////////////////////////////// SIMULATING: LOGIN

var loginUITests = function(){

	target.captureScreenWithName("1 - Login Screen");
	
};

////////////////////////////////////////////////////////////////////// SIMULATING: LOGIN
var loginTest = function(username,password){
		var login = "Simulating Login Test";
	
	
		UIALogger.logStart(login);
	
	
		//TYPE USERNAME
		window.textFields()["usernameField"].tap();
		app.keyboard().typeString(username + "\n");
			
		// TYPE PASSWORD
		window.secureTextFields()["passwordField"].tap();
		app.keyboard().typeString(password);
	
		// CLICK LOGIN
		window.buttons()["arrowForward"].tap();
	
	UIALogger.logPass(login);
	
	
};
//////////////////////////////////////////////////////////////////////  SEARCH UI TEST
var searchUITests = function(){
	
	target.delay(1);
	target.captureScreenWithName("2 - Search UI");
	
	};


////////////////////////////////////////////////////////////////////// SIMULATING: SEARCHING FOR THE GAME
var searchGame = function(gameName){
	
	var searchGame = "Search Game Test";
	UIALogger.logStart(searchGame);
	
	target.frontMostApp().tabBar().buttons()["Search"].tap();		
	
	//Input name of game
	
	window.tableViews()["Empty list"].cells()["Cancel"].searchBars()[0].tap();

	
	app.keyboard().typeString(gameName);
	app.keyboard().buttons()["Search"].tap();
	
	// wait for game to show
	target.delay(1); 
	target.captureScreenWithName('3 - Game Found');
	
	UIALogger.logPass(searchGame);
	
};


//////////////////////////////////////////////////////////////////////  SELECT GAME

var selectGame = function(gameName){
	
	
	var selectGame = "Select Game Test";
	UIALogger.logStart(selectGame);
	
	window.tableViews()["Empty list"].cells()["ARIS-Tester, 0.0 km, 1 reviews, econtreras"].tap();
	
	target.delay(1);
	target.captureScreenWithName('4 - Game Start Screen');
	
	//RESET GAME IF "RESET" BUTTON IS THERE


	if(window.tableViews()["Empty list"].cells()["New Game"].checkIsValid())
		{ 
			// CREATE NEW GAME
		window.tableViews()["Empty list"].cells()["New Game"].tap();
		}
	else{
	
		target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()["Reset"].tap();
	
		
		// CREATE NEW GAME
		window.tableViews()["Empty list"].cells()["New Game"].tap();
		
	}
	
	UIALogger.logPass(selectGame);
	};

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

////////////////////////////////////////////////////////////////////// WHAT DO DO INSIDE THE GAME?

var inGame = function() {
var inGame = "In Game Activity";
UIALogger.logStart(inGame);	
	
	// Initial Plaque appeared, take screenshot
	
	target.delay(1);
	target.captureScreenWithName('5 - Initial Plaque');
	
	// Let screen with quests load
	//SCREEN CAPTURE
	target.delay(1);
	target.captureScreenWithName('6 - Initial Quests');
	
	// Initial plaque - press continue
	
	window.staticTexts()["Continue"].tap();
	 	
	
	//GO TO MAP
	
	app.navigationBar().buttons()["threeLines"].tap();

target.frontMostApp().mainWindow().tableViews()[0].cells()["Map"].tap();
	
	

	//TAP ON NORMAL ITEM AND QUICK TRAVEL
	
	window.elements()["Normal Item"].tap();
	app.actionSheet().buttons()["Quick Travel"].tap();
	app.navigationBar().buttons()["arrowBack"].tap();
	

	
	//QUEST COMPLETE, DISMISS
	window.staticTexts()["Continue > "].tap();
	
	
	//TAP ON PLAQUE ON MAP
	target.delay(5);
	window.elements()["Plaque"].tap();
	app.actionSheet().buttons()["Quick Travel"].tap();
	window.staticTexts()["Continue"].tap();
	
	
	
	//////////////////////////////////////////////////TAP ON GREETING CHARACTER
	
	
	
	UIATarget.localTarget().pushTimeout(10);
	
	window.elements()["Greeting/Closing Character"].tap();
 	
	
	app.actionSheet().buttons()["Quick Travel"].tap();
	
	
	UIATarget.localTarget().popTimeout();
	
	
	
	
	//I AM THE PC CHARACTER
	target.delay(1);
	window.staticTexts()["Continue"].tap();
	
	
	// I AM THE NPC CHARACTER
	target.delay(1);
	window.staticTexts()["Continue"].tap();
	
	
	//NOC WITH CUSTOM MEDIA
	target.delay(1);
	window.staticTexts()["Continue"].tap();
	
	
	//Leave Conversation
	target.delay(2);
	window.scrollViews()[0].scrollViews()[0].webViews()[0].staticTexts()["Leave Conversation"].tap();
	
	
	
	//////////////////////////////Wait for Conversation Tester
	UIATarget.localTarget().pushTimeout(10);
	window.elements()["Conversation Tester"].tap();
	
	
	UIATarget.localTarget().popTimeout();
	
	//Quick Travel to Conversation Character
	app.actionSheet().buttons()["Quick Travel"].tap();
	
	
	//Hello I am the conversation Test Character
	window.staticTexts()["Continue"].tap();
	
	
	//No Script
	window.scrollViews()[0].scrollViews()[0].webViews()[0].tap();
	window.staticTexts()["Continue"].tap();
	
	
	// NPC and PC Tag
	target.delay(2);
	window.scrollViews()[0].scrollViews()[0].webViews()[0].tap();
	target.delay(1);
	window.staticTexts()["Continue"].tap();
	target.delay(1);
	window.staticTexts()["Continue"].tap();
	
	
	// Item Tag
	target.delay(1);
	window.scrollViews()[0].scrollViews()[0].webViews()[0].tap();
	target.delay(1);
 	app.navigationBar().buttons()["arrowBack"].tap();
 	
	//Plaque Tag
	window.scrollViews()[0].scrollViews()[0].webViews()[0].tap();
	target.delay(1);
	window.staticTexts()["Continue"].tap();
	
	
	// Video Tag == This is funky, it exited me.
	target.delay(1);
	

	
	// Panoramic Tag  == This is funky , it exited me.
		
	

	// Webpage Tag
	
	target.frontMostApp().mainWindow().scrollViews()[0].scrollViews()[2].webViews()[0].tap();
	target.delay(2);
	target.frontMostApp().navigationBar().buttons()["arrowBack"].tap();
	
	
	
	// Exit to Map
	
	target.frontMostApp().mainWindow().scrollViews()[0].scrollViews()[2].webViews()[0].tap();
	target.frontMostApp().mainWindow().staticTexts()["Continue"].tap();
	
	
	//Back to Character
	window.elements()["Conversation Tester"].tap();
	app.actionSheet().buttons()["Quick Travel"].tap();
	window.staticTexts()["Continue"].tap();
	
	
	// Exit to Plaque
	
	window.scrollViews()[0].scrollViews()[2].webViews()[0].tap();
	window.staticTexts()["Continue"].tap();
	window.staticTexts()["Continue"].tap();
	
	
	//Back to Character
	window.elements()["Conversation Tester"].tap();
	target.delay(1);
	app.actionSheet().buttons()["Quick Travel"].tap();
	target.delay(1);
	window.staticTexts()["Continue"].tap();
	
	
	/// EXIT TO ITEM
	target.delay(1);
	window.scrollViews()[0].scrollViews()[2].webViews()[0].tap();
	target.delay(1);
	window.staticTexts()["Continue"].tap();
	target.delay(1);
	target.frontMostApp().navigationBar().buttons()["arrowBack"].tap();
	

	
	//Back to Character
	target.delay(2);
	window.elements()["Conversation Tester"].tap();
	target.delay(1);
	app.actionSheet().buttons()["Quick Travel"].tap();
	target.delay(1);
	window.staticTexts()["Continue"].tap();
	
	// EXIT TO CHARACTER
	window.scrollViews()[0].scrollViews()[2].webViews()[0].tap();
	target.delay(1);
	window.staticTexts()["Continue"].tap();
	target.delay(1);
	window.staticTexts()["Continue"].tap();
	target.delay(1);
	window.scrollViews()[0].scrollViews()[0].webViews()[0].tap();
	

	
	//Back to Character 

	target.delay(1);
	window.elements()["Conversation Tester"].tap();
	target.delay(1);
	app.actionSheet().buttons()["Quick Travel"].tap();
	target.delay(1);
	window.staticTexts()["Continue"].tap();
	
	
	
	//EXIT TO WEBPAGE
	window.scrollViews()[0].scrollViews()[2].webViews()[0].tap();
	window.staticTexts()["Continue"].tap();
	app.navigationBar().buttons()["arrowBack"].tap();
	

	
	// EXIT TO PANORAMIC -- this is broken

UIALogger.logPass(inGame);
	
};


//////////////////////////////////////////////////////////////////////  RESET GAME 
var reset = function(){
	
	var resetGame = "Resetting Game";
	UIALogger.logStart(resetGame);
	
	app.navigationBar().buttons()["threeLines"].tap();
	target.delay(1);
	window.staticTexts()["Leave Game"].tap();
	target.delay(1);
	app.navigationBar().buttons()["arrowBack"].tap();
	
	resetUser();
	

	
	UIALogger.logPass(resetGame);
	
	};

///////////////////////	 Call the Tests your want to run here //////////////////////////////

/////Main
resetUser();
loginUITests(); //Test UI Elements
loginTest(username, password);
searchUITests(); // Test UI Elements
searchGame(gameName);
selectGame();
inGame();
reset();

