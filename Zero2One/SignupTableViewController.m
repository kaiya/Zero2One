//
//  SignupTableViewController.m
//  Zero2One
//
//  Created by K.Yawn Xoan on 4/26/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import "SignupTableViewController.h"

@interface SignupTableViewController ()

@end

@implementation SignupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.scrollEnabled = NO;
    //empty text field can not click sign up button
    _signupBtnOutlet.userInteractionEnabled = NO;
    _signupBtnOutlet.alpha = 0.3;
    //listen to text tield editing event
    [_passwordTextField addTarget:self action:@selector(textEditingEnd:) forControlEvents:UIControlEventEditingChanged];
    
}

#pragma mark - listen to text tield editing event
- (void)textEditingEnd:(id)sender{
    
    _signupBtnOutlet.userInteractionEnabled = YES;
    _signupBtnOutlet.alpha = 1.0;
    
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
    [_passwordTextField  resignFirstResponder];
    
}
#pragma mark - button click events
//cancel button clicked
- (IBAction)cancelBtnClicked:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
//sign up button clicked
- (IBAction)signupBtnClicked:(UIButton *)sender {
    
    [SVProgressHUD showWithStatus:@"Signing up" maskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD setBackgroundColor:[UIColor grayColor]];
    
    
    NSDictionary *headers = @{ @"x-lc-id": @"GBlGr53Qb9gnMHzA8Oh3SqN2-gzGzoHsz",
                               @"x-lc-key": @"4Y75VJPn7m5eWQayGnT6qFFK",
                               @"content-type": @"application/json"};
    NSDictionary *parameters = @{ @"username": _phoneNumberTextField.text,
                                  @"password": _passwordTextField.text,
                                  @"phone": _phoneNumberTextField.text};
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.azfs.com.cn/1.1/users"]
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
            if (responseCode==201) {
                NSLog(@"sign up success");
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSUTF8StringEncoding error:nil];
                NSString *sessionToken = [json valueForKey:@"sessionToken"];
                NSLog(@"SessionToken:%@", sessionToken); //todo store in user defaults.
                [self dismissViewControllerAnimated:YES completion:nil];
                [SVProgressHUD showSuccessWithStatus:@"Sign up success"];
            }else{
                NSLog(@"sign up failed");
                [SVProgressHUD showErrorWithStatus:responseString];
            }
            
        }
            }];
    
    
    
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
