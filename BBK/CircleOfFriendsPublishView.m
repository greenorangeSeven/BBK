//
//  CircleOfFriendsPublishView.m
//  BBK
//
//  Created by Seven on 14-12-19.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "CircleOfFriendsPublishView.h"
#import "UIImageView+WebCache.h"
#import "RepairImageCell.h"

#define ORIGINAL_MAX_WIDTH 640.0f

@interface CircleOfFriendsPublishView ()
{
    int topicTypeId;
    NSArray *topicTypeArray;
    NSMutableArray *topicImageArray;
    int selectCaremaIndex;
}

@end

@implementation CircleOfFriendsPublishView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"社区朋友圈";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle: @"发布" style:UIBarButtonItemStyleBordered target:self action:@selector(submitTopicAction:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    self.topicContentTv.delegate = self;
    topicImageArray = [[NSMutableArray alloc] initWithCapacity:9];
    UIImage *myImage = [UIImage imageNamed:@"cameralogo"];
    [topicImageArray addObject:myImage];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[RepairImageCell class] forCellWithReuseIdentifier:RepairImageCellIdentifier];
    
    [self getTopicTypeData];
}

- (IBAction)submitTopicAction:(id)sender {
    NSString *contentStr = self.topicContentTv.text;
    if (contentStr == nil || [contentStr length] == 0) {
        [Tool showCustomHUD:@"请发表您这一刻的想法" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];

    //生成新增报修Sign
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:[NSString stringWithFormat:@"%d", topicTypeId] forKey:@"typeId"];
    [param setValue:contentStr forKey:@"content"];
    [param setValue:userInfo.regUserId forKey:@"userId"];
    [param setValue:userInfo.defaultUserHouse.cellId forKey:@"cellId"];
    NSString *addTopicSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_addTopicInfo] params:param];

    NSString *addTopicUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_addTopicInfo];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:addTopicUrl]];
    [request setUseCookiePersistence:[[UserModel Instance] isLogin]];
    [request setTimeOutSeconds:30];
    [request setPostValue:Appkey forKey:@"accessId"];
    [request setPostValue:addTopicSign forKey:@"sign"];
    [request setPostValue:[NSString stringWithFormat:@"%d", topicTypeId] forKey:@"typeId"];
    [request setPostValue:contentStr forKey:@"content"];
    [request setPostValue:userInfo.regUserId forKey:@"userId"];
    [request setPostValue:userInfo.defaultUserHouse.cellId forKey:@"cellId"];
    for (int i = 0 ; i < [topicImageArray count] - 1; i++) {
        UIImage *topicImage = [topicImageArray objectAtIndex:i];
        [request addData:UIImageJPEGRepresentation(topicImage, 0.8f) withFileName:@"img.jpg" andContentType:@"image/jpeg" forKey:[NSString stringWithFormat:@"pic%d", i]];
    }
    request.tag = 1;

    request.delegate = self;
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestSubmit:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"提交朋友圈" andView:self.view andHUD:request.hud];
}

- (void)requestSubmit:(ASIHTTPRequest *)request
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
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_RefreshTopic object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)getTopicTypeData
{
    //生成获取报修类型URL
    NSString *typeUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findAllTopicType] params:nil];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:typeUrl]];
    [request setUseCookiePersistence:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestSucceed:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"加载中..." andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
    }
}
- (void)requestSucceed:(ASIHTTPRequest *)request
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
        return;
    }
    else
    {
        topicTypeArray = [Tool readJsonStrToTopicTypeArray:request.responseString];
        TopicType *topicType = [topicTypeArray objectAtIndex:0];
        self.topicTypeNameLb.text = [NSString stringWithFormat:@"【%@】", topicType.typeName];
        topicTypeId = topicType.typeId;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    int textLength = [textView.text length];
    if (textLength == 0) {
        [self.topicContentPlaceholder setHidden:NO];
    }else{
        [self.topicContentPlaceholder setHidden:YES];
    }
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [topicImageArray count];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RepairImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RepairImageCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"RepairImageCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[RepairImageCell class]]) {
                cell = (RepairImageCell *)o;
                break;
            }
        }
    }
    int row = [indexPath row];
    UIImage *repairImage = [topicImageArray objectAtIndex:row];
    cell.repairIv.image = repairImage;
    
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100, 80);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if (row == [topicImageArray count] -1) {
        UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        cameraSheet.tag = 0;
        [cameraSheet showInView:self.view];
    }
    else
    {
        UIActionSheet *delSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"取消"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"删除", nil];
        delSheet.tag = 2;
        selectCaremaIndex = row;
        [delSheet showInView:self.view];
    }
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (actionSheet.tag == 2) {
        if (buttonIndex == 0) {
            [topicImageArray removeObjectAtIndex:selectCaremaIndex];
            [self.collectionView reloadData];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        UIImage *smallImage = [self imageByScalingToMaxSize:portraitImg];
        [topicImageArray insertObject:smallImage atIndex:[topicImageArray count] -1];
        [self.collectionView reloadData];
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

- (IBAction)selectTopicTypeAction:(id)sender {
    if ([topicTypeArray count]> 0) {
        TopicType *topicType = [topicTypeArray objectAtIndex:0];
        self.topicTypeNameLb.text = [NSString stringWithFormat:@"【%@】", topicType.typeName];
        topicTypeId = topicType.typeId;
    }
    else
    {
        [Tool showCustomHUD:@"暂无标签" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (IS_IOS8) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:@"\n\n\n\n\n\n\n\n\n\n\n\n"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIPickerView *typePicker = [[UIPickerView alloc] init];
        typePicker.delegate = self;
        typePicker.showsSelectionIndicator = YES;
        [alert.view addSubview:typePicker];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n"
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"确  定", nil];
        actionSheet.tag = 1;
        [actionSheet showInView:self.view];
        UIPickerView *typePicker = [[UIPickerView alloc] init];
        typePicker.delegate = self;
        typePicker.showsSelectionIndicator = YES;
        [actionSheet addSubview:typePicker];
    }
}

//返回显示的列数
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//返回当前列显示的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [topicTypeArray count];
}

#pragma mark Picker Delegate Methods

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    TopicType *type = (TopicType *)[topicTypeArray objectAtIndex:row];
    return [NSString stringWithFormat:@"【%@】", type.typeName];
}

-(void) pickerView: (UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent: (NSInteger)component
{
    TopicType *type = (TopicType *)[topicTypeArray objectAtIndex:row];
    topicTypeId = type.typeId;
    self.topicTypeNameLb.text = [NSString stringWithFormat:@"【%@】", type.typeName];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTintColor:[Tool getColorForMain]];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

@end
