//
//  myProfileTableViewController.m
//  Zero2One
//
//  Created by K.Yawn Xoan on 4/24/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import "myProfileTableViewController.h"

@interface myProfileTableViewController ()

@end

@implementation myProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //pick name via userdefault
    NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
    _showNameLabel.text = [UserDefault stringForKey:@"name"];
    
    //create image view to store photo
    _photoImageVIew = [[UIImageView alloc]initWithFrame:CGRectMake(150, 45, 80, 80)];
    _photoImageVIew.layer.masksToBounds = YES;
    _photoImageVIew.layer.cornerRadius = _photoImageVIew.bounds.size.width * 0.5;
    [self.view addSubview:_photoImageVIew];
    //pick image from local disk via document path
    //check if the file image exists or not
    //对比onlineavatar和mygravatar是否相同 即 onlineavatar是否及时更新
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
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
            _photoImageVIew.image = onlineAvatar;
        }else{
            _photoImageVIew.image = myGravatar;
        }
        
    }else{
        _photoImageVIew.image = [UIImage imageNamed:@"myGravatarDefault.png"];
    }
    
}

- (void) viewWillDisappear:(BOOL)animated{
    [self uploadAvatarPng];
    
}

#pragma mark - uploadAvatar

- (void) uploadAvatarPng{
    
    NSUserDefaults *UserDafault = [NSUserDefaults standardUserDefaults];
    NSString *imageName = [[UserDafault valueForKey:@"username"] stringByAppendingString:@".png"];
    NSLog(@"iamgeName:%@",imageName);
    // Dictionary that holds post parameters. You can set your post parameters that your server accepts or programmed to accept.
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:@"1.0" forKey:@"ver"];
    [_params setObject:@"en" forKey:@"lan"];
    [_params setObject:[NSString stringWithFormat:@"2"] forKey:@"userId"];
    [_params setObject:[NSString stringWithFormat:@"uploadimageTitle"] forKey:@"title"];
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString* FileParamConstant = @"file";
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:@"http://www.azfs.com.cn/Login/uploadAvatar.php"];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ourDocumentPath = [documentPaths objectAtIndex:0];
    NSString *imagePath = [ourDocumentPath stringByAppendingString:@"/myGravatar.png"];
    UIImage *imageToPost = [UIImage imageWithContentsOfFile:imagePath];
    NSData *imageData = UIImageJPEGRepresentation(imageToPost, 1.0);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", FileParamConstant,imageName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    [request setURL:requestURL];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
    }];
    
}

#pragma mark - button click events
//pick button clicked
- (IBAction)pickPhotoBtnClicked:(UIButton *)sender {
    
    UIActionSheet *myActionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose photo from library",@"take photos", nil];
    [myActionSheet showInView:self.view];
    
}
#pragma mark - action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 0){
        [self choosePhoto];
        
    }else if(buttonIndex == 1){
        [self takePhoto];
    }
}

#pragma mark - pick photo
//choose photo
- (void) choosePhoto{
    
    UIImagePickerController *photoPickeer = [[UIImagePickerController alloc]init];
    photoPickeer.delegate = self;
    photoPickeer.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    photoPickeer.allowsEditing = YES;
    [self presentViewController:photoPickeer animated:YES completion:nil];
    
}
//take photo
-(void) takePhoto{
    
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc]init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    photoPicker.allowsEditing = YES;
    [self presentViewController:photoPicker animated:YES completion:nil];
    
}
#pragma mark - image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    _photoImageVIew.image = info[UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:true completion:nil];
    
    
    //write to local disk
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ourDocumentPath = [documentPaths objectAtIndex:0];
    [self saveImageToDisk:ourDocumentPath imageToSave:_photoImageVIew.image];
    
}
#pragma mark - save image to disk

- (BOOL)saveImageToDisk:(NSString *)directoryPath imageToSave:(UIImage *) image{
    
    BOOL isSaved = false;
    NSString *imageType = @"png";
    if ([[imageType lowercaseString]isEqualToString:@"png"]) {
        isSaved = [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",@"myGravatar",@"png"]] atomically:YES];
        NSLog(@"save status%d",isSaved);
        NSLog(@"%@",directoryPath);
        
    }else if([[imageType lowercaseString]isEqualToString:@"jpg"] || [[imageType lowercaseString]isEqualToString:@"jpeg"]){
        isSaved = [UIImageJPEGRepresentation(image,1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",@"myGravatar",@"jpg"]] atomically:YES];
    }else{
        NSLog(@"image save failed");
    }
    return isSaved;
}
//pass name delegate

- (void)passValue:(NSString *)value{
    
    _showNameLabel.text = value;
    NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
    [UserDefault setObject:value forKey:@"name"];
    [UserDefault synchronize];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    id showNameVC = segue.destinationViewController;
    [showNameVC setValue:self forKey:@"delegate"];
    
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
