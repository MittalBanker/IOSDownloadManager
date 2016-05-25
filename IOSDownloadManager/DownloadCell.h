//
//  IOSDownloadTableViewCell.h
//  IOSDownloadManager
//
//  Created by Mittal J. Banker on 24/05/16.
//  Copyright © 2016 digicorp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadCell : UITableViewCell
{
    
}
@property(strong) IBOutlet UILabel *lblFileName;
@property(strong) IBOutlet UIProgressView *progressView;
@property(strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
