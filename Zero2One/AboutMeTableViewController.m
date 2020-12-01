//
//  AboutMeTableViewController.m
//  Zero2One
//
//  Created by K.Yawn Xoan on 4/23/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import "AboutMeTableViewController.h"

@interface AboutMeTableViewController ()

@end

@implementation AboutMeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

//refresh UI before view appear

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    //create imageview to add photo
    _showPhotoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(30, 45, 80, 80)];
    _showPhotoImageView.layer.masksToBounds = YES;
    _showPhotoImageView.layer.cornerRadius = _showPhotoImageView.bounds.size.width * 0.5;
    [self.view addSubview:_showPhotoImageView];
    
    //pick image from local disk via document path
    //check if the file image exists or not
    //对比onlineavatar和mygravatar是否相同 即 onlineavatar是否及时更新
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ourDocumentPath = [documentPaths objectAtIndex:0];
    NSString *imageName = [NSString stringWithFormat:@"%@.png",[UserDefault valueForKey:@"username"]];
    NSString *onlineAvatarImagePath = [ourDocumentPath stringByAppendingPathComponent:imageName];
    UIImage *onlineAvatar = [UIImage imageWithContentsOfFile:onlineAvatarImagePath];
    NSString *myGravatarImagePath = [ourDocumentPath stringByAppendingString:@"/myGravatar.png"];
    UIImage *myGravatar = [UIImage imageWithContentsOfFile:myGravatarImagePath];
    NSLog(@"myGravatar image path:%@",myGravatarImagePath);
    
    if ([fileManager fileExistsAtPath:myGravatarImagePath]) {
        
        if ([fileManager contentsEqualAtPath:myGravatarImagePath andPath:onlineAvatarImagePath]) {
            _showPhotoImageView.image = onlineAvatar;
        }else{
            _showPhotoImageView.image = myGravatar;
        }
        
        //        _showPhotoImageView.image = [fileManager contentsEqualAtPath:myGravatarImagePath andPath:onlineAvatarImagePath] ?  onlineAvatar :  myGravatar;
        
    }else{
        _showPhotoImageView.image = [UIImage imageNamed:@"myGravatarDefault.png"];
    }
    //pick name from userdefault
    _aboutMeNameLabel.text = [UserDefault stringForKey:@"name"];
    _showUserNameLabel.text = [UserDefault stringForKey:@"username"];
    
}

#pragma mark - tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //feedback via email
    if (indexPath.section == 1 && indexPath.row == 0) {
        
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc]init];
        [composer setMailComposeDelegate:self];
        if ([MFMailComposeViewController canSendMail]) {
            
            NSArray *toRecipients = [NSArray arrayWithObjects:@"xiongkaiya@gmail.com", nil];
            //set mailcpmposer
            [composer setSubject:@"Feedback"];
            [composer setToRecipients:toRecipients];
            [composer setMessageBody:@"" isHTML:NO];
            [composer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
            [self presentViewController:composer animated:YES completion:nil];
            
        }else{
            [SVProgressHUD showErrorWithStatus:@"can not send email"];
        }
        
    }
    
    //logout action sheet
    if (indexPath.section  == 2 && indexPath.row == 0) {
        
        UIActionSheet *logoutActionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Logout", nil];
        [logoutActionSheet showInView:self.view];
        
    }
    
}

#pragma mark - actionsheet delegate
//logout

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        
        NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
        
//        NSURL *url = [NSURL URLWithString:@"http://www.azfs.com.cn/Login/changeStatus.php"];
//        NSString *post = [[NSString alloc]initWithFormat:@"username=%@",[UserDefault stringForKey:@"username"]];
//        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
//        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
//        [req setHTTPMethod:@"POST"];
//        [req setHTTPBody:postData];
//        [req setTimeoutInterval:10.0];
//
//        NSOperationQueue *myQueue = [NSOperationQueue mainQueue];
//        [NSURLConnection sendAsynchronousRequest:req queue:myQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//
//            if (connectionError) {
//
//                NSLog(@"Http error:%@%ld",connectionError.localizedDescription,(long)connectionError.code);
//
//            }else{
//
//                NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
//                NSString *responseString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//                NSLog(@"Http Response Code :%ld",(long)responseCode);
//                NSLog(@"http Response String: %@",responseString);
//
//                if ([responseString isEqualToString:@"success"]) {
//
//                    NSLog(@"logout success ");
//                    //pick username and email, and then remove them from  userdefault
//                    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//                    [userDefault removeObjectForKey:@"username"];
//                    [userDefault removeObjectForKey:@"email"];
//                    [UserDefault removeObjectForKey:@"name"];
//                    [UserDefault removeObjectForKey:@"contacts"];
//                    //sync with local disk to storge it
//                    [userDefault synchronize];
//                    //remove user's image
////                    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
////                    NSString *ourDocumentPath = [documentPaths objectAtIndex:0];
////                    NSString *imagePath = [ourDocumentPath stringByAppendingString:@"/myGravatar.png"];
////                    if ([[NSFileManager defaultManager]removeItemAtPath:imagePath error:nil]) {
////                        NSLog(@"remove user's image success");
////                       }else{
////                        NSLog(@"remove user's image failed");
////                    }
//                    [SVProgressHUD showSuccessWithStatus:@"success logout"];
//
//                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//                    //get the view that users will go after logout
//                    id view = [storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
//                    //present the login view modally
//                    [self presentViewController:view animated:YES completion:^{
//                    }];
//
//
//                }else{
//
//                    NSLog(@"logout failed ");
//                    [SVProgressHUD showErrorWithStatus:@"change failed"];
//                }
//            }
//
//        }];

        
        NSLog(@"logout success ");
        //pick username and email, and then remove them from  userdefault
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault removeObjectForKey:@"username"];
        [userDefault removeObjectForKey:@"email"];
        [UserDefault removeObjectForKey:@"name"];
        [UserDefault removeObjectForKey:@"contacts"];
        //sync with local disk to storge it
        [userDefault synchronize];
        //remove user's image
        //                    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //                    NSString *ourDocumentPath = [documentPaths objectAtIndex:0];
        //                    NSString *imagePath = [ourDocumentPath stringByAppendingString:@"/myGravatar.png"];
        //                    if ([[NSFileManager defaultManager]removeItemAtPath:imagePath error:nil]) {
        //                        NSLog(@"remove user's image success");
        //                       }else{
        //                        NSLog(@"remove user's image failed");
        //                    }
        [SVProgressHUD showSuccessWithStatus:@"success logout"];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        //get the view that users will go after logout
        id view = [storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
        //present the login view modally
        [self presentViewController:view animated:YES completion:^{
        }];
    }
}

#pragma mark - mail delegate
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (result == MFMailComposeResultFailed) {
        [SVProgressHUD showErrorWithStatus:@"failed"];
    }else if (result == MFMailComposeResultSent){
        [SVProgressHUD showSuccessWithStatus:@"Sent"];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
