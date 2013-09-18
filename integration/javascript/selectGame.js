var selectGame = function(gameName){
	
	
	test("Selecting Game", function(target,app) {
	
	//Tap the Game
	window.tableViews()["Empty list"].cells()["ARIS-Tester, 0.0 km, 1 reviews, econtreras"].tap();
		
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
	
		//end tuneupjs "test"
		 });
	
	//end function
	};
