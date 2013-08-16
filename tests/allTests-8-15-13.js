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

		if (app.navigationBar().rightButton().checkIsValid() )
		{
			app.navigationBar().rightButton().tap();
			target.frontMostApp().mainWindow().buttons()["Logout"].tap();
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
	
	window.tableViews()["Empty list"].cells()[0].textFields()[0].tap();
	
		target.frontMostApp().keyboard().typeString(username + "\n");
			
		// TYPE PASSWORD
		window.tableViews()["Empty list"].cells()[1].secureTextFields()[0].tap();
	
	
	target.frontMostApp().keyboard().typeString(password);
	
		// CLICK LOGIN
		target.frontMostApp().mainWindow().buttons()[0].tap();
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
	target.frontMostApp().mainWindow().searchBars()[0].tap();
	target.frontMostApp().keyboard().typeString(gameName);
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
	
	// Initial Plaque appeared, press continue
	
	target.delay(1);
	target.captureScreenWithName('5 - Initial Plaque');
	window.scrollViews()[0].buttons()["Tap To Continue"].tap();
	// Let screen with quests load
	//SCREEN CAPTURE
	target.delay(1);
	target.captureScreenWithName('6 - Initial Quests');
	
	
	//GO TO MAP
	target.frontMostApp().tabBar().buttons()["Map"].tap();
	
	//TAP ON NORMAL ITEM AND QUICK TRAVEL
	
	target.frontMostApp().mainWindow().elements()["Normal Item"].tap();
	target.frontMostApp().actionSheet().buttons()["Quick Travel"].tap();
	target.frontMostApp().mainWindow().buttons()["Back"].tap();
	target.frontMostApp().mainWindow().buttons()[0].tap();
	
	
	
	//TAP ON PLAQUE ON MAP

	target.frontMostApp().mainWindow().elements()["Plaque"].tap();
	target.frontMostApp().actionSheet().buttons()["Quick Travel"].tap();
	target.frontMostApp().mainWindow().scrollViews()[0].buttons()["Tap To Continue"].tap();
	
	
	//////////////////////////////////////////////////TAP ON GREETING CHARACTER
	
	UIATarget.localTarget().pushTimeout(10);
	
	target.frontMostApp().mainWindow().elements()["Greeting/Closing Character"].tap();
	target.frontMostApp().actionSheet().buttons()["Quick Travel"].tap();
	
	UIATarget.localTarget().popTimeout();
	
	
	
	
	//I AM THE PC CHARACTER
	target.frontMostApp().mainWindow().buttons()["Tap To Continue"].tap();
	
	
	
	// I AM THE NPC CHARACTER
	target.frontMostApp().mainWindow().buttons()["Tap To Continue"].tap();
	
	//NOC WITH CUSTOM MEDIA
	target.frontMostApp().mainWindow().buttons()["Tap To Continue"].tap();
	
	//Leave Conversation
	target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()["Leave Conversation"].tap();
	// Alert detected. Expressions for handling alerts should be moved into the UIATarget.onAlert function definition.
	
	
	//////////////////////////////Wait for Conversation Tester
	UIATarget.localTarget().pushTimeout(10);
	target.frontMostApp().mainWindow().elements()["Conversation Tester"].tap();
	UIATarget.localTarget().popTimeout();
	
	
	
	//No Script
	
	
	// NPC and PC Tag
	
	// Item Tag
		
	//Plaque Tag
		
	// Video Tag

	
	// Panoramic Tag
		

	// Webpage Tag
		
	
	// Exit to Map
	target.frontMostApp().mainWindow().scrollViews()[3].tableViews()["Empty list"].cells()["Exit to Map"].tap();
	target.delay(1);
	target.captureScreenWithName('21 - Exit to Map');
	target.frontMostApp().mainWindow().scrollViews()[1].buttons()["Tap to Continue"].tap();
	
	//Back to Character and EXIT TO PLAQUE
	target.frontMostApp().mainWindow().elements()["Conversation Tester"].tap();
	target.frontMostApp().actionSheet().buttons()["Quick Travel"].tap();
	
	target.frontMostApp().mainWindow().scrollViews()[2].buttons()["Tap to Continue"].tap();
	target.frontMostApp().mainWindow().scrollViews()[3].tableViews()["Empty list"].cells()["Exit to Plaque"].tap();
	target.frontMostApp().mainWindow().scrollViews()[1].buttons()["Tap to Continue"].tap();
	target.delay(1);
	target.captureScreenWithName('22 - Exit to Plaque');
	target.frontMostApp().mainWindow().scrollViews()[0].buttons()["Tap To Continue"].tap();
	
	// //Back to Character and EXIT TO ITEM
	target.frontMostApp().mainWindow().elements()["Conversation Tester"].tap();
	target.frontMostApp().actionSheet().buttons()["Quick Travel"].tap();
	target.frontMostApp().mainWindow().scrollViews()[2].buttons()["Tap to Continue"].tap();
	target.frontMostApp().mainWindow().scrollViews()[3].tableViews()["Empty list"].cells()["Exit to Item"].tap();
	target.frontMostApp().mainWindow().scrollViews()[1].buttons()["Tap to Continue"].tap();
	target.delay(1);
	target.captureScreenWithName('23 - Exit to Item');
	target.frontMostApp().navigationBar().leftButton().tap();
	
	//Back to Character and EXIT TO CHARACTER
	target.frontMostApp().mainWindow().elements()["Conversation Tester"].tap();
	target.frontMostApp().actionSheet().buttons()["Quick Travel"].tap();
	target.frontMostApp().mainWindow().scrollViews()[2].buttons()["Tap to Continue"].tap();
	target.frontMostApp().mainWindow().scrollViews()[3].tableViews()["Empty list"].cells()["Exit to Character"].tap();
	target.delay(1);
	target.frontMostApp().mainWindow().scrollViews()[1].buttons()["Tap to Continue"].tap();
	target.delay(1);
	target.frontMostApp().mainWindow().scrollViews()[2].buttons()["Tap to Continue"].tap();
	target.delay(1);
	target.frontMostApp().mainWindow().scrollViews()[1].buttons()["Tap to Continue"].tap();
	
	//Back to Character and EXIT TO WEBSITE
	target.frontMostApp().mainWindow().elements()["Conversation Tester"].tap();
	target.frontMostApp().actionSheet().buttons()["Quick Travel"].tap();
	target.frontMostApp().mainWindow().scrollViews()[2].buttons()["Tap to Continue"].tap();
	target.frontMostApp().mainWindow().scrollViews()[3].tableViews()["Empty list"].cells()["Exit to Webpage"].tap();
	target.frontMostApp().mainWindow().scrollViews()[1].buttons()["Tap to Continue"].tap();
	target.frontMostApp().navigationBar().leftButton().tap();
	
	
// ----------------
UIALogger.logPass(inGame);
	
};


//////////////////////////////////////////////////////////////////////  RESET GAME 
var reset = function(){
	
	var resetGame = "Resetting Game";
	UIALogger.logStart(resetGame);
	
	
	target.frontMostApp().tabBar().buttons()["More"].tap();
	target.frontMostApp().mainWindow().tableViews()[0].cells()["Leave Game"].tap();
	target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()["Reset"].tap();
			target.delay(2);
	
	target.frontMostApp().navigationBar().leftButton().tap();
	target.frontMostApp().mainWindow().searchBars()[0].tap();
	window.buttons()["Cancel"].tap();
	
	target.frontMostApp().navigationBar().rightButton().tap();
	target.frontMostApp().mainWindow().buttons()["Logout"].tap();
	
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

