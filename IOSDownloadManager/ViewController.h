//
//  ViewController.h
//  IOSDownloadManager
//
//  Created by Mittal J. Banker on 24/05/16.
//  Copyright © 2016 digicorp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,NSURLSessionDelegate,NSURLSessionDataDelegate>{
    
    NSArray *urlDownload;
    IBOutlet UITableView *tblDownloads;
}


@end

