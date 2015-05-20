//
//  showResultViewController.h
//  Zero2One
//
//  Created by K.Yawn Xoan on 5/20/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "SVProgressHUD.h"

@interface showResultViewController : UIViewController<UIActionSheetDelegate,MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *showResultTV;

@end
