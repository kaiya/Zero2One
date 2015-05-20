//
//  LoginTableViewController.h
//  Zero2One
//
//  Created by K.Yawn Xoan on 4/25/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"

@interface LoginTableViewController : UITableViewController


@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtnOutlet;



- (void)textEditingEnd:(id)sender;
- (void)shakeAnimationForView:(UIView *) view;
@end
