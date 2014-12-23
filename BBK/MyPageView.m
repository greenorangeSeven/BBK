//
//  MyPageView.m
//  BBK
//
//  Created by Seven on 14-12-2.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "MyPageView.h"
#import "UIImageView+WebCache.h"
#import "ModifyUserInfoView.h"
#import "InviteView.h"
#import "MyHouseUserView.h"
#import "ExpressView.h"
#import "ChangeHouseView.h"
#import "ReleasepermitView.h"

#define ORIGINAL_MAX_WIDTH 640.0f

@interface MyPageView ()
{
    UIWebView *phoneWebView;
    UIImage *userFace;
}

@end

@implementation MyPageView

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"我的";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(telAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"head_tel"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)telAction:(id)sender
{
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", userInfo.defaultUserHouse.phone]];
    if (!phoneWebView) {
        phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
}

//更新头像
- (IBAction)uploadFaceAction:(id)sender {
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

//修改信息
- (IBAction)modifyUserInfoAction:(id)sender {
    ModifyUserInfoView *modifyView = [[ModifyUserInfoView alloc] init];
    modifyView.parentView = self.view;
    modifyView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:modifyView animated:YES];
}

//邀请注册
- (IBAction)InviteAction:(id)sender {
    InviteView *inviteView = [[InviteView alloc] init];
    inviteView.parentView = self.view;
    inviteView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:inviteView animated:YES];
}

//我的房间有谁
- (IBAction)houseUserAction:(id)sender {
    MyHouseUserView *houseUserView = [[MyHouseUserView alloc] init];
    houseUserView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:houseUserView animated:YES];
}

//我的包裹
- (IBAction)myExpressAction:(id)sender {
    ExpressView *expressView = [[ExpressView alloc] init];
    expressView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:expressView animated:YES];
}

//切换房间
- (IBAction)changeHouseAction:(id)sender {
    ChangeHouseView *changeView = [[ChangeHouseView alloc] init];
    changeView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:changeView animated:YES];
}

//电子放行单
- (IBAction)releasepermitActon:(id)sender {
    ReleasepermitView *releaseView = [[ReleasepermitView alloc] init];
    releaseView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:releaseView animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[Tool getColorForMain]];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    [self.userFaceIv setImageWithURL:[NSURL URLWithString:userInfo.photoFull] placeholderImage:[UIImage imageNamed:@"default_head.png"]];
    
    self.userInfoLb.text = [NSString stringWithFormat:@"%@(%@)", userInfo.regUserName, userInfo.mobileNo];
    self.userAddressLb.text = [NSString stringWithFormat:@"%@%@%@--%@", userInfo.defaultUserHouse.cellName, userInfo.defaultUserHouse.buildingName, userInfo.defaultUserHouse.numberName, userInfo.defaultUserHouse.userTypeName];
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    self.userFaceIv.image = editedImage;
    userFace = editedImage;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        UserInfo *userInfo = [[UserModel Instance] getUserInfo];
        //生成更换头像URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:userInfo.regUserId forKey:@"regUserId"];
        NSString *changePhotoSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_changeUserPhoto] params:param];
        
        NSString *changePhotoUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_changeUserPhoto] params:param];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:changePhotoUrl]];
        [request setUseCookiePersistence:[[UserModel Instance] isLogin]];
        [request setTimeOutSeconds:30];
        [request setPostValue:Appkey forKey:@"accessId"];
        [request setPostValue:changePhotoSign forKey:@"sign"];
        [request setPostValue:userInfo.regUserId forKey:@"regUserId"];
        if (userFace != nil) {
            [request addData:UIImageJPEGRepresentation(userFace, 0.8f) withFileName:@"img.jpg" andContentType:@"image/jpeg" forKey:@"pic"];
        }
        [request setDelegate:self];
        [request setDidFailSelector:@selector(requestFailed:)];
        [request setDidFinishSelector:@selector(requestChangeUserPhoto:)];
        [request startAsynchronous];
        
        request.hud = [[MBProgressHUD alloc] initWithView:self.view];
        [Tool showHUD:@"头像更新..." andView:self.view andHUD:request.hud];
    }];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
}

- (void)requestChangeUserPhoto:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSLog(@"%@", request.responseString);
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == NO) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                     message:[[json objectForKey:@"header"] objectForKey:@"msg"]
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [av show];
        return;
    }
    else
    {
        userFace = nil;
        NSString *userPhoto = [json objectForKey:@"data"];
        [[UserModel Instance] saveValue:userPhoto ForKey:@"photoFull"];
    }
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0) {
        if (buttonIndex == 0) {
            // 拍照
            if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                //使用前置摄像头
//                if ([self isFrontCameraAvailable]) {
//                    controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
//                }
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
            
        } else if (buttonIndex == 1) {
            // 从相册中选取
            if ([self isPhotoLibraryAvailable]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

@end
