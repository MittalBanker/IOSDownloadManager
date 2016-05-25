//
//  ViewController.m
//  IOSDownloadManager
//
//  Created by Mittal J. Banker on 24/05/16.
//  Copyright © 2016 digicorp. All rights reserved.
//

#import "ViewController.h"
#import "DownloadManager.h"
#import "DownloadCell.h"
#import "AppDelegate.h"
#import "Download.h"
@interface ViewController () <DownloadManagerDelegate>

@property (strong, nonatomic) DownloadManager *downloadManager;
@property (strong, nonatomic) NSDate *startDate;
@property (nonatomic) NSInteger downloadErrorCount;
@property (nonatomic) NSInteger downloadSuccessCount;

@end;
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    urlDownload = @[@"http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/s72-55482.jpg",@"http://spaceflight.nasa.gov/gallery/images/apollo/apollo10/hires/as10-34-5162.jpg",
                    @"http://spaceflight.nasa.gov/gallery/images/apollo-soyuz/apollo-soyuz/hires/s75-33375.jpg"];
    
    
 
    
    self.downloadManager = [[DownloadManager alloc] initWithDelegate:self];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]  initWithTitle:@"Download" style:UIBarButtonItemStyleDone target:self action:@selector(downloadFiles:)];
}

-(IBAction)downloadFiles:(id)sender{
//    NSURLSession *session = [self backgroundSession];
//    
//    for (NSString *filename in urlDownload)
//    {
//        NSURL *url = [NSURL URLWithString:filename];
//        NSURLSessionTask *downloadTask = [session downloadTaskWithURL:url];
//        [downloadTask resume];
//    }
    self.downloadManager = [[DownloadManager alloc] initWithDelegate:self];
    
    // queue the files to be downloaded
    AppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
    for (NSString *urlString in urlDownload)
    {
        NSString *downloadFilename = [appDelegate.downloadFolder stringByAppendingPathComponent:[urlString lastPathComponent]];
        NSURL *url = [NSURL URLWithString:urlString];
        
        [self.downloadManager addDownloadWithFilename:downloadFilename URL:url];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View delegate and data source methods

// our table view will simply display a list of files being downloaded

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [urlDownload count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DownloadCell";
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
   // Download *download = self.downloadManager.downloads[indexPath.row];
    
    // the name of the file
    
    cell.lblFileName.text = [urlDownload[indexPath.row] lastPathComponent];
    
//    if (download.isDownloading)
//    {
//        // if we're downloading a file turn on the activity indicator
//        
//        if (!cell.activityIndicator.isAnimating)
//            [cell.activityIndicator startAnimating];
//        
//        cell.activityIndicator.hidden = NO;
//        cell.progressView.hidden = NO;
//        
//        [self updateProgressViewForIndexPath:indexPath download:download];
//    }
//    else
//    {
//        // if not actively downloading, no spinning activity indicator view nor file download progress view is needed
//        
//        [cell.activityIndicator stopAnimating];
//        cell.activityIndicator.hidden = YES;
//        cell.progressView.hidden = YES;
//    }
//    
    return cell;
}

#pragma mark - TABLE VIEW METHODS

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  65;
}

#pragma mark - Table view utility methods

- (void)updateProgressViewForIndexPath:(NSIndexPath *)indexPath download:(Download *)download
{
    DownloadCell *cell = (DownloadCell *)[tblDownloads cellForRowAtIndexPath:indexPath];
    
    // if the cell is not visible, we can return
    
    if (!cell)
        return;
    
    if (download.expectedContentLength >= 0)
    {
        // if the server was able to tell us the length of the file, then update progress view appropriately
        // to reflect what % of the file has been downloaded
        
       cell.progressView.progress = (double) (download.progressContentLength ) ;
    }
    else
    {
        // if the server was unable to tell us the length of the file, we'll change the progress view, but
        // it will just spin around and around, not really telling us the progress of the complete download,
        // but at least we get some progress update as bytes are downloaded.
        //
        // This progress view will just be what % of the current megabyte has been downloaded
        
        cell.progressView.progress = (double) (download.progressContentLength ) ;
    }
}



- (NSURLSession *)backgroundSession
{
    static NSURLSession *session = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"kBackgroundId"];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    });
    return session;
}




- (void)downloadManager:(DownloadManager *)downloadManager downloadDidFinishLoading:(Download *)download;
{
    self.downloadSuccessCount++;
    
   // [self.tblDownloads reloadData];
}

// optional method to indicate that individual download failed
//
// In this view controller, I'll keep track of a counter for entertainment purposes and update
// tableview that's showing a list of the current downloads.

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidFail:(Download *)download;
{
    NSLog(@"%s %@ error=%@", __FUNCTION__, download.filename, download.error);
    
    self.downloadErrorCount++;
    
    //[self.tblDownloads reloadData];
}

// optional method to indicate progress of individual download
//
// In this view controller, I'll update progress indicator for the download.

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidReceiveData:(Download *)download;
{
    for (NSInteger row = 0; row < [downloadManager.downloads count]; row++)
    {
        if (download == downloadManager.downloads[row])
        {
            NSLog(@"download url %@",download.url);
            
            DownloadCell *cell = [tblDownloads cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
           
            cell.progressView.progress = (double) (download.progressContentLength ) ;
            //[self updateProgressViewForIndexPath:[NSIndexPath indexPathForRow:row inSection:0] download:download];
            break;
        }
    }
}


@end
