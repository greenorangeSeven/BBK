//
//  PublishTradeView.m
//  BBK
//
//  Created by Seven on 14-12-21.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "PublishTradeView.h"
#import "NSString+STRegex.h"

#define ORIGINAL_MAX_WIDTH 640.0f

@interface PublishTradeView ()
{
    UserInfo *userInfo;
}

@end

@implementation PublishTradeView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.view.frame.size.height);
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"交易买卖";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle: @"发布" style:UIBarButtonItemStyleBordered target:self action:@selector(publishAction:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    userInfo = [[UserModel Instance] getUserInfo];
    
    self.phoneTf.text = userInfo.mobileNo;
    self.contentTv.delegate = self;
}

- (void)textViewDidChange:(UITextView *)textView
{
    int textLength = [textView.text length];
    if (textLength == 0) {
        [self.contentPlaceholder setHidden:NO];
    }else{
        [self.contentPlaceholder setHidden:YES];
    }
}

- (void)publishAction:(id)sender
{
    NSString *titleStr = self.titleTf.text;
    NSString *priceStr = self.priceTf.text;
    NSString *contentStr = self.contentTv.text;
    NSString *phoneStr = self.phoneTf.text;
    if (titleStr == nil || [titleStr length] == 0) {
        [Tool showCustomHUD:@"请输入标题" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (priceStr == nil || [priceStr length] == 0) {
        [Tool showCustomHUD:@"请输入价格" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (contentStr == nil || [contentStr length] == 0) {
        [Tool showCustomHUD:@"请输入描述" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (![phoneStr isValidPhoneNum]) {
        [Tool showCustomHUD:@"手机号错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:titleStr forKey:@"title"];
    [param setValue:contentStr forKey:@"content"];
    [param setValue:phoneStr forKey:@"phone"];
    [param setValue:priceStr forKey:@"price"];
    [param setValue:userInfo.regUserId forKey:@"userId"];
    [param setValue:@"0" forKey:@"typeId"];
    NSString *addBusinessSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_addBusinessInfoForApp] params:param];
    
    NSString *addBusinessUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_addBusinessInfoForApp];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:addBusinessUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:Appkey forKey:@"accessId"];
    [request setPostValue:addBusinessSign forKey:@"sign"];
    [request setPostValue:titleStr forKey:@"title"];
    [request setPostValue:contentStr forKey:@"content"];
    [request setPostValue:phoneStr forKey:@"phone"];
    [request setPostValue:priceStr forKey:@"price"];
    [request setPostValue:userInfo.regUserId forKey:@"userId"];
    [request setPostValue:@"0" forKey:@"typeId"];
    if (self.cameraImage != nil) {
        [request addData:UIImageJPEGRepresentation(self.cameraImage, 0.8f) withFileName:@"img.jpg" andContentType:@"image/jpeg" forKey:@"pic"];
    }
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestAddBusiness:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"发布中..." andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
        
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    if(self.navigationItem.rightBarButtonItem.enabled == NO)
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}
- (void)requestAddBusiness:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
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
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return;
    }
    else
    {
        [Tool showCustomHUD:@"已发布，请等待审核" andView:self.parentView  andImage:@"37x-Failure.png" andAfterDelay:1];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
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

- (IBAction)cameraAction:(id)sender {
    UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    cameraSheet.tag = 0;
    [cameraSheet showInView:self.view];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0) {
        if (buttonIndex == 0) {
            // 拍照
            if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
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
        else if (buttonIndex == 1) {
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
        self.cameraImage = [self imageByScalingToMaxSize:portraitImg];
        self.cameraIv.image = self.cameraImage;
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
//拍照处理

@end
