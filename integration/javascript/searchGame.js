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