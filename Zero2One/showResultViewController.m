//
//  showResultViewController.m
//  Zero2One
//
//  Created by K.Yawn Xoan on 5/20/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import "showResultViewController.h"

@interface showResultViewController ()

@end

@implementation showResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showResult:) name:@"passResult" object:nil];

    
}

- (void) showResult:(NSNotification *) notification{
    id resultText = notification.object;
    _showResultTV.text = resultText;
    
}
- (IBAction)dismissBtn:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
    
}
- (IBAction)shareResult:(UIBarButtonItem *)sender {
    
    UIActionSheet *shareResult = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share via Email",@"Share with Friends", nil];
    [shareResult showInView:self.view];
    
}
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
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
        [composer setMessageBody:_showResultTV.text isHTML:NO];
        [composer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:composer animated:YES completion:nil];
        
    }else{
        [SVProgressHUD showErrorWithStatus:@"can not send email"];
    }
    
}

#pragma mark - shareWithFriends

- (void) shareWithFriends{
    
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
- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"passResult" object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based a
 pplication, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
