//
//  Playhead.h
//  ARIS
//
//  Created by Justin Moeller on 7/10/13.
//
//

#import <UIKit/UIKit.h>

@class Playhead;

@protocol PlayheadControlDelegate <NSObject>

-(void)playheadControl:(Playhead *)playhead wasTouched:(NSSet *)touches;
-(float)getPlayProgress;

@end

@interface Playhead : UIControl

@property (assign) id<PlayheadControlDelegate> delegate;

@end
