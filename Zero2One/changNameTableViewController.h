//
//  changNameTableViewController.h
//  Zero2One
//
//  Created by K.Yawn Xoan on 4/24/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"

@interface changNameTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) NSString *string;

@property (weak) id delegate;

@end
@protocol passNameValue <NSObject>

- (void)passValue:(NSString *) value;


@end
