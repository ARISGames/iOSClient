//
//  ARISUploader.m
//  ARIS
//
//  Created by Garrett Smith on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ARISUploader.h"
#import "zlib.h"
#import "AppModel.h"
#import "AppServices.h"

static NSString * const BOUNDRY = @"0xKhTmLbOuNdArY";

@interface ARISUploader()
{
    id __unsafe_unretained delegate;
}

- (void) uploadSucceeded:(BOOL)success;
- (NSURLRequest *) postRequestWithURL:(NSURL *)url boundry:(NSString *)boundry fileUrl:(NSURL *)aFileURLtoUpload;

@end

@implementation ARISUploader

@synthesize userInfo;
@synthesize responseString;
@synthesize error;

- (id) initWithURLToUpload:(NSURL*)aUrlToUpload gameSpecific:(BOOL)aGame delegate:(id)aDelegate doneSelector:(SEL)aDoneSelector errorSelector:(SEL)anErrorSelector
{
    if ((self = [super init]))
    {
        serverURL = [[AppModel sharedAppModel].serverURL URLByAppendingPathComponent:[NSString stringWithFormat:@"services/%@/uploadHandler.php",kARISServerServicePackage]];
        urlToUpload = aUrlToUpload;
        delegate = aDelegate;
        doneSelector = aDoneSelector;
        errorSelector = anErrorSelector;
        game = aGame;
    }
    return self;
}

- (void) upload
{
    NSURLRequest *urlRequest = [self postRequestWithURL:serverURL boundry:BOUNDRY fileUrl:urlToUpload];
    
    if(!urlRequest){ [self uploadSucceeded:NO]; return; }
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    if(!connection){ [self uploadSucceeded:NO]; return; }
    
    // Now wait for the URL connection to call us back.
}

- (void)dealloc
{
    serverURL = nil;
    urlToUpload = nil;
    delegate = nil;
    doneSelector = NULL;
    errorSelector = NULL;
}

- (NSURLRequest *) postRequestWithURL:(NSURL *)url boundry:(NSString *)boundry fileUrl:(NSURL *)aFileURLtoUpload;
{
    // from http://www.cocoadev.com/index.pl?HTTPFileUpload
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundry] forHTTPHeaderField:@"Content-Type"];
    
    NSData *data = [NSData dataWithContentsOfURL:aFileURLtoUpload];
    NSMutableData *postData = [NSMutableData dataWithCapacity:[data length] + 512];
    [postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:[@"Content-Disposition: form-data; name=\"path\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	if(game) [postData appendData:[[NSString stringWithFormat:@"\r\n%d\r\n", [AppModel sharedAppModel].currentGame.gameId] dataUsingEncoding:NSUTF8StringEncoding]];
    else     [postData appendData:[@"\r\nplayer\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[[NSString stringWithFormat:@"--%@\r\n",boundry] dataUsingEncoding:NSUTF8StringEncoding]];
		    
    //The actual file
	[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"ipodfile.%@\"\r\n",aFileURLtoUpload.pathExtension] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[NSData dataWithData:data]];
	[postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundry] dataUsingEncoding:NSUTF8StringEncoding]];
	
    [urlRequest setHTTPBody:postData];
    return urlRequest;
}

- (NSData *) compress:(NSData *)data
{
    if (!data || [data length] == 0)
        return nil;
    
    // zlib compress doc says destSize must be 1% + 12 bytes greater than source.
    uLong destSize = [data length] * 1.001 + 12;
    NSMutableData *destData = [NSMutableData dataWithLength:destSize];
    
    int anError = compress([destData mutableBytes],
                         &destSize,
                         [data bytes],
                         [data length]);
    if (anError != Z_OK) {
        NSLog(@"ARISUploader: compress: zlib error on compress:%d\n", anError);
        return nil;
    }
    
    [destData setLength:destSize];
    return destData;
}

- (void) uploadSucceeded:(BOOL)success
{
    [delegate performSelector:success ? doneSelector : errorSelector
                   withObject:self];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"ARISUploader: connectionDidFinishLoading");
    [self uploadSucceeded:uploadDidSucceed];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)aError
{
    NSLog(@"ARISUploader: connectiondidFailWithError");
    [self uploadSucceeded:NO];
    self.error = aError;
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"ARISUploader: connectiondidReceiveResponse");
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"ARISUploader: connectiondidReceiveData");
    
    NSString *reply = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    
    if ([reply hasPrefix:@"aris"])
    {
        uploadDidSucceed = YES;
        self.responseString = reply;
    }
    else
        NSLog(@"%@",reply);
}

@end
