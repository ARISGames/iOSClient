#import "tuneup_js/tuneup.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();
target.logElementTree();

var username = "aris-test";
var password = "aris";
var gameName = "ARIS-Tester";

// RESET USER IF ALREADY LOGGED IN
var resetToLoginScreen = function()
{
	test("Reset To Login Screen", function(target,app){
		 	if (app.navigationBar().buttons()["threeLines"].checkIsValid())
		 	{
		 		
		 		UIALogger.logMessage("Inside ThreeLines If Statement");
				app.navigationBar().buttons()["threeLines"].tap();
				target.delay(1);
				window.staticTexts()["Leave Game"].tap();
				target.delay(1);
				app.navigationBar().buttons()["arrowBack"].tap();
			}
		 
			if (app.navigationBar().buttons()["idcard"].checkIsValid())
			{
				app.navigationBar().buttons()["idcard"].tap();
				window.staticTexts()["Logout"].tap();

			}
	});	
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
		 target.delay(2);
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

var initialPlaque = function(){
	test("Dismiss Initial Plaque the Go To Map", function(target,app){
	
		// Initial plaque - press continue
		window.staticTexts()["Continue"].tap();
		 
		 
		//GO TO MAP
		app.navigationBar().buttons()["threeLines"].tap();
		window.tableViews()[0].cells()["Map"].tap();
		 
	});	
};

var normalItem = function(){
	test ("Normal Item", function(target,app){
	
		  
	
		//TAP ON NORMAL ITEM AND QUICK TRAVEL  
		window.elements()["Normal Item"].tap();
		app.actionSheet().buttons()["Quick Travel"].tap();
		  
		  
		  
		  
		//Check "Navigation bar says 'Normal Item'?"
		UIALogger.logMessage("Navigation bar says 'Normal Item' ?");
		assertEquals("Normal Item", app.navigationBar().name(), "PAss");
		  
		  
		  //Tap Three lines
		window.staticTexts()["..."].tap();
		  
		  
		//Check "Item content says 'Normal Item' "
		UIALogger.logMessage("Item content says 'Normal Item' ?");
		assertEquals("Normal Item", window.scrollViews()[1].scrollViews()[0].webViews()[0].staticTexts()["Normal Item"].name(), "PAss");
		  

		  app.navigationBar().buttons()["arrowBack"].tap();
		
	});
};

var plaque = function(){
	test("Plaque", function(target,app){
		//TAP ON PLAQUE ON MAP
		target.delay(5);
		 
		window.elements()["Plaque"].tap();
		app.actionSheet().buttons()["Quick Travel"].tap();
		 
		// Plaque content name is "Plaque Content"
		UIALogger.logMessage("Check 'Plaque' Message");
		assertEquals("Plaque Content", window.scrollViews()[0].scrollViews()[0].webViews()[0].staticTexts()["Plaque Content"].name());
		 
		 
		//Check "Does the Navigation say 'Plaque'?"
		UIALogger.logMessage("Navigation bar says 'Plaque' ?");
		assertEquals("Plaque",target.frontMostApp().navigationBar().name());
		 
		 
		 
		 
		window.staticTexts()["Continue"].tap();
	
	});	
};

var greetingCharacter = function(){
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
};

var dropConversationTester = function(){
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
};

var normalScriptTests = function(){
	
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
		test("Item Tag", function(target,app){
			target.delay(1);
			window.scrollViews()[0].scrollViews()[0].webViews()[0].tap();
			target.delay(1);
			app.navigationBar().buttons()["arrowBack"].tap();	 
		});
	
	
		//Plaque Tag
	test("Plaque Tag",function(target,app){
		 
		window.scrollViews()[0].scrollViews()[0].webViews()[0].tap();
		target.delay(1);
		window.staticTexts()["Continue"].tap();
		 
		 

		 //Check "Forgot Password" Button
		UIALogger.logMessage("Navigation bar says 'Plaque' ?");
		assertEquals("Plaque",target.frontMostApp().navigationBar().name());
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 });
	
		// Video Tag == This is funky, it exited me.
	
		// Panoramic Tag  == This is funky , it exited me.
		
		// End Normal Script Tests	
};


var exitToScripts = function() {
		
	
	//EXIT SCRIPT TESTS
	test("Exit To Webpage", function(target,app){
		// Webpage Tag
		target.frontMostApp().mainWindow().scrollViews()[0].scrollViews()[2].webViews()[0].tap();
		target.delay(2);
		target.frontMostApp().navigationBar().buttons()["arrowBack"].tap();
	});
	test("Exit To Map", function(target,app){
		// Exit to Map
		target.frontMostApp().mainWindow().scrollViews()[0].scrollViews()[2].webViews()[0].tap();
		target.frontMostApp().mainWindow().staticTexts()["Continue"].tap();
	});
	test("Back To Character", function(target,app){
		//Back to Character
		window.elements()["Conversation Tester"].tap();
		app.actionSheet().buttons()["Quick Travel"].tap();
		window.staticTexts()["Continue"].tap();
	});
	test("Exit To Plaque", function(target,app){
		// Exit to Plaque
		window.scrollViews()[0].scrollViews()[2].webViews()[0].tap();
		window.staticTexts()["Continue"].tap();
		window.staticTexts()["Continue"].tap();
	});
	test("Back To Character", function(target,app){
		//Back to Character
		window.elements()["Conversation Tester"].tap();
		target.delay(1);
		app.actionSheet().buttons()["Quick Travel"].tap();
		target.delay(1);
		window.staticTexts()["Continue"].tap();
	});
	test("Exit To Item", function(target,app){
		/// EXIT TO ITEM
		target.delay(1);
		window.scrollViews()[0].scrollViews()[2].webViews()[0].tap();
		target.delay(1);
		window.staticTexts()["Continue"].tap();
		target.delay(1);
		target.frontMostApp().navigationBar().buttons()["arrowBack"].tap();
	});
	test("Back To Character", function(target,app){
		//Back to Character
		target.delay(2);
		window.elements()["Conversation Tester"].tap();
		target.delay(1);
		app.actionSheet().buttons()["Quick Travel"].tap();
		target.delay(1);
		window.staticTexts()["Continue"].tap();
	});
	test("Exit To Character", function(target,app){
		// EXIT TO CHARACTER
		window.scrollViews()[0].scrollViews()[2].webViews()[0].tap();
		target.delay(1);
		window.staticTexts()["Continue"].tap();
		target.delay(1);
		window.staticTexts()["Continue"].tap();
		target.delay(1);
		window.scrollViews()[0].scrollViews()[0].webViews()[0].tap();
	});
	test("Back To Character", function(target,app){
		//Back to Character
		target.delay(1);
		window.elements()["Conversation Tester"].tap();
		target.delay(1);
		app.actionSheet().buttons()["Quick Travel"].tap();
		target.delay(1);
		window.staticTexts()["Continue"].tap();
	});
	test("Exit To Webpage", function(target,app){
		//EXIT TO WEBPAGE
		window.scrollViews()[0].scrollViews()[2].webViews()[0].tap();
		window.staticTexts()["Continue"].tap();
		app.navigationBar().buttons()["arrowBack"].tap();
	});
		// EXIT TO PANORAMIC -- this is broken
		 
	
};



var testDecoder = function() {


test("Decoder Plaque Item", function(target, app){
	 
	 //Go Into Decoder From MAP	
	 app.navigationBar().buttons()["threeLines"].tap();
	 window.tableViews()["Empty list"].cells()["Decoder"].tap();
	 
	 // Plaque Decoder
	 window.textFields()[0].tap();
	 target.delay(1);
	 app.keyboard().typeString('4982\n');
	 
	 //Entered plaque?
	 target.frontMostApp().mainWindow().staticTexts()["Continue"].tap();
	
	 // Clear text Field
	 window.textFields()[0].tap();
	 target.delay(1);
	 target.frontMostApp().keyboard().keys()["Delete"].tap();
	 target.delay(1);
	 target.frontMostApp().keyboard().keys()["Delete"].tap();
	 target.delay(1);
	 target.frontMostApp().keyboard().keys()["Delete"].tap();
	 target.delay(1);
	 target.frontMostApp().keyboard().keys()["Delete"].tap();
	 
	 });
	 
	test("Decoder Normal Item", function(target,app){
		 
		 
		 
	 //Go Into Decoder From MAP	
	 app.navigationBar().buttons()["threeLines"].tap();
	 window.tableViews()["Empty list"].cells()["Decoder"].tap();
	 
	// Normal Item Decoder
	 window.textFields()[0].tap();
	 target.delay(1);
	 app.keyboard().typeString('8317\n');
	 
	 //Entered Normal Item?
	
	 app.navigationBar().buttons()["arrowBack"].tap();
		 
	 // Clear text Field
	 window.textFields()[0].tap();
		 target.delay(1);
	 target.frontMostApp().keyboard().keys()["Delete"].tap();
		 target.delay(1);
	 target.frontMostApp().keyboard().keys()["Delete"].tap();
		 target.delay(1);
	 target.frontMostApp().keyboard().keys()["Delete"].tap();
		 target.delay(1);
	 target.frontMostApp().keyboard().keys()["Delete"].tap();
		 
		 
		 
		 
		 
		 });
	 
	
	 


};

	
////////////////////////////Main



// Reset the game from anywhere in the application
resetToLoginScreen();

//Login to account
loginTest(username, password);

//Search for Game
searchGame(gameName);

// Select Game
selectGame();

/////////////////////////////////////////////////////////////////// Begin In game Tests

// Dismiss Initial Plaque
initialPlaque();
 

//Normal Item Test
normalItem();



//Plaque Test 
plaque();



// Greeting Character Dialogue Test
greetingCharacter();

// Has the Conversation Tester Dropped?
dropConversationTester();

// Test Normal Scripts
normalScriptTests();

//Test Exit to Scripts
exitToScripts();

//Test Decoder



testDecoder();


/////////////////////////////////////////////////////////////////////// End In game Tests

// Reset Back to Login Screen
resetToLoginScreen();


