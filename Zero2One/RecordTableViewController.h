//
//  RecordTableViewController.h
//  Zero2One
//
//  Created by K.Yawn Xoan on 5/13/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"

@interface RecordTableViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>


@property (strong, nonatomic) IBOutlet UITableView *tableView2;
@property(weak, nonatomic) NSArray *contactsArray;
@property(weak, nonatomic) NSArray *contactsUserName;

@end
