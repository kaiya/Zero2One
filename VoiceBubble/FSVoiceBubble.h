//
//  FSVoiceBubble.h
//  Pods
//
//  Created by Wenchao Ding on 3/25/15.
//
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


@class FSVoiceBubble;

#ifndef IBInspectable
#define IBInspectable
#endif

@protocol FSVoiceBubbleDelegate <NSObject>

- (void)voiceBubbleDidStartPlaying:(FSVoiceBubble *)voiceBubble;
- (void)showResultVC;
- (void)recognizeDidFinishWithResult:(NSString *) recognizeResult;

@end

@interface FSVoiceBubble : UIView<IFlySpeechRecognizerDelegate>
{
    IFlySpeechRecognizer *_iflySpeechRecognizer;
}

@property (strong, nonatomic) NSURL *contentURL;
@property (strong, nonatomic) NSData *myAudioData;
@property (strong, nonatomic) NSString *result;
@property (strong, nonatomic) IBInspectable UIColor *textColor;
@property (strong, nonatomic) IBInspectable UIColor *waveColor;
@property (strong, nonatomic) IBInspectable UIColor *animatingWaveColor;
@property (strong, nonatomic) IBInspectable UIImage *bubbleImage;
@property (assign, nonatomic) IBInspectable BOOL    invert;
@property (assign, nonatomic) IBInspectable BOOL    exclusive;
@property (assign, nonatomic) IBInspectable BOOL    durationInsideBubble;
@property (assign, nonatomic) IBInspectable CGFloat waveInset;
@property (assign, nonatomic) IBInspectable CGFloat textInset;
@property (assign, nonatomic) IBOutlet id<FSVoiceBubbleDelegate> delegate;

@property (readonly, getter=isPlaying) BOOL playing;

- (void)play;
- (void)pause;
- (void)stop;
- (void) recognize:(UILongPressGestureRecognizer *) gestureRecognizer;

- (void)startAnimating;
- (void)stopAnimating;

@end

