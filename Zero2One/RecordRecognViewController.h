//
//  RecordRecognViewController.h
//  Zero2One
//
//  Created by K.Yawn Xoan on 4/23/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "iflyMSC/IFlySpeechRecognizerDelegate.h"
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "KYAudioRecorderController.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <CoreMedia/CoreMedia.h>
#import "SVProgressHUD.h"


@interface RecordRecognViewController : UIViewController<UIActionSheetDelegate,MFMailComposeViewControllerDelegate,KYAudioRecorderControllerDelegate,IFlySpeechRecognizerDelegate>
{
    IFlySpeechRecognizer *_iflySpeechRecognizer;
}
@property (weak, nonatomic) IBOutlet UITextView     *resultTextField;
@property(nonatomic, strong) NSString               *recordedFilePath;
@property(nonatomic, strong) NSString               *result;
@property(weak, nonatomic) NSArray                  *contactsArray;
@property(weak, nonatomic) NSArray                  *contactsUserName;

@end
