//
//  LoginTableViewController.m
//  Zero2One
//
//  Created by K.Yawn Xoan on 4/25/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import "LoginTableViewController.h"

@interface LoginTableViewController ()

@end

@implementation LoginTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.scrollEnabled = NO;
    
    //empty phonenumber and password can not click login button
    _loginBtnOutlet.userInteractionEnabled = NO;
    _loginBtnOutlet.alpha = 0.3;
    //listening password text field editing event
    [_passwordTextField addTarget:self action:@selector(textEditingEnd:) forControlEvents:UIControlEventEditingChanged];
    
}

//listening password text field editing event
- (void)textEditingEnd:(id)sender{
    
    //not empty
    _loginBtnOutlet.userInteractionEnabled = YES;
    _loginBtnOutlet.alpha = 1.0;
    
}
#pragma mark - dismiss the keyboard

- (IBAction)phoneNumberDidEndOnExit:(UITextField *)sender {
    [_phoneNumberTextField resignFirstResponder];
}
- (IBAction)passwordDidEndOnExit:(UITextField *)sender {
    [_passwordTextField resignFirstResponder];
}

- (IBAction)controlTouchDown:(UIControl *)sender {
    
    [_phoneNumberTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
}
#pragma mark - login event

- (IBAction)loginBtnClicked:(UIButton *)sender {
    
    //    [SVProgressHUD showWithStatus:@"logining" maskType:SVProgressHUDMaskTypeClear];
    //    [SVProgressHUD setBackgroundColor:[UIColor grayColor]];
    
    NSDictionary *headers = @{ @"x-lc-id": @"GBlGr53Qb9gnMHzA8Oh3SqN2-gzGzoHsz",
                               @"x-lc-key": @"4Y75VJPn7m5eWQayGnT6qFFK",
                               @"content-type": @"application/json"};
    NSDictionary *parameters = @{ @"username": _phoneNumberTextField.text,
                                  @"password": _passwordTextField.text};
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.azfs.com.cn/1.1/login"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:postData];
    
    
    NSOperationQueue *myQueue = [NSOperationQueue currentQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:myQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"Http error:%@%ld",connectionError.localizedDescription,(long)connectionError.code);
        }else{
            
            [SVProgressHUD dismiss];
            NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
            NSString *responseString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Http Response Code :%ld",(long)responseCode);
            NSLog(@"http Response String: %@",responseString);
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSUTF8StringEncoding error:nil];
            NSNumber *returnCodeNumber = [json valueForKey:@"code"];
            NSInteger returnCode = [returnCodeNumber integerValue];
            NSString *sessionToken = [json valueForKey:@"sessionToken"];
            if (responseCode == 200 && sessionToken != nil) {
            
                NSLog(@"login success, sessionToken:%@", sessionToken);
                NSString *userObjectId = [json valueForKey:@"objectId"];
                NSString *userName = [json valueForKey:@"username"];
                // login success and store the username via userdefault
                NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
                [UserDefault setObject:_phoneNumberTextField.text forKey:@"username"];
                [UserDefault setObject:userName forKey:@"name"]; //for what?
                [UserDefault setObject:sessionToken forKey:@"sessionToken"];
                [UserDefault setObject:userObjectId forKey:@"userObjectId"];
                [UserDefault synchronize];
                //go to the main view after login successfully
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                id mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"MainView"];
                [self presentViewController:mainViewController animated:YES completion:^{
                }];
                
            }else if(returnCode == 210 || returnCode == 211){

                NSLog(@"username or password incorrect ");
                [self shakeAnimationForView:_phoneNumberTextField];
                [self  shakeAnimationForView:_passwordTextField];

                [SVProgressHUD showErrorWithStatus:@"username or password incorrect"];
            }else{
                NSLog(@"login failed");
                [SVProgressHUD showErrorWithStatus:responseString];
            }
            
        }
    }];
    
}


#pragma mark 抖动动画

- (void)shakeAnimationForView:(UIView *) view

{
    
    // 获取到当前的View
    
    CALayer *viewLayer = view.layer;
    
    // 获取当前View的位置
    
    CGPoint position = viewLayer.position;
    
    // 移动的两个终点位置
    
    CGPoint x = CGPointMake(position.x + 10, position.y);
    
    CGPoint y = CGPointMake(position.x - 10, position.y);
    
    // 设置动画
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    // 设置运动形式
    
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    
    // 设置开始位置
    
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    
    // 设置结束位置
    
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    
    // 设置自动反转
    
    [animation setAutoreverses:YES];
    
    // 设置时间
    
    [animation setDuration:.06];
    
    // 设置次数
    
    [animation setRepeatCount:3];
    
    // 添加上动画
    
    [viewLayer addAnimation:animation forKey:nil];
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Table view data source
 
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 #warning Potentially incomplete method implementation.
 // Return the number of sections.
 return 0;
 }
 
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 #warning Incomplete method implementation.
 // Return the number of rows in the section.
 return 0;
 }
 
 */

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
