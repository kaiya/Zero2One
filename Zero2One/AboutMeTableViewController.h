//
//  AboutMeTableViewController.h
//  Zero2One
//
//  Created by K.Yawn Xoan on 4/23/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "myProfileTableViewController.h"
#import "SVProgressHUD.h"

@interface AboutMeTableViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *aboutMeNameLabel;
@property (nonatomic) UIImageView *showPhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *showUserNameLabel;

@end
