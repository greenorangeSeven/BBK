//
//  AddRepairView.m
//  BBK
//
//  Created by Seven on 14-12-8.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "AddRepairView.h"
#import "UIImageView+WebCache.h"
#import "RepairType.h"
#import "RepairImageCell.h"
#import "RepairTableView.h"
#import "CommDetailView.h"

#define ORIGINAL_MAX_WIDTH 640.0f

@interface AddRepairView ()
{
    NSString *repairTypeId;
    NSArray *repairTypeArray;
    NSMutableArray *repairImageArray;
    int selectCaremaIndex;
    
    UIWebView *phoneWebView;
}

@end

@implementation AddRepairView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.view.frame.size.height);
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"物业报修";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle: @"报修单" style:UIBarButtonItemStyleBordered target:self action:@selector(pushRepairListAction:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    [self.userFaceIv setImageWithURL:[NSURL URLWithString:userInfo.photoFull] placeholderImage:[UIImage imageNamed:@"default_head.png"]];
    
    self.userInfoLb.text = [NSString stringWithFormat:@"%@(%@)", userInfo.regUserName, userInfo.mobileNo];
    self.userAddressLb.text = [NSString stringWithFormat:@"%@%@%@--%@", userInfo.defaultUserHouse.cellName, userInfo.defaultUserHouse.buildingName, userInfo.defaultUserHouse.numberName, userInfo.defaultUserHouse.userTypeName];
    
    self.repairContentTv.delegate = self;
    
    repairImageArray = [[NSMutableArray alloc] initWithCapacity:4];
    UIImage *myImage = [UIImage imageNamed:@"cameralogo"];
    [repairImageArray addObject:myImage];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[RepairImageCell class] forCellWithReuseIdentifier:RepairImageCellIdentifier];
    
    [self getRepairTypeData];
}

- (void)pushRepairListAction:(id)sender
{
    RepairTableView *repairTableView = [[RepairTableView alloc] init];
    repairTableView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:repairTableView animated:YES];
}

- (void)getRepairTypeData
{
    //生成获取报修类型URL
    NSString *typeUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_FindAllRepairType] params:nil];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:typeUrl]];
    [request setUseCookiePersistence:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestSucceed:)];
    [request startAsynchronous];
    request.tag = 0;
    
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
        if (request.tag == 0) {
            repairTypeArray = [Tool readJsonStrToRepairTypeArray:request.responseString];
            RepairType *repairType = [repairTypeArray objectAtIndex:0];
            self.repairTypeNameLb.text = repairType.typeName;
            repairTypeId = repairType.typeId;
        }
        else
        {
            
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    int textLength = [textView.text length];
    if (textLength == 0) {
        [self.repairContentPlaceholder setHidden:NO];
    }else{
        [self.repairContentPlaceholder setHidden:YES];
    }
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [repairImageArray count];
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
    UIImage *repairImage = [repairImageArray objectAtIndex:row];
    cell.repairIv.image = repairImage;
    
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(75, 65);
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
    if (row == [repairImageArray count] -1) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
            [repairImageArray removeObjectAtIndex:selectCaremaIndex];
            [self.collectionView reloadData];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        UIImage *smallImage = [self imageByScalingToMaxSize:portraitImg];
        [repairImageArray insertObject:smallImage atIndex:[repairImageArray count] -1];
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

- (IBAction)selectRepairTypeAction:(id)sender {
    if ([repairTypeArray count]> 0) {
        RepairType *repairType = [repairTypeArray objectAtIndex:0];
        self.repairTypeNameLb.text = repairType.typeName;
        repairTypeId = repairType.typeId;
    }
    else
    {
        [Tool showCustomHUD:@"暂无报修类型" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
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
    return [repairTypeArray count];
}

#pragma mark Picker Delegate Methods

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    RepairType *type = (RepairType *)[repairTypeArray objectAtIndex:row];
    return type.typeName;
}

-(void) pickerView: (UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent: (NSInteger)component
{
    RepairType *type = (RepairType *)[repairTypeArray objectAtIndex:row];
    repairTypeId = type.typeId;
    self.repairTypeNameLb.text = type.typeName;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 300, 30)];
    myView.textAlignment = UITextAlignmentCenter;
    RepairType *type = (RepairType *)[repairTypeArray objectAtIndex:row];
    myView.text = type.typeName;
    myView.font = [UIFont systemFontOfSize:18];         //用label来设置字体大小
    myView.backgroundColor = [UIColor clearColor];
    return myView;
}

- (IBAction)telServiceAction:(id)sender {
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", userInfo.defaultUserHouse.phone]];
    if (!phoneWebView) {
        phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
}

- (IBAction)submitRepairAction:(id)sender {
    NSString *contentStr = self.repairContentTv.text;
    if (contentStr == nil || [contentStr length] == 0) {
        [Tool showCustomHUD:@"请填写报修描述" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    self.submitRepairBtn.enabled = NO;
    
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    
    //生成新增报修Sign
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:repairTypeId forKey:@"typeId"];
    [param setValue:contentStr forKey:@"repairContent"];
    [param setValue:userInfo.regUserId forKey:@"regUserId"];
    [param setValue:userInfo.defaultUserHouse.numberId forKey:@"numberId"];
    NSString *addRegirSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_AddRepairWork] params:param];
    
    NSString *addRegirUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_AddRepairWork];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:addRegirUrl]];
    [request setUseCookiePersistence:[[UserModel Instance] isLogin]];
    [request setTimeOutSeconds:30];
    [request setPostValue:Appkey forKey:@"accessId"];
    [request setPostValue:addRegirSign forKey:@"sign"];
    [request setPostValue:repairTypeId forKey:@"typeId"];
    [request setPostValue:contentStr forKey:@"repairContent"];
    [request setPostValue:userInfo.regUserId forKey:@"regUserId"];
    [request setPostValue:userInfo.defaultUserHouse.numberId forKey:@"numberId"];
    for (int i = 0 ; i < [repairImageArray count] - 1; i++) {
        UIImage *repairImage = [repairImageArray objectAtIndex:i];
        [request addData:UIImageJPEGRepresentation(repairImage, 0.8f) withFileName:@"img.jpg" andContentType:@"image/jpeg" forKey:[NSString stringWithFormat:@"pic%d", i]];
    }
    request.tag = 1;
    
    request.delegate = self;
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestSubmit:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"提交报修" andView:self.view andHUD:request.hud];
}

- (IBAction)pushRepairCostView:(id)sender {
    NSString *pushDetailHtm = [NSString stringWithFormat:@"%@%@%@", api_base_url, htm_repairItemList ,Appkey];
    CommDetailView *detailView = [[CommDetailView alloc] init];
    detailView.titleStr = @"收费标准";
    detailView.urlStr = pushDetailHtm;
    [self.navigationController pushViewController:detailView animated:YES];
    
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
        self.submitRepairBtn.enabled = YES;
        return;
    }
    else
    {
        RepairTableView *repairTableView = [[RepairTableView alloc] init];
        repairTableView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:repairTableView animated:YES];
        
        [repairImageArray removeAllObjects];
        UIImage *myImage = [UIImage imageNamed:@"cameralogo"];
        [repairImageArray addObject:myImage];
        [self.collectionView reloadData];
        
        self.repairContentTv.text = @"";
        self.repairContentPlaceholder.hidden = NO;
        self.submitRepairBtn.enabled = YES;
    }
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
