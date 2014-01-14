//
//  NoteRecorderViewController.h
//  AudioDemo
//
//  Created by Brian Deith on 3/18/10.
//  Copyright Dept. of Awesome - University of Wisconsin - Madison 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NoteRecorderViewControllerDelegate
- (void) audioChosenWithURL:(NSURL *)url;
- (void) recorderViewControllerCancelled;
@end

@interface NoteRecorderViewController : UIViewController
- (id) initWithDelegate:(id<NoteRecorderViewControllerDelegate>)d;
@end
