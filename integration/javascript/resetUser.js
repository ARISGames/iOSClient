var resetUser = function()
{
	
	

	test("Resetting the User if already logged in.", function(target,app){
	
	
		if (app.navigationBar().buttons()["idcard"].checkIsValid())
		{
			app.navigationBar().buttons()["idcard"].tap();
			window.staticTexts()["Logout"].tap();
			
		}
		 
		 //End Tuneup.js Test
		 });
	
	//End Reset Function
	};