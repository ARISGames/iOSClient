/// This JS script tests the UI Elements and Accessibility tags for the ARIS game "Game-Tester"

// Line below is what Bwoken uses, no need to download Tuneup.js in advance
// #github "alexvollmer/tuneup_js/tuneup.js"

//import tuneup.js library relative to the script location
#import "tuneup_js/tuneup.js"

//Reset User if Already Logged in
#import "resetUser.js"

//Simulating Login
#import "login.js"

//Searching for Game
#import "searchGame.js"

//Select Game
#import "selectGame.js"

//In Game play
#import "ARIS-Tester.js"

//Alert Handler
#import "alertHandler.js"

//Reset user from in game
#import "resetFromInsideGame.js"

/////Variables
var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();
target.logElementTree();

var username = "aris-test";
var password = "aris";
var gameName = "ARIS-Tester";


/////Main//
resetUser();
loginTest(username, password);
searchGame(gameName);
selectGame();
inGame();
reset();

