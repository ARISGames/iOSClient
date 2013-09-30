#import "tuneup_js/tuneup.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();
target.logElementTree();

var username = "aris-test";
var password = "aris";
var gameName = "ARIS-Tester";

// RESET USER IF ALREADY LOGGED IN
var resetUser = function()
{
	test("Resetting the User if already logged in.", function(target,app){
	
		io	});	
};

// SIMULATING: LOGIN
var loginTest = function(username,password){
	
	//This is a tuneup_js test
	test("Login Screen", function(target, app){
		 		 
		//Check "Create Account" Message
		UIALogger.logMessage("Check 'Create Account' Message");
		assertEquals("Create Account", window.buttons()["Create Account"].name());
		 
		//Check "Forgot Password" Button
		UIALogger.logMessage("Check 'Forgot Password?' Message");
		assertEquals("Forgot Password?",window.buttons()["Forgot Password?"].name());
		 		 
		//TYPE USERNAME
		window.textFields()[0].tap();
		app.keyboard().typeString(username + "\n");
			
		// TYPE PASSWORD
		window.secureTextFields()[0].tap();
		app.keyboard().typeString(password);
	
		// CLICK LOGIN
		window.buttons()["arrowForward"].tap();
	});
	
};

// SIMULATING: SEARCHING FOR THE GAME
var searchGame = function(gameName){
	
	test("Search Game Test", function(target,app){
	
		//Tap "Search"
		app.tabBar().buttons()["Search"].tap();	
	
		//Assertion empty list
		UIALogger.logMessage("Check that the list is empty before starting");
		assertEquals("No results found", window.tableViews()["Empty list"].cells()["No results found"].name());	 
	
		//Tap Search Bar and Input Name
		window.tableViews()["Empty list"].cells()["Cancel"].searchBars()[0].tap();
		app.keyboard().typeString(gameName);
		 
		// Tap Search
		app.keyboard().buttons()["Search"].tap();	
	});
};


//  SELECT GAME
var selectGame = function(gameName){
	
	test("Selecting Game", function(target,app) 
	{
	
		//Tap the top Game
		target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()[1].tap();
		 
		//RESET GAME IF "RESET" BUTTON IS THERE
		if(window.tableViews()["Empty list"].cells()["New Game"].checkIsValid())
		{ 
			// CREATE NEW GAME
			window.tableViews()["Empty list"].cells()["New Game"].tap();
		}
		 
		else
		{
			target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()["Reset"].tap();
			// CREATE NEW GAME
			window.tableViews()["Empty list"].cells()["New Game"].tap();
		}
	
			//end tuneupjs "test"
	});

};

// FUNCTION TO HANDLE ALERTS

UIATarget.onAlert = function onAlert(alert) {

  	var title = alert.name();	
	
  	UIALogger.logWarning("Alert with title '" + title + "' encountered.");
   	if (title == "Are you sure?")
   	{
    	alert.buttons()["Reset"].tap();
   		return true;  //alert handled, so bypass the default handler
 	}
  	return false;
}

// A HUGE PILE OF TESTS
// TODO: BREAK ME UP
var inGame = function() {
	
	
	test("Initial Plaque,Normal Item and Plaque", function(target,app){
	
		// Initial plaque - press continue
		window.staticTexts()["Continue"].tap();
		});
	
	test ("Normal Item", function(target,app){
	
		//GO TO MAP
		app.navigationBar().buttons()["threeLines"].tap();
		window.tableViews()[0].cells()["Map"].tap();
	
		//TAP ON NORMAL ITEM AND QUICK TRAVEL
		window.elements()["Normal Item"].tap();
		app.actionSheet().buttons()["Quick Travel"].tap();
		app.navigationBar().buttons()["arrowBack"].tap();
		
		});
	
	
	test("Plaque", function(target,app){
		//TAP ON PLAQUE ON MAP
		target.delay(5);
		window.elements()["Plaque"].tap();
		app.actionSheet().buttons()["Quick Travel"].tap();
		window.staticTexts()["Continue"].tap();
	
		});
	

	// GREETING CHARACTER TEST
	test("Greeting Character - PC/NPC/Custom Media", function(target,app){
	
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

	});
	
	// TAP CONVERSATION TESTER TEST
	test("Conversation Tester Dropped", function(target, app) {
	
		 //Wait for him to drop
		target.delay(11);
		window.elements()["Conversation Tester"].tap();
	 
		//Quick Travel to Conversation Character
		app.actionSheet().buttons()["Quick Travel"].tap();
	
		//Hello I am the conversation Test Character
		window.staticTexts()["Continue"].tap();
	
		 //End TAP CONVERSATION TESTER TEST
	 });
	
	//NORMAL SCRIPT TESTS
	test("No Script", function(target,app){
		 
		//No Script
		window.scrollViews()[0].scrollViews()[0].webViews()[0].tap();
		window.staticTexts()["Continue"].tap();
	
		});
		
		test("NPC and PC Tag", function(target,app){
		
		// NPC and PC Tag
		target.delay(2);
		window.scrollViews()[0].scrollViews()[0].webViews()[0].tap();
		target.delay(1);
		window.staticTexts()["Continue"].tap();
		target.delay(1);
		window.staticTexts()["Continue"].tap();
		
		});
		
	
	
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
	
		// Panoramic Tag  == This is funky , it exited me.
		
		// End Normal Script Tests
		
	
	//EXIT SCRIPT TESTS
	test("EXIT TO SCRIPTS", function(target,app){
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
		 
	});
	
};

//  RESET FROM INSIDE GAME
var reset = function(){
	test("Resetting Game", function(target,app) {
		app.navigationBar().buttons()["threeLines"].tap();
		target.delay(1);
		window.staticTexts()["Leave Game"].tap();
		target.delay(1);
		app.navigationBar().buttons()["arrowBack"].tap();
		resetUser();
	});
};


var resetToMap = function(){

test("Reset to In Game Menu", function(target,app){
	 
	 //Inside Character, Web Item, Normal Item
	 if (app.navigationBar().buttons()["arrowBack"].checkIsValid())
		{
			app.navigationBar().buttons()["arrowBack"].tap();
		} 
	 //Inside Plaque
	 else if (window.staticTexts()["Continue"].checkIsValid())
	 	{
	 	window.staticTexts()["Continue"].tap();
	 	}
	 // quick nav tapped or item tapped
	 else if (app.actionSheet().cancelButton().checkIsValid())
	 	{
		app.actionSheet().cancelButton().tap();
	 	}
	 
	 //Tap the three bars
	 if (app.navigationBar().buttons()["threeLines"].checkIsValid())
		{
			app.navigationBar().buttons()["threeLines"].tap();
		} 
	 });
};


	
//Run the Tests

resetUser();
loginTest(username, password);
searchGame(gameName);
selectGame();
inGame();
reset();


//resetToMap();