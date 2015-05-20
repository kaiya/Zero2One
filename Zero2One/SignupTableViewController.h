//
//  SignupTableViewController.h
//  Zero2One
//
//  Created by K.Yawn Xoan on 4/26/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"

@interface SignupTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signupBtnOutlet;

@end
