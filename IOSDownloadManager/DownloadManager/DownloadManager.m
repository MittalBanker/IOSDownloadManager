//
//  DownloadManager.m
//  IOSDownloadManager
//
//  Created by Mittal J. Banker on 24/05/16.
//  Copyright © 2016 digicorp. All rights reserved.
//

#import "DownloadManager.h"
#import "Download.h"

@interface DownloadManager () <DownloadDelegate>

@property (nonatomic) BOOL cancelAllInProgress;

@end
#pragma mark - DownloadManager public methods
@implementation DownloadManager
- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _downloads = [[NSMutableArray alloc] init];
        _maxConcurrentDownloads = 4;
    }
    
    return self;
}

- (instancetype)initWithDelegate:(id<DownloadManagerDelegate>)delegate
{
    self = [self init];
    
    if (self) {
        _delegate = delegate;
    }
    
    return self;
}

- (void)addDownloadWithFilename:(NSString *)filename URL:(NSURL *)url
{
    Download *download = [[Download alloc] initWithFilename:filename URL:url delegate:self];
    
    [self.downloads addObject:download];
    
    [self start];
}

- (void)start
{
    [self tryDownloading];
}

- (void)cancelAll
{
    self.cancelAllInProgress = YES;
    
    while ([self.downloads count] > 0) {
        [[self.downloads objectAtIndex:0] cancel];
    }
    
    self.cancelAllInProgress = NO;
    
    [self informDelegateThatDownloadsAreDone];
}

#pragma mark - DownloadDelegate Methods

- (void)downloadDidFinishLoading:(Download *)download
{
//    [self.downloads removeObject:download];
//    
//    if ([self.delegate respondsToSelector:@selector(downloadManager:downloadDidFinishLoading:)]) {
//        [self.delegate downloadManager:self downloadDidFinishLoading:download];
//    }
    
    [self tryDownloading];
}

- (void)downloadDidFail:(Download *)download
{
    [self.downloads removeObject:download];
    
    if ([self.delegate respondsToSelector:@selector(downloadManager:downloadDidFail:)])
        [self.delegate downloadManager:self downloadDidFail:download];
    
    if (!self.cancelAllInProgress) {
        [self tryDownloading];
    }
}

- (void)downloadDidReceiveData:(Download *)download
{
    if ([self.delegate respondsToSelector:@selector(downloadManager:downloadDidReceiveData:)]) {
        [self.delegate downloadManager:self downloadDidReceiveData:download];
    }
}

#pragma mark - Private methods

- (void)informDelegateThatDownloadsAreDone
{
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingAllForManager:)]) {
        [self.delegate didFinishLoadingAllForManager:self];
    }
}

- (void)tryDownloading
{
    NSInteger totalDownloads = [self.downloads count];
    
    // if we're done, inform the delegate
    
    if (totalDownloads == 0) {
        [self informDelegateThatDownloadsAreDone];
        return;
    }
    
    // while there are downloads waiting to be started and we haven't hit the maxConcurrentDownloads, then start
    
//    while ([self countUnstartedDownloads] > 0 && [self countActiveDownloads] < self.maxConcurrentDownloads) {
        for (Download *download in self.downloads) {
            if (!download.isDownloading) {
                [download start];
                break;
            }
        }
    //}
}

- (NSInteger)countUnstartedDownloads
{
    return [self.downloads count] - [self countActiveDownloads];
}

- (NSInteger)countActiveDownloads
{
    NSInteger activeDownloadCount = 0;
    
    for (Download *download in self.downloads) {
        if (download.isDownloading)
            activeDownloadCount++;
    }
    
    return activeDownloadCount;
}

@end
