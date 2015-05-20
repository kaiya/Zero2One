//
//  ContactsViewController.m
//  Zero2One
//
//  Created by K.Yawn Xoan on 4/23/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import "ContactsViewController.h"
#define HOST @"vp0.org"
#define PORT 50904

@interface ContactsViewController ()

@end

@implementation ContactsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView1.dataSource = self;
    _tableView1.delegate = self;
    
    //connect via socket
    NSError *connectError = nil;
    _socket = [[AsyncSocket alloc]initWithDelegate:self];
//    [_socket connectToHost:HOST onPort:PORT error:&connectError];
    if (connectError) {
        NSLog(@"connect error:%@",connectError);
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [self.tableView1 reloadData];
    NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
    NSString *contacts = [UserDefault valueForKey:@"contacts"];
    _contactsArray = [contacts  componentsSeparatedByString:@","];
    NSString *UserName = [UserDefault valueForKey:@"contactsUserName"];
    _contactsUserName  = [ UserName componentsSeparatedByString:@","];
    
}

#pragma mark - tableview delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _contactsArray.count-1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellId = @"contactscell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell  == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    UIImageView *contactsImageView = (UIImageView *) [cell viewWithTag:1];
    contactsImageView.layer.masksToBounds = YES;
    contactsImageView.layer.cornerRadius = 20;
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ourDocumentPath = [documentPaths objectAtIndex:0];
    NSString *imageName = [NSString stringWithFormat:@"%@.png",_contactsUserName[indexPath.row]];
    NSString *imagePath = [ourDocumentPath stringByAppendingPathComponent:imageName];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    UIImage *myGravatar = [UIImage imageWithData:imageData];
    if (imageData != nil) {
        contactsImageView.image = myGravatar;
    }else{
        contactsImageView.image = [UIImage imageNamed:@"myGravatarDefault.png"];
    }
    
    UILabel *contactsName = (UILabel *) [cell viewWithTag:2];
    contactsName.text = _contactsArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
    NSString *contacts = [UserDefault valueForKey:@"contacts"];
    _contactsArray = [contacts  componentsSeparatedByString:@","];
    NSString *show = [NSString stringWithFormat:@"invite %@ to record a message?",_contactsArray[indexPath.row]];
   
    _partner = _contactsArray[indexPath.row];
    NSLog(@"partner yi fu zhi:%@",_partner);
    _partnerAlertView = [[UIAlertView alloc]initWithTitle:nil message:show delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
    [_partnerAlertView show];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - actionsheet delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView == _partnerAlertView) {
        NSLog(@"%ld",(long)buttonIndex);
        if (buttonIndex == 1) {
            NSLog(@"partner:%@",_partner);
            //write data
            NSString *sendString = [NSString stringWithFormat:@"%@\n",_partner];
            [_socket writeData:[sendString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
        }
    }else if (alertView == _readDataAlertView){
        
        if (buttonIndex == 1) {
            //accept invitation
            
            //go to the main view after login successfully
//            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//            id mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"MainView"];
//            [self presentViewController:mainViewController animated:YES completion:^{
//            }];
        }
    }
    
}

#pragma mark - Asyncsocket delegate


- (void) onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    
    NSLog(@"contactsview did connect to host");
    
    
    // send username
    
    NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
    NSString *sendString = [NSString stringWithFormat:@"%@\n",[UserDefault valueForKey:@"name"]];
    [_socket writeData:[sendString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
    NSLog(@"write data : send name");
    
    [_socket readDataWithTimeout:-1 tag:1];
    
}
- (void) onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"did write data with tag 1");
    NSLog(@"tag%ld",tag);
}

- (void) onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"did read data");
    NSString *msg = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"read data:%@",msg);
    _readDataAlertView = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [_readDataAlertView show];
    
}

- (void) onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err{
    NSLog(@"did disconnect with error:%@",err);
    [_socket connectToHost:HOST onPort:PORT error:nil];
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
