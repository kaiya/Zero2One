//
//  KYAudioRecorderController.h
//  Zero2One
//
//  Created by K.Yawn Xoan on 4/22/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//
#import <UIKit/UIKit.h>

@class KYAudioRecorderController;

@protocol KYAudioRecorderControllerDelegate <UINavigationControllerDelegate>

-(void)audioRecorderController:(KYAudioRecorderController*)controller didFinishWithAudioAtPath:(NSString*)filePath;
-(void)audioRecorderControllerDidCancel:(KYAudioRecorderController*)controller;

@end


@interface KYAudioRecorderController : UINavigationController

@property(nonatomic, weak) id<KYAudioRecorderControllerDelegate,UINavigationControllerDelegate> delegate;

@end
