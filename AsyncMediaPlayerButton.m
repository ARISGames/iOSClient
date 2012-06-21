//
//  AsyncMediaPlayerButton.m
//  ARIS
//
//  Created by David Gagnon on 2/4/12.
//  Copyright (c) 2012 University of Wisconsin. All rights reserved.
//

#import "AsyncMediaPlayerButton.h"
#import "AppModel.h"
#import "UIImage+Scale.h"
BOOL isLoading;

@implementation AsyncMediaPlayerButton

@synthesize media;
@synthesize mMoviePlayer;
@synthesize presentingController;

-(id)initWithFrame:(CGRect)frame media:(Media *)aMedia presentingController:(UIViewController *)aPresentingController{
    self.media = aMedia;
   return [self initWithFrame:frame mediaId:[aMedia.uid intValue] presentingController:aPresentingController];
}

-(id)initWithFrame:(CGRect)frame mediaId:(int)mediaId presentingController:(UIViewController*)aPresentingController{    
    NSLog(@"AsyncMoviePlayerButton: initWithFrame,mediaId,presentingController");
    
    if (self = [super initWithFrame:frame]) {
        NSLog(@"AsyncMoviePlayerButton: super init successful");
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.presentingController = aPresentingController;
        if(!self.media)
        self.media = [[AppModel sharedAppModel] mediaForMediaId:mediaId];
        
        //Create movie player object
        if(!mMoviePlayer){
            mMoviePlayer = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:media.url]];
        }
        else{
            ARISMoviePlayerViewController *mMoviePlayerAlloc = [self.mMoviePlayer initWithContentURL:[NSURL URLWithString: media.url]]; 
            self.mMoviePlayer = mMoviePlayerAlloc; 
        }
        
        self.mMoviePlayer.moviePlayer.shouldAutoplay = NO;
        [self.mMoviePlayer.moviePlayer prepareToPlay];
        
        [self setImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [self setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [self addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
        
        //Load the background
        if (self.media.image) {
            NSLog(@"AsyncMoviePlayerButton: init: thumbnail was in media.image cache");
            UIImage *videoThumbSized = [[UIImage imageWithData: self.media.image] scaleToSize:self.frame.size];        
            [self setBackgroundImage:videoThumbSized forState:UIControlStateNormal];
        }
        
        else if ([media.type isEqualToString:kMediaTypeVideo]){
          //  if(!isLoading){
            NSLog(@"AsyncMoviePlayerButton: fetching thumbnail for a video ");
          //  isLoading = YES;
            NSNumber *thumbTime = [NSNumber numberWithFloat:1.0f];
            NSArray *timeArray = [NSArray arrayWithObject:thumbTime];
            [self.mMoviePlayer.moviePlayer requestThumbnailImagesAtTimes:timeArray timeOption:MPMovieTimeOptionNearestKeyFrame];
            
            NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
            [dispatcher addObserver:self selector:@selector(movieThumbDidFinish:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:mMoviePlayer.moviePlayer];
          //  }
        }
        else if ([media.type isEqualToString:kMediaTypeAudio]){
            self.media.image = UIImageJPEGRepresentation([UIImage imageNamed:@"microphoneBackground.jpg"], 1.0);
            UIImage *videoThumbSized = [[UIImage imageNamed:@"microphoneBackground.jpg"] scaleToSize:self.frame.size];        
            [self setBackgroundImage:videoThumbSized forState:UIControlStateNormal];
        }
    }
    NSLog(@"AsyncMoviePlayerButton: init complete");
    
    return self;
}    


-(void)movieThumbDidFinish:(NSNotification*) aNotification
{
    NSLog(@"AsyncMoviePlayerButton: movieThumbDidFinish");
    NSDictionary *userInfo = aNotification.userInfo;
    self.media.image = UIImageJPEGRepresentation([userInfo objectForKey:MPMoviePlayerThumbnailImageKey], 1.0);
    NSError *e = [userInfo objectForKey:MPMoviePlayerThumbnailErrorKey];
    
    UIImage *videoThumbSized = [[UIImage imageWithData:self.media.image] scaleToSize:self.frame.size];        
    [self setBackgroundImage:videoThumbSized forState:UIControlStateNormal];
    
    
    if (e) {
        NSLog(@"MPMoviePlayerThumbnail ERROR: %@",e);
    }
    
   // isLoading = NO;
}

-(void)playMovie:(id)sender {
    NSLog(@"AsyncMoviePlayerButton: Pressed");
    
    if (self.presentingController && [self.presentingController respondsToSelector:@selector(presentMoviePlayerViewControllerAnimated:)]){
        [self.presentingController presentMoviePlayerViewControllerAnimated:mMoviePlayer];
    }
    [self.mMoviePlayer.moviePlayer play];
}

- (void)dealloc {
    NSLog(@"AsyncMediaPlayerButton: Dealloc");
    if(mMoviePlayer != nil){
    [mMoviePlayer.moviePlayer cancelAllThumbnailImageRequests];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}





@end
