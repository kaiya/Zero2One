//
//  changNameTableViewController.m
//  Zero2One
//
//  Created by K.Yawn Xoan on 4/24/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import "changNameTableViewController.h"

@interface changNameTableViewController ()

@end

@implementation changNameTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)cancleBtnClicked:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}
#pragma mark - save changed name
- (IBAction)saveBtnClicked:(UIBarButtonItem *)sender {
    
    NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
    
    [SVProgressHUD showWithStatus:@"changing" maskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD setBackgroundColor:[UIColor grayColor]];
    
    
    NSString *userObejctId = [UserDefault stringForKey:@"userObjectId"];
    NSString *url = [NSString stringWithFormat:@"https://api.azfs.com.cn/1.1/users/%@", userObejctId];
    NSDictionary *headers = @{ @"x-lc-id": @"GBlGr53Qb9gnMHzA8Oh3SqN2-gzGzoHsz",
                               @"x-lc-key": @"4Y75VJPn7m5eWQayGnT6qFFK",
                               @"content-type": @"application/json",
                               @"X-LC-Session":[UserDefault stringForKey:@"sessionToken"],
                               };
    NSDictionary *parameters = @{ @"username": _nameTextField.text};
    
    NSData *putData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"PUT"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:putData];
    
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
            NSString *updatedAt = [json valueForKey:@"updatedAt"];
            if (responseCode==200 && updatedAt != nil) {

                NSLog(@"change success ");
                [SVProgressHUD showSuccessWithStatus:@"change success"];
                [UserDefault setValue:_nameTextField.text forKey:@"username"];
                [_delegate passValue:_nameTextField.text];
                [self.navigationController popViewControllerAnimated:YES];

            }else{
                NSLog(@"Change name failed");
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
