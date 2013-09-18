//  RESET FROM INSIDE GAME
var reset = function(){
	
	test("Resetting Game", function(target,app) {
	
	app.navigationBar().buttons()["threeLines"].tap();
	target.delay(1);
	window.staticTexts()["Leave Game"].tap();
	target.delay(1);
	app.navigationBar().buttons()["arrowBack"].tap();
		 
	resetUser();
	
		//end Tuneup Test
		});
	//End Reset Function
	};