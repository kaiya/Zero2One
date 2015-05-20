//
//  FSVoiceBubble.m
//  Pods
//
//  Created by Wenchao Ding on 3/25/15.
//
//

#import "FSVoiceBubble.h"
#import "UIImage+FSExtension.h"
#import <AVFoundation/AVFoundation.h>


#define kFSVoiceBubbleShouldStopNotification @"FSVoiceBubbleShouldStopNotification"
#define UIImageNamed(imageName) [[UIImage imageNamed:[NSString stringWithFormat:@"FSVoiceBubble.bundle/%@", imageName]] imageWithRenderingMode:UIImageRenderingModeAutomatic]

@interface FSVoiceBubble () <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) AVURLAsset    *asset;
@property (strong, nonatomic) NSArray       *animationImages;
@property (weak  , nonatomic) UIButton      *contentButton;

- (void)initialize;
- (void)voiceClicked:(id)sender;
- (void)bubbleShouldStop:(NSNotification *)notification;

@end

@implementation FSVoiceBubble

@dynamic bubbleImage, textColor;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    
    
    //init iflySpeechRecognizer
    NSString *initString = [[NSString alloc]initWithFormat:@"appid=%@",@"54ffd80a"];
    [IFlySpeechUtility createUtility:initString];
    
    _iflySpeechRecognizer = [[IFlySpeechRecognizer alloc]init];
    _iflySpeechRecognizer.delegate = self;
    [_iflySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    [_iflySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_STREAM forKey:@"audio_source"];
    
    //initilaize button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImageNamed(@"fs_icon_wave_2") imageWithOverlayColor:self.waveColor]  forState:UIControlStateNormal];
    [button setBackgroundImage:UIImageNamed(@"fs_chat_bubble") forState:UIControlStateNormal];
    [button setTitle:@"0\"" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(voiceClicked:) forControlEvents:UIControlEventTouchUpInside];
    //    [button addTarget:self action:@selector(recognize) forControlEvents:UIControlEventTouchDown];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(recognize:)];
    longPress.minimumPressDuration = 0.8;
    [button addGestureRecognizer:longPress];
    button.backgroundColor                = [UIColor clearColor];
    button.titleLabel.font                = [UIFont systemFontOfSize:12];
    button.adjustsImageWhenHighlighted    = YES;
    button.imageView.animationDuration    = 2.0;
    button.imageView.animationRepeatCount = 30;
    button.imageView.clipsToBounds        = NO;
    button.imageView.contentMode          = UIViewContentModeCenter;
    button.contentHorizontalAlignment     = UIControlContentHorizontalAlignmentRight;
    [self addSubview:button];
    self.contentButton = button;
    
    self.waveColor = [UIColor colorWithRed:0/255.0 green:102/255.0 blue:51/255.0 alpha:1.0];
    self.textColor = [UIColor grayColor];
    
    _animatingWaveColor = [UIColor whiteColor];
    _exclusive = YES;
    _durationInsideBubble = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bubbleShouldStop:) name:kFSVoiceBubbleShouldStopNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFSVoiceBubbleShouldStopNotification object:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _contentButton.frame = self.bounds;
    
    NSString *title = [_contentButton titleForState:UIControlStateNormal];
    if (title && title.length) {
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[_contentButton titleForState:UIControlStateNormal] attributes:attributes];
        _contentButton.imageEdgeInsets = UIEdgeInsetsMake(0,
                                                          -self.bounds.size.width + 50 + _waveInset,
                                                          0,
                                                          self.bounds.size.width - 50 + 25 - attributedString.size.width - _waveInset);
        NSInteger textPadding = _invert ? 2 : 4;
        if (_durationInsideBubble) {
            _contentButton.titleEdgeInsets = UIEdgeInsetsMake(1, -8-_textInset, 0, 8+_textInset);
        } else {
            _contentButton.titleEdgeInsets = UIEdgeInsetsMake(self.bounds.size.height - attributedString.size.height,
                                                              attributedString.size.width + textPadding,
                                                              0,
                                                              -attributedString.size.width - textPadding);
        }
        self.layer.transform = _invert ? CATransform3DMakeRotation(M_PI, 0, 1.0, 0) : CATransform3DIdentity;
        _contentButton.titleLabel.layer.transform = _invert ? CATransform3DMakeRotation(M_PI, 0.0, 1.0, 0.0) : CATransform3DIdentity;
        
    }
}

# pragma mark - Setter & Getter

- (void)setWaveColor:(UIColor *)waveColor
{
    if (![_waveColor isEqual:waveColor]) {
        _waveColor = waveColor;
        [_contentButton setImage:[UIImageNamed(@"fs_icon_wave_2") imageWithOverlayColor:waveColor]  forState:UIControlStateNormal];
    }
}

- (void)setInvert:(BOOL)invert
{
    if (_invert != invert) {
        _invert = invert;
        [self setNeedsLayout];
    }
}

- (void)setBubbleImage:(UIImage *)bubbleImage
{
    [_contentButton setBackgroundImage:bubbleImage forState:UIControlStateNormal];
}

- (void)setTextColor:(UIColor *)textColor
{
    [_contentButton setTitleColor:textColor forState:UIControlStateNormal];
}

- (UIColor *)textColor
{
    return [_contentButton titleColorForState:UIControlStateNormal];
}

- (UIImage *)bubbleImage
{
    return [_contentButton backgroundImageForState:UIControlStateNormal];
}

- (void)setWaveInset:(CGFloat)waveInset
{
    if (_waveInset != waveInset) {
        _waveInset = waveInset;
        [self setNeedsLayout];
    }
}

- (void)setTextInset:(CGFloat)textInset
{
    if (_textInset != textInset) {
        _textInset = textInset;
        [self setNeedsLayout];
    }
}

- (void)setContentURL:(NSURL *)contentURL
{
    if (![_contentURL isEqual:contentURL]) {
        _contentURL = contentURL;
        if (self.isPlaying) {
            [self stop];
        }
        _contentButton.enabled = NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            _asset = [[AVURLAsset alloc] initWithURL:contentURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @YES}];
            CMTime duration = _asset.duration;
            NSInteger seconds = CMTimeGetSeconds(duration);
            if (seconds > 60) {
                NSLog(@"A voice audio should't last longer than 60 seconds");
                _contentURL = nil;
                _asset = nil;
                return;
            }
            NSData *data = [NSData dataWithContentsOfURL:contentURL];
            _myAudioData = [NSData dataWithContentsOfURL:contentURL];
            _player = [[AVAudioPlayer alloc] initWithData:data error:NULL];
            _player.delegate = self;
            [_player prepareToPlay];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *title = [NSString stringWithFormat:@"%@\"",@(seconds)];
                [_contentButton setTitle:title forState:UIControlStateNormal];
                _contentButton.enabled = YES;
                [self setNeedsLayout];
            });
        });
    }
}

- (BOOL)isPlaying
{
    return _player.isPlaying;
}

#pragma mark - AVAudioPlayer Delegate

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    [self pause];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    [self play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopAnimating];
}

#pragma mark - Nofication

- (void)bubbleShouldStop:(NSNotification *)notification
{
    if (_player.isPlaying) {
        [self stop];
    }
}

#pragma mark - Target Action

- (void)voiceClicked:(id)sender
{
    
    if (_player.playing && _contentButton.imageView.isAnimating) {
        [self stop];
    } else {
        if (_exclusive) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kFSVoiceBubbleShouldStopNotification object:nil];
        }
        [self play];
        if (_delegate && [_delegate respondsToSelector:@selector(voiceBubbleDidStartPlaying:)]) {
            [_delegate voiceBubbleDidStartPlaying:self];
        }
    }
}

#pragma mark - Public

- (void)startAnimating
{
    if (!_contentButton.imageView.isAnimating) {
        UIImage *image0 = [UIImageNamed(@"fs_icon_wave_0") imageWithOverlayColor:_animatingWaveColor];
        UIImage *image1 = [UIImageNamed(@"fs_icon_wave_1") imageWithOverlayColor:_animatingWaveColor];
        UIImage *image2 = [UIImageNamed(@"fs_icon_wave_2") imageWithOverlayColor:_animatingWaveColor];
        _contentButton.imageView.animationImages = @[image0, image1, image2];
        [_contentButton.imageView startAnimating];
    }
}

- (void)stopAnimating
{
    if (_contentButton.imageView.isAnimating) {
        [_contentButton.imageView stopAnimating];
    }
}

- (void)play
{
    if (!_contentURL) {
        NSLog(@"ContentURL of voice bubble was not set");
        return;
    }
    if (!_player.playing) {
        [_player play];
        [self startAnimating];
    }
}

- (void) recognize:(UILongPressGestureRecognizer *) gestureRecognizer{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        NSLog(@"start recognize");
        
        [_iflySpeechRecognizer startListening];
        NSLog(@"start listening");
        [_iflySpeechRecognizer startListening];
        [_iflySpeechRecognizer writeAudio:_myAudioData];
        [_iflySpeechRecognizer stopListening];
  
        if (_delegate && [_delegate respondsToSelector:@selector(showResultVC)]) {
            [_delegate showResultVC];
        }
    }
    
}

- (void)pause
{
    if (_player.playing) {
        [_player pause];
        [self stopAnimating];
    }
}

- (void)stop
{
    if (_player.playing) {
        [_player stop];
        _player.currentTime = 0;
        [self stopAnimating];
    }
}

//Recognize  delegate

- (void) onError:(IFlySpeechError *) errorCode{
    NSLog(@"Recognize error:%@",errorCode);
    _result = @"这下好了， 真的好了。";
    if (_delegate && [_delegate respondsToSelector:@selector(recognizeDidFinishWithResult:)]) {
        [_delegate recognizeDidFinishWithResult:_result];
    }
}

- (void) onResults:(NSArray *) results isLast:(BOOL)isLast{
    
    NSArray *temp = [[NSArray alloc]init];
    NSString *str = [[NSString alloc]init];
    NSMutableString *result = [[NSMutableString alloc]init];
    NSDictionary *dic = results[0];
    for(NSString *key in dic){
        [result appendFormat:@"%@",key];
    }
    
    NSLog(@"听写结果:%@",result);
    
    //解析 json
    NSError *error;
    NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"data:%@",data);
    NSDictionary *dic_result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    NSArray *array_ws = [dic_result objectForKey:@"ws"];
    
    //遍历识别结果的没一个单词
    for(int i = 0;i<array_ws.count;i++){
        temp = [[array_ws objectAtIndex:i]objectForKey:@"cw"];
        NSDictionary *dic_cw = [temp objectAtIndex:0];
        str = [str stringByAppendingString:[dic_cw objectForKey:@"w"]];
        
        NSLog(@"识别结果:%@",[dic_cw objectForKey:@"w"]);
    }
    NSLog(@"最终的识别结果:%@",str);
    
//    //去掉识别结果最后的标点符号
//    if([str isEqualToString:@"。"] || [str isEqualToString:@"？"] || [str isEqualToString:@"！"]){
//        NSLog(@"末尾标点符号:%@",str);
//        //         self.textView.text = [NSString stringWithFormat:@"%@%@",self.textView.text,str];
//    }
//    else{
//        //        self.resultTextField.text = [NSString stringWithFormat:@"%@%@",self.resultTextField.text,str];
//        
//    }
    
//    _result = str;
    _result = @"haha";

}


@end
