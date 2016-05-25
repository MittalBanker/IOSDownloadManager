//
//  Download.m
//  IOSDownloadManager
//
//  Created by Mittal J. Banker on 24/05/16.
//  Copyright © 2016 digicorp. All rights reserved.
//

#import "Download.h"
#import "AppDelegate.h"

@implementation Download

#pragma mark - Public methods

- (instancetype)initWithFilename:(NSString *)filename URL:(NSURL *)url delegate:(id<DownloadDelegate>)delegate
{
    self = [super init];
    
    if (self) {
        _filename = [filename copy];
        _url = [url copy];
        _delegate = delegate;
    }
    
    return self;
}

- (void)start
{
    NSURLSession *session = [self backgroundSession];
  //  NSURL *url = [NSURL URLWithString:_filename];
//    NSURL *url = [NSURL URLWithString:
//                  [[_filename stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]
//                   stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    NSURLSessionTask *downloadTask = [session downloadTaskWithURL:_url];
    [downloadTask resume];
    
    
    
    
}


- (NSURLSession *)backgroundSession
{
    static NSURLSession *session = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"backgroundSession"];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    });
    return session;
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSString *documentsPath    = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSLog(documentsPath);
    NSString *finalPath        = [documentsPath stringByAppendingPathComponent:[[[downloadTask originalRequest] URL] lastPathComponent]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL success;
    NSError *error;
    if ([fileManager fileExistsAtPath:finalPath]==TRUE) {
        success = [fileManager removeItemAtPath:finalPath error:&error];
        NSAssert(success, @"removeItemAtPath error: %@", error);
    }
   // if ([fileManager fileExistsAtPath:[location absoluteString]]==TRUE) {
        
    success = [fileManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:finalPath] error:&error];
   // }
    //NSAssert(success, @"moveItemAtURL error: %@", error);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
    // Update your UI if you want to
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
    if (totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown) {
        NSLog(@"Unknown transfer size");
    }
    else{
        self.progressContentLength  = (double)totalBytesWritten *1.0/(double)totalBytesExpectedToWrite;
        NSLog(@"%f",self.progressContentLength);
        if ([self.delegate respondsToSelector:@selector(downloadDidReceiveData:)])
            [self.delegate downloadDidReceiveData:self];
    }
    
    
    
    
}



- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error)
        NSLog(@"%s: %@", __FUNCTION__, error);
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSLog(@"%s: %@", __FUNCTION__, error);
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    AppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
}

@end
