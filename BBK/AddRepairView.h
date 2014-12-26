//
//  AddRepairView.h
//  BBK
//
//  Created by Seven on 14-12-8.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddRepairView : UIViewController<UITextViewDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *userFaceIv;
@property (weak, nonatomic) IBOutlet UILabel *userInfoLb;
@property (weak, nonatomic) IBOutlet UILabel *userAddressLb;

@property (weak, nonatomic) IBOutlet UILabel *repairContentPlaceholder;
@property (weak, nonatomic) IBOutlet UITextView *repairContentTv;
@property (weak, nonatomic) IBOutlet UILabel *repairTypeNameLb;
@property (weak, nonatomic) IBOutlet UIButton *submitRepairBtn;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)selectRepairTypeAction:(id)sender;
- (IBAction)telServiceAction:(id)sender;
- (IBAction)submitRepairAction:(id)sender;
- (IBAction)pushRepairCostView:(id)sender;

@end
