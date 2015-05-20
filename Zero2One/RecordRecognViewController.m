//
//  RecordRecognViewController.m
//  Zero2One
//
//  Created by K.Yawn Xoan on 4/23/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import "RecordRecognViewController.h"

@interface RecordRecognViewController ()

@end

@implementation RecordRecognViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init iflySpeechRecognizer
    NSString *initString = [[NSString alloc]initWithFormat:@"appid=%@",@"54ffd80a"];
    [IFlySpeechUtility createUtility:initString];
    
    _iflySpeechRecognizer = [[IFlySpeechRecognizer alloc]init];
    _iflySpeechRecognizer.delegate = self;
    [_iflySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    [_iflySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_STREAM forKey:@"audio_source"];
    
    //检查contacts是否有值 没有就异步请求获取contacts
    NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
    
    if ([UserDefault valueForKey:@"contacts"] != nil && [UserDefault valueForKey:@"contactsUserName"] != nil) {
        
    }else{
        
        [self listUsers];
        [self listUserName];
    }
    
}

- (void) viewDidAppear:(BOOL)animated{
    
    NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ourDocumentPath = [documentPaths objectAtIndex:0];
    NSLog(@"our document path :%@",ourDocumentPath);
    NSString *myGravatarImagePath = [ourDocumentPath stringByAppendingString:@"/myGravatar.png"];
    NSString *imageName = [NSString stringWithFormat:@"%@.png",[UserDefault valueForKey:@"username"]];
    NSString *myOnlineAvatarImagePath = [ourDocumentPath stringByAppendingPathComponent:imageName];
    NSString *UserName = [UserDefault valueForKey:@"contactsUserName"];
    _contactsUserName  = [ UserName componentsSeparatedByString:@","];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *myownAvatarFilePath = [ourDocumentPath stringByAppendingFormat:@"/%@.png",_contactsUserName[_contactsUserName.count-2]];
    NSLog(@"my own avatar file path :%@",myownAvatarFilePath);
    if (![fileManager fileExistsAtPath:myownAvatarFilePath] && _contactsUserName[_contactsUserName.count-2] != nil) {
        //get avatar image for contacts
        for (int i =0; i<_contactsUserName.count-1; i++) {
            NSLog(@"contacts username :%@",_contactsUserName[i]);
            NSString *imageURL = [NSString stringWithFormat:@"http://www.azfs.com.cn/Login/Avatar/%@.png",_contactsUserName[i]];
            NSString *imageName = [NSString stringWithFormat:@"%@",_contactsUserName[i]];
            UIImage *avatarImage = [self getImageFromURL:imageURL];
            [self saveImage:avatarImage withFileName:imageName inDirectory:ourDocumentPath];
            NSLog(@":loading image");
        }
        [SVProgressHUD showSuccessWithStatus:@"loaded"];
        
        
    }
    [fileManager copyItemAtPath:myOnlineAvatarImagePath toPath:myGravatarImagePath error:nil];
    
}

#pragma mark - load avatar

- (UIImage *) getImageFromURL:(NSString *) fileURL{
    
    UIImage *result;
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:imageData];
    return result;
}

- (void) saveImage:(UIImage *)image withFileName:(NSString *)imageName inDirectory:(NSString *) directoryPath{
    
    [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",imageName,@"png"] ] atomically:YES];
    
}

- (void) listUsers{
    
    NSURL *url = [NSURL URLWithString:@"http://www.azfs.com.cn/Login/listUsers.php"];
    NSString *post = [[NSString alloc]initWithFormat:@""];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:postData];
    [req setTimeoutInterval:10.0];
    
    //异步获取网络数据
    
    NSOperationQueue *myQueue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:req queue:myQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        
        
        if (connectionError) {
            
            NSLog(@"Http error:%@%ld",connectionError.localizedDescription,(long)connectionError.code);
            
        }else{
            
            NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
            NSString *responseString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Http Response Code :%ld",(long)responseCode);
            NSLog(@"http Response : %@",responseString);
            NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
            [UserDefault setObject:responseString forKey:@"contacts"];
            [UserDefault synchronize];
            
        }
        
    }];
    
}

//list username for pick their online avatar

- (void) listUserName {
    
    
    
    NSURL *url = [NSURL URLWithString:@"http://www.azfs.com.cn/Login/listUserName.php"];
    NSString *post = [[NSString alloc]initWithFormat:@""];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:postData];
    [req setTimeoutInterval:10.0];
    
    //异步获取网络数据
    
    NSOperationQueue *myQueue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:req queue:myQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        
        
        if (connectionError) {
            
            NSLog(@"Http error:%@%ld",connectionError.localizedDescription,(long)connectionError.code);
            
        }else{
            
            NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
            NSString *responseString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Http Response Code :%ld",(long)responseCode);
            NSLog(@"http Response  username : %@",responseString);
            NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
            [UserDefault setObject:responseString forKey:@"contactsUserName"];
            [UserDefault synchronize];
        }
        
    }];
    
}

//dismiss the keyboard
- (IBAction)controlTouchDown:(UIControl *)sender {
    [_resultTextField resignFirstResponder];
}

//share button clicked event
- (IBAction)shareBtnClicked:(UIBarButtonItem *)sender {
    
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share via Email",@"Share With Friends", nil];
    [shareActionSheet showInView:self.view];
    
}

#pragma mark - startRecording

//recording
- (IBAction)recordBtnClicked:(UIButton *)sender {
    
    KYAudioRecorderController *controller = [[KYAudioRecorderController alloc] init];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
    
}


//record delegate
-(void)audioRecorderController:(KYAudioRecorderController*)controller didFinishWithAudioAtPath:(NSString*)filePath{
    
    _recordedFilePath = filePath;
    NSLog(@"%@",_recordedFilePath);
}
-(void)audioRecorderControllerDidCancel:(KYAudioRecorderController*)controller{
    
}

#pragma mark - startRecognizing

//Recognizing

- (IBAction)recognizeBtnClicked:(UIButton *)sender {
    
    [_iflySpeechRecognizer startListening];
    NSLog(@"start listening");
    //gou zao nsdata
    NSData *audioData = [NSData dataWithContentsOfFile:_recordedFilePath];
    [_iflySpeechRecognizer startListening];
    [_iflySpeechRecognizer writeAudio:audioData];
    [_iflySpeechRecognizer stopListening];
    
}

//Recognize  delegate

- (void) onError:(IFlySpeechError *) errorCode{
    NSLog(@"Recognize error:%@",errorCode);
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
    
    //json jie xi
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
    
    //去掉识别结果最后的标点符号
    if([str isEqualToString:@"。"] || [str isEqualToString:@"？"] || [str isEqualToString:@"！"]){
        NSLog(@"末尾标点符号:%@",str);
        //         self.textView.text = [NSString stringWithFormat:@"%@%@",self.textView.text,str];
    }
    else{
        self.resultTextField.text = [NSString stringWithFormat:@"%@%@",self.resultTextField.text,str];
        
    }
    _result = str;
    
}

#pragma mark - actionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"buttonindex:%ld",(long)buttonIndex);
    if (buttonIndex == 0) {
        NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
        if ([UserDefault stringForKey:@"email"] == nil) {
            [SVProgressHUD showErrorWithStatus:@"add an email address"];
        }else{
            
            [self shareViaEmail];
            
        }
        
    }else if (buttonIndex == 1){
        
        [self shareWithFriends];
        
    }
}

#pragma mark - shareViaEmail


- (void)shareViaEmail{
    
    
    MFMailComposeViewController *composer = [[MFMailComposeViewController alloc]init];
    [composer setMailComposeDelegate:self];
    if ([MFMailComposeViewController canSendMail]) {
        
        NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
        NSArray *toRecipients = [NSArray arrayWithObjects:[UserDefault stringForKey:@"email"], nil];
        [composer setSubject:@"RecognizeResult"];
        [composer setToRecipients:toRecipients];
        [composer setMessageBody:_resultTextField.text isHTML:NO];
        [composer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:composer animated:YES completion:nil];
        
    }else{
        [SVProgressHUD showErrorWithStatus:@"can not send email"];
    }
    
}

#pragma mark - sendmail delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    if (result == MFMailComposeResultFailed) {
        [SVProgressHUD showErrorWithStatus:@"failed"];
    }else if (result == MFMailComposeResultSent){
        [SVProgressHUD showSuccessWithStatus:@"Sent"];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - shareWithFriends

- (void) shareWithFriends{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
