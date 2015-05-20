//
//  ConsoleTableViewController.h
//  Zero2One
//
//  Created by K.Yawn Xoan on 5/14/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SVProgressHUD.h"

@interface ConsoleTableViewController : UITableViewController{
    //recorder
    AVAudioRecorder *recorder;
    //player
    AVAudioPlayer *player;
    NSDictionary *recorderSettingsDict;;
    //Timer
    NSTimer *timer;
    //images
    NSMutableArray *volumImages;
    double lowPassResults;
    //recordingFilePath
    NSString *recordingFilePath;
//    NSString *fileLocation;
    NSString *fileName;
    NSString *docDir;
}

@property(strong, nonatomic) UIToolbar *toolbar;
@property(strong, nonatomic) UIButton *recordBtn;
@property(strong, nonatomic) NSString  *ourDocumentPath;
@property(strong, nonatomic) NSUserDefaults *UserDefault;
@property(strong, nonatomic) NSMutableArray *fileNameArray;
@end
