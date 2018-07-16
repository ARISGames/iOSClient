//
//  ARISMediaURLProtocol.m
//  ARIS
//
//  Created by Michael Tolly on 7/16/18.
//

#import <Foundation/Foundation.h>
#import "ARISMediaURLProtocol.h"
#import "Media.h"
#import "AppModel.h"
#import "AppServices.h"
#import "ARISMediaLoader.h"

@interface ARISMediaURLProtocol() <ARISMediaLoaderDelegate>
{
}

@end

@implementation ARISMediaURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest*)theRequest
{
  if ([theRequest.URL.scheme caseInsensitiveCompare:@"arismedia"] == NSOrderedSame) {
    return YES;
  }
  return NO;
}

+ (NSURLRequest*)canonicalRequestForRequest:(NSURLRequest*)theRequest
{
  return theRequest;
}

- (void)startLoading
{
  NSLog(@"loading ARIS media URL: %@", self.request.URL);
  long media_id = [self.request.URL.host intValue];
  NSLog(@"loading ARIS media ID: %ld", media_id);
  Media *media = [_MODEL_MEDIA_ mediaForId:media_id];
  ARISDelegateHandle *selfDelegateHandle = [[ARISDelegateHandle alloc] initWithDelegate:self];
  [_SERVICES_MEDIA_ loadMedia:media delegateHandle:selfDelegateHandle]; //calls 'mediaLoaded' upon complete
}

- (void)mediaLoaded:(Media *)m {
  NSURLResponse *response = [[NSURLResponse alloc] initWithURL:self.request.URL
                                                      MIMEType:[m mimeType]
                                         expectedContentLength:[[m data] length]
                                              textEncodingName:nil];
  
  [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
  [[self client] URLProtocol:self didLoadData:[m data]];
  [[self client] URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{
  // ideally, should cancel loading the media here
}

@end
