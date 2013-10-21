#import "tuneup_js/tuneup.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();
target.logElementTree();

var username = "aris-test";
var password = "aris";
var gameName = "ARIS-Tester";

							/*  ******* RESER USER ******* */
var resetToLoginScreen = function()
{

test("Reset to Three bars in game.", function(target,app){
   
   //Inside Character, Web Item, Normal Item
   if (app.navigationBar().buttons()["arrowBack"].checkIsValid())
   		 {
		 app.navigationBar().buttons()["arrowBack"].tap();
  		  } 
   //Inside Plaque
   else if (window.staticTexts()["Continue"].checkIsValid())
    	 {
    	 window.staticTexts()["Continue"].tap();
	 	app.navigationBar().buttons()["arrowBack"].tap();
    	 }
   // quick nav tapped or item tapped
   else if (app.actionSheet().cancelButton().checkIsValid())
   		  {
   		 app.actionSheet().cancelButton().tap();
    	 }
  });

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

							/*  ******* SIMULATE LOGIN ******* */
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

									/*  ******* SIMULATE LOGIN ******* */
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


									/*  ******* SELECT GAME ******* */
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

									/*  ******* ALERT FUNCTION ******* */

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

										/*  ******* NOARMAL ITEM TESTS ******* */
var normalItem = function(){
	test ("Normal Item", function(target,app){
	
	
		//TAP ON NORMAL ITEM AND QUICK TRAVEL  
		window.elements()["Normal Item"].tap();
		app.actionSheet().buttons()["Quick Travel"].tap();
		  

		//Check "Navigation bar says 'Normal Item'?"
		UIALogger.logMessage("Navigation bar says 'Normal Item' ?");
		assertEquals("Normal Item", app.navigationBar().name());
		    
		  //Tap Three lines
		window.staticTexts()["..."].tap();	  
		  
		//Check "Item content says 'Normal Item' "
		UIALogger.logMessage("Item content says 'Normal Item' ?");
		assertEquals("Normal Item", window.scrollViews()[1].scrollViews()[0].webViews()[0].staticTexts()["Normal Item"].name());
		  

		  app.navigationBar().buttons()["arrowBack"].tap();
		
	});
};

								/*  ******* PLAQUE TESTS ******* */
var plaque = function(){
	test("Plaque", function(target,app){
		//TAP ON PLAQUE ON MAP
		target.delay(5);
		 
		window.elements()["Plaque"].tap();
		app.actionSheet().buttons()["Quick Travel"].tap();
		 
		UIALogger.logMessage("Navigation bar says 'Plaque' ?");
		assertEquals("Plaque",target.frontMostApp().navigationBar().name());
		 
		 		// Plaque content name is "Plaque Content"
		UIALogger.logMessage("Plaque content says 'Plaque Content' ");
		assertEquals("Plaque Content", window.scrollViews()[0].scrollViews()[0].webViews()[0].staticTexts()["Plaque Content"].name());
		 
 
		window.staticTexts()["Continue"].tap();
	
	});	
};


							/*  ******* GREETING CHARACTER TESTS ******* */
var greetingCharacter = function(){
	// GREETING CHARACTER TEST
	test("Enter Greeting Character", function(target,app){
		 
		window.elements()["Greeting/Closing Character"].tap();
		app.actionSheet().buttons()["Quick Travel"].tap();
		UIALogger.message("Navigation says 'You'? ");		 
		 });	
	
	test("PC Character Test",function(target,app){
		 //I AM THE PC CHARACTER
		 
		  assertEquals("I'm the PC",window.scrollViews()[3].scrollViews()[0].webViews()[0].staticTexts()["I'm the PC"].name())
		 target.delay(1);
		 window.staticTexts()["Continue"].tap();
		 });
	
	test("NPC Character Test",function(target,app){
		 // I AM THE NPC CHARACTER
		 
		 assertEquals("I'm the NPC",window.scrollViews()[1].scrollViews()[0].webViews()[0].staticTexts()["I'm the NPC"].name())
		target.delay(1);
		window.staticTexts()["Continue"].tap();
		 });
	
	test("NOC With Custom Media Test",function(target,app){
		 //NOC WITH CUSTOM MEDIA
		 
		 assertEquals("NOC with custom media",window.scrollViews()[1].scrollViews()[0].webViews()[0].staticTexts()["NOC with custom media"].name())
		 target.delay(1);
		 window.staticTexts()["Continue"].tap();
		 });
	
	test("Leaving Converstaion Tester", function(target,app){
		 //Leave Conversation
		target.delay(2);
		window.scrollViews()[0].scrollViews()[0].webViews()[0].staticTexts()["Leave Conversation"].tap();
		 });

		 
};
							/*  ******* ENTER CONVERSATION TESTER ******* */
var enterConversationTester = function(){
	// TAP CONVERSATION TESTER TEST
	test("Enter Conversation Tester", function(target, app) {
		window.elements()["Conversation Tester"].tap();
		app.actionSheet().buttons()["Quick Travel"].tap();
		window.staticTexts()["Continue"].tap();
	 });	
};


							/*  ******* NORMAL SCRIPTS TESTS ******* */
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
		//window.scrollViews()[0].scrollViews()[0].webViews()[0].tap();
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
		 
		 
		 });
	
		// Video Tag == This is funky, it exited me.
	
		// Panoramic Tag  == This is funky , it exited me.
		
		// End Normal Script Tests	
};

									/*  ******* EXIT TO SCRIPTS TESTS ******* */
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


								/*  ******* DECODER TESTS ******* */
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



//Added as noted in the tread below
// https://github.com/alexvollmer/tuneup_js/pull/49
var imageAsserter = function(){
		 
		 createImageAsserter('integration/javascript/tuneup_js', 'integration/tmp/results', 'integration/ref_images');
		
	assertScreenMatchesImageNamed("login", "Login Image does not match");
		 

};

	
////////////////////////////Main


// Reset the game from anywhere in the application
resetToLoginScreen();
 
//Test Login Image 
 imageAsserter();

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
enterConversationTester();

window.logElementTree();

// Test Normal Scripts
normalScriptTests();
 
window.logElementTree();

//Test Exit to Scripts
exitToScripts();

//Test Decoder
testDecoder();


/////////////////////////////////////////////////////////////////////// End In game Tests

// Reset Back to Login Screen
resetToLoginScreen();


