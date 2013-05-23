//
//  NoteContentCell.m
//  ARIS
//
//  Created by Brian Thiel on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NoteContentCell.h"
#import "NoteContent.h"
#import "AppModel.h"
#import "AppServices.h"

@interface NoteContentCell() <UITextViewDelegate>
{
    NoteContent *content;

    IBOutlet UIButton *retryButton;
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UITextView *titleLbl;
    IBOutlet UILabel *detailLbl;
    IBOutlet UILabel *holdLbl;
    IBOutlet UIImageView *imageView;
    NSIndexPath *indexPath;
    
    id<NoteContentCellDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) NoteContent *content;

@property (nonatomic, strong) IBOutlet UIButton *retryButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) IBOutlet UITextView *titleLbl;
@property (nonatomic, strong) IBOutlet UILabel *detailLbl;
@property (nonatomic, strong) IBOutlet UILabel *holdLbl;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) NSIndexPath *indexPath;

- (IBAction) retryUpload;

@end

@implementation NoteContentCell

@synthesize content;
@synthesize retryButton;
@synthesize spinner;
@synthesize titleLbl;
@synthesize detailLbl;
@synthesize holdLbl;
@synthesize imageView;
@synthesize indexPath;

- (void) awakeFromNib
{
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(holdTextBox:)];
    [holdLbl addGestureRecognizer:gesture];
    [self.titleLbl setUserInteractionEnabled:NO];
}

- (void) setupWithNoteContent:(NoteContent *)nc delegate:(id<NoteContentCellDelegate>)d
{
    self.content = nc;
    delegate = d;
    
    
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    
    self.titleLbl.text = [self.content.getTitle substringToIndex:24];
    
    if([[self.content getType] isEqualToString:@"TEXT"])
    {
        self.imageView.image = [UIImage imageNamed:@"noteicon.png"];
        self.detailLbl.text = self.content.getText;
    }
    else if([[self.content getType] isEqualToString:@"PHOTO"])
    {
        [self addSubview:[[AsyncMediaImageView alloc] initWithFrame:self.imageView.frame andMedia:self.content.getMedia]];
    }
    else if([[self.content getType] isEqualToString:@"AUDIO"] ||
            [[self.content getType] isEqualToString:@"VIDEO"])
    {
        AsyncMediaImageView *aView = [[AsyncMediaImageView alloc] initWithFrame:self.imageView.frame andMedia:self.content.getMedia];
        UIImageView *overlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_button.png"]];
        overlay.frame = CGRectMake(aView.frame.origin.x, aView.frame.origin.y, aView.frame.size.width/2, aView.frame.size.height/2);
        overlay.center = aView.center;
        
        //overlay.alpha = .6;
        [self addSubview:aView];
        [self addSubview:overlay];
    }
    
    self.titleLbl.text = self.content.getTitle;
    
    [self checkForRetry];
}

-(void)checkForRetry
{
    if(![self.content respondsToSelector:@selector(getUploadState)] || ![[self.content getUploadState] isEqualToString:@"uploadStateDONE"])
    {
        retryButton.hidden = NO;
        self.titleLbl.userInteractionEnabled = NO;
        self.holdLbl.userInteractionEnabled = NO;
        [self.titleLbl setFrame:CGRectMake(65, 4, 147, 30)];
        self.titleLbl.hidden = YES;
        if([[(UploadContent *)self.content getUploadState] isEqualToString:@"uploadStateFAILED"])
        {
            [self.retryButton setBackgroundImage:[UIImage imageNamed:@"blue_button.png"] forState:UIControlStateNormal];
            self.retryButton.userInteractionEnabled = YES;
            [self.retryButton setTitle: @"Retry" forState: UIControlStateNormal];
            self.retryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            [self.retryButton setFrame:CGRectMake(228, 15, 80, 30)];
            [spinner stopAnimating];
            spinner.hidden = YES;
        }
        else if([[self.content getUploadState] isEqualToString:@"uploadStateQUEUED"])
        {
            [self.retryButton setBackgroundImage:[UIImage imageNamed:@"grey_button.png"] forState:UIControlStateNormal];
            [self.retryButton setTitle: @"  Waiting" forState: UIControlStateNormal];
            [self.retryButton setFrame:CGRectMake(208, 15, 100, 30)];
            self.retryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            self.retryButton.userInteractionEnabled = NO;
            [spinner startAnimating];
            spinner.hidden = NO;
        }
        else
        {
            [self.retryButton setBackgroundImage:[UIImage imageNamed:@"grey_button.png"] forState:UIControlStateNormal];
            [self.retryButton setTitle: @"  Uploading" forState: UIControlStateNormal];
            [self.retryButton setFrame:CGRectMake(187, 15, 121, 30)];
            self.retryButton.userInteractionEnabled = NO;
            
            [spinner startAnimating];
            spinner.hidden = NO;
            self.retryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
    }
    else
    {
        self.titleLbl.hidden = NO;
        self.titleLbl.userInteractionEnabled = YES;
        self.holdLbl.userInteractionEnabled = YES;
        
        retryButton.hidden = YES;
        [self.titleLbl setFrame:CGRectMake(65, 4, 235, 30)];
        [spinner stopAnimating];
        spinner.hidden = YES;
    }
}

- (void) retryUpload
{    
    retryButton.hidden = YES;
    [self.titleLbl setFrame:CGRectMake(65, 4, 235, 30)];
    [spinner startAnimating];
    spinner.hidden = NO;
    NSLog(@"Deleting Upload forNoteId:%d withFileURL:%@",self.content.getNoteId,self.content.getMedia.url);
    [[AppModel sharedAppModel].uploadManager uploadContentForNoteId:self.content.getNoteId withTitle:self.content.getTitle withText:self.content.getText withType:self.content.getType withFileURL:[NSURL URLWithString:self.content.getMedia.url]];
    NSLog(@"Retrying Upload forNoteId:%d withTitle:%@ withText:%@ withType:%@ withFileURL:%@",self.content.getNoteId,self.content.getTitle,self.content.getText,self.content.getType,self.content.getMedia.url);
    [self checkForRetry];
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
}

- (BOOL) textViewShouldEndEditing:(UITextView *)textView
{
    [delegate cellFinishedEditing:self];
    return YES;
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];  
        [self.content setTitle:textView.text];
        [[AppServices sharedAppServices] updateNoteContent:self.content.contentId title:textView.text];
        
        return NO;
    }
    if([textView.text length] > 24) textView.text = [textView.text substringToIndex:24];
    return YES;
}

- (void) holdTextBox:(UIPanGestureRecognizer *) gestureRecognizer
{    
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStatePossible || gestureRecognizer.state == UIGestureRecognizerStateRecognized)
    {
        [self.titleLbl setEditable:YES];
        [self.titleLbl becomeFirstResponder];
        [delegate cellStartedEditing:self];
    }
    else
        [self.titleLbl setUserInteractionEnabled:NO];
}

@end
