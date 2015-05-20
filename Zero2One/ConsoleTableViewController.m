//
//  ConsoleTableViewController.m
//  Zero2One
//
//  Created by K.Yawn Xoan on 5/14/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import "ConsoleTableViewController.h"
#import "FSVoiceBubble.h"
#import "FSVoiceBubbleCell.h"

@interface ConsoleTableViewController ()<FSVoiceBubbleDelegate,UITableViewDelegate,UITableViewDataSource>

@property (assign, nonatomic) NSInteger currentRow;
@end

@implementation ConsoleTableViewController
@synthesize toolbar;
@synthesize recordBtn;
@synthesize ourDocumentPath;
@synthesize UserDefault;
@synthesize fileNameArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    ourDocumentPath = [documentPaths objectAtIndex:0];
    UserDefault = [NSUserDefaults standardUserDefaults];

#pragma mark - init recorder
    [SVProgressHUD setBackgroundColor:[UIColor grayColor]];
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        //7.0第一次运行会提示，是否允许使用麦克风
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *sessionError;
        //AVAudioSessionCategoryPlayAndRecord用于录音和播放
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        if(session == nil)
            NSLog(@"Error creating session: %@", [sessionError description]);
        else
            [session setActive:YES error:nil];
    }
    
    docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
    //录音设置 16000
    //    recorderSettingsDict = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:kAudioFormatMPEG4AAC],AVFormatIDKey,[NSNumber numberWithFloat:44100.0],AVSampleRateKey,[NSNumber numberWithInt:2],AVNumberOfChannelsKey,nil];
    recorderSettingsDict = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,[NSNumber numberWithFloat:16000.0],AVSampleRateKey,[NSNumber numberWithInt:1],AVNumberOfChannelsKey, nil];
    
    //音量图片数组
    volumImages = [[NSMutableArray alloc]initWithObjects:@"RecordingSignal001",@"RecordingSignal002",@"RecordingSignal003",@"RecordingSignal004", @"RecordingSignal005",@"RecordingSignal006",@"RecordingSignal007",@"RecordingSignal008",nil];
    
}
- (void) viewWillAppear:(BOOL)animated{
    
    fileNameArray = [[NSMutableArray alloc]init];
    NSString *readWithKey = [[NSString alloc]initWithFormat:@"%@fileNameArray",[UserDefault valueForKey:@"selectRowUserName"]];
    if ([UserDefault valueForKey:readWithKey] == nil) {
        
    }else{
        
        [fileNameArray addObjectsFromArray:[UserDefault valueForKey:readWithKey]];
    }
    _currentRow = -1;
    
#pragma mark - toolbar
    //Initialize the toolbar
    toolbar = [[UIToolbar alloc] init];
    toolbar.barStyle = UIBarStyleDefault;
    //Set the toolbar to fit the width of the app.
    [toolbar sizeToFit];
    
    //Caclulate the height of the toolbar
    CGFloat toolbarHeight = [toolbar frame].size.height + 5;//44 + 5
    
    //Get the bounds of the parent view
    CGRect rootViewBounds = self.parentViewController.view.bounds;
    
    //Get the height of the parent view.
    CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
    
    //Get the width of the parent view,
    CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
    
    //Create a rectangle for the toolbar
    CGRect rectArea = CGRectMake(0, rootViewHeight - toolbarHeight, rootViewWidth, toolbarHeight);
    
    //Reposition and resize the receiver
    [toolbar setFrame:rectArea];
    
    //Create a flexible space
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    recordBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [recordBtn setTitle:@"Record" forState:UIControlStateNormal];
    [recordBtn setBounds:CGRectMake(0, 0, 200, 36)];
    recordBtn.layer.cornerRadius = 5;
    //    [recordBtn setBackgroundColor:[UIColor colorWithRed:0 green:0.61 blue:0.45 alpha:1]];
    [recordBtn setBackgroundColor:[UIColor colorWithRed:168/255.0 green:70/255.0 blue:1.0 alpha:1.0]];
    [recordBtn setTitleColor:[UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1] forState:UIControlStateNormal];
    [recordBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [recordBtn addTarget:self action:@selector(recordStart:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *recordItem = [[UIBarButtonItem alloc]initWithCustomView:recordBtn];
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace,recordItem,flexibleSpace, nil]];
    
    //Add the toolbar as a subview to the navigation controller.
    [self.navigationController.view addSubview:toolbar];
    
    
}

- (void) viewWillDisappear:(BOOL)animated{
    toolbar.hidden = YES;
    
    //保存filenamearray到nsuserdefault中
    NSString *saveWithKey = [[NSString alloc]initWithFormat:@"%@fileNameArray",[UserDefault valueForKey:@"selectRowUserName"]];
    if (fileNameArray == nil) {
        
    }else{
        [UserDefault setObject:fileNameArray forKey:saveWithKey];
        [UserDefault synchronize];
    }
    fileNameArray = nil;
}

- (void) recordStart:(id)sender {
    
    //按下录音
    if ([self canRecord]) {
        
        NSError *error = nil;
        //必须真机上测试,模拟器上可能会崩溃
        fileName = [[NSProcessInfo processInfo] globallyUniqueString];
        [fileNameArray addObject:fileName];
        recordingFilePath = [NSString stringWithFormat:@"%@/%@.pcm",docDir,fileName];
        NSLog(@"filename:%@",fileName);
        NSLog(@"filenameArray:%@",fileNameArray);
        recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:recordingFilePath] settings:recorderSettingsDict error:&error];
        
        if (recorder) {
            [recordBtn setTitle:@"Stop" forState:UIControlStateNormal];
            [recordBtn addTarget:self action:@selector(recordStop:) forControlEvents:UIControlEventTouchUpOutside];
            NSLog(@"start recording");
            recorder.meteringEnabled = YES;
            [recorder prepareToRecord];
            [recorder record];
            
            //启动定时器
            timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(levelTimer:) userInfo:nil repeats:YES];
            
        } else
        {
            int errorCode = *(int *) [error code];
            NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
        }
    }
}

-(void)recordStop:(id)sender{
    
    //录音停止
    NSLog(@"stop record");
    [recordBtn setTitle:@"Record" forState:UIControlStateNormal];
    [recorder stop];
    recorder = nil;
    //结束定时器
    [timer invalidate];
    timer = nil;
    [self.tableView reloadData];
    
}

-(void)levelTimer:(NSTimer*)timer_
{
    //call to refresh meter values刷新平均和峰值功率,此计数是以对数刻度计量的,-160表示完全安静，0表示最大输入值
    [recorder updateMeters];
    lowPassResults = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
    
    NSLog(@"Low pass results: %f",lowPassResults);
    
    if (0 < lowPassResults <= 0.06) {
        [SVProgressHUD showImage:[UIImage imageNamed:[volumImages objectAtIndex:0]] status:nil];
    }else if (0.06 < lowPassResults <= 0.13){
        [SVProgressHUD showImage:[UIImage imageNamed:[volumImages objectAtIndex:1]] status:nil];
    }else if (0.13 < lowPassResults <= 0.29){
        [SVProgressHUD showImage:[UIImage imageNamed:[volumImages objectAtIndex:2]] status:nil];
    }else if (0.29 < lowPassResults <= 0.41){
        [SVProgressHUD showImage:[UIImage imageNamed:[volumImages objectAtIndex:3]] status:nil];
    }else if (0.41 < lowPassResults <= 0.53){
        [SVProgressHUD showImage:[UIImage imageNamed:[volumImages objectAtIndex:4]] status:nil];
    }else if (0.53 < lowPassResults <= 0.67){
        [SVProgressHUD showImage:[UIImage imageNamed:[volumImages objectAtIndex:5]] status:nil];
    }else if (0.67 < lowPassResults <= 0.76){
        [SVProgressHUD showImage:[UIImage imageNamed:[volumImages objectAtIndex:6]] status:nil];
    }else if (0.83 < lowPassResults <= 0.9){
        [SVProgressHUD showImage:[UIImage imageNamed:[volumImages objectAtIndex:7]] status:nil];
    }else{
        [SVProgressHUD showImage:[UIImage imageNamed:[volumImages objectAtIndex:7]] status:nil];
    }
    
}

//判断是否允许使用麦克风7.0新增的方法requestRecordPermission
-(BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                }
                else {
                    bCanRecord = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[UIAlertView alloc] initWithTitle:nil message:@"Zero2One需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil] show];
                    });
                }
            }];
        }
    }
    
    return bCanRecord;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [fileNameArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSVoiceBubbleCell *cell = nil;
    NSString *myImageName = [NSString stringWithFormat:@"%@.png",[UserDefault valueForKey:@"username"]];
    NSString *MyImagePath = [ourDocumentPath stringByAppendingPathComponent:myImageName];
    NSString *partnerImageName = [NSString stringWithFormat:@"%@.png",[UserDefault valueForKey:@"selectRowUserName"]];
    NSString *partnerImagePath = [ourDocumentPath stringByAppendingPathComponent:partnerImageName];
    //    BOOL invert = indexPath.row % 2 > 0;
    BOOL invert = YES;
    if (!invert) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell_invert"];
    }
    cell.portraitImageView.image = [UIImage imageWithContentsOfFile:invert ? MyImagePath : partnerImagePath];
    if (fileName == nil) {
        NSLog(@"wei fu zhi ");
    }else{
        NSString *fileLocation = [NSString stringWithFormat:@"%@/%@.pcm",docDir,fileNameArray[indexPath.row]];
        cell.voiceBubble.contentURL = [NSURL fileURLWithPath:fileLocation];
        NSLog(@"cell file location :%@",fileLocation);
        
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.voiceBubble.tag = indexPath.row;
    if (indexPath.row == _currentRow) {
        [cell.voiceBubble startAnimating];
    } else {
        [cell.voiceBubble stopAnimating];
    }
    return cell;
}

- (void)voiceBubbleDidStartPlaying:(FSVoiceBubble *)voiceBubble
{
    _currentRow = voiceBubble.tag;
}
- (void)showResultVC{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    id showResultVC = [storyboard instantiateViewControllerWithIdentifier:@"recognizeresult"];
    [self presentViewController:showResultVC animated:NO completion:^{
        
    }];
}
- (void) recognizeDidFinishWithResult:(NSString *)recognizeResult{
    NSLog(@"consoletableviewcontroller: recognizeresult :%@",recognizeResult);
    [[NSNotificationCenter defaultCenter]postNotificationName:@"passResult" object:recognizeResult];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
