//
//  DataCollectionViewController.h
//  ARIS
//
//  Created by Brian Thiel on 8/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DataCollectionViewController : UIViewController {
    IBOutlet UIButton *cameraButton;
    IBOutlet UIButton *videoButton;
    IBOutlet UIButton *audioButton;
    IBOutlet UIButton *noteButton;
    id delegate;
}

@property(nonatomic,retain)IBOutlet UIButton *cameraButton;
@property(nonatomic,retain)IBOutlet UIButton *videoButton;
@property(nonatomic,retain)IBOutlet UIButton *audioButton;
@property(nonatomic,retain)IBOutlet UIButton *noteButton;
@property(nonatomic, retain) id delegate;

-(IBAction)cameraButtonTouchAction;
-(IBAction)videoButtonTouchAction;
-(IBAction)audioButtonTouchAction;
-(IBAction)noteButtonTouchAction;

@end
