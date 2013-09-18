var loginTest = function(username,password){
	
	//This is a tuneup_js test
	test("Login Screen", function(target, app){
		 
		//////////////// MAKING ASSERTIONS
		 
		//Check "Create Account" Message
		UIALogger.logMessage("Check 'Create Account' Message");
		assertEquals("Create Account", window.buttons()["Create Account"].name());
		 
		 
		//Check "Forgot Password" Button
		UIALogger.logMessage("Check 'Forgot Password?' Message");
		assertEquals("Forgot Password?",window.buttons()["Forgot Password?"].name());
		 
		
		//////////////// LOGGING IN
		 
		 
		//TYPE USERNAME
		//window.textFields()["usernameField"].tap();
		window.textFields()[0].tap();
		app.keyboard().typeString(username + "\n");
			
		// TYPE PASSWORD
		//window.secureTextFields()["passwordField"].tap();
		window.secureTextFields()[0].tap();
		app.keyboard().typeString(password);
	
		// CLICK LOGIN
		window.buttons()["arrowForward"].tap();
		});
	
};
