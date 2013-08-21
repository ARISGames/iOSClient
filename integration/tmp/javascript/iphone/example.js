#import ../example_js.js
var target, window;

target = UIATarget.localTarget();

window = target.frontMostApp().mainWindow();
