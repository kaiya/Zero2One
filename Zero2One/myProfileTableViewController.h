//
//  myProfileTableViewController.h
//  Zero2One
//
//  Created by K.Yawn Xoan on 4/24/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "changNameTableViewController.h"

@interface myProfileTableViewController : UITableViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,passNameValue>

@property (nonatomic) UIImageView *photoImageVIew;
@property (nonatomic) IBOutlet UILabel *showNameLabel;
@property (nonatomic, weak) NSString *string;
@property (weak) id delegate;

@end

