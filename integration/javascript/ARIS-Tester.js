var inGame = function() {
	
///// INITIAL IN GAME TEST
	test("Initial Plaque,Normal Item and Plaque", function(target,app){
	
	// Initial plaque - press continue
	window.staticTexts()["Continue"].tap();
	
	//GO TO MAP
	app.navigationBar().buttons()["threeLines"].tap();
	window.tableViews()[0].cells()["Map"].tap();
	
	

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
	
	 //End Initial In Game Test
	 });
	
	
///// GREETING CHARACTER TEST
	
	test("Greeting Character", function(target,app){
	
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
	
	
		 //End Greeting Character Test
		 });
	
//// TAP CONVERSATION TESTER TEST

test("Tap Conversation Tester", function(target, app) {
	
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
	
	
	test("Testing regular scripts", function(target,app){
		 
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
	
	// Panoramic Tag  == This is funky , it exited me.
		
	// End Normal Script Tests
	});
	
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
		 
		 //End EXIT TO SCRIPTS
		 });


	
};

