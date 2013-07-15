var target = UIATarget.localTarget();
target.frontMostApp().tabBar().buttons()["Search"].tap();
target.frontMostApp().mainWindow().buttons()["Cancel"].tap();
target.frontMostApp().tabBar().buttons()["Popular"].tap();
target.frontMostApp().tabBar().buttons()["Recent"].tap();