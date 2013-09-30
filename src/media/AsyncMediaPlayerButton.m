//
//  AsyncMediaPlayerButton.m
//  ARIS
//
//  Created by David Gagnon on 2/4/12.
//  Copyright (c) 2012 University of Wisconsin. All rights reserved.
//

#import "AsyncMediaPlayerButton.h"
#import "Media.h"
#import "ARISMoviePlayerViewController.h"
#import "AppModel.h"
#import "UIImage+Scale.h"

@interface AsyncMediaPlayerButton()
{
    BOOL hasStartedLoading;
    Media *media;
    ARISMoviePlayerViewController *mMoviePlayer;
    
    ARISViewController *presenter;
    id<AsyncMediaPlayerButtonDelegate> __unsafe_unretained delegate;
}

@property (nonatomic) Media *media;
@property (nonatomic) ARISMoviePlayerViewController *mMoviePlayer;

@end

@implementation AsyncMediaPlayerButton

@synthesize media;
@synthesize mMoviePlayer;


- (id) initWithFrame:(CGRect)frame mediaId:(int)mediaId presenter:(ARISViewController *)p preloadNow:(BOOL)preload
{
    return [self initWithFrame:frame mediaId:[[AppModel sharedAppModel] mediaForMediaId:mediaId ofType:nil] presenter:p preloadNow:preload];
}

- (id) initWithFrame:(CGRect)frame media:(Media *)aMedia presenter:(ARISViewController *)p preloadNow:(BOOL)preload
{
    if(self = [super initWithFrame:frame])
    {
        presenter = p;
        self.media = aMedia;
        hasStartedLoading = NO;
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self setImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [self setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [self addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
        
        if(self.media.image)
            [self setBackgroundImage:[[UIImage imageWithData: self.media.image] scaleToSize:self.frame.size] forState:UIControlStateNormal];
        
        if([media.type isEqualToString:@"VIDEO"])
        {
            self.mMoviePlayer = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:media.url]];
            self.mMoviePlayer.moviePlayer.shouldAutoplay = NO;
            [self.mMoviePlayer.moviePlayer requestThumbnailImagesAtTimes:[NSArray arrayWithObject:[NSNumber numberWithFloat:1.0f]] timeOption:MPMovieTimeOptionNearestKeyFrame];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieThumbDidFinish:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:self.mMoviePlayer.moviePlayer];
        }
        else if([media.type isEqualToString:@"AUDIO"])
        {
            self.mMoviePlayer = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:media.url]];
            self.mMoviePlayer.moviePlayer.shouldAutoplay = NO;
            self.media.image = UIImageJPEGRepresentation([UIImage imageNamed:@"microphoneBackground.jpg"], 1.0);
            [self setBackgroundImage:[[UIImage imageNamed:@"microphoneBackground.jpg"] scaleToSize:self.frame.size] forState:UIControlStateNormal];
        }
        
        if(preload) [self attemptLoadingContent];
    }
    return self;
}

- (void) attemptLoadingContent
{
    if(hasStartedLoading) return;
    hasStartedLoading = YES;
    
    [self.mMoviePlayer.moviePlayer prepareToPlay];
}

- (void) movieThumbDidFinish:(NSNotification*)notification
{
    self.media.image = UIImageJPEGRepresentation([notification.userInfo objectForKey:MPMoviePlayerThumbnailImageKey], 1.0);
    NSError *error = [notification.userInfo objectForKey:MPMoviePlayerThumbnailErrorKey];
    
    if(error)
        NSLog(@"MPMoviePlayerThumbnail ERROR: %@",error);
    else
        [self setBackgroundImage:[[UIImage imageWithData:self.media.image] scaleToSize:self.frame.size] forState:UIControlStateNormal];
}

- (void) playMovie:(id)sender
{
    [self attemptLoadingContent];
    
    [presenter presentMoviePlayerViewControllerAnimated:self.mMoviePlayer];
    [self.mMoviePlayer.moviePlayer play];
}

- (void) dealloc
{
    if(self.mMoviePlayer) [self.mMoviePlayer.moviePlayer cancelAllThumbnailImageRequests];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
