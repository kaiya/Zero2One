//
//  ContactsViewController.h
//  Zero2One
//
//  Created by K.Yawn Xoan on 4/23/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"
#import "AsyncSocket.h"
#import <QuartzCore/QuartzCore.h>



@interface ContactsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,AsyncSocketDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView1;
@property(weak, nonatomic) NSArray *contactsArray;
@property(weak, nonatomic) NSArray *contactsUserName;
@property(strong, nonatomic) AsyncSocket *socket;
@property(strong, nonatomic) NSString *partner;
@property (strong, nonatomic) UIAlertView *partnerAlertView;
@property (strong, nonatomic) UIAlertView *readDataAlertView;

@end
