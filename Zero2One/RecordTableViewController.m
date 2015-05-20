//
//  RecordTableViewController.m
//  Zero2One
//
//  Created by K.Yawn Xoan on 5/13/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import "RecordTableViewController.h"

@interface RecordTableViewController ()

@end

@implementation RecordTableViewController
@synthesize tableView2;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView2.delegate = self;
    self.tableView2.dataSource = self;
    
    
    //刷新控件
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    refresh.attributedTitle = [[NSAttributedString alloc]initWithString:@"pull down refresh"];
    refresh.tintColor = [UIColor blueColor];
    [refresh addTarget:self action:@selector(pulltoRefresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
    //检查contacts是否有值 没有就异步请求获取contacts
    if ([UserDefault valueForKey:@"contacts"] != nil && [UserDefault valueForKey:@"contactsUserName"] != nil) {
        
    }else{
        
        [self listUsers];
        [self listUserName];
    }
    NSString *contacts = [UserDefault valueForKey:@"contacts"];
    _contactsArray = [contacts  componentsSeparatedByString:@","];
    NSString *UserName = [UserDefault valueForKey:@"contactsUserName"];
    _contactsUserName  = [ UserName componentsSeparatedByString:@","];
    
    [SVProgressHUD showWithStatus:@"loading" maskType:SVProgressHUDMaskTypeBlack];
}
#pragma mark - refresh control
- (void) pulltoRefresh{
    [self.tableView2 reloadData];
    NSLog(@"refreshing");
    [self.refreshControl endRefreshing];
}

- (void)viewWillAppear:(BOOL)animated{
    
    NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
    NSString *contacts = [UserDefault valueForKey:@"contacts"];
    _contactsArray = [contacts  componentsSeparatedByString:@","];
    NSString *UserName = [UserDefault valueForKey:@"contactsUserName"];
    _contactsUserName  = [ UserName componentsSeparatedByString:@","];
    
}


- (void) viewDidAppear:(BOOL)animated{
    
    [self.tableView2 reloadData];
    NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ourDocumentPath = [documentPaths objectAtIndex:0];
    NSString *myGravatarImagePath = [ourDocumentPath stringByAppendingString:@"/myGravatar.png"];
    NSString *imageName = [NSString stringWithFormat:@"%@.png",[UserDefault valueForKey:@"username"]];
    NSString *myOnlineAvatarImagePath = [ourDocumentPath stringByAppendingPathComponent:imageName];
    NSString *UserName = [UserDefault valueForKey:@"contactsUserName"];
    _contactsUserName  = [ UserName componentsSeparatedByString:@","];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *myownAvatarFilePath = [ourDocumentPath stringByAppendingFormat:@"/%@.png",_contactsUserName[_contactsUserName.count-2]];
    //判断用户头像是否存在，不存在则联网获取
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
        
        [self performSelectorOnMainThread:@selector(pulltoRefresh) withObject:nil waitUntilDone:NO];
    }
    [fileManager copyItemAtPath:myOnlineAvatarImagePath toPath:myGravatarImagePath error:nil];
    
    [SVProgressHUD dismiss];
    
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

//list username for picking their online avatar

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


#pragma mark - tableview delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
    NSString *contacts = [UserDefault valueForKey:@"contacts"];
    _contactsArray = [contacts  componentsSeparatedByString:@","];
    return _contactsArray.count-1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
    NSString *contacts = [UserDefault valueForKey:@"contacts"];
    _contactsArray = [contacts  componentsSeparatedByString:@","];
    NSString *UserName = [UserDefault valueForKey:@"contactsUserName"];
    _contactsUserName  = [ UserName componentsSeparatedByString:@","];
    
    static NSString *cellId = @"consolecell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell  == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    UIImageView *contactsImageView = (UIImageView *) [cell viewWithTag:1];
    contactsImageView.layer.masksToBounds = YES;
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
    NSString *UserName = [UserDefault valueForKey:@"contactsUserName"];
    _contactsUserName  = [ UserName componentsSeparatedByString:@","];
    //跳转至录音界面
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *consoleViewController = [storyboard instantiateViewControllerWithIdentifier:@"console"];
    consoleViewController.title = _contactsArray[indexPath.row];
    [UserDefault setObject:_contactsUserName[indexPath.row] forKey:@"selectRowUserName"];
    //隐藏录音回话界面toolbar
    self.tabBarController.hidesBottomBarWhenPushed = YES;
    consoleViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:consoleViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
